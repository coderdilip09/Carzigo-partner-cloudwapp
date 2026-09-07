import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_image_source_sheet.dart';
import 'package:carzigo_partner/common_widgets/app_kyc_stepper.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/common_widgets/app_text_field.dart';
import 'package:carzigo_partner/common_widgets/app_upload_box.dart';
import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class BankDetailsScreen extends StatelessWidget {
  const BankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BankDetailsProvider(),
      child: Consumer<BankDetailsProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AppBg(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBackHeader(title: AppStrings.bankDetails.tr()),
                      const SizedBox(height: 16),
                      const AppKycStepper(currentStep: KycStep.bank),
                      const SizedBox(height: 24),
                      Text(
                        AppStrings.enterBankDetails.tr(),
                        style: AppTextStyles.style(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        hint: AppStrings.accountHolderName.tr(),
                        prefixAsset: AppAssets.personFilled,
                        borderColor: AppColors.textFieldBorder,
                        textCapitalization: TextCapitalization.words,
                        onChanged: provider.setHolderName,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        hint: AppStrings.bankAccountNumber.tr(),
                        prefixAsset: AppAssets.personId,
                        keyboardType: TextInputType.number,
                        borderColor: AppColors.textFieldBorder,
                        onChanged: provider.setAccountNumber,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        hint: AppStrings.ifscCode.tr(),
                        prefixAsset: AppAssets.personId,
                        borderColor: AppColors.textFieldBorder,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: provider.setIfsc,
                      ),
                      const SizedBox(height: 20),
                      AppUploadBox(
                        title: AppStrings.uploadCheque.tr(),
                        subtitle: AppStrings.uploadClearImage.tr(),
                        imageFile: provider.chequeImage,
                        onTap: () => showImageSourceSheet(
                          context,
                          onCamera: () =>
                              provider.pickCheque(ImageSource.camera),
                          onGallery: () =>
                              provider.pickCheque(ImageSource.gallery),
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
            ),
          );
        },
      ),
    );
  }
}
