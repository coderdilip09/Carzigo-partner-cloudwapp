import 'package:carzigo_partner/utils/base_provider.dart';

enum ScheduleTab { upcoming, completed, cancelled }

class ScheduleProvider extends BaseProvider {
  ScheduleProvider({ScheduleTab initialTab = ScheduleTab.upcoming})
      : currentTab = initialTab;

  ScheduleTab currentTab;

  void setTab(ScheduleTab tab) {
    currentTab = tab;
    safeNotifyListeners();
  }
}
