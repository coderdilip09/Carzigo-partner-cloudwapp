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

  void _onBack(BuildContext context, KycOverviewProvider provider) {
    if (provider.handleBack(context)) {
      showLogoutDialog(context);
    }
  }

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
              _onBack(context, provider);
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
                                        title: provider.pageTitle,
                                        onBack: () =>
                                            _onBack(context, provider),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        provider.pageSubtitle,
                                        style: AppTextStyles.style(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      _KycStatusBanner(provider: provider),
                                      const SizedBox(height: 20),
                                      Text(
                                        provider.hasPartialRejection
                                            ? AppStrings.fixRejectedSections
                                                  .tr()
                                            : AppStrings.requiredDocuments.tr(),
                                        style: AppTextStyles.style(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _KycItem(
                                        title: AppStrings.identityProof.tr(),
                                        subtitle: AppStrings.identityDocsHint
                                            .tr(),
                                        isDone: provider.isIdentityDone,
                                        isPending:
                                            !provider.isLoading &&
                                            !provider.isIdentityDone,
                                        onTap: provider.tapOnIdentity,
                                      ),
                                      const SizedBox(height: 12),
                                      _KycItem(
                                        title: AppStrings.addressProof.tr(),
                                        subtitle: provider.isAddressRejected
                                            ? (provider.addressRejectReason ??
                                                  AppStrings.rejected.tr())
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
                                      const SizedBox(height: 12),
                                      _KycItem(
                                        title: AppStrings.bankDetails.tr(),
                                        subtitle: provider.isBankRejected
                                            ? (provider.bankRejectReason ??
                                                  AppStrings.rejected.tr())
                                            : AppStrings.bankDocsHint.tr(),
                                        isDone: provider.isBankDone,
                                        isPending:
                                            !provider.isLoading &&
                                            !provider.isBankDone &&
                                            !provider.isBankRejected,
                                        isRejected: provider.isBankRejected,
                                        onTap: provider.tapOnBank,
                                      ),
                                      const SizedBox(height: 12),
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
                                      if (provider.isApproved)
                                        AppSolidButton(
                                          label: AppStrings.goToDashboard.tr(),
                                          onTap: provider.goToDashboard,
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
                                        )
                                      else if (provider.showStartCta)
                                        AppSolidButton(
                                          label: _ctaLabel(provider),
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

  String _ctaLabel(KycOverviewProvider provider) {
    if (provider.canSubmit) {
      return provider.isRejected
          ? AppStrings.resubmitForReview.tr()
          : AppStrings.reviewAndSubmit.tr();
    }
    if (provider.hasPartialRejection) {
      return AppStrings.updateRejectedItems.tr();
    }
    return AppStrings.startKycVerification.tr();
  }
}

class _KycStatusBanner extends StatelessWidget {
  const _KycStatusBanner({required this.provider});

  final KycOverviewProvider provider;

  @override
  Widget build(BuildContext context) {
    final rejected = provider.isRejected;
    final approved = provider.isApproved;
    final underReview = provider.isUnderReview;
    final readyToSubmit = provider.isReadyToSubmit;

    final String title;
    final String body;
    final Color bgColor;
    final Color? iconColor;
    final Border? border;
    final String iconAsset;

    if (rejected) {
      title = AppStrings.kycRejected.tr();
      body = AppStrings.kycRejectedBody.tr();
      bgColor = AppColors.destructiveLight;
      iconColor = AppColors.destructive;
      border = Border.all(color: AppColors.destructiveBorder);
      iconAsset = AppAssets.kycPending;
    } else if (approved) {
      title = AppStrings.kycApproved.tr();
      body = AppStrings.kycApprovedBody.tr();
      bgColor = AppColors.greenLight;
      iconColor = null;
      border = null;
      iconAsset = AppAssets.check;
    } else if (underReview) {
      title = AppStrings.kycUnderReview.tr();
      body = provider.bannerMessage?.trim().isNotEmpty == true
          ? provider.bannerMessage!
          : AppStrings.kycUnderReviewBody.tr();
      bgColor = AppColors.peach;
      iconColor = null;
      border = null;
      iconAsset = AppAssets.kycPending;
    } else if (readyToSubmit) {
      title = AppStrings.reviewAndSubmit.tr();
      body = AppStrings.kycReadyToSubmitSubtitle.tr();
      bgColor = AppColors.peach;
      iconColor = null;
      border = null;
      iconAsset = AppAssets.kycPending;
    } else {
      title = AppStrings.kycPending.tr();
      body = AppStrings.kycPendingBody.tr();
      bgColor = AppColors.peach;
      iconColor = null;
      border = null;
      iconAsset = AppAssets.kycPending;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: border,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(
            iconAsset,
            size: 32,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.style(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppTextStyles.style(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
                    const SizedBox(height: 4),
                    if (isRejected)
                      _ExpandableRejectReason(text: subtitle)
                    else
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.style(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
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
      ),
    );
  }
}

/// Collapses long admin reject reasons; tap Read more / Show less to expand.
class _ExpandableRejectReason extends StatefulWidget {
  const _ExpandableRejectReason({required this.text});

  final String text;

  @override
  State<_ExpandableRejectReason> createState() =>
      _ExpandableRejectReasonState();
}

class _ExpandableRejectReasonState extends State<_ExpandableRejectReason> {
  static const int _collapsedLines = 2;

  /// Rough threshold: longer admin notes get Read more.
  static const int _expandCharThreshold = 90;
  bool _expanded = false;

  bool get _canExpand => widget.text.trim().length > _expandCharThreshold;

  @override
  void didUpdateWidget(covariant _ExpandableRejectReason oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.style(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.destructive,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _expanded || !_canExpand ? null : _collapsedLines,
          overflow: _expanded || !_canExpand
              ? TextOverflow.visible
              : TextOverflow.ellipsis,
          style: style,
        ),
        if (_canExpand) ...[
          const SizedBox(height: 4),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                _expanded ? AppStrings.showLess.tr() : AppStrings.readMore.tr(),
                style: AppTextStyles.style(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
