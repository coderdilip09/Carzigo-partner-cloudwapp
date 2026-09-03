import 'package:carzigo_partner/common_widgets/app_dialogs.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/screens/profile/documents/documents_screen.dart';
import 'package:carzigo_partner/screens/profile/edit_profile/edit_profile_screen.dart';
import 'package:carzigo_partner/screens/profile/help_support/help_support_screen.dart';
import 'package:carzigo_partner/screens/profile/privacy/privacy_screen.dart';
import 'package:carzigo_partner/screens/profile/terms/terms_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:carzigo_partner/utils/mock_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileProvider extends BaseProvider {
  void tapOnMyProfile() => AppNavigation.to(const EditProfileScreen());
  void tapOnDocuments() => AppNavigation.to(const DocumentsScreen());
  void tapOnHelp() => AppNavigation.to(const HelpSupportScreen());
  void tapOnTerms() => AppNavigation.to(const TermsScreen());
  void tapOnPrivacy() => AppNavigation.to(const PrivacyScreen());
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, showBottomNav ? 80 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.profile.tr(),
                    style: AppTextStyles.style(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    AppStrings.manageAccount.tr(),
                    style: AppTextStyles.style(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.peach, AppColors.peachCard],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: AppImageView(
                                  AppAssets.dummyProfile,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: AppIcon(
                                  AppAssets.camera,
                                  size: 12,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                MockData.userFullName,
                                style: AppTextStyles.style(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                MockData.userEmail,
                                style: AppTextStyles.style(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                MockData.userPhone,
                                style: AppTextStyles.style(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: provider.tapOnMyProfile,
                          icon: AppIcon(
                            AppAssets.edit,
                            size: 14,
                            color: AppColors.white,
                          ),
                          label: Text(AppStrings.edit.tr()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MenuTile(
                    iconAsset: AppAssets.person,
                    title: AppStrings.myProfile.tr(),
                    subtitle: AppStrings.myProfileSubtitle.tr(),
                    onTap: provider.tapOnMyProfile,
                  ),
                  _MenuTile(
                    iconAsset: AppAssets.location,
                    title: AppStrings.savedAddresses.tr(),
                    subtitle: AppStrings.savedAddressesSubtitle.tr(),
                    onTap: () {},
                  ),
                  _MenuTile(
                    iconAsset: AppAssets.headset,
                    title: AppStrings.helpSupport.tr(),
                    subtitle: AppStrings.helpSupportSubtitle.tr(),
                    onTap: provider.tapOnHelp,
                  ),
                  _MenuTile(
                    iconAsset: AppAssets.document,
                    title: AppStrings.termsConditions.tr(),
                    subtitle: AppStrings.termsSubtitle.tr(),
                    onTap: provider.tapOnTerms,
                  ),
                  _MenuTile(
                    iconAsset: AppAssets.privacy,
                    title: AppStrings.privacyPolicy.tr(),
                    subtitle: AppStrings.privacySubtitle.tr(),
                    onTap: provider.tapOnPrivacy,
                  ),
                  _MenuTile(
                    iconAsset: AppAssets.folder,
                    title: AppStrings.documents.tr(),
                    subtitle: AppStrings.documentsSubtitle.tr(),
                    onTap: provider.tapOnDocuments,
                  ),
                  const SizedBox(height: 8),
                  _MenuTile(
                    iconAsset: AppAssets.logout,
                    title: AppStrings.logout.tr(),
                    subtitle: AppStrings.logoutSubtitle.tr(),
                    isDestructive: true,
                    onTap: () => showLogoutDialog(context),
                  ),
                  _MenuTile(
                    iconAsset: AppAssets.delete,
                    title: AppStrings.deleteAccount.tr(),
                    subtitle: AppStrings.deleteSubtitle.tr(),
                    isDestructive: true,
                    onTap: () => showDeleteAccountDialog(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isDestructive ? AppColors.destructive : AppColors.menuIcon;
    final titleColor =
        isDestructive ? AppColors.destructive : AppColors.textPrimary;
    final subtitleColor = isDestructive
        ? AppColors.destructive.withValues(alpha: 0.7)
        : AppColors.pureBlack;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.pinkSection : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDestructive
              ? null
              : Border.all(color: AppColors.completedCardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive ? AppColors.white : AppColors.peach,
                shape: BoxShape.circle,
              ),
              child: AppIcon(iconAsset, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.style(
                      fontSize: 11,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            AppIcon(
              AppAssets.chevronRight,
              color: isDestructive
                  ? AppColors.destructive
                  : AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
