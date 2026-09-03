import 'package:carzigo_partner/screens/dashboard/dashboard_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/base_provider.dart';

class ApplicationPendingProvider extends BaseProvider {
  void tapOnCheckStatus() {
    AppNavigation.offAll(const DashboardScreen());
  }

  void tapOnLogout() {
    // Handled in screen
  }
}
