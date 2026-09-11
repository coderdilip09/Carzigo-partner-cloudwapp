import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:carzigo_partner/models/job_data_model.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

class ServiceDetailsProvider extends BaseProvider {
  ServiceDetailsProvider({this.jobId, JobDataModel? initialJob})
    : job = initialJob {
    if (initialJob != null) {
      currentStep = initialJob.step;
    }
    load();
  }

  final String? jobId;
  JobDataModel? job;
  bool isLoading = false;
  bool isAddingToCalendar = false;
  int currentStep = 1;

  String get displayScheduleId =>
      job?.scheduleId?.trim().isNotEmpty == true
      ? job!.scheduleId!.trim()
      : (job?.id ?? '');

  String get displayDate => job?.date?.trim() ?? '';
  String get displayTimeRange => job?.timeRange?.trim() ?? '';
  String get displayCustomerName => job?.customerName?.trim() ?? '';
  String get displayCustomerInitials {
    final initials = job?.customerInitials?.trim();
    if (initials != null && initials.isNotEmpty) return initials;
    final name = displayCustomerName;
    if (name.isEmpty) return '';
    final parts = name.split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    return parts.take(2).map((e) => e[0].toUpperCase()).join();
  }

  String get displayPhone => job?.customerPhone?.trim() ?? '';
  String get displayEmail => job?.customerEmail?.trim() ?? '';
  String get displayAddress => job?.address?.trim() ?? '';
  String get displayNotes => job?.notes?.trim() ?? '';
  String get displayInstructions => job?.customerInstructions?.trim() ?? '';
  String get displayAssignedAt => job?.assignedAt?.trim() ?? '';
  String get displayServiceName => job?.serviceName?.trim() ?? '';

  Future<void> load() async {
    final id = jobId ?? job?.id;
    if (id == null || id.isEmpty) {
      if (job == null) {
        AppToast.error(AppStrings.requestFailed.tr());
      }
      return;
    }

    // Keep showing passed job while refreshing details.
    if (job == null) {
      isLoading = true;
      safeNotifyListeners();
    }

    try {
      final res = await Api.getJobDetails(id);
      if (!res.isSuccess || res.data == null) {
        if (job == null) {
          AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        }
        return;
      }
      job = res.data;
      currentStep = res.data!.step;
    } catch (e, st) {
      debugPrint('Get job details failed: $e\n$st');
      if (job == null) {
        AppToast.error(AppStrings.requestFailed.tr());
      }
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<void> markStep(int step) async {
    if (step != currentStep + 1) return;
    final id = job?.id ?? jobId;
    if (id == null || id.isEmpty) {
      currentStep = step;
      safeNotifyListeners();
      return;
    }

    final status = switch (step) {
      2 => JobWorkflowStatus.onTheWay,
      3 => JobWorkflowStatus.onSite,
      4 => JobWorkflowStatus.inProgress,
      5 => JobWorkflowStatus.completed,
      _ => JobWorkflowStatus.assigned,
    };

    final res = await Api.updateJobStatus(id: id, status: status);
    if (!res.isSuccess) {
      AppToast.error(res.message ?? AppStrings.requestFailed.tr());
      return;
    }
    if (res.data != null) {
      job = res.data;
      currentStep = res.data!.step;
    } else {
      currentStep = step;
    }
    safeNotifyListeners();
  }

  Future<void> tapOnAddToCalendar() async {
    if (isAddingToCalendar) return;
    final range = _resolveEventRange();
    if (range == null) {
      AppToast.error(AppStrings.calendarAddFailed.tr());
      return;
    }

    isAddingToCalendar = true;
    safeNotifyListeners();

    try {
      final title = displayServiceName.isNotEmpty
          ? displayServiceName
          : AppStrings.serviceDetails.tr();
      final description = [
        if (displayCustomerName.isNotEmpty) 'Customer: $displayCustomerName',
        if (displayPhone.isNotEmpty) 'Phone: $displayPhone',
        if (displayNotes.isNotEmpty) 'Notes: $displayNotes',
        if (displayInstructions.isNotEmpty)
          'Instructions: $displayInstructions',
        if (displayScheduleId.isNotEmpty) 'Schedule: $displayScheduleId',
      ].join('\n');

      final event = Event(
        title: title,
        description: description,
        location: displayAddress,
        startDate: range.$1,
        endDate: range.$2,
      );

      final added = await Add2Calendar.addEvent2Cal(event);
      if (added) {
        AppToast.success(AppStrings.calendarAdded.tr());
      } else {
        AppToast.error(AppStrings.calendarAddFailed.tr());
      }
    } catch (e, st) {
      debugPrint('Add to calendar failed: $e\n$st');
      AppToast.error(AppStrings.calendarAddFailed.tr());
    } finally {
      isAddingToCalendar = false;
      safeNotifyListeners();
    }
  }

  /// Parses [date] + [timeRange] into start/end. Returns null if unusable.
  (DateTime, DateTime)? _resolveEventRange() {
    final date = _parseDate(displayDate);
    if (date == null) return null;

    final times = _parseTimeRange(displayTimeRange);
    if (times == null) {
      final start = DateTime(date.year, date.month, date.day, 9, 0);
      return (start, start.add(const Duration(hours: 1)));
    }

    final start = DateTime(
      date.year,
      date.month,
      date.day,
      times.$1.hour,
      times.$1.minute,
    );
    var end = DateTime(
      date.year,
      date.month,
      date.day,
      times.$2.hour,
      times.$2.minute,
    );
    if (!end.isAfter(start)) {
      end = start.add(const Duration(hours: 1));
    }
    return (start, end);
  }

  DateTime? _parseDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;

    // dd/MM/yyyy or dd-MM-yyyy
    final slash = RegExp(r'^(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{2,4})$');
    final m = slash.firstMatch(value);
    if (m != null) {
      final d = int.parse(m.group(1)!);
      final month = int.parse(m.group(2)!);
      var y = int.parse(m.group(3)!);
      if (y < 100) y += 2000;
      return DateTime(y, month, d);
    }

    // e.g. 11 Sep 2024 / Sep 11, 2024
    try {
      return DateFormat('d MMM yyyy').parseLoose(value);
    } catch (_) {}
    try {
      return DateFormat('MMM d, yyyy').parseLoose(value);
    } catch (_) {}
    try {
      return DateFormat('dd MMMM yyyy').parseLoose(value);
    } catch (_) {}

    return null;
  }

  (DateTime, DateTime)? _parseTimeRange(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final parts = value.split(RegExp(r'\s*[-–—to]+\s*', caseSensitive: false));
    if (parts.length < 2) return null;

    final start = _parseTimeOfDay(parts[0]);
    final end = _parseTimeOfDay(parts[1]);
    if (start == null || end == null) return null;
    return (start, end);
  }

  DateTime? _parseTimeOfDay(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    try {
      return DateFormat('h:mm a').parseLoose(value);
    } catch (_) {}
    try {
      return DateFormat('hh:mm a').parseLoose(value);
    } catch (_) {}
    try {
      return DateFormat('H:mm').parseLoose(value);
    } catch (_) {}
    try {
      return DateFormat('HH:mm').parseLoose(value);
    } catch (_) {}

    return null;
  }
}
