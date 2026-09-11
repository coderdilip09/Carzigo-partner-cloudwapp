import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/screens/profile/documents/documents_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void _showDocumentPreview(
  BuildContext context, {
  required String title,
  required String line1,
  required String line2,
  String? previewUrl,
  required String fallbackAsset,
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
              child: _DocImage(
                url: previewUrl,
                fallbackAsset: fallbackAsset,
                fit: BoxFit.cover,
                iconSize: 88,
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
    return ChangeNotifierProvider(
      create: (_) => DocumentsProvider(),
      child: Consumer<DocumentsProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AppBg(
              child: SafeArea(
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
                        child: provider.isLoading && provider.review == null
                            ? const Center(child: CircularProgressIndicator())
                            : !provider.hasAnyDocument
                            ? Center(
                                child: Text(
                                  AppStrings.noData.tr(),
                                  style: AppTextStyles.style(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: provider.load,
                                child: SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    children: [
                                      if (provider.hasIdentity)
                                        _DocCard(
                                          iconAsset: AppAssets.badge,
                                          title: AppStrings.identityProof.tr(),
                                          line1: provider.identityDocLabel,
                                          line2: provider.identityMasked,
                                          previewUrl:
                                              provider.identityPreviewUrl,
                                          fallbackAsset: AppAssets.docProof,
                                          showStackedPreview: true,
                                          isVerified: provider.hasIdentity,
                                          statusLabel: provider.statusLabel(
                                            provider.hasIdentity,
                                          ),
                                          onEdit: provider.tapOnEditIdentity,
                                        ),
                                      if (provider.hasAddress)
                                        _DocCard(
                                          iconAsset: AppAssets.location,
                                          title: AppStrings.addressProof.tr(),
                                          line1: provider.addressDocLabel,
                                          line2: provider.addressMasked,
                                          previewUrl:
                                              provider.addressPreviewUrl,
                                          fallbackAsset: AppAssets.docProof,
                                          showStackedPreview: true,
                                          isVerified: provider.hasAddress,
                                          statusLabel: provider.statusLabel(
                                            provider.hasAddress,
                                          ),
                                          onEdit: provider.tapOnEditAddress,
                                        ),
                                      if (provider.hasBank)
                                        _DocCard(
                                          iconAsset: AppAssets.bank,
                                          title: AppStrings.bankDetails.tr(),
                                          line1: provider.bankName,
                                          line2: provider.bankMasked,
                                          previewUrl: provider.bankPreviewUrl,
                                          fallbackAsset: AppAssets.bank,
                                          showStackedPreview: false,
                                          isVerified: provider.hasBank,
                                          statusLabel: provider.statusLabel(
                                            provider.hasBank,
                                          ),
                                          onEdit: provider.tapOnEditBank,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      if (provider.canSubmit) ...[
                        AppSolidButton(
                          label: AppStrings.submitForVerification.tr(),
                          onTap: provider.tapOnSubmit,
                          isLoading: provider.isSubmitting,
                        ),
                        const SizedBox(height: 12),
                      ],
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIcon(
                              AppAssets.lock,
                              size: 14,
                              color: AppColors.black,
                            ),
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
            ),
          );
        },
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
    required this.fallbackAsset,
    required this.onEdit,
    required this.isVerified,
    required this.statusLabel,
    this.previewUrl,
    this.showStackedPreview = false,
  });

  final String iconAsset;
  final String title;
  final String line1;
  final String line2;
  final String? previewUrl;
  final String fallbackAsset;
  final bool showStackedPreview;
  final bool isVerified;
  final String statusLabel;
  final VoidCallback onEdit;

  void _onView(BuildContext context) {
    _showDocumentPreview(
      context,
      title: title,
      line1: line1,
      line2: line2,
      previewUrl: previewUrl,
      fallbackAsset: fallbackAsset,
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
        border: Border.all(color: AppColors.completedCardBorder),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            AppAssets.edit,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          Container(
                            width: 14,
                            height: 1,
                            color: AppColors.primary,
                          ),
                        ],
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
                  url: previewUrl,
                  asset: fallbackAsset,
                  stacked: showStackedPreview,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.performanceCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIcon(
                      isVerified
                          ? AppAssets.shieldFilled
                          : AppAssets.kycPending,
                      size: 14,
                      color: AppColors.accentOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
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

class _DocImage extends StatelessWidget {
  const _DocImage({
    required this.fallbackAsset,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.iconSize = 20,
  });

  final String? url;
  final String fallbackAsset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double iconSize;

  bool get _isNetwork {
    final value = url?.trim() ?? '';
    return value.startsWith('http://') || value.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return Image.network(
        url!.trim(),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, error, stackTrace) =>
            _Fallback(asset: fallbackAsset, size: iconSize),
      );
    }
    if (fallbackAsset == AppAssets.docProof) {
      return AppImageView(
        fallbackAsset,
        width: width,
        height: height,
        fit: fit,
      );
    }
    return _Fallback(asset: fallbackAsset, size: iconSize);
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppIcon(asset, size: size, color: AppColors.primary),
    );
  }
}

class _DocPreview extends StatelessWidget {
  const _DocPreview({
    required this.asset,
    required this.stacked,
    this.url,
  });

  final String? url;
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
          child: _DocImage(
            url: url,
            fallbackAsset: AppAssets.docProof,
            width: 34,
            height: 42,
            fit: BoxFit.cover,
            iconSize: 16,
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
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        child: _DocImage(
          url: url,
          fallbackAsset: asset,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          iconSize: 20,
        ),
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
