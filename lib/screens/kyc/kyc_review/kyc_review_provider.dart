import 'package:carzigo_partner/screens/kyc/application_pending/application_pending_screen.dart';
import 'package:carzigo_partner/screens/kyc/address_proof/address_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_screen.dart';
import 'package:carzigo_partner/screens/kyc/identity_proof/identity_proof_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class KycReviewProvider extends BaseProvider {
  void tapOnSubmit() {
    AppToast.success(AppStrings.applicationSubmitted.tr());
    AppNavigation.to(const ApplicationPendingScreen());
  }

  void tapOnEditIdentity() => AppNavigation.to(const IdentityProofScreen());
  void tapOnEditAddress() => AppNavigation.to(const AddressProofScreen());
  void tapOnEditBank() => AppNavigation.to(const BankDetailsScreen());
}
