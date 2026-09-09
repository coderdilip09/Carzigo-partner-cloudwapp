import 'dart:io';

import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppUploadBox extends StatelessWidget {
  const AppUploadBox({
    super.key,
    this.title,
    this.subtitle,
    this.onTap,
    this.imageFile,
    this.imageUrl,
  });

  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final File? imageFile;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 165,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.pendingBadge,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.style(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.15,
                color: const Color(0xFF000000),
              ),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.style(
                fontSize: 11,
                height: 1.15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap ??
                () => AppToast.show(AppStrings.uploadComingSoon.tr()),
            child: SizedBox(
              height: 75,
              width: double.infinity,
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  dashPattern: const [6, 4],
                  strokeWidth: 1.2,
                  color: const Color(0xFFD0D0D0),
                  radius: const Radius.circular(12),
                  padding: EdgeInsets.zero,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _preview() ??
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const AppImageView(
                              AppAssets.imageUpload,
                              width:50,
                              height:50,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppStrings.tapToUpload.tr(),
                              style: AppTextStyles.style(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF000000),
                                decoration: TextDecoration.underline,
                              ).copyWith(
                                decorationColor: const Color(0xFF000000),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _preview() {
    final Widget? image;
    if (imageFile != null) {
      image = Image.file(imageFile!, fit: BoxFit.cover);
    } else {
      final url = imageUrl?.trim() ?? '';
      if (url.startsWith('http://') || url.startsWith('https://')) {
        image = Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        );
      } else {
        image = null;
      }
    }
    if (image == null) return null;
    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        Positioned(
          right: 6,
          bottom: 6,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.edit,
              size: 14,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}
