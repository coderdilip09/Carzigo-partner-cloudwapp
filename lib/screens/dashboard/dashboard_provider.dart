import 'package:carzigo_partner/screens/schedule/schedule_provider.dart';
import 'package:carzigo_partner/utils/base_provider.dart';

class DashboardProvider extends BaseProvider {
  int currentIndex = 0;
  ScheduleTab scheduleTab = ScheduleTab.upcoming;

  void setIndex(int index) {
    currentIndex = index;
    safeNotifyListeners();
  }

  void openSchedule([ScheduleTab tab = ScheduleTab.upcoming]) {
    scheduleTab = tab;
    currentIndex = 1;
    safeNotifyListeners();
  }
}
