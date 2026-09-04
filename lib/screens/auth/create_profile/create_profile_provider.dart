import 'dart:io';

import 'package:carzigo_partner/screens/kyc/kyc_overview/kyc_overview_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_status.dart';
import 'package:carzigo_partner/services/image_pick_service/image_pick_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

class CreateProfileProvider extends BaseProvider {
  String name = '';
  String email = '';
  File? profileImage;

  String? photoError;
  String? nameError;
  String? emailError;

  void setName(String value) {
    name = value;
    if (nameError != null) nameError = null;
    safeNotifyListeners();
  }

  void setEmail(String value) {
    email = value;
    if (emailError != null) emailError = null;
    safeNotifyListeners();
  }

  Future<void> pickFromCamera() => _pick(ImageSource.camera);

  Future<void> pickFromGallery() => _pick(ImageSource.gallery);

  Future<void> _pick(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null) return;
    profileImage = file;
    if (photoError != null) photoError = null;
    safeNotifyListeners();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[\w.\-+]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value);
  }

  bool _validate() {
    var isValid = true;

    if (profileImage == null) {
      photoError = AppStrings.photoRequired.tr();
      isValid = false;
    } else {
      photoError = null;
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      nameError = AppStrings.nameRequired.tr();
      isValid = false;
    } else {
      nameError = null;
    }

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      emailError = AppStrings.emailRequired.tr();
      isValid = false;
    } else if (!_isValidEmail(trimmedEmail)) {
      emailError = AppStrings.emailInvalid.tr();
      isValid = false;
    } else {
      emailError = null;
    }

    safeNotifyListeners();
    return isValid;
  }

  void tapOnSave() {
    if (!_validate()) return;
    KycStatus.markProfilePhotoDone();
    AppNavigation.to(const KycOverviewScreen());
  }
}
