import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/screens/auth/login/login_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

const _dialogTopShadow = BoxShadow(
  color: Color(0x40000000),
  offset: Offset(0, -6.2),
  blurRadius: 0,
  spreadRadius: 0,
);

Widget _dialogShell({required Widget child}) {
  return Dialog(
    elevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.transparent,
    clipBehavior: Clip.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [_dialogTopShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    ),
  );
}

void showLogoutDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (ctx) => _dialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppImageView(
            AppAssets.logoutImage,
            height: 100,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.logoutConfirmTitle.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.logoutConfirmBody.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                AppNavigation.offAll(const LoginScreen());
              },
              icon: const AppIcon(AppAssets.logout, color: AppColors.white),
              label: Text(AppStrings.logoutConfirmYes.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.black,
                side: const BorderSide(color: AppColors.destructiveBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                AppStrings.cancel.tr(),
                style: AppTextStyles.style(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void showDeleteAccountDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (ctx) => _dialogShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppImageView(
            AppAssets.deleteAccountImage,
            height: 100,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.deleteConfirmTitle.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.deleteConfirmBody.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                AppNavigation.offAll(const LoginScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.destructive,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                AppStrings.deleteConfirmYes.tr(),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.black,
                side: const BorderSide(color: AppColors.destructiveBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                AppStrings.cancel.tr(),
                style: AppTextStyles.style(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
