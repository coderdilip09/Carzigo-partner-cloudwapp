import 'dart:io';

import 'package:carzigo_partner/screens/kyc/kyc_overview/kyc_overview_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_status.dart';
import 'package:carzigo_partner/services/image_pick_service/image_pick_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateProfileProvider extends BaseProvider {
  final formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  File? profileImage;
  String? photoError;
  bool submitted = false;

  void setName(String value) {
    name = value;
  }

  void setEmail(String value) {
    email = value;
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

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired.tr();
    }
    return null;
  }

  String? validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return AppStrings.emailRequired.tr();
    }
    if (!RegExp(r'^[\w.\-+]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(trimmed)) {
      return AppStrings.emailInvalid.tr();
    }
    return null;
  }

  bool _validatePhoto() {
    if (profileImage == null) {
      photoError = AppStrings.photoRequired.tr();
      return false;
    }
    photoError = null;
    return true;
  }

  void tapOnSave() {
    submitted = true;
    final photoOk = _validatePhoto();
    final fieldsOk = formKey.currentState?.validate() ?? false;
    safeNotifyListeners();
    if (!photoOk || !fieldsOk) return;
    KycStatus.markProfilePhotoDone();
    AppToast.success(AppStrings.profileCompleted.tr());
    AppNavigation.to(const KycOverviewScreen());
  }
}
