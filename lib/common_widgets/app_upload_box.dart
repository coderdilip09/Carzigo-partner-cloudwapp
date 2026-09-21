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
    this.formatsHint,
    this.onTap,
    this.imageFile,
    this.imageUrl,
    this.fileName,
    this.isPdf = false,
  });

  final String? title;
  final String? subtitle;
  final String? formatsHint;
  final VoidCallback? onTap;
  final File? imageFile;
  final String? imageUrl;
  final String? fileName;
  final bool isPdf;

  bool get _hasFile =>
      imageFile != null ||
      (imageUrl?.trim().isNotEmpty ?? false) ||
      (fileName?.trim().isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.peachCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: AppTextStyles.style(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTextStyles.style(
                fontSize: 12,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (formatsHint != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: formatsHint!
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .map(
                    (label) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.peachLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label.toUpperCase(),
                        style: AppTextStyles.style(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap ??
                () => AppToast.show(AppStrings.uploadComingSoon.tr()),
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                dashPattern: const [6, 4],
                strokeWidth: 1.4,
                color: _hasFile ? AppColors.primary : const Color(0xFFD0D0D0),
                radius: const Radius.circular(14),
                padding: EdgeInsets.zero,
              ),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 120),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.pendingBadge.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: _hasFile ? _filledPreview() : _emptyState(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const AppImageView(
              AppAssets.imageUpload,
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.tapToUpload.tr(),
            style: AppTextStyles.style(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.uploadPdfOrImageHint.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filledPreview() {
    if (isPdf || _looksLikePdf) {
      final name = (fileName?.trim().isNotEmpty ?? false)
          ? fileName!.trim()
          : (imageFile != null
                ? _fileNameOf(imageFile!.path)
                : AppStrings.pdfDocument.tr());
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.peachLight,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.style(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.tapToChange.tr(),
                    style: AppTextStyles.style(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
          ],
        ),
      );
    }

    final Widget image;
    if (imageFile != null) {
      image = Image.file(imageFile!, fit: BoxFit.cover);
    } else {
      final url = imageUrl?.trim() ?? '';
      image = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _networkFallback(),
      );
    }

    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit, size: 14, color: AppColors.white),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.tapToChange.tr(),
                    style: AppTextStyles.style(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _networkFallback() {
    return Container(
      color: AppColors.peachLight,
      alignment: Alignment.center,
      child: Text(
        AppStrings.document.tr(),
        style: AppTextStyles.style(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  bool get _looksLikePdf {
    final name = (fileName ?? imageFile?.path ?? imageUrl ?? '').toLowerCase();
    return name.endsWith('.pdf') || name.contains('.pdf?');
  }

  static String _fileNameOf(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    return parts.isEmpty ? path : parts.last;
  }
}
