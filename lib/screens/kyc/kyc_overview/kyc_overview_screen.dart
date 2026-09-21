import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_dialogs.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/screens/kyc/kyc_overview/kyc_overview_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KycOverviewScreen extends StatelessWidget {
  const KycOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KycOverviewProvider()..load(),
      child: Consumer<KycOverviewProvider>(
        builder: (context, provider, _) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              showLogoutDialog(context);
            },
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: Stack(
                children: [
                  const Positioned.fill(
                    child: AppImageView(AppAssets.bg, fit: BoxFit.cover),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: RefreshIndicator(
                        onRefresh: provider.load,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: IntrinsicHeight(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppBackHeader(
                                        title: AppStrings.completeKyc.tr(),
                                        onBack: () => showLogoutDialog(context),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        AppStrings.kycSubtitle.tr(),
                                        style: AppTextStyles.style(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: provider.isRejected
                                              ? AppColors.destructiveLight
                                              : AppColors.peach,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: provider.isRejected
                                              ? Border.all(
                                                  color: AppColors
                                                      .destructiveBorder,
                                                )
                                              : null,
                                        ),
                                        child: Row(
                                          children: [
                                            AppIcon(
                                              AppAssets.kycPending,
                                              size: 32,
                                              color: provider.isRejected
                                                  ? AppColors.destructive
                                                  : null,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    provider.isRejected
                                                        ? AppStrings
                                                              .kycRejected
                                                              .tr()
                                                        : AppStrings.kycPending
                                                              .tr(),
                                                    style: AppTextStyles.style(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  Text(
                                                    provider.bannerMessage ??
                                                        (provider.isRejected
                                                            ? AppStrings
                                                                  .kycRejectedBody
                                                                  .tr()
                                                            : AppStrings
                                                                  .kycPendingBody
                                                                  .tr()),
                                                    style: AppTextStyles.style(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                  if (provider
                                                      .isAddressRejected) ...[
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      '${AppStrings.addressProof.tr()}: ${provider.addressRejectReason ?? AppStrings.rejected.tr()}',
                                                      style: AppTextStyles.style(
                                                        fontSize: 11,
                                                        color: AppColors
                                                            .destructive,
                                                      ),
                                                    ),
                                                  ],
                                                  if (provider
                                                      .isBankRejected) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${AppStrings.bankDetails.tr()}: ${provider.bankRejectReason ?? AppStrings.rejected.tr()}',
                                                      style: AppTextStyles.style(
                                                        fontSize: 11,
                                                        color: AppColors
                                                            .destructive,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        provider.hasPartialRejection
                                            ? AppStrings.fixRejectedSections
                                                  .tr()
                                            : AppStrings.planBenefits.tr(),
                                        style: AppTextStyles.style(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _KycItem(
                                        title: AppStrings.identityProof.tr(),
                                        subtitle:
                                            AppStrings.identityDocsHint.tr(),
                                        isDone: provider.isIdentityDone,
                                        isPending:
                                            !provider.isLoading &&
                                            !provider.isIdentityDone,
                                        onTap: provider.tapOnIdentity,
                                      ),
                                      _KycItem(
                                        title: AppStrings.addressProof.tr(),
                                        subtitle: provider.isAddressRejected
                                            ? (provider.addressRejectReason ??
                                                  AppStrings
                                                      .localAddressDocsHint
                                                      .tr())
                                            : AppStrings.localAddressDocsHint
                                                  .tr(),
                                        isDone: provider.isAddressProofDone,
                                        isPending:
                                            !provider.isLoading &&
                                            !provider.isAddressProofDone &&
                                            !provider.isAddressRejected,
                                        isRejected: provider.isAddressRejected,
                                        onTap: provider.tapOnAddressProof,
                                      ),
                                      _KycItem(
                                        title: AppStrings.bankDetails.tr(),
                                        subtitle: provider.isBankRejected
                                            ? (provider.bankRejectReason ??
                                                  AppStrings.bankDocsHint.tr())
                                            : AppStrings.bankDocsHint.tr(),
                                        isDone: provider.isBankDone,
                                        isPending:
                                            !provider.isLoading &&
                                            !provider.isBankDone &&
                                            !provider.isBankRejected,
                                        isRejected: provider.isBankRejected,
                                        onTap: provider.tapOnBank,
                                      ),
                                      _KycItem(
                                        title: AppStrings.profilePhoto.tr(),
                                        subtitle: AppStrings
                                            .clearPhotoVerification
                                            .tr(),
                                        isDone: provider.isProfilePhotoDone,
                                        isPending:
                                            !provider.isLoading &&
                                            !provider.isProfilePhotoDone,
                                        onTap: provider.tapOnProfilePhoto,
                                      ),
                                      const Spacer(),
                                      AppSolidButton(
                                        label: provider.canSubmit
                                            ? (provider.isRejected
                                                  ? AppStrings
                                                        .resubmitForReview
                                                        .tr()
                                                  : AppStrings.reviewAndSubmit
                                                        .tr())
                                            : (provider.hasPartialRejection
                                                  ? AppStrings
                                                        .fixRejectedSections
                                                        .tr()
                                                  : AppStrings
                                                        .startKycVerification
                                                        .tr()),
                                        onTap: provider.tapOnStartKyc,
                                        isLoading: provider.isLoading,
                                        trailing: Container(
                                          width: 28,
                                          height: 28,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.white,
                                              width: 1.5,
                                            ),
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _KycItem extends StatelessWidget {
  const _KycItem({
    required this.title,
    required this.subtitle,
    this.isDone = false,
    this.isPending = false,
    this.isRejected = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isDone;
  final bool isPending;
  final bool isRejected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isRejected
              ? AppColors.destructiveLight
              : isDone
                  ? AppColors.peachLight
                  : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRejected
                ? AppColors.destructiveBorder
                : isDone
                    ? AppColors.completedCardBorder
                    : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.style(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.style(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isRejected
                          ? AppColors.destructive
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isRejected)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.destructive,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppStrings.rejected.tr(),
                  style: AppTextStyles.style(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
              )
            else if (isDone)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                ),
                child: AppIcon(
                  AppAssets.check,
                  size: 16,
                  color: AppColors.white,
                ),
              )
            else if (isPending)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
      ),
    );
  }
}
