import 'package:carzigo_partner/models/user_data_model.dart';
import 'package:carzigo_partner/screens/auth/create_profile/create_profile_screen.dart';
import 'package:carzigo_partner/screens/auth/login/login_screen.dart';
import 'package:carzigo_partner/screens/dashboard/dashboard_screen.dart';
import 'package:carzigo_partner/screens/kyc/application_pending/application_pending_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_overview/kyc_overview_screen.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/prefs_service/prefs_service.dart';
import 'package:flutter/material.dart';

class AuthRouteService {
  AuthRouteService._();

  static Future<Widget> resolveStart() async {
    final loggedIn = await PrefsService().isLoggedIn;
    if (!loggedIn) return const LoginScreen();
    return resolveLoggedIn();
  }

  static Future<Widget> resolveLoggedIn({AuthDataModel? auth}) async {
    if (!_hasCompletedProfile(auth, await PrefsService().getUser())) {
      return const CreateProfileScreen();
    }

    try {
      final res = await Api.getKycAccountStatus();
      if (res.isSuccess && res.data != null) {
        if (res.data!.isApproved) return const DashboardScreen();
        if (res.data!.isSubmittedForReview) {
          return const ApplicationPendingScreen();
        }
      }
    } catch (e, st) {
      debugPrint('AuthRouteService KYC status failed: $e\n$st');
    }

    return const KycOverviewScreen();
  }

  static bool _hasCompletedProfile(AuthDataModel? auth, UserDataModel? stored) {
    if (auth != null) {
      if (auth.needsProfile == true) return false;
      if (auth.user?.hasCompletedProfile == true) return true;
      if (auth.needsProfile == false) return true;
    }
    return stored?.hasCompletedProfile == true;
  }
}
