import 'dart:io';

import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_source_sheet.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_page_scaffold.dart';
import 'package:carzigo_partner/common_widgets/app_phone_field.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/common_widgets/app_text_field.dart';
import 'package:carzigo_partner/screens/profile/edit_profile/edit_profile_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditProfileProvider(),
      child: Consumer<EditProfileProvider>(
        builder: (context, provider, _) {
          return AppPageScaffold(
            title: AppStrings.editProfile.tr(),
            showBackText: true,
            titleInline: false,
            headerExtra: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                AppStrings.editProfileSubtitle.tr(),
                style: AppTextStyles.style(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            bottomBar: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSolidButton(
                    label: AppStrings.updateProfile.tr(),
                    onTap: provider.tapOnSave,
                    isLoading: provider.isLoading,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon(
                        AppAssets.lock,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          AppStrings.infoSafe.tr(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.style(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            body: Form(
              key: provider.formKey,
              autovalidateMode: provider.submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          await showImageSourceSheet(
                            context,
                            useRootNavigator: false,
                            onCamera: provider.pickFromCamera,
                            onGallery: provider.pickFromGallery,
                          );
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.peachCard,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: _ProfilePhoto(
                                  file: provider.profileImage,
                                  url: provider.photoUrl,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
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
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        AppStrings.profilePhoto.tr(),
                        style: AppTextStyles.style(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Center(
                      child: Text(
                        AppStrings.tapToChangePhoto.tr(),
                        style: AppTextStyles.style(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      controller: provider.nameController,
                      prefixAsset: AppAssets.personFilled,
                      prefixIconColor: AppColors.primary,
                      textCapitalization: TextCapitalization.words,
                      validator: provider.validateName,
                    ),
                    const SizedBox(height: 12),
                    AppPhoneField(
                      controller: provider.phoneController,
                      readOnly: true,
                      showDivider: false,
                      borderColor: AppColors.textFieldBorderGrey,
                      suffix: OutlinedButton(
                        onPressed: provider.tapOnChangeNumber,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          AppStrings.changeNumber.tr(),
                          style: AppTextStyles.style(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: provider.emailController,
                      prefixAsset: AppAssets.email,
                      prefixIconColor: AppColors.primary,
                      keyboardType: TextInputType.emailAddress,
                      validator: provider.validateEmail,
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
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({this.file, this.url});

  final File? file;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final localFile = file;
    if (localFile != null) {
      return Image.file(localFile, width: 110, height: 110, fit: BoxFit.cover);
    }
    final photoUrl = url?.trim() ?? '';
    if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
      return Image.network(
        photoUrl,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) => const AppImageView(
          AppAssets.dummyProfile,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
        ),
      );
    }
    return const AppImageView(
      AppAssets.dummyProfile,
      width: 110,
      height: 110,
      fit: BoxFit.cover,
    );
  }
}
