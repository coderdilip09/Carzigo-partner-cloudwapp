import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';

class AppSolidButton extends StatelessWidget {
  const AppSolidButton({
    super.key,
    required this.label,
    this.onTap,
    this.leading,
    this.trailing,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.style(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
      ),
    );
  }
}
