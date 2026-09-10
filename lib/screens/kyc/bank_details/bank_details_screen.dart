import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_image_source_sheet.dart';
import 'package:carzigo_partner/common_widgets/app_kyc_stepper.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/common_widgets/app_text_field.dart';
import 'package:carzigo_partner/common_widgets/app_upload_box.dart';
import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_provider.dart';
import 'package:carzigo_partner/screens/kyc/kyc_document_number.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BankDetailsScreen extends StatelessWidget {
  const BankDetailsScreen({
    super.key,
    this.loadSaved = false,
    this.editOnly = false,
  });

  final bool loadSaved;
  final bool editOnly;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BankDetailsProvider(
        loadSaved: loadSaved,
        editOnly: editOnly,
      ),
      child: Consumer<BankDetailsProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AppBg(
              child: SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: provider.formKey,
                    autovalidateMode: provider.submitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppBackHeader(title: AppStrings.bankDetails.tr()),
                        if (!editOnly) ...[
                          const SizedBox(height: 16),
                          const AppKycStepper(currentStep: KycStep.bank),
                        ],
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
                          controller: provider.holderNameController,
                          hint: AppStrings.accountHolderName.tr(),
                          prefixAsset: AppAssets.personFilled,
                          borderColor: AppColors.textFieldBorder,
                          textCapitalization: TextCapitalization.words,
                          validator: provider.validateHolderName,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: provider.bankNameController,
                          hint: AppStrings.bankName.tr(),
                          prefixAsset: AppAssets.personFilled,
                          borderColor: AppColors.textFieldBorder,
                          textCapitalization: TextCapitalization.words,
                          validator: provider.validateBankName,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          key: ValueKey(
                            KycDocNumber.isMasked(
                              provider.accountNumberController.text,
                            ),
                          ),
                          controller: provider.accountNumberController,
                          hint: AppStrings.bankAccountNumber.tr(),
                          prefixAsset: AppAssets.personId,
                          keyboardType:
                              KycDocNumber.isMasked(
                                provider.accountNumberController.text,
                              )
                              ? TextInputType.text
                              : TextInputType.number,
                          borderColor: AppColors.textFieldBorder,
                          validator: provider.validateAccountNumber,
                          maxLength:
                              KycDocNumber.isMasked(
                                provider.accountNumberController.text,
                              )
                              ? null
                              : 18,
                          inputFormatters:
                              KycDocNumber.isMasked(
                                provider.accountNumberController.text,
                              )
                              ? const []
                              : [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: provider.ifscController,
                          hint: AppStrings.ifscCode.tr(),
                          prefixAsset: AppAssets.personId,
                          borderColor: AppColors.textFieldBorder,
                          textCapitalization: TextCapitalization.characters,
                          validator: provider.validateIfsc,
                          maxLength: 11,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9]'),
                            ),
                            TextInputFormatter.withFunction((
                              oldValue,
                              newValue,
                            ) {
                              return newValue.copyWith(
                                text: newValue.text.toUpperCase(),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AppUploadBox(
                          title: AppStrings.uploadCheque.tr(),
                          subtitle: AppStrings.uploadClearImage.tr(),
                          imageFile: provider.chequeImage,
                          imageUrl: provider.chequeUrl,
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
                          isLoading: provider.isLoading,
                        ),
                      ],
                    ),
                  ),
                    ),
                    if (provider.isFetching)
                      const Positioned.fill(
                        child: AbsorbPointer(
                          child: Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primary,
                              ),
                            ),
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
}
