import 'dart:io';

import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickService {
  ImagePickService._();

  static final ImagePicker _picker = ImagePicker();

  static const _squareRatio = CropAspectRatio(ratioX: 1, ratioY: 1);

  /// Pick from camera/gallery, then open native image cropper.
  /// Returns null if user cancels pick or crop.
  ///
  /// When [squareOnly] is true (profile photo), aspect is locked to 1:1.
  static Future<File?> pickAndCrop(
    ImageSource source, {
    bool squareOnly = false,
  }) async {
    File? stableCopy;
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
        requestFullMetadata: false,
      );
      if (picked == null) return null;

      final original = File(picked.path);
      if (!await original.exists() || await original.length() == 0) {
        AppToast.error(AppStrings.imagePickFailed.tr());
        return null;
      }

      // iOS: camera VC must finish dismissing before TOCropViewController
      // can present. Opening immediately returns null / blank cropper.
      if (Platform.isIOS) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      // Copy into app temp as .jpg so UIImage can load camera captures reliably.
      stableCopy = await _stableJpegCopy(original);
      if (stableCopy == null) {
        AppToast.error(AppStrings.imagePickFailed.tr());
        return null;
      }

      try {
        final cropped = await ImageCropper().cropImage(
          sourcePath: stableCopy.path,
          aspectRatio: squareOnly ? _squareRatio : null,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 90,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: AppStrings.cropImage.tr(),
              toolbarColor: AppColors.primary,
              toolbarWidgetColor: AppColors.white,
              activeControlsWidgetColor: AppColors.primary,
              cropStyle: squareOnly ? CropStyle.circle : CropStyle.rectangle,
              initAspectRatio: squareOnly
                  ? CropAspectRatioPreset.square
                  : CropAspectRatioPreset.original,
              lockAspectRatio: squareOnly,
              aspectRatioPresets: squareOnly
                  ? const [CropAspectRatioPreset.square]
                  : const [
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
              cropStyle: squareOnly ? CropStyle.circle : CropStyle.rectangle,
              aspectRatioLockEnabled: squareOnly,
              resetAspectRatioEnabled: !squareOnly,
              // Helps iOS present TOCropViewController after camera dismiss.
              embedInNavigationController: true,
              aspectRatioPresets: squareOnly
                  ? const [CropAspectRatioPreset.square]
                  : const [
                      CropAspectRatioPreset.original,
                      CropAspectRatioPreset.square,
                      CropAspectRatioPreset.ratio3x2,
                      CropAspectRatioPreset.ratio4x3,
                      CropAspectRatioPreset.ratio16x9,
                    ],
            ),
          ],
        );
        if (cropped == null) {
          // User cancelled crop (or dismiss) — do not keep the image.
          await _safeDelete(stableCopy);
          return null;
        }
        return File(cropped.path);
      } on MissingPluginException catch (e) {
        // Happens after adding the plugin without a full app reinstall.
        debugPrint(
          'image_cropper plugin missing — using uncropped image. '
          'Stop the app and run a full rebuild (not hot restart). $e',
        );
        return stableCopy;
      }
    } on PlatformException catch (e) {
      debugPrint('Image pick/crop failed: ${e.code} ${e.message}');
      await _safeDelete(stableCopy);
      AppToast.error(AppStrings.imagePickFailed.tr());
      return null;
    } catch (e, st) {
      debugPrint('Image pick/crop failed: $e\n$st');
      await _safeDelete(stableCopy);
      AppToast.error(AppStrings.imagePickFailed.tr());
      return null;
    }
  }

  /// Writes a flushed JPEG copy under the app temp directory.
  static Future<File?> _stableJpegCopy(File original) async {
    try {
      final bytes = await original.readAsBytes();
      if (bytes.isEmpty) return null;
      final dir = await getTemporaryDirectory();
      final dest = File(
        '${dir.path}/carzigo_pick_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await dest.writeAsBytes(bytes, flush: true);
      if (!await dest.exists() || await dest.length() == 0) return null;
      return dest;
    } catch (e, st) {
      debugPrint('stable jpeg copy failed: $e\n$st');
      return null;
    }
  }

  static Future<void> _safeDelete(File? file) async {
    if (file == null) return;
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  /// Pick PDF or image file (png/jpeg/jpg/heif/heic/pdf).
  static Future<File?> pickDocumentFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const [
          'pdf',
          'png',
          'jpg',
          'jpeg',
          'heif',
          'heic',
        ],
        allowMultiple: false,
        withData: false,
      );
      final path = result?.files.single.path;
      if (path == null || path.isEmpty) return null;
      return File(path);
    } on PlatformException catch (e) {
      debugPrint('Document pick failed: ${e.code} ${e.message}');
      AppToast.error(AppStrings.imagePickFailed.tr());
      return null;
    } catch (e, st) {
      debugPrint('Document pick failed: $e\n$st');
      AppToast.error(AppStrings.imagePickFailed.tr());
      return null;
    }
  }
}
