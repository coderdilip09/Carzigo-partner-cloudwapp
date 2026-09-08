import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_kyc_stepper.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/screens/kyc/kyc_review/kyc_review_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/mock_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KycReviewScreen extends StatelessWidget {
  const KycReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KycReviewProvider(),
      child: Consumer<KycReviewProvider>(
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
                      AppBackHeader(title: AppStrings.reviewAndSubmit.tr()),
                      const SizedBox(height: 16),
                      const AppKycStepper(currentStep: KycStep.bank),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.reviewYourDetails.tr(),
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.verifyBeforeSubmitting.tr(),
                        style: AppTextStyles.style(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ReviewCard(
                        title: AppStrings.identityProof.tr(),
                        line1: AppStrings.aadhaarCard.tr(),
                        line2: MockData.aadhaarMasked,
                        onEdit: provider.tapOnEditIdentity,
                        trailingAsset: AppAssets.docProof,
                      ),
                      _ReviewCard(
                        title: AppStrings.addressProof.tr(),
                        line1: AppStrings.aadhaarCard.tr(),
                        line2: MockData.aadhaarMasked,
                        onEdit: provider.tapOnEditAddress,
                        trailingAsset: AppAssets.docProof,
                      ),
                      _ReviewCard(
                        title: AppStrings.bankDetails.tr(),
                        line1: AppStrings.mockBankName.tr(),
                        line2: AppStrings.mockBankAccountMasked.tr(),
                        onEdit: provider.tapOnEditBank,
                        trailingAsset: AppAssets.bank,
                        tintTrailing: true,
                      ),
                      const SizedBox(height: 24),
                      AppSolidButton(
                        label: AppStrings.submitForVerification.tr(),
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

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.line1,
    required this.line2,
    required this.onEdit,
    required this.trailingAsset,
    this.tintTrailing = false,
  });

  final String title;
  final String line1;
  final String line2;
  final VoidCallback onEdit;
  final String trailingAsset;
  final bool tintTrailing;

  @override
  Widget build(BuildContext context) {
    final isSvg = trailingAsset.toLowerCase().endsWith('.svg');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.peachCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.edit.tr(),
                      style: AppTextStyles.style(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppIcon(
                          AppAssets.edit,
                          size: 14,
                          color: AppColors.textPrimary,
                        ),
                        Container(
                          width: 14,
                          height: 1,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line1,
                      style: AppTextStyles.style(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      line2,
                      style: AppTextStyles.style(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isSvg)
                AppIcon(
                  trailingAsset,
                  size: 40,
                  color: tintTrailing ? AppColors.textSecondary : null,
                )
              else
                AppImageView(
                  trailingAsset,
                  width: 48,
                  height: 36,
                  fit: BoxFit.contain,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
