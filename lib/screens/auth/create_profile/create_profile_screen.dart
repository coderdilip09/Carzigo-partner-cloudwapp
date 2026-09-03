import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/common_widgets/app_text_field.dart';
import 'package:carzigo_partner/screens/auth/create_profile/create_profile_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateProfileScreen extends StatelessWidget {
  const CreateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateProfileProvider(),
      child: Consumer<CreateProfileProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBackHeader(
                      title: AppStrings.letsGetStarted.tr(),
                      showBackText: false,
                    ),
                    Text(
                      AppStrings.createProfileSubtitle.tr(),
                      style: AppTextStyles.style(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: () => _showImageSourceSheet(context, provider),
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1,
                                ),
                                color: AppColors.peach,
                              ),
                              child: ClipOval(
                                child: provider.profileImage != null
                                    ? Image.file(
                                        provider.profileImage!,
                                        width: 94,
                                        height: 94,
                                        fit: BoxFit.cover,
                                      )
                                    : const AppImageView(
                                        AppAssets.dummyProfile,
                                        width: 94,
                                        height: 94,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: AppIcon(
                                  AppAssets.camera,
                                  size: 16,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        AppStrings.addProfilePhoto.tr(),
                        style: AppTextStyles.style(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Center(
                      child: Text(
                        AppStrings.addProfilePhotoHint.tr(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.style(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      hint: AppStrings.enterFullName.tr(),
                      prefixAsset: AppAssets.personFilled,
                      prefixIconColor: AppColors.accentOrange,
                      borderColor: AppColors.textFieldBorderGrey,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      hint: AppStrings.enterEmail.tr(),
                      prefixAsset: AppAssets.email,
                      prefixIconColor: AppColors.accentOrange,
                      borderColor: AppColors.textFieldBorderGrey,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _FeatureGrid(),
                    const SizedBox(height: 24),
                    AppSolidButton(
                      label: AppStrings.saveAndContinue.tr(),
                      onTap: provider.tapOnSave,
                      trailing: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 1.5),
                        ),
                        child: AppIcon(
                          AppAssets.arrowForward,
                          size: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showImageSourceSheet(
    BuildContext context,
    CreateProfileProvider provider,
  ) async {
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
                    await provider.pickFromCamera();
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
                    await provider.pickFromGallery();
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
}

class _FeatureGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (
        const AppIcon(
          AppAssets.lock,
          color: AppColors.accentOrange,
          size: 18,
        ),
        AppStrings.secure.tr(),
        AppStrings.createSecureHint.tr(),
      ),
      (
        const AppIcon(
          AppAssets.flashFilled,
          color: AppColors.accentOrange,
          size: 18,
        ),
        AppStrings.quickSetup.tr(),
        AppStrings.createQuickHint.tr(),
      ),
      (
        const Icon(
          Icons.person_outline,
          size: 18,
          color: AppColors.accentOrange,
        ),
        AppStrings.personalized.tr(),
        AppStrings.createPersonalizedHint.tr(),
      ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.peachLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.peach,
                    shape: BoxShape.circle,
                  ),
                  child: item.$1,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 16,
                  child: Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.style(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 28,
                  child: Text(
                    item.$3,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.style(
                      fontSize: 9,
                      height: 1.3,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

