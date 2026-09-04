import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_source_sheet.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_kyc_stepper.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/common_widgets/app_upload_box.dart';
import 'package:carzigo_partner/screens/kyc/identity_proof/identity_proof_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class IdentityProofScreen extends StatelessWidget {
  const IdentityProofScreen({super.key});

  static const _docIcons = [
    AppAssets.aadhaar,
    AppAssets.pan,
    AppAssets.drivingLicense,
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IdentityProofProvider(),
      child: Consumer<IdentityProofProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBackHeader(title: AppStrings.identityProof.tr()),
                    const SizedBox(height: 16),
                    const AppKycStepper(currentStep: KycStep.identity),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.selectDocumentType.tr(),
                      style: AppTextStyles.style(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      AppStrings.chooseAnyOne.tr(),
                      style: AppTextStyles.style(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(provider.docs.length, (i) {
                      final selected = provider.selectedDoc == i;
                      return GestureDetector(
                        onTap: () => provider.selectDoc(i),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.peachCard,
                            ),
                          ),
                          child: Row(
                            children: [
                              AppImageView(
                                _docIcons[i],
                                width: 42,
                                height: 30,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  provider.docs[i].tr(),
                                  style: AppTextStyles.style(
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              selected
                                  ? Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary,
                                      ),
                                      alignment: Alignment.center,
                                      child: AppIcon(
                                        AppAssets.check,
                                        size: 14,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : AppIcon(
                                      AppAssets.circle,
                                      color: AppColors.textPrimary,
                                    ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.uploadDocument.tr(),
                      style: AppTextStyles.style(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    AppUploadBox(
                      title: AppStrings.frontSide.tr(),
                      subtitle: AppStrings.uploadFrontSide.tr(),
                      imageFile: provider.frontImage,
                      onTap: () => showImageSourceSheet(
                        context,
                        onCamera: () =>
                            provider.pickFront(ImageSource.camera),
                        onGallery: () =>
                            provider.pickFront(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppUploadBox(
                      title: AppStrings.backSide.tr(),
                      subtitle: AppStrings.uploadBackSide.tr(),
                      imageFile: provider.backImage,
                      onTap: () => showImageSourceSheet(
                        context,
                        onCamera: () =>
                            provider.pickBack(ImageSource.camera),
                        onGallery: () =>
                            provider.pickBack(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppSolidButton(
                      label: AppStrings.submit.tr(),
                      onTap: provider.tapOnSubmit,
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
