import 'dart:io';

import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_screen.dart';
import 'package:carzigo_partner/services/image_pick_service/image_pick_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:image_picker/image_picker.dart';

class AddressProofProvider extends BaseProvider {
  int selectedDoc = 0;
  File? documentImage;

  final docs = [
    AppStrings.aadhaarCard,
    AppStrings.panCard,
    AppStrings.drivingLicense,
  ];

  void selectDoc(int index) {
    selectedDoc = index;
    safeNotifyListeners();
  }

  Future<void> pickDocument(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null) return;
    documentImage = file;
    safeNotifyListeners();
  }

  void tapOnSubmit() {
    AppNavigation.to(const BankDetailsScreen());
  }
}
