import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_kyc_stepper.dart';
import 'package:carzigo_partner/common_widgets/app_shimmer.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/screens/kyc/identity_proof/identity_proof_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
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
                child: AppShimmer(
                  enabled: provider.isFetching,
                  child: SingleChildScrollView(
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
                        if (provider.isVerified &&
                            (provider.verifiedName ?? '').isNotEmpty) ...[
                          const SizedBox(height: 20),
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
                                const SizedBox(height: 6),
                                Text(
                                  provider.verifiedName!,
                                  style: AppTextStyles.style(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
            ),
          );
        },
      ),
    );
  }
}
