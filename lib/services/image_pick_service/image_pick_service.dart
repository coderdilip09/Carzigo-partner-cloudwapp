import 'dart:io';

import 'dart:io';

import 'package:carzigo_partner/common_widgets/app_image_crop_screen.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickService {
  ImagePickService._();

  static final ImagePicker _picker = ImagePicker();

  /// Pick from camera/gallery, then open in-app crop screen.
  /// Returns null if user cancels pick or crop.
  static Future<File?> pickAndCrop(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
      );
      if (picked == null) return null;

      final bytes = await File(picked.path).readAsBytes();
      final cropped = await AppImageCropScreen.open(bytes);
      return cropped;
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
