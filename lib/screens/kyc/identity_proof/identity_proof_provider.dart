import 'dart:io';

import 'package:carzigo_partner/screens/kyc/address_proof/address_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_status.dart';
import 'package:carzigo_partner/services/image_pick_service/image_pick_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

class IdentityProofProvider extends BaseProvider {
  int selectedDoc = 0;
  File? frontImage;
  File? backImage;

  final docs = [
    AppStrings.aadhaarCard,
    AppStrings.panCard,
    AppStrings.drivingLicense,
  ];

  void selectDoc(int index) {
    selectedDoc = index;
    safeNotifyListeners();
  }

  Future<void> pickFront(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null) return;
    frontImage = file;
    safeNotifyListeners();
  }

  Future<void> pickBack(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null) return;
    backImage = file;
    safeNotifyListeners();
  }

  bool _validate() {
    if (frontImage == null) {
      AppToast.error(AppStrings.frontImageRequired.tr());
      return false;
    }
    if (backImage == null) {
      AppToast.error(AppStrings.backImageRequired.tr());
      return false;
    }
    return true;
  }

  void tapOnSubmit() {
    if (!_validate()) return;
    KycStatus.markIdentityDone();
    AppNavigation.to(const AddressProofScreen());
  }
}
