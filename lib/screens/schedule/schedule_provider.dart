import 'package:carzigo_partner/models/job_data_model.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum ScheduleTab { upcoming, completed, cancelled }

class ScheduleProvider extends BaseProvider {
  ScheduleProvider({ScheduleTab initialTab = ScheduleTab.upcoming})
    : currentTab = initialTab {
    load();
  }

  ScheduleTab currentTab;
  ScheduleListDataModel? data;
  bool isLoading = false;

  List<JobDataModel> get jobs => data?.jobs ?? [];
  String get totalJobs => data?.totalJobsLabel ?? '00';
  String get completed => data?.completedLabel ?? '00';
  String get inProgress => data?.inProgressLabel ?? '00';

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

  Future<void> setTab(ScheduleTab tab) async {
    if (currentTab == tab && data != null) return;
    currentTab = tab;
    safeNotifyListeners();
    await load();
  }

  Future<void> load() async {
    final tab = currentTab;
    isLoading = true;
    safeNotifyListeners();

    try {
      final res = await Api.getJobs(tab: tab.name);
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
