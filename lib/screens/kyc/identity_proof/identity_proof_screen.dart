import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_kyc_stepper.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/screens/kyc/identity_proof/identity_proof_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IdentityProofScreen extends StatelessWidget {
  const IdentityProofScreen({
    super.key,
    this.loadSaved = false,
    this.editOnly = false,
  });

  final bool loadSaved;
  final bool editOnly;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IdentityProofProvider(
        loadSaved: loadSaved,
        editOnly: editOnly,
      ),
      child: Consumer<IdentityProofProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AppBg(
              child: SafeArea(
                child: provider.isFetching
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: AppBackHeader(
                              title: AppStrings.identityProof.tr(),
                            ),
                          ),
                          const Expanded(
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
                        ],
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppBackHeader(
                              title: AppStrings.identityProof.tr(),
                            ),
                            if (!editOnly) ...[
                              const SizedBox(height: 16),
                              const AppKycStepper(
                                currentStep: KycStep.identity,
                              ),
                            ],
                            const SizedBox(height: 24),
                            Text(
                              AppStrings.verifyWithDigilocker.tr(),
                              style: AppTextStyles.style(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.digilockerHint.tr(),
                              style: AppTextStyles.style(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _AadhaarStatusCard(provider: provider),
                            if (provider.isVerified &&
                                ((provider.verifiedName ?? '').isNotEmpty ||
                                    (provider.maskedAadhaar ?? '')
                                        .isNotEmpty)) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.peachLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.completedCardBorder,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.digilockerVerified.tr(),
                                      style: AppTextStyles.style(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    if ((provider.verifiedName ?? '')
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        provider.verifiedName!,
                                        style: AppTextStyles.style(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                    if ((provider.maskedAadhaar ?? '')
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        provider.maskedAadhaar!,
                                        style: AppTextStyles.style(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            if (!provider.isVerified)
                              AppSolidButton(
                                label: AppStrings.verifyWithDigilocker.tr(),
                                onTap: () =>
                                    provider.tapOnVerifyDigilocker(context),
                                isLoading: provider.isLoading,
                              )
                            else
                              AppSolidButton(
                                label: AppStrings.digilockerContinue.tr(),
                                onTap: provider.tapOnContinue,
                                isLoading: provider.isLoading,
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

/// Same pattern as old doc picker: Aadhaar image + Pending / check on the right.
class _AadhaarStatusCard extends StatelessWidget {
  const _AadhaarStatusCard({required this.provider});

  final IdentityProofProvider provider;

  @override
  Widget build(BuildContext context) {
    final verified = provider.isVerified;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: verified ? AppColors.peachLight : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: verified ? AppColors.completedCardBorder : AppColors.peachCard,
        ),
      ),
      child: Row(
        children: [
          AppImageView(
            AppAssets.aadhaar,
            width: 42,
            height: 30,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.aadhaarCard.tr(),
              style: AppTextStyles.style(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (verified)
            Container(
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
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.pendingBadge,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppStrings.pending.tr(),
                style: AppTextStyles.style(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF000000),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
