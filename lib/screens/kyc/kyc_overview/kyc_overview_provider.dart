import 'package:carzigo_partner/screens/kyc/address_proof/address_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_screen.dart';
import 'package:carzigo_partner/screens/kyc/identity_proof/identity_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_status.dart';
import 'package:carzigo_partner/screens/profile/edit_profile/edit_profile_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/base_provider.dart';

class KycOverviewProvider extends BaseProvider {
  bool get isIdentityDone => KycStatus.identityDone;
  bool get isAddressDone => KycStatus.addressDone;
  bool get isBankDone => KycStatus.bankDone;
  bool get isProfilePhotoDone => KycStatus.profilePhotoDone;

  Future<void> tapOnStartKyc() async {
    await AppNavigation.to(const IdentityProofScreen());
    safeNotifyListeners();
  }

  Future<void> tapOnIdentity() async {
    await AppNavigation.to(const IdentityProofScreen());
    safeNotifyListeners();
  }

  Future<void> tapOnAddress() async {
    await AppNavigation.to(const AddressProofScreen());
    safeNotifyListeners();
  }

  Future<void> tapOnBank() async {
    await AppNavigation.to(const BankDetailsScreen());
    safeNotifyListeners();
  }

  Future<void> tapOnProfilePhoto() async {
    await AppNavigation.to(const EditProfileScreen());
    safeNotifyListeners();
  }
}
