import 'dart:io';
import 'dart:typed_data';

import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppImageCropScreen extends StatefulWidget {
  const AppImageCropScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  static Future<File?> open(Uint8List imageBytes) {
    return AppNavigation.to<File>(AppImageCropScreen(imageBytes: imageBytes));
  }

  @override
  State<AppImageCropScreen> createState() => _AppImageCropScreenState();
}

class _AppImageCropScreenState extends State<AppImageCropScreen> {
  final _controller = CropController();
  bool _isCropping = false;

  Future<void> _onCropped(CropResult result) async {
    if (result is CropFailure) {
      if (mounted) {
        setState(() => _isCropping = false);
        AppToast.error(AppStrings.imagePickFailed.tr());
      }
      return;
    }

    final success = result as CropSuccess;
    try {
      final file = File(
        '${Directory.systemTemp.path}/crop_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(success.croppedImage, flush: true);
      if (!mounted) return;
      AppNavigation.back(file);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCropping = false);
      AppToast.error(AppStrings.imagePickFailed.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text(
          AppStrings.cropImage.tr(),
          style: AppTextStyles.style(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isCropping
                ? null
                : () {
                    setState(() => _isCropping = true);
                    _controller.crop();
                  },
            child: Text(
              AppStrings.done.tr(),
              style: AppTextStyles.style(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Crop(
            image: widget.imageBytes,
            controller: _controller,
            onCropped: _onCropped,
            baseColor: AppColors.black,
            maskColor: Colors.black.withValues(alpha: 0.55),
            cornerDotBuilder: (size, _) => Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (_isCropping)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
