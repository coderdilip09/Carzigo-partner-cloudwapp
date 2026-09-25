import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:carzigo_partner/models/job_data_model.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/app_rating_service/app_rating_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailsProvider extends BaseProvider {
  ServiceDetailsProvider({this.jobId, JobDataModel? initialJob})
    : job = initialJob,
      isLoading = true {
    if (initialJob != null) {
      currentStep = initialJob.step;
    }
    load();
  }

  final String? jobId;
  JobDataModel? job;
  bool isLoading;
  bool isAddingToCalendar = false;
  bool isUpdating = false;
  int currentStep = 1;

  String get displayScheduleId =>
      job?.scheduleId?.trim().isNotEmpty == true
      ? job!.scheduleId!.trim()
      : (job?.id ?? '');

  String get displayDate => job?.date?.trim() ?? '';

  bool get isScheduledToday {
    final scheduled = job?.scheduledDate?.trim();
    if (scheduled != null && scheduled.isNotEmpty) {
      return scheduled == _todayIsoInIst();
    }
    final date = parseJobDate(displayDate) ?? parseJobDate(job?.date ?? '');
    if (date == null) return false;
    final today = _nowInIst();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool get needsOnTheWayNotTodayConfirm => !isScheduledToday;

  static DateTime _nowInIst() {
    return DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
  }

  static String _todayIsoInIst() {
    final now = _nowInIst();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
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
  double? get displayLat => job?.lat;
  double? get displayLng => job?.lng;
  String get displayNotes => job?.notes?.trim() ?? '';
  String get displayInstructions => job?.customerInstructions?.trim() ?? '';
  String get displayAssignedAt => job?.assignedAt?.trim() ?? '';
  String get displayServiceName => job?.serviceName?.trim() ?? '';
  String get displayVehicleModel => job?.vehicleModel?.trim() ?? '';
  String get displayPlateNumber => job?.plateNumber?.trim() ?? '';
  String get displayVehicleImage => job?.vehicleImage?.trim() ?? '';
  String get displayCar {
    final label = job?.car?.trim();
    if (label != null && label.isNotEmpty) return label;
    final parts = [
      if (displayVehicleModel.isNotEmpty) displayVehicleModel,
      if (displayPlateNumber.isNotEmpty) displayPlateNumber,
    ];
    return parts.join(' • ');
  }

  bool get hasCarDetails => displayCar.isNotEmpty;

  String get displayStatus {
    final tag = (job?.displayTag ?? '').toLowerCase().trim();
    if (tag == 'not_complete') return AppStrings.notComplete.tr();
    if (tag == 'rejected') return AppStrings.reject.tr();
    if (tag == 'cancelled') return AppStrings.cancelled.tr();
    if (tag == 'completed') return AppStrings.completed.tr();
    final ui = job?.uiStatus?.trim();
    if (ui != null && ui.isNotEmpty) return ui;
    return AppStrings.upcoming.tr();
  }

  Future<void> load() async {
    final id = jobId ?? job?.id;
    if (id == null || id.isEmpty) {
      isLoading = false;
      if (job == null) {
        AppToast.error(AppStrings.requestFailed.tr());
      }
      safeNotifyListeners();
      return;
    }

    isLoading = true;
    safeNotifyListeners();

    try {
      final res = await Api.getJobDetails(id);
      if (!res.isSuccess || res.data == null) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }
      job = res.data;
      currentStep = res.data!.step;
    } catch (e, st) {
      debugPrint('Get job details failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<void> openPhone() async {
    final phone = displayPhone.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.isEmpty) {
      AppToast.error(AppStrings.noData.tr());
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      final launched = await launchUrl(uri);
      if (!launched) {
        AppToast.error(AppStrings.requestFailed.tr());
      }
    } catch (e, st) {
      debugPrint('Open phone failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    }
  }

  Future<void> openMaps() async {
    final lat = displayLat;
    final lng = displayLng;
    final address = displayAddress;

    Uri uri;
    if (lat != null && lng != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    } else if (address.isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
      );
    } else {
      AppToast.error(AppStrings.noData.tr());
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        AppToast.error(AppStrings.requestFailed.tr());
      }
    } catch (e, st) {
      debugPrint('Open maps failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    }
  }

  Future<void> markStep(int step) async {
    if (isUpdating) return;
    if (step != currentStep + 1) return;
    if (job?.canUpdate == false ||
        (job?.displayTag ?? '').toLowerCase() == 'not_complete') {
      AppToast.error(AppStrings.notComplete.tr());
      return;
    }
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

    isUpdating = true;
    safeNotifyListeners();

    try {
      final res = await Api.updateJobStatus(
        id: id,
        status: JobWorkflowStatus.toApiStatus(status),
      );
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
      if (status == JobWorkflowStatus.completed) {
        AppRatingService.instance.maybePrompt();
      }
    } finally {
      isUpdating = false;
      safeNotifyListeners();
    }
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
        if (displayScheduleId.isNotEmpty) 'Schedule: $displayScheduleId',
        if (displayCustomerName.isNotEmpty) 'Customer: $displayCustomerName',
        if (displayPhone.isNotEmpty) 'Phone: $displayPhone',
        if (displayCar.isNotEmpty) 'Vehicle: $displayCar',
        if (displayNotes.isNotEmpty) 'Notes: $displayNotes',
        if (displayInstructions.isNotEmpty)
          'Instructions: $displayInstructions',
      ].join('\n');

      final event = Event(
        title: title,
        description: description,
        location: displayAddress,
        startDate: range.$1,
        endDate: range.$2,
        allDay: false,
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
    final date = parseJobDate(displayDate) ?? parseJobDate(job?.date ?? '');
    if (date == null) return null;

    final slot = job?.slotMinutes != null && job!.slotMinutes! > 0
        ? job!.slotMinutes!
        : 60;

    final times = _parseTimeRange(displayTimeRange);
    if (times != null) {
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
        end = start.add(Duration(minutes: slot));
      }
      return (start, end);
    }

    final single = _parseTimeOfDay(displayTimeRange);
    if (single != null) {
      final start = DateTime(
        date.year,
        date.month,
        date.day,
        single.hour,
        single.minute,
      );
      return (start, start.add(Duration(minutes: slot)));
    }

    final start = DateTime(date.year, date.month, date.day, 9, 0);
    return (start, start.add(Duration(minutes: slot)));
  }

  DateTime? parseJobDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
    if (iso != null) {
      return DateTime(
        int.parse(iso.group(1)!),
        int.parse(iso.group(2)!),
        int.parse(iso.group(3)!),
      );
    }

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

    // English month names only — avoid current locale (e.g. hi) failing on "24 Sep 2026"
    const locale = 'en';
    try {
      return DateFormat('d MMM yyyy', locale).parseLoose(value);
    } catch (_) {}
    try {
      return DateFormat('dd MMM yyyy', locale).parseLoose(value);
    } catch (_) {}
    try {
      return DateFormat('MMM d, yyyy', locale).parseLoose(value);
    } catch (_) {}
    try {
      return DateFormat('dd MMMM yyyy', locale).parseLoose(value);
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
      return DateFormat('h a').parseLoose(value);
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
