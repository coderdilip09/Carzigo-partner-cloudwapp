import 'dart:io';

import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickService {
  ImagePickService._();

  static final ImagePicker _picker = ImagePicker();

  /// Pick from camera/gallery, then open native image cropper.
  /// Returns null if user cancels pick or crop.
  static Future<File?> pickAndCrop(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
      );
      if (picked == null) return null;

      try {
        final cropped = await ImageCropper().cropImage(
          sourcePath: picked.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 90,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: AppStrings.cropImage.tr(),
              toolbarColor: AppColors.primary,
              toolbarWidgetColor: AppColors.white,
              activeControlsWidgetColor: AppColors.primary,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ],
            ),
            IOSUiSettings(
              title: AppStrings.cropImage.tr(),
              doneButtonTitle: AppStrings.done.tr(),
              cancelButtonTitle: AppStrings.cancel.tr(),
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ],
            ),
          ],
        );
        if (cropped == null) return null;
        return File(cropped.path);
      } on MissingPluginException catch (e) {
        // Happens after adding the plugin without a full app reinstall.
        debugPrint(
          'image_cropper plugin missing — using uncropped image. '
          'Stop the app and run a full rebuild (not hot restart). $e',
        );
        return File(picked.path);
      }
    } on PlatformException catch (e) {
      debugPrint('Image pick/crop failed: ${e.code} ${e.message}');
      AppToast.error(AppStrings.imagePickFailed.tr());
      return null;
    } catch (e, st) {
      debugPrint('Image pick/crop failed: $e\n$st');
      AppToast.error(AppStrings.imagePickFailed.tr());
      return null;
    }
  }
}
