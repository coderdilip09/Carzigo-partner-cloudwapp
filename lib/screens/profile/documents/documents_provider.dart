import 'package:carzigo_partner/models/kyc_status_model.dart';
import 'package:carzigo_partner/screens/kyc/address_proof/address_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/application_pending/application_pending_screen.dart';
import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_screen.dart';
import 'package:carzigo_partner/screens/kyc/identity_proof/identity_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_document_number.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

class DocumentsProvider extends BaseProvider {
  DocumentsProvider() {
    load();
  }

  KycStatusModel? review;
  bool isLoading = false;
  bool isSubmitting = false;

  bool get canSubmit => review?.canSubmit == true;
  bool get hasIdentity => review?.identity?.isDone == true;
  bool get hasAddress => review?.address?.isDone == true;
  bool get hasBank => review?.bank?.isDone == true;
  bool get hasAnyDocument => hasIdentity || hasAddress || hasBank;

  String get identityDocLabel =>
      KycDocNumber.cardLabel(review?.identity?.docType);

  String get identityMasked {
    final value = review?.identity?.maskedNumber?.trim();
    if (value != null && value.isNotEmpty) return value;
    return AppStrings.noData.tr();
  }

  String? get identityPreviewUrl =>
      review?.identity?.frontUrl ?? review?.identity?.documentUrl;

  String get addressDocLabel =>
      KycDocNumber.cardLabel(review?.address?.docType);

  String get addressMasked {
    final value = review?.address?.maskedNumber?.trim();
    if (value != null && value.isNotEmpty) return value;
    return AppStrings.noData.tr();
  }

  String? get addressPreviewUrl =>
      review?.address?.documentUrl ?? review?.address?.frontUrl;

  String get bankName {
    final name = review?.bank?.bankName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final holder = review?.bank?.holderName?.trim();
    if (holder != null && holder.isNotEmpty) return holder;
    return AppStrings.noData.tr();
  }

  String get bankMasked {
    final value = review?.bank?.accountNumberMasked?.trim();
    if (value != null && value.isNotEmpty) return value;
    return AppStrings.noData.tr();
  }

  String? get bankPreviewUrl => review?.bank?.chequeUrl;

  String statusLabel(bool isDone) =>
      isDone ? AppStrings.verified.tr() : AppStrings.pending.tr();

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
      debugPrint('Get documents failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<void> tapOnEditIdentity() async {
    await AppNavigation.to(
      const IdentityProofScreen(loadSaved: true, editOnly: true),
    );
    await load();
  }

  Future<void> tapOnEditAddress() async {
    await AppNavigation.to(
      const AddressProofScreen(loadSaved: true, editOnly: true),
    );
    await load();
  }

  Future<void> tapOnEditBank() async {
    await AppNavigation.to(
      const BankDetailsScreen(loadSaved: true, editOnly: true),
    );
    await load();
  }

  Future<void> tapOnSubmit() async {
    if (isSubmitting || isLoading || !canSubmit) return;

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
      debugPrint('Submit KYC from documents failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isSubmitting = false;
      safeNotifyListeners();
    }
  }
}
