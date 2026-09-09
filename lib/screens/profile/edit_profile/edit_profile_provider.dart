import 'dart:io';

import 'package:carzigo_partner/screens/profile/edit_profile/change_number/change_number_screen.dart';
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

class EditProfileProvider extends BaseProvider {
  EditProfileProvider() {
    loadProfile();
  }

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  File? profileImage;
  String? photoUrl;
  bool submitted = false;
  bool isLoading = false;

  Future<void> loadProfile() async {
    try {
      final saved = await PrefsService().getUser();
      if (saved != null) {
        _applyUser(
          name: saved.displayName,
          email: saved.email,
          phone: saved.phone,
          photo: saved.photoUrl,
        );
        safeNotifyListeners();
      }

      final res = await Api.getProfile();
      if (res.isSuccess && res.data != null) {
        await PrefsService().saveUser(res.data!);
        _applyUser(
          name: res.data!.displayName,
          email: res.data!.email,
          phone: res.data!.phone,
          photo: res.data!.photoUrl,
        );
      } else if (saved == null) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
      }
    } catch (e, st) {
      debugPrint('Get profile failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      safeNotifyListeners();
    }
  }

  void _applyUser({
    String? name,
    String? email,
    String? phone,
    String? photo,
  }) {
    if (name != null) nameController.text = name;
    if (email != null) emailController.text = email;
    if (phone != null) phoneController.text = phone;
    photoUrl = photo ?? photoUrl;
  }

  Future<void> pickFromCamera() => _pick(ImageSource.camera);

  Future<void> pickFromGallery() => _pick(ImageSource.gallery);

  Future<void> _pick(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null) return;
    profileImage = file;
    safeNotifyListeners();
  }

  Future<void> tapOnChangeNumber() async {
    final newPhone = await AppNavigation.to<String>(const ChangeNumberScreen());
    if (newPhone == null || newPhone.isEmpty) return;
    phoneController.text = newPhone;
    safeNotifyListeners();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired.tr();
    }
    return null;
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return AppStrings.emailRequired.tr();
    }
    if (!RegExp(r'^[\w.\-+]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
      return AppStrings.emailInvalid.tr();
    }
    return null;
  }

  Future<void> tapOnSave() async {
    if (isLoading) return;

    submitted = true;
    final fieldsOk = formKey.currentState?.validate() ?? false;
    safeNotifyListeners();
    if (!fieldsOk) return;

    isLoading = true;
    safeNotifyListeners();

    try {
      var photo = photoUrl;
      if (profileImage != null) {
        final uploadRes = await Api.uploadImage(file: profileImage!);
        if (!uploadRes.isSuccess || !(uploadRes.data?.hasFullUrl ?? false)) {
          AppToast.error(uploadRes.message ?? AppStrings.uploadFailed.tr());
          return;
        }
        photo = uploadRes.data!.resolvedUrl;
      }

      final profileRes = await Api.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        photo: photo,
      );
      if (!profileRes.isSuccess || profileRes.data == null) {
        AppToast.error(profileRes.message ?? AppStrings.requestFailed.tr());
        return;
      }

      await PrefsService().saveUser(profileRes.data!);
      AppToast.success(profileRes.message ?? AppStrings.profileUpdated.tr());
      AppNavigation.back();
    } catch (e, st) {
      debugPrint('Update profile failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
