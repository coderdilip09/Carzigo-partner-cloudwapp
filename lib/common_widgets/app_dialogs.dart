import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/screens/auth/login/login_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_status.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/services/prefs_service/prefs_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
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
    barrierDismissible: false,
    builder: (ctx) {
      var isLoading = false;
      return StatefulBuilder(
        builder: (ctx, setState) {
          return PopScope(
            canPop: !isLoading,
            child: _dialogShell(
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
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = true);
                              try {
                                final res = await Api.logout();
                                if (!res.isSuccess) {
                                  AppToast.error(
                                    res.message ??
                                        AppStrings.requestFailed.tr(),
                                  );
                                  setState(() => isLoading = false);
                                  return;
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                AppToast.success(
                                  res.message ??
                                      AppStrings.logoutConfirmYes.tr(),
                                );
                                KycStatus.resetForNewNumber();
                                await PrefsService().clear();
                                AppNavigation.offAll(const LoginScreen());
                              } catch (e, st) {
                                debugPrint('Logout failed: $e\n$st');
                                AppToast.error(AppStrings.requestFailed.tr());
                                setState(() => isLoading = false);
                              }
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const AppIcon(
                              AppAssets.logout,
                              color: AppColors.white,
                            ),
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
                      onPressed: isLoading ? null : () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.black,
                        side: const BorderSide(
                          color: AppColors.destructiveBorder,
                        ),
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
        },
      );
    },
  );
}

void showDeleteAccountDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      var isLoading = false;
      return StatefulBuilder(
        builder: (ctx, setState) {
          return PopScope(
            canPop: !isLoading,
            child: _dialogShell(
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
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = true);
                              try {
                                final res = await Api.deleteAccount();
                                if (!res.isSuccess) {
                                  AppToast.error(
                                    res.message ??
                                        AppStrings.requestFailed.tr(),
                                  );
                                  setState(() => isLoading = false);
                                  return;
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                                AppToast.success(
                                  res.message ??
                                      AppStrings.deleteConfirmYes.tr(),
                                );
                                KycStatus.resetForNewNumber();
                                await PrefsService().clear();
                                AppNavigation.offAll(const LoginScreen());
                              } catch (e, st) {
                                debugPrint('Delete account failed: $e\n$st');
                                AppToast.error(AppStrings.requestFailed.tr());
                                setState(() => isLoading = false);
                              }
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
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              AppStrings.deleteConfirmYes.tr(),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.black,
                        side: const BorderSide(
                          color: AppColors.destructiveBorder,
                        ),
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
        },
      );
    },
  );
}
