import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_shimmer.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/screens/profile/documents/documents_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

bool _isPdfUrl(String url) {
  final path = url.toLowerCase().split('?').first.split('#').first;
  return path.endsWith('.pdf') || path.contains('.pdf');
}

bool _isLikelyDocumentFile(String url) {
  final path = url.toLowerCase().split('?').first.split('#').first;
  return path.endsWith('.pdf') ||
      path.endsWith('.doc') ||
      path.endsWith('.docx') ||
      path.endsWith('.xls') ||
      path.endsWith('.xlsx') ||
      path.endsWith('.csv') ||
      path.endsWith('.txt');
}

Future<void> _openExternalDocument(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    AppToast.error(AppStrings.documentUnavailable.tr());
    return;
  }
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    AppToast.error(AppStrings.documentUnavailable.tr());
  }
}

Future<void> _viewDocuments(
  BuildContext context, {
  required String title,
  required List<String> urls,
  String fallbackAsset = AppAssets.docProof,
}) async {
  final clean = urls
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList();

  if (clean.isEmpty) {
    AppToast.error(AppStrings.documentUnavailable.tr());
    return;
  }

  final first = clean.first;
  if (_isLikelyDocumentFile(first) || _isPdfUrl(first)) {
    await _openExternalDocument(first);
    return;
  }

  // Image extension, or unknown CDN URL — open in-app viewer.
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => _DocumentViewerDialog(
      title: title,
      urls: clean,
      fallbackAsset: fallbackAsset,
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
                        child: AppShimmer(
                          enabled:
                              provider.isLoading && provider.review == null,
                          child: provider.isLoading && provider.review == null
                              ? const SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _IdentityDocCard(
                                        proofType: 'Document type placeholder',
                                        number: 'XXXX XXXX XXXX',
                                        isVerified: true,
                                        statusLabel: 'Verified',
                                        documentUrls: [],
                                      ),
                                      _DocCard(
                                        iconAsset: AppAssets.location,
                                        title: 'Address Proof',
                                        line1: 'Document type placeholder',
                                        line2: 'XXXX XXXX XXXX',
                                        previewUrl: null,
                                        fallbackAsset: AppAssets.docProof,
                                        showStackedPreview: true,
                                        isVerified: true,
                                        statusLabel: 'Verified',
                                      ),
                                      _DocCard(
                                        iconAsset: AppAssets.bank,
                                        title: 'Bank Details',
                                        line1: 'Bank name placeholder',
                                        line2: 'XXXX XXXX XXXX',
                                        previewUrl: null,
                                        fallbackAsset: AppAssets.bank,
                                        showStackedPreview: false,
                                        isVerified: true,
                                        statusLabel: 'Verified',
                                      ),
                                    ],
                                  ),
                                )
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
                                          _IdentityDocCard(
                                            proofType:
                                                provider.identityDocLabel,
                                            number: provider.identityMasked,
                                            isVerified: provider.hasIdentity,
                                            statusLabel: provider.statusLabel(
                                              provider.hasIdentity,
                                            ),
                                            documentUrls:
                                                provider.identityDocumentUrls,
                                          ),
                                        if (provider.hasAddress)
                                          _DocCard(
                                            iconAsset: AppAssets.location,
                                            title:
                                                AppStrings.addressProof.tr(),
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
                                          ),
                                        if (provider.hasBank)
                                          _DocCard(
                                            iconAsset: AppAssets.bank,
                                            title: AppStrings.bankDetails.tr(),
                                            line1: provider.bankName,
                                            line2: provider.bankMasked,
                                            previewUrl:
                                                provider.bankPreviewUrl,
                                            fallbackAsset: AppAssets.bank,
                                            showStackedPreview: false,
                                            isVerified: provider.hasBank,
                                            statusLabel: provider.statusLabel(
                                              provider.hasBank,
                                            ),
                                          ),
                                      ],
                                    ),
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

class _IdentityDocCard extends StatelessWidget {
  const _IdentityDocCard({
    required this.proofType,
    required this.number,
    required this.isVerified,
    required this.statusLabel,
    required this.documentUrls,
  });

  final String proofType;
  final String number;
  final bool isVerified;
  final String statusLabel;
  final List<String> documentUrls;

  String? get _previewUrl =>
      documentUrls.isEmpty ? null : documentUrls.first;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isVerified ? AppColors.verified : AppColors.accentOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.peachCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  AppStrings.identityProof.tr(),
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                      size: 13,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: AppTextStyles.style(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.proofType.tr(),
                      style: AppTextStyles.style(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      proofType,
                      style: AppTextStyles.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppStrings.documentNumber.tr(),
                      style: AppTextStyles.style(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      number,
                      style: AppTextStyles.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _viewDocuments(
                  context,
                  title: AppStrings.identityProof.tr(),
                  urls: documentUrls,
                ),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _DocImage(
                        url: _previewUrl,
                        fallbackAsset: AppAssets.docProof,
                        width: 64,
                        height: 48,
                        fit: BoxFit.cover,
                        iconSize: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.view.tr(),
                          style: AppTextStyles.style(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppIcon(
                          AppAssets.chevronRight,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
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

class _DocumentViewerDialog extends StatefulWidget {
  const _DocumentViewerDialog({
    required this.title,
    required this.urls,
    required this.fallbackAsset,
  });

  final String title;
  final List<String> urls;
  final String fallbackAsset;

  @override
  State<_DocumentViewerDialog> createState() => _DocumentViewerDialogState();
}

class _DocumentViewerDialogState extends State<_DocumentViewerDialog> {
  late final PageController _pageController;
  int _index = 0;
  bool _imageFailed = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String get _currentUrl => widget.urls[_index];

  String _sideLabel(int i) {
    if (widget.urls.length < 2) return '';
    if (i == 0) return AppStrings.frontSide.tr();
    if (i == 1) return AppStrings.backSide.tr();
    return '${i + 1}/${widget.urls.length}';
  }

  @override
  Widget build(BuildContext context) {
    final side = _sideLabel(_index);

    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.style(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (side.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          side,
                          style: AppTextStyles.style(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  behavior: HitTestBehavior.opaque,
                  child: const Icon(
                    Icons.close,
                    size: 22,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 320,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.urls.length,
                onPageChanged: (i) {
                  setState(() {
                    _index = i;
                    _imageFailed = false;
                  });
                },
                itemBuilder: (_, i) {
                  final url = widget.urls[i];
                  if (_isPdfUrl(url) || _isLikelyDocumentFile(url)) {
                    return _FilePlaceholder(
                      isPdf: _isPdfUrl(url),
                      onOpen: () => _openExternalDocument(url),
                    );
                  }
                  return InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: _NetworkOrFallbackImage(
                      url: url,
                      fallbackAsset: widget.fallbackAsset,
                      onFailed: () {
                        if (mounted && _index == i) {
                          setState(() => _imageFailed = true);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            if (widget.urls.length > 1) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.urls.length, (i) {
                  final active = i == _index;
                  return Container(
                    width: active ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
            if (_imageFailed ||
                _isPdfUrl(_currentUrl) ||
                _isLikelyDocumentFile(_currentUrl)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _openExternalDocument(_currentUrl),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    AppStrings.openDocument.tr(),
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NetworkOrFallbackImage extends StatefulWidget {
  const _NetworkOrFallbackImage({
    required this.url,
    required this.fallbackAsset,
    required this.onFailed,
  });

  final String url;
  final String fallbackAsset;
  final VoidCallback onFailed;

  @override
  State<_NetworkOrFallbackImage> createState() =>
      _NetworkOrFallbackImageState();
}

class _NetworkOrFallbackImageState extends State<_NetworkOrFallbackImage> {
  bool _notified = false;

  void _notifyFailed() {
    if (_notified) return;
    _notified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onFailed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isHttp = widget.url.startsWith('http://') ||
        widget.url.startsWith('https://');

    if (!isHttp) {
      _notifyFailed();
      return _Fallback(asset: widget.fallbackAsset, size: 72);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        widget.url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, error, stackTrace) {
          _notifyFailed();
          return ColoredBox(
            color: AppColors.peachLight,
            child: _Fallback(asset: widget.fallbackAsset, size: 72),
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilePlaceholder extends StatelessWidget {
  const _FilePlaceholder({required this.isPdf, required this.onOpen});

  final bool isPdf;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.peachLight,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            Text(
              isPdf
                  ? AppStrings.pdfDocument.tr()
                  : AppStrings.openDocument.tr(),
              style: AppTextStyles.style(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
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
    required this.fallbackAsset,
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

  void _onView(BuildContext context) {
    _viewDocuments(
      context,
      title: title,
      urls: [if (previewUrl != null) previewUrl!],
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
