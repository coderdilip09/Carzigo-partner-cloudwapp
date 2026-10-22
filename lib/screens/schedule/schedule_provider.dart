import 'package:carzigo_partner/models/job_data_model.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum ScheduleTab { upcoming, inProgress, completed, cancelled }

class ScheduleProvider extends BaseProvider {
  ScheduleProvider({ScheduleTab initialTab = ScheduleTab.upcoming})
    : currentTab = initialTab {
    load();
  }

  ScheduleTab currentTab;
  ScheduleListDataModel? data;
  bool isLoading = true;
  bool isSearchOpen = false;
  String searchQuery = '';

  String get _apiTab {
    switch (currentTab) {
      case ScheduleTab.inProgress:
        return 'in_progress';
      case ScheduleTab.upcoming:
      case ScheduleTab.completed:
      case ScheduleTab.cancelled:
        return currentTab.name;
    }
  }

  List<JobDataModel> get jobs {
    final all = data?.jobs ?? [];
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return all;
    return all.where((job) {
      bool matches(String? value) =>
          (value ?? '').toLowerCase().contains(query);
      return matches(job.customerName) ||
          matches(job.serviceName) ||
          matches(job.vehicleModel) ||
          matches(job.car) ||
          matches(job.plateNumber);
    }).toList();
  }

  String get totalJobs => data?.totalJobsLabel ?? '00';
  String get completed => data?.completedLabel ?? '00';
  String get inProgress => data?.inProgressLabel ?? '00';
  String get cancelled => data?.cancelledLabel ?? '00';

  List<(String date, List<JobDataModel> jobs)> get groupedJobs {
    final map = <String, List<JobDataModel>>{};
    final undated = <JobDataModel>[];
    for (final job in jobs) {
      final date = job.date?.trim() ?? '';
      if (date.isEmpty) {
        undated.add(job);
      } else {
        map.putIfAbsent(date, () => []).add(job);
      }
    }
    return [
      ...map.entries.map((e) => (e.key, e.value)),
      if (undated.isNotEmpty) ('', undated),
    ];
  }

  void toggleSearch() {
    isSearchOpen = !isSearchOpen;
    if (!isSearchOpen) {
      searchQuery = '';
    }
    safeNotifyListeners();
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    safeNotifyListeners();
  }

  void clearSearch() {
    searchQuery = '';
    safeNotifyListeners();
  }

  Future<void> setTab(ScheduleTab tab) async {
    if (currentTab == tab && data != null) return;
    currentTab = tab;
    isLoading = true;
    data = null;
    safeNotifyListeners();
    await load(silent: true);
  }

  Future<Set<DateTime>> loadUpcomingDays() async {
    List<JobDataModel> items = const [];
    if (currentTab == ScheduleTab.upcoming && data != null) {
      items = data!.jobs;
    } else {
      final res = await Api.getJobs(tab: 'upcoming');
      if (res.isSuccess && res.data != null) items = res.data!.jobs;
    }
    final days = <DateTime>{};
    for (final job in items) {
      final iso = job.scheduledDate?.trim() ?? '';
      final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(iso);
      if (match == null) continue;
      days.add(DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      ));
    }
    return days;
  }

  Future<void> reportDayOff(
    DateTime date, {
    required bool emergency,
    String? reason,
  }) async {
    final iso =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final res = await Api.reportUnavailability(
      date: iso,
      kind: emergency ? 'emergency' : 'planned',
      note: reason,
    );
    if (!res.isSuccess) {
      AppToast.error(res.message ?? AppStrings.requestFailed.tr());
      return;
    }
    AppToast.success(AppStrings.dayOffSaved.tr());
    await load();
  }

  Future<void> load({bool silent = false}) async {
    final tab = currentTab;
    if (!silent) {
      isLoading = true;
      safeNotifyListeners();
    }

    try {
      final res = await Api.getJobs(tab: _apiTab);
      if (tab != currentTab) return;
      if (!res.isSuccess || res.data == null) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        data = null;
        return;
      }
      data = res.data;
    } catch (e, st) {
      debugPrint('Get services failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      if (tab == currentTab) {
        isLoading = false;
        safeNotifyListeners();
      }
    }
  }
}
