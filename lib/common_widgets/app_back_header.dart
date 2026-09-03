import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppBackHeader extends StatelessWidget {
  const AppBackHeader({
    super.key,
    this.title,
    this.showBackText = true,
    this.titleInline = false,
    this.onBack,
  });

  final String? title;
  final bool showBackText;
  final bool titleInline;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final backButton = GestureDetector(
      onTap: onBack ?? AppNavigation.back,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: AppIcon(AppAssets.back, size: 20),
            ),
          ),
          if (showBackText) ...[
            const SizedBox(width: 8),
            Text(
              AppStrings.back.tr(),
              style: AppTextStyles.style(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF000000),
              ),
            ),
          ],
        ],
      ),
    );

    if (titleInline) {
      return Row(
        children: [
          backButton,
          if (title != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title!,
                style: AppTextStyles.style(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [backButton]),
        if (title != null) ...[
          const SizedBox(height: 16),
          Text(
            title!,
            style: AppTextStyles.style(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
