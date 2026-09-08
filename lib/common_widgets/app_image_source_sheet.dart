import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<void> showImageSourceSheet(
  BuildContext context, {
  required Future<void> Function() onCamera,
  required Future<void> Function() onGallery,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: AppIcon(AppAssets.camera, color: AppColors.primary),
                title: Text(
                  AppStrings.takePhoto.tr(),
                  style: AppTextStyles.style(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await onCamera();
                },
              ),
              ListTile(
                leading: AppIcon(AppAssets.folder, color: AppColors.primary),
                title: Text(
                  AppStrings.chooseFromGallery.tr(),
                  style: AppTextStyles.style(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await onGallery();
                },
              ),
              ListTile(
                title: Text(
                  AppStrings.cancel.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style(color: AppColors.textSecondary),
                ),
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
      );
    },
  );
}
