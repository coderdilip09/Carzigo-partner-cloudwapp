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
/// 4. KYC `pending_review` / `submitted` (real submit) → Application Pending
/// 5. Else → KYC Overview
///
/// Always prefer GET /kyc/status after profile is complete. OTP verify only
/// returns [partners.kyc_status], which is `'pending'` for new partners and
/// does not mean KYC was submitted.
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

    // Partner auth flags are ambiguous (`kyc_status: pending` on create).
    // Always refresh via /kyc/status unless caller already forced it —
    // still call the API for OTP so draft users are not sent to Pending.
    final shouldHitStatus = forceStatusCheck || auth != null;
    if (shouldHitStatus) {
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
    }

    // Status failed: fall back to last known flags (prefs / auth).
    // Never treat bare `pending` as submitted — that is the default for new partners.
    final fallback = _routeFromFlags(
      approval: auth?.user?.approval ?? stored?.approval,
      kycStatus: auth?.kyc?.overallStatus ??
          auth?.user?.kycStatus ??
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

    // Only real KYC submit states → Application Pending.
    if (k == KycOverallStatus.pendingReview ||
        k == KycOverallStatus.submitted) {
      return const ApplicationPendingScreen();
    }

    if (k == KycOverallStatus.rejected) {
      return const KycOverviewScreen();
    }

    // Incomplete / default partner flags → stay on KYC Overview.
    // Note: partners.kyc_status is often `'pending'` before any submit.
    if (k == null ||
        k.isEmpty ||
        k == KycOverallStatus.draft ||
        k == KycOverallStatus.notStarted ||
        k == KycOverallStatus.inProgress ||
        k == KycOverallStatus.pending) {
      return const KycOverviewScreen();
    }

    // KYC verified/approved but partner approval still pending → under review.
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
