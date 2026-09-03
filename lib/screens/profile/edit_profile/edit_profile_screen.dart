import 'dart:io';

import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_source_sheet.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_phone_field.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/common_widgets/app_text_field.dart';
import 'package:carzigo_partner/services/image_pick_service/image_pick_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/mock_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: MockData.userFullName);
    _phoneController = TextEditingController(text: '8785895757');
    _emailController = TextEditingController(
      text: AppStrings.emailHintExample.tr(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null || !mounted) return;
    setState(() => _profileImage = file);
  }

  void _onChangeNumber() {
    AppToast.show(AppStrings.updatePhoneHint.tr());
  }

  void _onUpdateProfile() {
    AppNavigation.back();
    AppToast.success(AppStrings.profileUpdated.tr());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBackHeader(
                      title: AppStrings.editProfile.tr(),
                      showBackText: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.editProfileSubtitle.tr(),
                      style: AppTextStyles.style(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: GestureDetector(
                        onTap: () => showImageSourceSheet(
                          context,
                          onCamera: () => _pick(ImageSource.camera),
                          onGallery: () => _pick(ImageSource.gallery),
                        ),
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
                                child: _profileImage != null
                                    ? Image.file(
                                        _profileImage!,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      )
                                    : AppImageView(
                                        AppAssets.dummyProfile,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
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
                      controller: _nameController,
                      prefixAsset: AppAssets.person,
                      prefixIconColor: AppColors.primary,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 12),
                    AppPhoneField(
                      controller: _phoneController,
                      suffix: GestureDetector(
                        onTap: _onChangeNumber,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.textFieldBorder,
                            ),
                          ),
                          child: Text(
                            AppStrings.changeNumber.tr(),
                            style: AppTextStyles.style(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _emailController,
                      prefixAsset: AppAssets.email,
                      prefixIconColor: AppColors.primary,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _onChangeNumber,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.textFieldBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.notificationCircle,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: AppIcon(
                                AppAssets.lock,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.changeNumber.tr(),
                                    style: AppTextStyles.style(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppStrings.updatePhoneHint.tr(),
                                    style: AppTextStyles.style(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppIcon(
                              AppAssets.chevronRight,
                              size: 18,
                              color: AppColors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  AppSolidButton(
                    label: AppStrings.updateProfile.tr(),
                    onTap: _onUpdateProfile,
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
          ],
        ),
      ),
    );
  }
}
