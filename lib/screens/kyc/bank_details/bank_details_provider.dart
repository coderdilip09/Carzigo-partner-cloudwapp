import 'dart:io';

import 'package:carzigo_partner/screens/kyc/kyc_review/kyc_review_screen.dart';
import 'package:carzigo_partner/services/image_pick_service/image_pick_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:image_picker/image_picker.dart';

class BankDetailsProvider extends BaseProvider {
  File? chequeImage;

  Future<void> pickCheque(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null) return;
    chequeImage = file;
    safeNotifyListeners();
  }

  void tapOnSubmit() {
    AppNavigation.to(const KycReviewScreen());
  }
}
