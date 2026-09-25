import 'package:carzigo_partner/models/document_change_request_model.dart';
import 'package:carzigo_partner/models/kyc_status_model.dart';
import 'package:carzigo_partner/screens/kyc/application_pending/application_pending_screen.dart';
import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_screen.dart';
import 'package:carzigo_partner/screens/kyc/identity_proof/identity_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_document_number.dart';
import 'package:carzigo_partner/screens/kyc/local_address/local_address_screen.dart';
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
  DocumentChangeRequestModel? changeRequest;
  bool isLoading = true;
  bool isSubmitting = false;
  bool isRequestingChange = false;
  bool isSubmittingChange = false;

  bool get canSubmit => review?.canSubmit == true;
  bool get hasIdentity => review?.identity?.isDone == true;
  bool get hasAddress => review?.address?.isDone == true;
  bool get hasBank => review?.bank?.isDone == true;
  bool get hasAnyDocument => hasIdentity || hasAddress || hasBank;

  bool get hasOpenChangeRequest => changeRequest?.isOpen == true;
  bool get canRequestChange =>
      !hasOpenChangeRequest &&
      (review?.overallStatus == KycOverallStatus.approved ||
          review?.partnerKycStatus == KycOverallStatus.verified ||
          review?.partnerKycStatus == KycOverallStatus.approved ||
          review?.approval == 'approved' ||
          (hasIdentity && hasAddress && hasBank && review?.canSubmit != true));

  bool get canSubmitDocumentChanges =>
      changeRequest?.canSubmitChanges == true;

  DocumentChangeDraftModel? _draftOf(String section) =>
      sectionStatus(section)?.draft;

  String get identityDocLabel {
    final draftType = _draftOf('identity')?.docType;
    if (draftType != null) return KycDocNumber.cardLabel(draftType);
    return KycDocNumber.cardLabel(review?.identity?.docType);
  }

  String get identityMasked {
    final draftNumber = _draftOf('identity')?.docNumber;
    if (draftNumber != null) return draftNumber;
    final value = review?.identity?.maskedNumber?.trim();
    if (value != null && value.isNotEmpty) return value;
    return AppStrings.noData.tr();
  }

  String? get identityPreviewUrl =>
      review?.identity?.frontUrl ?? review?.identity?.documentUrl;

  List<String> get identityDocumentUrls {
    final draftUrls = _draftOf('identity')?.documentUrls ?? const [];
    if (draftUrls.isNotEmpty) return draftUrls;
    final urls = <String>[];
    void add(String? value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return;
      if (!urls.contains(trimmed)) urls.add(trimmed);
    }

    add(review?.identity?.frontUrl);
    add(review?.identity?.backUrl);
    add(review?.identity?.documentUrl);
    return urls;
  }

  String get addressDocLabel {
    final draft = _draftOf('address');
    if (draft?.docType != null) return KycDocNumber.cardLabel(draft!.docType);
    if ((draft?.addressLine ?? '').isNotEmpty) return draft!.addressLine!;
    return KycDocNumber.cardLabel(review?.address?.docType);
  }

  String get addressMasked {
    final draft = _draftOf('address');
    if ((draft?.docNumber ?? '').isNotEmpty) return draft!.docNumber!;
    if ((draft?.addressLine ?? '').isNotEmpty) return draft!.addressLine!;
    final value = review?.address?.maskedNumber?.trim();
    if (value != null && value.isNotEmpty) return value;
    return AppStrings.noData.tr();
  }

  String? get addressPreviewUrl =>
      review?.address?.documentUrl ?? review?.address?.frontUrl;

  List<String> get addressDocumentUrls {
    final draftUrls = _draftOf('address')?.documentUrls ?? const [];
    if (draftUrls.isNotEmpty) return draftUrls;
    final urls = <String>[];
    void add(String? value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return;
      if (!urls.contains(trimmed)) urls.add(trimmed);
    }

    add(review?.address?.documentUrl);
    add(review?.address?.frontUrl);
    add(review?.address?.backUrl);
    return urls;
  }

  String get bankName {
    final draftName = _draftOf('bank')?.bankName;
    if (draftName != null) return draftName;
    final name = review?.bank?.bankName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final holder = review?.bank?.holderName?.trim();
    if (holder != null && holder.isNotEmpty) return holder;
    return AppStrings.noData.tr();
  }

  String get bankMasked {
    final draftAccount = _draftOf('bank')?.accountNumber;
    if (draftAccount != null) return _maskAccount(draftAccount);
    final raw = (review?.bank?.accountNumberMasked ??
            review?.bank?.accountNumber)
        ?.trim();
    if (raw == null || raw.isEmpty) return AppStrings.noData.tr();
    return _maskAccount(raw);
  }

  String _maskAccount(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) {
      final last4 = digits.substring(digits.length - 4);
      return 'A/C No. xxxx $last4';
    }

    final lower = raw.toLowerCase();
    if (lower.contains('a/c') || lower.contains('account')) return raw;
    return 'A/C No. $raw';
  }

  String? get bankPreviewUrl => review?.bank?.chequeUrl;

  List<String> get bankDocumentUrls {
    final draftUrls = _draftOf('bank')?.documentUrls ?? const [];
    if (draftUrls.isNotEmpty) return draftUrls;
    final url = bankPreviewUrl?.trim() ?? '';
    if (url.isEmpty) return const [];
    return [url];
  }

  DocumentChangeSectionModel? sectionStatus(String section) =>
      changeRequest?.sectionOf(section);

  bool isSectionUploaded(String section) {
    final change = sectionStatus(section);
    if (change == null) return false;
    if (change.isPendingReview) return true;
    return change.canUpdate && (change.draftReady || change.hasDraft);
  }

  String statusLabelFor(String section, bool isDone) {
    final change = sectionStatus(section);
    if (change != null) {
      if (change.isPendingReview) {
        return AppStrings.docChangeUnderReview.tr();
      }
      if (change.canUpdate && (change.draftReady || change.hasDraft)) {
        return AppStrings.docChangeUploaded.tr();
      }
      switch (change.status) {
        case 'requested':
          return AppStrings.docChangeAwaitingApproval.tr();
        case 'unlocked':
          return AppStrings.docChangeUpdateAllowed.tr();
        case 'rejected_docs':
          return AppStrings.docChangeDocsRejected.tr();
        case 'rejected_permission':
          return AppStrings.docChangePermissionRejected.tr();
        case 'approved':
          return AppStrings.verified.tr();
      }
    }
    return isDone ? AppStrings.verified.tr() : AppStrings.pending.tr();
  }

  bool isSectionVerified(String section, bool isDone) {
    final change = sectionStatus(section);
    if (change == null) return isDone;
    if (change.isApproved) return true;
    if (change.isRequested ||
        change.canUpdate ||
        change.isPendingReview ||
        change.isPermissionRejected) {
      return false;
    }
    return isDone;
  }

  bool canUpdateSection(String section) =>
      sectionStatus(section)?.canUpdate == true;

  Future<void> load() async {
    isLoading = true;
    safeNotifyListeners();

    try {
      final reviewRes = await Api.getKycReview();
      if (reviewRes.isSuccess && reviewRes.data != null) {
        review = reviewRes.data;
      } else if (!reviewRes.isSuccess) {
        AppToast.error(reviewRes.message ?? AppStrings.requestFailed.tr());
      }

      final changeRes = await Api.getDocumentChangeCurrent();
      if (changeRes.isSuccess) {
        changeRequest = changeRes.data;
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
      const LocalAddressScreen(
        editOnly: true,
        forDocumentChange: true,
      ),
    );
    await load();
  }

  Future<void> tapOnEditBank() async {
    await AppNavigation.to(
      const BankDetailsScreen(
        loadSaved: true,
        editOnly: true,
        forDocumentChange: true,
      ),
    );
    await load();
  }

  Future<bool> submitChangeRequest({
    required List<String> sections,
    required String reason,
  }) async {
    if (isRequestingChange) return false;
    final trimmed = reason.trim();
    if (sections.isEmpty) {
      AppToast.error(AppStrings.docChangeSelectSection.tr());
      return false;
    }
    if (trimmed.length < 3) {
      AppToast.error(AppStrings.docChangeReasonRequired.tr());
      return false;
    }

    isRequestingChange = true;
    safeNotifyListeners();
    try {
      final res = await Api.createDocumentChangeRequest(
        sections: sections,
        reason: trimmed,
      );
      if (!res.isSuccess || res.data == null) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return false;
      }
      changeRequest = res.data;
      AppToast.success(
        res.message ?? AppStrings.docChangeRequestSubmitted.tr(),
      );
      safeNotifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('Create document change failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
      return false;
    } finally {
      isRequestingChange = false;
      safeNotifyListeners();
    }
  }

  Future<void> tapOnSubmitDocumentChanges() async {
    if (isSubmittingChange || !canSubmitDocumentChanges) return;
    isSubmittingChange = true;
    safeNotifyListeners();
    try {
      final res = await Api.submitDocumentChange();
      if (!res.isSuccess || res.data == null) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }
      changeRequest = res.data;
      AppToast.success(
        res.message ?? AppStrings.docChangeSubmittedForReview.tr(),
      );
    } catch (e, st) {
      debugPrint('Submit document change failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isSubmittingChange = false;
      safeNotifyListeners();
    }
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
