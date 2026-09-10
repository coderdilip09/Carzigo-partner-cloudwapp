import 'package:carzigo_partner/models/kyc_status_model.dart';
import 'package:carzigo_partner/models/user_data_model.dart';
import 'package:carzigo_partner/screens/auth/create_profile/create_profile_screen.dart';
import 'package:carzigo_partner/screens/auth/login/login_screen.dart';
import 'package:carzigo_partner/screens/dashboard/dashboard_screen.dart';
import 'package:carzigo_partner/screens/kyc/application_pending/application_pending_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_overview/kyc_overview_screen.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/prefs_service/prefs_service.dart';
import 'package:flutter/material.dart';

/// Onboarding / session routing.
///
/// 1. No token → Login
/// 2. Profile incomplete → Create Profile
/// 3. Partner [approval] approved → Dashboard
/// 4. KYC submitted / pending_review (or approval pending after submit) → Application Pending
/// 5. Else → KYC Overview
///
/// After OTP: use verify response first (skip /kyc/status when clear).
/// After splash / app kill: refresh via GET /kyc/status.
class AuthRouteService {
  AuthRouteService._();

  static Future<Widget> resolveStart() async {
    final loggedIn = await PrefsService().isLoggedIn;
    if (!loggedIn) return const LoginScreen();
    return resolveLoggedIn(forceStatusCheck: true);
  }

  static Future<Widget> resolveLoggedIn({
    AuthDataModel? auth,
    bool forceStatusCheck = false,
  }) async {
    final stored = await PrefsService().getUser();
    if (!_hasCompletedProfile(auth, stored)) {
      return const CreateProfileScreen();
    }

    // OTP / fresh auth: decide from response fields when possible.
    if (!forceStatusCheck && auth != null) {
      final fromAuth = _routeFromFlags(
        approval: auth.user?.approval,
        kycStatus: auth.user?.kycStatus ?? auth.kyc?.overallStatus,
      );
      if (fromAuth != null) return fromAuth;
    }

    try {
      final res = await Api.getKycAccountStatus();
      if (res.isSuccess && res.data != null) {
        if (res.data!.isApproved) return const DashboardScreen();
        if (res.data!.isSubmittedForReview) {
          return const ApplicationPendingScreen();
        }
        return const KycOverviewScreen();
      }
    } catch (e, st) {
      debugPrint('AuthRouteService KYC status failed: $e\n$st');
    }

    // Status failed: fall back to last known user flags (prefs / auth).
    final fallback = _routeFromFlags(
      approval: auth?.user?.approval ?? stored?.approval,
      kycStatus: auth?.user?.kycStatus ??
          auth?.kyc?.overallStatus ??
          stored?.kycStatus,
    );
    return fallback ?? const KycOverviewScreen();
  }

  /// Returns a screen when flags are clear enough; otherwise null.
  static Widget? _routeFromFlags({
    String? approval,
    String? kycStatus,
  }) {
    final a = approval?.toLowerCase().trim();
    final k = kycStatus?.toLowerCase().trim();

    if (a == KycOverallStatus.approved) {
      return const DashboardScreen();
    }

    if (k == KycOverallStatus.pendingReview ||
        k == KycOverallStatus.submitted) {
      return const ApplicationPendingScreen();
    }

    if (a == KycOverallStatus.pending &&
        (k == KycOverallStatus.approved ||
            k == KycOverallStatus.verified ||
            k == KycOverallStatus.pending)) {
      return const ApplicationPendingScreen();
    }

    if (k == null ||
        k == KycOverallStatus.draft ||
        k == KycOverallStatus.notStarted ||
        k == KycOverallStatus.inProgress ||
        k.isEmpty) {
      return const KycOverviewScreen();
    }

    // Unclear combo (e.g. verified without approval) → caller may hit status API.
    if (k == KycOverallStatus.verified || k == KycOverallStatus.approved) {
      if (a == null || a.isEmpty) return null;
      if (a == KycOverallStatus.pending) {
        return const ApplicationPendingScreen();
      }
    }

    return null;
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
