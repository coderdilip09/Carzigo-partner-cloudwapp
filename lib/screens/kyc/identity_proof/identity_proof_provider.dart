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
      if (clientId.isEmpty &&
          (session.url == null || session.url!.isEmpty) &&
          (session.token == null || session.token!.isEmpty)) {
        AppToast.error(AppStrings.digilockerFailed.tr());
        return;
      }

      if (!context.mounted) return;
      final completedClientId = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => DigilockerWebViewScreen(
            clientId: clientId.isNotEmpty ? clientId : 'pending',
            url: session.url,
            token: session.token,
            gateway: session.gateway ?? 'sandbox',
          ),
        ),
      );

      // Back / cancel — do not call complete with start client_id (causes Surepass 404).
      final id = completedClientId?.trim() ?? '';
      if (id.isEmpty || id == 'pending') {
        return;
      }

      final complete = await Api.completeDigilocker(clientId: id);
      if (!complete.isSuccess) {
        AppToast.error(complete.message ?? AppStrings.digilockerFailed.tr());
        return;
      }

      isVerified = true;
      verifiedName = complete.data?.identity?.fullName;
      maskedAadhaar = complete.data?.identity?.maskedNumber;
      localAddressDone = complete.data?.localAddress?.isDone == true;
      KycStatus.markIdentityDone();
      KycStatus.markAddressDone();
      AppToast.success(
        complete.message ?? AppStrings.digilockerVerified.tr(),
      );

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
    if (!isVerified) return;
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
