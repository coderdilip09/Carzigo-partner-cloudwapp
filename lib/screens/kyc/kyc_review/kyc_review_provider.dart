import 'package:carzigo_partner/screens/kyc/application_pending/application_pending_screen.dart';
import 'package:carzigo_partner/screens/kyc/address_proof/address_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_screen.dart';
import 'package:carzigo_partner/screens/kyc/identity_proof/identity_proof_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/base_provider.dart';

class KycReviewProvider extends BaseProvider {
  void tapOnSubmit() {
    AppNavigation.to(const ApplicationPendingScreen());
  }

  void tapOnEditIdentity() => AppNavigation.to(const IdentityProofScreen());
  void tapOnEditAddress() => AppNavigation.to(const AddressProofScreen());
  void tapOnEditBank() => AppNavigation.to(const BankDetailsScreen());
}
