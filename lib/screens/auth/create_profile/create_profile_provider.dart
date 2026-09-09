import 'dart:io';

import 'package:carzigo_partner/screens/kyc/kyc_overview/kyc_overview_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_status.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/image_pick_service/image_pick_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/services/prefs_service/prefs_service.dart';
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
  bool isLoading = false;

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

  Future<void> tapOnSave() async {
    if (isLoading) return;

    submitted = true;
    final photoOk = _validatePhoto();
    final fieldsOk = formKey.currentState?.validate() ?? false;
    safeNotifyListeners();
    if (!photoOk || !fieldsOk) return;

    isLoading = true;
    safeNotifyListeners();

    try {
      final uploadRes = await Api.uploadImage(file: profileImage!);
      if (!uploadRes.isSuccess || !(uploadRes.data?.hasFullUrl ?? false)) {
        AppToast.error(uploadRes.message ?? AppStrings.uploadFailed.tr());
        return;
      }

      final profileRes = await Api.updateProfile(
        name: name.trim(),
        email: email.trim(),
        photo: uploadRes.data!.resolvedUrl,
      );
      if (!profileRes.isSuccess || profileRes.data == null) {
        AppToast.error(profileRes.message ?? AppStrings.requestFailed.tr());
        return;
      }

      await PrefsService().saveUser(profileRes.data!);
      KycStatus.markProfilePhotoDone();
      AppToast.success(profileRes.message ?? AppStrings.profileCompleted.tr());
      AppNavigation.to(const KycOverviewScreen());
    } catch (e, st) {
      debugPrint('Create profile failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }
}
