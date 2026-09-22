import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_image_source_sheet.dart';
import 'package:carzigo_partner/common_widgets/app_kyc_stepper.dart';
import 'package:carzigo_partner/common_widgets/app_option_sheet.dart';
import 'package:carzigo_partner/common_widgets/app_shimmer.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/common_widgets/app_text_field.dart';
import 'package:carzigo_partner/common_widgets/app_upload_box.dart';
import 'package:carzigo_partner/screens/kyc/local_address/local_address_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class LocalAddressScreen extends StatelessWidget {
  const LocalAddressScreen({super.key, this.editOnly = false});

  final bool editOnly;

  Future<void> _pickState(
    BuildContext context,
    LocalAddressProvider provider,
  ) async {
    final selected = await showAppOptionSheet(
      context: context,
      title: AppStrings.selectState.tr(),
      options: provider.states,
      selected: provider.selectedState,
      searchHint: AppStrings.searchState.tr(),
    );
    if (selected == null || !context.mounted) return;
    provider.selectState(selected);
  }

  Future<void> _pickCity(
    BuildContext context,
    LocalAddressProvider provider,
  ) async {
    if (provider.selectedState == null || provider.selectedState!.isEmpty) {
      AppToast.error(AppStrings.selectStateFirst.tr());
      return;
    }
    final selected = await showAppOptionSheet(
      context: context,
      title: AppStrings.selectCity.tr(),
      options: provider.citiesForState,
      selected: provider.selectedCity,
      searchHint: AppStrings.searchCity.tr(),
    );
    if (selected == null || !context.mounted) return;
    provider.selectCity(selected);
  }

  Widget _radioRow({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.peachCard,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.textHint,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.style(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocalAddressProvider(editOnly: editOnly),
      child: Consumer<LocalAddressProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AppBg(
              child: SafeArea(
                child: AppShimmer(
                  enabled: provider.isFetching,
                  child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: provider.formKey,
                          autovalidateMode: provider.submitted
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppBackHeader(
                                title: AppStrings.addressProof.tr(),
                              ),
                              if (!editOnly) ...[
                                const SizedBox(height: 16),
                                const AppKycStepper(
                                  currentStep: KycStep.address,
                                ),
                              ],
                              const SizedBox(height: 24),
                              Text(
                                AppStrings.sameAsDocumentAddress.tr(),
                                style: AppTextStyles.style(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.sameAsDocumentAddressHint.tr(),
                                style: AppTextStyles.style(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (!provider.hasDocumentAddress) ...[
                                const SizedBox(height: 8),
                                Text(
                                  AppStrings.sameAddressUnavailable.tr(),
                                  style: AppTextStyles.style(
                                    fontSize: 12,
                                    color: AppColors.destructive,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              _radioRow(
                                label: AppStrings.yes.tr(),
                                selected: provider.sameAsDocument,
                                onTap: () => provider.setSameAsDocument(true),
                              ),
                              _radioRow(
                                label: AppStrings.no.tr(),
                                selected: !provider.sameAsDocument,
                                onTap: () => provider.setSameAsDocument(false),
                              ),
                              if (provider.showAddressForm) ...[
                                const SizedBox(height: 16),
                                Text(
                                  AppStrings.enterLocalAddress.tr(),
                                  style: AppTextStyles.style(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  AppStrings.localAddressHint.tr(),
                                  style: AppTextStyles.style(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: provider.stateController,
                                  hint: AppStrings.selectState.tr(),
                                  prefixAsset: AppAssets.location,
                                  borderColor: AppColors.textFieldBorder,
                                  readOnly: true,
                                  onTap: () => _pickState(context, provider),
                                  suffix: const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  validator: provider.validateState,
                                ),
                                const SizedBox(height: 12),
                                AppTextField(
                                  controller: provider.cityController,
                                  hint: AppStrings.selectCity.tr(),
                                  prefixAsset: AppAssets.location,
                                  borderColor: AppColors.textFieldBorder,
                                  readOnly: true,
                                  onTap: () => _pickCity(context, provider),
                                  suffix: const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  validator: provider.validateCity,
                                ),
                                const SizedBox(height: 12),
                                AppTextField(
                                  controller: provider.lineController,
                                  hint: AppStrings.addressLine.tr(),
                                  prefixAsset: AppAssets.location,
                                  borderColor: AppColors.textFieldBorder,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  validator: provider.validateLine,
                                ),
                                const SizedBox(height: 12),
                                AppTextField(
                                  controller: provider.landmarkController,
                                  hint: AppStrings.landmarkOptional.tr(),
                                  prefixAsset: AppAssets.location,
                                  borderColor: AppColors.textFieldBorder,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                ),
                                const SizedBox(height: 12),
                                AppTextField(
                                  controller: provider.pincodeController,
                                  hint: AppStrings.pincode.tr(),
                                  prefixAsset: AppAssets.location,
                                  borderColor: AppColors.textFieldBorder,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  maxLength: 6,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                  onChanged: provider.onPincodeChanged,
                                  autovalidateMode:
                                      provider.submitted ||
                                          provider.pincodeStateError != null
                                      ? AutovalidateMode.always
                                      : AutovalidateMode.onUserInteraction,
                                  suffix: provider.isVerifyingPincode
                                      ? const Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            14,
                                            12,
                                            14,
                                            12,
                                          ),
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        )
                                      : null,
                                  validator: provider.validatePincode,
                                ),
                              ],
                              if (provider.showAddressForm) ...[
                                const SizedBox(height: 20),
                                AppUploadBox(
                                  title: AppStrings.uploadDocument.tr(),
                                  subtitle: AppStrings.uploadClearDocument.tr(),
                                  formatsHint:
                                      AppStrings.uploadFormatsChip.tr(),
                                  imageFile: provider.documentIsPdf
                                      ? null
                                      : provider.documentImage,
                                  imageUrl: provider.documentIsPdf
                                      ? null
                                      : provider.documentUrl,
                                  fileName: provider.documentFileName,
                                  isPdf: provider.documentIsPdf ||
                                      (provider.documentUrl
                                              ?.toLowerCase()
                                              .contains('.pdf') ??
                                          false),
                                  onTap: () => showDocumentSourceSheet(
                                    context,
                                    onCamera: () => provider.pickDocument(
                                      ImageSource.camera,
                                    ),
                                    onGallery: () => provider.pickDocument(
                                      ImageSource.gallery,
                                    ),
                                    onFile: provider.pickDocumentFile,
                                  ),
                                ),
                                if (provider.submitted &&
                                    !provider.hasDocument) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    AppStrings.documentImageRequired.tr(),
                                    style: AppTextStyles.style(
                                      fontSize: 12,
                                      color: AppColors.destructive,
                                    ),
                                  ),
                                ],
                              ],
                              const SizedBox(height: 24),
                              AppSolidButton(
                                label: AppStrings.submit.tr(),
                                onTap: provider.tapOnSubmit,
                                isLoading:
                                    provider.isLoading ||
                                    provider.isVerifyingPincode,
                              ),
                            ],
                          ),
                        ),
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
