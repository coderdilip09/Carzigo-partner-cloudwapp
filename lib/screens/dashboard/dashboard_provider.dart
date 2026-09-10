import 'package:carzigo_partner/models/dashboard_data_model.dart';
import 'package:carzigo_partner/models/user_data_model.dart';
import 'package:carzigo_partner/screens/schedule/schedule_provider.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/prefs_service/prefs_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

enum PerformancePeriod { month, week }

class DashboardProvider extends BaseProvider {
  DashboardProvider() {
    loadProfile();
    loadDashboard();
  }

  UserDataModel? user;
  DashboardDataModel? dashboard;
  bool isLoading = false;
  int currentIndex = 0;
  ScheduleTab scheduleTab = ScheduleTab.upcoming;
  PerformancePeriod performancePeriod = PerformancePeriod.month;

  String get helloName {
    final fromDashboard = dashboard?.displayName?.trim();
    if (fromDashboard != null && fromDashboard.isNotEmpty) {
      return fromDashboard;
    }
    return user?.displayName ?? '';
  }

  String? get serviceArea {
    final area = dashboard?.serviceArea?.trim();
    if (area != null && area.isNotEmpty) return area;
    return null;
  }

  String get performancePeriodLabel => performancePeriod == PerformancePeriod.week
      ? AppStrings.thisWeek
      : AppStrings.thisMonth;

  int get performanceCompleted => performancePeriod == PerformancePeriod.week
      ? (dashboard?.weekCompleted ?? 0)
      : (dashboard?.monthCompleted ?? 0);

  double? get performanceAvgRating =>
      performancePeriod == PerformancePeriod.week
      ? dashboard?.weekAvgRating
      : dashboard?.monthAvgRating;

  void setPerformancePeriod(PerformancePeriod period) {
    if (performancePeriod == period) return;
    performancePeriod = period;
    safeNotifyListeners();
  }

  Future<void> loadProfile() async {
    try {
      final saved = await PrefsService().getUser();
      if (saved != null) {
        user = saved;
        safeNotifyListeners();
      }

      final res = await Api.getProfile();
      if (res.isSuccess && res.data != null) {
        await PrefsService().saveUser(res.data!);
        user = res.data;
        safeNotifyListeners();
      }
    } catch (e, st) {
      debugPrint('Dashboard get profile failed: $e\n$st');
    }
  }

  Future<void> loadDashboard({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      safeNotifyListeners();
    }

    try {
      final res = await Api.getDashboard();
      if (res.isSuccess && res.data != null) {
        dashboard = res.data;
      } else {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
      }
    } catch (e, st) {
      debugPrint('Dashboard fetch failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<void> _refreshUserFromPrefs() async {
    final saved = await PrefsService().getUser();
    if (saved == null) return;
    user = saved;
    safeNotifyListeners();
  }

  void setIndex(int index) {
    currentIndex = index;
    safeNotifyListeners();
    if (index == 0) {
      _refreshUserFromPrefs();
      loadDashboard(silent: true);
    }
  }

  void openSchedule([ScheduleTab tab = ScheduleTab.upcoming]) {
    scheduleTab = tab;
    currentIndex = 1;
    safeNotifyListeners();
  }
}
