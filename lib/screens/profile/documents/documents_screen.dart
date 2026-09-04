import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/screens/kyc/address_proof/address_proof_screen.dart';
import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_screen.dart';
import 'package:carzigo_partner/screens/kyc/identity_proof/identity_proof_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/mock_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

void _showDocumentPreview(
  BuildContext context, {
  required String title,
  required String line1,
  required String line2,
  required String previewAsset,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.style(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  behavior: HitTestBehavior.opaque,
                  child: const Icon(
                    Icons.close,
                    size: 22,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.peachLight,
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: previewAsset == AppAssets.docProof
                  ? const SizedBox.expand(
                      child: AppImageView(
                        AppAssets.docProof,
                        fit: BoxFit.cover,
                      ),
                    )
                  : AppIcon(
                      previewAsset,
                      size: 88,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(height: 14),
            Text(
              line1,
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              line2,
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  AppStrings.cancel.tr(),
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackHeader(title: AppStrings.documents.tr()),
              Text(
                AppStrings.documentsSubtitle.tr(),
                style: AppTextStyles.style(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _DocCard(
                        iconAsset: AppAssets.badge,
                        title: AppStrings.identityProof.tr(),
                        line1: AppStrings.aadhaarCard.tr(),
                        line2: MockData.aadhaarMasked,
                        previewAsset: AppAssets.docProof,
                        showStackedPreview: true,
                        onEdit: () =>
                            AppNavigation.to(const IdentityProofScreen()),
                      ),
                      _DocCard(
                        iconAsset: AppAssets.location,
                        title: AppStrings.addressProof.tr(),
                        line1: AppStrings.aadhaarCard.tr(),
                        line2: MockData.aadhaarMasked,
                        previewAsset: AppAssets.docProof,
                        showStackedPreview: true,
                        onEdit: () =>
                            AppNavigation.to(const AddressProofScreen()),
                      ),
                      _DocCard(
                        iconAsset: AppAssets.bank,
                        title: AppStrings.bankDetails.tr(),
                        line1: AppStrings.mockBankName.tr(),
                        line2: AppStrings.mockBankAccountMasked.tr(),
                        previewAsset: AppAssets.bank,
                        showStackedPreview: false,
                        onEdit: () =>
                            AppNavigation.to(const BankDetailsScreen()),
                      ),
                    ],
                  ),
                ),
              ),
              AppSolidButton(
                label: AppStrings.submitForVerification.tr(),
                onTap: () {},
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIcon(AppAssets.lock, size: 14, color: AppColors.black),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.documentsSafe.tr(),
                      style: AppTextStyles.style(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocCard extends StatelessWidget {
  const _DocCard({
    required this.iconAsset,
    required this.title,
    required this.line1,
    required this.line2,
    required this.previewAsset,
    required this.onEdit,
    this.showStackedPreview = false,
  });

  final String iconAsset;
  final String title;
  final String line1;
  final String line2;
  final String previewAsset;
  final bool showStackedPreview;
  final VoidCallback onEdit;

  void _onView(BuildContext context) {
    _showDocumentPreview(
      context,
      title: title,
      line1: line1,
      line2: line2,
      previewAsset: previewAsset,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.peach,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: AppIcon(iconAsset, color: AppColors.black, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.sectionTitle,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.edit.tr(),
                        style: AppTextStyles.style(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AppIcon(
                        AppAssets.edit,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line1,
                      style: AppTextStyles.style(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      line2,
                      style: AppTextStyles.style(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _onView(context),
                behavior: HitTestBehavior.opaque,
                child: _DocPreview(
                  asset: previewAsset,
                  stacked: showStackedPreview,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.performanceCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(
                      AppAssets.shieldFilled,
                      size: 14,
                      color: AppColors.accentOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.verified.tr(),
                      style: AppTextStyles.style(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _onView(context),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.view.tr(),
                      style: AppTextStyles.style(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppIcon(
                      AppAssets.chevronRight,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocPreview extends StatelessWidget {
  const _DocPreview({required this.asset, required this.stacked});

  final String asset;
  final bool stacked;

  Widget _cardThumb({
    required double dx,
    required double dy,
    required double angle,
  }) {
    return Positioned(
      right: dx,
      top: dy,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 34,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: const AppImageView(
            AppAssets.docProof,
            width: 34,
            height: 42,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!stacked) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.peachLight,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: AppIcon(asset, size: 20, color: AppColors.textMuted),
      );
    }

    return SizedBox(
      width: 56,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _cardThumb(dx: 0, dy: 4, angle: 0.18),
          _cardThumb(dx: 8, dy: 2, angle: 0.08),
          _cardThumb(dx: 16, dy: 0, angle: -0.04),
        ],
      ),
    );
  }
}
