import 'package:carzigo_partner/screens/kyc/digilocker/digilocker_webview_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_status.dart';
import 'package:carzigo_partner/screens/kyc/local_address/local_address_screen.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Digilocker-based Identity + Address Proof.
class IdentityProofProvider extends BaseProvider {
  IdentityProofProvider({
    this.loadSaved = false,
    this.editOnly = false,
  }) {
    if (loadSaved) loadSavedData();
  }

  final bool loadSaved;
  final bool editOnly;

  bool isLoading = false;
  bool isFetching = false;
  bool isVerified = false;
  String? verifiedName;
  String? maskedAadhaar;
  bool localAddressDone = false;

  Future<void> loadSavedData() async {
    if (!loadSaved) return;
    isFetching = true;
    safeNotifyListeners();

    try {
      final res = await Api.getKycReview();
      if (!res.isSuccess) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }
      final identity = res.data?.identity;
      localAddressDone = res.data?.localAddress?.isDone == true;
      isVerified = identity?.isDone == true;
      verifiedName = identity?.fullName;
      maskedAadhaar = identity?.maskedNumber;
    } catch (e, st) {
      debugPrint('Load Digilocker KYC failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isFetching = false;
      safeNotifyListeners();
    }
  }

  Future<void> tapOnVerifyDigilocker(BuildContext context) async {
    if (isLoading || isFetching) return;
    isLoading = true;
    safeNotifyListeners();

    try {
      final start = await Api.startDigilocker();
      if (!start.isSuccess || start.data == null) {
        AppToast.error(start.message ?? AppStrings.digilockerFailed.tr());
        return;
      }

      final session = start.data!;
      final clientId = session.clientId?.trim() ?? '';
      final url = session.url?.trim() ?? '';
      final token = session.token?.trim() ?? '';
      final hasLink = url.isNotEmpty || token.isNotEmpty;

      if (clientId.isEmpty && !hasLink) {
        AppToast.error(AppStrings.digilockerSessionIncomplete.tr());
        return;
      }

      // Mock Digilocker: never open empty WebView — complete immediately.
      final isMockSession =
          session.isMock || clientId.startsWith('mock_digilocker_');
      String id;

      if (isMockSession) {
        if (clientId.isEmpty) {
          AppToast.error(AppStrings.digilockerSessionIncomplete.tr());
          return;
        }
        debugPrint(
          'Digilocker mock path — skipping WebView, client_id=$clientId',
        );
        id = clientId;
      } else if (!hasLink) {
        AppToast.error(AppStrings.digilockerSessionIncomplete.tr());
        return;
      } else {
        if (!context.mounted) {
          AppToast.error(AppStrings.digilockerFailed.tr());
          return;
        }
        final completedClientId = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (_) => DigilockerWebViewScreen(
              clientId: clientId.isNotEmpty ? clientId : 'pending',
              url: url.isNotEmpty ? url : null,
              token: token.isNotEmpty ? token : null,
              gateway: session.gateway ?? 'sandbox',
            ),
          ),
        );

        id = completedClientId?.trim() ?? '';
        if (id.isEmpty || id == 'pending') {
          AppToast.error(AppStrings.digilockerCancelled.tr());
          return;
        }
      }

      final complete = await Api.completeDigilocker(clientId: id);
      if (!complete.isSuccess) {
        AppToast.error(complete.message ?? AppStrings.digilockerFailed.tr());
        return;
      }

      final identity = complete.data?.identity;
      isVerified = true;
      final name = identity?.fullName?.trim();
      final masked = identity?.maskedNumber?.trim();
      if (name != null && name.isNotEmpty) verifiedName = name;
      if (masked != null && masked.isNotEmpty) maskedAadhaar = masked;
      localAddressDone = complete.data?.localAddress?.isDone == true;
      KycStatus.markIdentityDone();
      KycStatus.markAddressDone();
      AppToast.success(
        complete.message ?? AppStrings.digilockerVerified.tr(),
      );
      safeNotifyListeners();

      if (editOnly) {
        AppNavigation.back();
        return;
      }
      _goNext();
    } catch (e, st) {
      debugPrint('Digilocker flow failed: $e\n$st');
      AppToast.error(AppStrings.digilockerFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  void tapOnContinue() {
    if (!isVerified) {
      AppToast.error(AppStrings.completeIdentityFirst.tr());
      return;
    }
    if (editOnly) {
      AppNavigation.back();
      return;
    }
    _goNext();
  }

  void _goNext() {
    AppNavigation.to(
      LocalAddressScreen(editOnly: false),
    );
  }
}
