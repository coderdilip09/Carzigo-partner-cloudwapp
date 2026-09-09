import 'package:carzigo_partner/models/kyc_status_model.dart';
import 'package:carzigo_partner/screens/kyc/application_pending/application_pending_screen.dart';
import 'package:carzigo_partner/screens/kyc/address_proof/address_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_screen.dart';
import 'package:carzigo_partner/screens/kyc/identity_proof/identity_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_document_number.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class KycReviewProvider extends BaseProvider {
  KycStatusModel? review;
  bool isLoading = false;
  bool isSubmitting = false;

  bool get canSubmit => review?.canSubmit == true;

  String get identityDocLabel =>
      KycDocNumber.cardLabel(review?.identity?.docType);

  String get identityMasked =>
      review?.identity?.maskedNumber?.trim().isNotEmpty == true
      ? review!.identity!.maskedNumber!
      : '-';

  String get addressDocLabel =>
      KycDocNumber.cardLabel(review?.address?.docType);

  String get addressMasked =>
      review?.address?.maskedNumber?.trim().isNotEmpty == true
      ? review!.address!.maskedNumber!
      : '-';

  String get bankName =>
      review?.bank?.bankName?.trim().isNotEmpty == true
      ? review!.bank!.bankName!
      : (review?.bank?.holderName ?? '-');

  String get bankMasked =>
      review?.bank?.accountNumberMasked?.trim().isNotEmpty == true
      ? review!.bank!.accountNumberMasked!
      : '-';

  Future<void> load() async {
    isLoading = true;
    safeNotifyListeners();

    try {
      final res = await Api.getKycReview();
      if (res.isSuccess && res.data != null) {
        review = res.data;
      } else {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
      }
    } catch (e, st) {
      debugPrint('Get KYC review failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<void> tapOnSubmit() async {
    if (isSubmitting || isLoading) return;
    if (!canSubmit) {
      AppToast.error(AppStrings.requestFailed.tr());
      return;
    }

    isSubmitting = true;
    safeNotifyListeners();

    try {
      final res = await Api.submitKyc();
      if (!res.isSuccess) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }
      AppToast.success(
        res.data?.message ??
            res.message ??
            AppStrings.applicationSubmitted.tr(),
      );
      AppNavigation.offAll(const ApplicationPendingScreen());
    } catch (e, st) {
      debugPrint('Submit KYC failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isSubmitting = false;
      safeNotifyListeners();
    }
  }

  Future<void> tapOnEditIdentity() async {
    await AppNavigation.to(const IdentityProofScreen(loadSaved: true));
    await load();
  }

  Future<void> tapOnEditAddress() async {
    await AppNavigation.to(const AddressProofScreen(loadSaved: true));
    await load();
  }

  Future<void> tapOnEditBank() async {
    await AppNavigation.to(const BankDetailsScreen(loadSaved: true));
    await load();
  }
}
