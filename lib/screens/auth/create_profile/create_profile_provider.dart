import 'dart:io';

import 'package:carzigo_partner/screens/kyc/kyc_overview/kyc_overview_screen.dart';
import 'package:carzigo_partner/services/image_pick_service/image_pick_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:image_picker/image_picker.dart';

class CreateProfileProvider extends BaseProvider {
  String name = '';
  String email = '';
  File? profileImage;

  Future<void> pickFromCamera() => _pick(ImageSource.camera);

  Future<void> pickFromGallery() => _pick(ImageSource.gallery);

  Future<void> _pick(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null) return;
    profileImage = file;
    safeNotifyListeners();
  }

  void tapOnSave() {
    AppNavigation.to(const KycOverviewScreen());
  }
}
