import 'package:carzigo_partner/screens/kyc/address_proof/address_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_screen.dart';
import 'package:carzigo_partner/screens/kyc/identity_proof/identity_proof_screen.dart';
import 'package:carzigo_partner/screens/profile/edit_profile/edit_profile_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/base_provider.dart';

class KycOverviewProvider extends BaseProvider {
  void tapOnStartKyc() {
    AppNavigation.to(const IdentityProofScreen());
  }

  void tapOnIdentity() {
    AppNavigation.to(const IdentityProofScreen());
  }

  void tapOnAddress() {
    AppNavigation.to(const AddressProofScreen());
  }

  void tapOnBank() {
    AppNavigation.to(const BankDetailsScreen());
  }

  void tapOnProfilePhoto() {
    AppNavigation.to(const EditProfileScreen());
  }
}
