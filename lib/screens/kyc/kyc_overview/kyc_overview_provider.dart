import 'package:carzigo_partner/models/kyc_status_model.dart';
import 'package:carzigo_partner/screens/kyc/address_proof/address_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_screen.dart';
import 'package:carzigo_partner/screens/kyc/identity_proof/identity_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_review/kyc_review_screen.dart';
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
  bool get isAddressDone => overview?.isAddressDone ?? false;
  bool get isBankDone => overview?.isBankDone ?? false;
  bool get isProfilePhotoDone => overview?.isProfilePhotoDone ?? false;
  bool get canSubmit => overview?.canSubmit == true;
  String? get bannerMessage => overview?.message;

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
    await AppNavigation.to(IdentityProofScreen(loadSaved: isIdentityDone));
    await load();
  }

  Future<void> tapOnAddress() async {
    await AppNavigation.to(AddressProofScreen(loadSaved: isAddressDone));
    await load();
  }

  Future<void> tapOnBank() async {
    await AppNavigation.to(BankDetailsScreen(loadSaved: isBankDone));
    await load();
  }

  Future<void> tapOnProfilePhoto() async {
    await AppNavigation.to(const EditProfileScreen());
    await load();
  }

  Future<void> _openFirstPendingStep() async {
    if (!isIdentityDone) {
      await AppNavigation.to(const IdentityProofScreen());
      return;
    }
    if (!isAddressDone) {
      await AppNavigation.to(const AddressProofScreen());
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
