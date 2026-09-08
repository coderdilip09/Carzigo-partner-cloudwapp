import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.iconAsset,
    required this.value,
    required this.label,
    this.backgroundColor,
  });

  final String iconAsset;
  final String value;
  final String label;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.peachCard),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.peach,
                shape: BoxShape.circle,
              ),
              child: AppIcon(iconAsset, color: AppColors.primary, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.style(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
