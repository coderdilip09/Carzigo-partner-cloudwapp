import 'package:carzigo_partner/models/kyc_status_model.dart';
import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_screen.dart';
import 'package:carzigo_partner/screens/kyc/identity_proof/identity_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_review/kyc_review_screen.dart';
import 'package:carzigo_partner/screens/kyc/local_address/local_address_screen.dart';
import 'package:carzigo_partner/screens/profile/edit_profile/edit_profile_screen.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class KycOverviewProvider extends BaseProvider {
  KycStatusModel? overview;
  bool isLoading = false;

  bool get isIdentityDone => overview?.isIdentityDone ?? false;
  bool get isAddressProofDone => overview?.isAddressProofDone ?? false;
  bool get isBankDone => overview?.isBankDone ?? false;
  bool get isProfilePhotoDone => overview?.isProfilePhotoDone ?? false;
  bool get canSubmit => overview?.canSubmit == true;
  String? get bannerMessage => overview?.message;
  bool get isRejected => overview?.isRejected == true;
  bool get isAddressRejected => overview?.isAddressRejected == true;
  bool get isBankRejected => overview?.isBankRejected == true;
  String? get addressRejectReason => overview?.rejectedAddressReason;
  String? get bankRejectReason => overview?.rejectedBankReason;

  /// When sections were rejected, only those need rework.
  bool get hasPartialRejection =>
      isRejected && (isAddressRejected || isBankRejected);

  Future<void> load() async {
    isLoading = true;
    safeNotifyListeners();

    final res = await Api.getKycStatus();

    isLoading = false;
    if (res.isSuccess && res.data != null) {
      overview = res.data;
    } else {
      AppToast.error(res.message ?? AppStrings.kycPending.tr());
    }
    safeNotifyListeners();
  }

  Future<void> tapOnStartKyc() async {
    if (canSubmit) {
      await AppNavigation.to(const KycReviewScreen());
      await load();
      return;
    }
    await _openFirstPendingStep();
    await load();
  }

  Future<void> tapOnIdentity() async {
    if (hasPartialRejection && isIdentityDone) {
      AppToast.error(AppStrings.kycSectionLocked.tr());
      return;
    }
    await AppNavigation.to(
      IdentityProofScreen(
        loadSaved: isIdentityDone,
        editOnly: isIdentityDone,
      ),
    );
    await load();
  }

  Future<void> tapOnAddressProof() async {
    if (!isIdentityDone) {
      AppToast.error(AppStrings.completeIdentityFirst.tr());
      return;
    }
    if (hasPartialRejection && !isAddressRejected && isAddressProofDone) {
      AppToast.error(AppStrings.kycSectionLocked.tr());
      return;
    }
    await AppNavigation.to(
      LocalAddressScreen(
        editOnly: isAddressProofDone || isAddressRejected,
      ),
    );
    await load();
  }

  Future<void> tapOnBank() async {
    if (hasPartialRejection && !isBankRejected && isBankDone) {
      AppToast.error(AppStrings.kycSectionLocked.tr());
      return;
    }
    await AppNavigation.to(
      BankDetailsScreen(loadSaved: isBankDone || isBankRejected),
    );
    await load();
  }

  Future<void> tapOnProfilePhoto() async {
    if (hasPartialRejection && isProfilePhotoDone) {
      AppToast.error(AppStrings.kycSectionLocked.tr());
      return;
    }
    if (!isIdentityDone) {
      AppToast.error(AppStrings.completeIdentityFirst.tr());
      return;
    }
    if (!isAddressProofDone) {
      AppToast.error(AppStrings.completeAddressFirst.tr());
      return;
    }
    if (!isBankDone) {
      AppToast.error(AppStrings.completeBankFirst.tr());
      return;
    }
    await AppNavigation.to(const EditProfileScreen());
    await load();
  }

  Future<void> _openFirstPendingStep() async {
    if (hasPartialRejection) {
      if (isAddressRejected) {
        await AppNavigation.to(const LocalAddressScreen(editOnly: true));
        return;
      }
      if (isBankRejected) {
        await AppNavigation.to(const BankDetailsScreen(loadSaved: true));
        return;
      }
    }
    if (!isIdentityDone) {
      await AppNavigation.to(const IdentityProofScreen());
      return;
    }
    if (!isAddressProofDone) {
      await AppNavigation.to(const LocalAddressScreen());
      return;
    }
    if (!isBankDone) {
      await AppNavigation.to(const BankDetailsScreen());
      return;
    }
    if (!isProfilePhotoDone) {
      await AppNavigation.to(const EditProfileScreen());
    }
  }
}
