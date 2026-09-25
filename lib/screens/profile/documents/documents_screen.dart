import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_bottom_sheet.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
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

Future<void> _showRequestChangeSheet(
  BuildContext context,
  DocumentsProvider provider,
) async {
  final reasonController = TextEditingController();
  var identity = false;
  var address = false;
  var bank = false;

  final submitted = await showAppBottomSheet<bool>(
    context: context,
    builder: (ctx) {
      return AppBottomSheetBody(
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.requestDocumentChange.tr(),
                  style: AppTextStyles.style(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: identity,
                  title: Text(AppStrings.identityProof.tr()),
                  onChanged: (v) => setModalState(() => identity = v ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: address,
                  title: Text(AppStrings.addressProof.tr()),
                  onChanged: (v) => setModalState(() => address = v ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: bank,
                  title: Text(AppStrings.bankDetails.tr()),
                  onChanged: (v) => setModalState(() => bank = v ?? false),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: AppStrings.docChangeReasonHint.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppSolidButton(
                  label: AppStrings.submit.tr(),
                  isLoading: provider.isRequestingChange,
                  onTap: () async {
                    final sections = <String>[
                      if (identity) 'identity',
                      if (address) 'address',
                      if (bank) 'bank',
                    ];
                    final ok = await provider.submitChangeRequest(
                      sections: sections,
                      reason: reasonController.text,
                    );
                    if (ok && context.mounted) {
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
              ],
            );
          },
        ),
      );
    },
  );

  reasonController.dispose();
  if (submitted == true) {
    // already refreshed via provider
  }
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
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    20 + appSystemBottomInset(context),
                  ),
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
                                      _DocInfoCard(
                                        title: 'Identity Proof',
                                        line1: 'Document type placeholder',
                                        line2: 'XXXX XXXX XXXX',
                                        isVerified: true,
                                        statusLabel: 'Verified',
                                        documentUrls: [],
                                      ),
                                      _DocInfoCard(
                                        title: 'Address Proof',
                                        line1: 'Document type placeholder',
                                        line2: 'XXXX XXXX XXXX',
                                        isVerified: true,
                                        statusLabel: 'Verified',
                                        documentUrls: [],
                                      ),
                                      _DocInfoCard(
                                        title: 'Bank Details',
                                        line1: 'Bank name placeholder',
                                        line2: 'XXXX XXXX XXXX',
                                        isVerified: true,
                                        statusLabel: 'Verified',
                                        documentUrls: [],
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
                                          _DocInfoCard(
                                            title: AppStrings.identityProof
                                                .tr(),
                                            line1: provider.identityDocLabel,
                                            line2: provider.identityMasked,
                                            isVerified:
                                                provider.isSectionVerified(
                                              'identity',
                                              provider.hasIdentity,
                                            ),
                                            isUploaded:
                                                provider.isSectionUploaded(
                                              'identity',
                                            ),
                                            statusLabel:
                                                provider.statusLabelFor(
                                              'identity',
                                              provider.hasIdentity,
                                            ),
                                            documentUrls:
                                                provider.identityDocumentUrls,
                                            showUpdate:
                                                provider.canUpdateSection(
                                              'identity',
                                            ),
                                            onUpdate:
                                                provider.tapOnEditIdentity,
                                            rejectReason: provider
                                                    .sectionStatus('identity')
                                                    ?.docsRejectReason ??
                                                provider
                                                    .sectionStatus('identity')
                                                    ?.permissionRejectReason,
                                          ),
                                        if (provider.hasAddress)
                                          _DocInfoCard(
                                            title: AppStrings.addressProof.tr(),
                                            line1: provider.addressDocLabel,
                                            line2: provider.addressMasked,
                                            isVerified:
                                                provider.isSectionVerified(
                                              'address',
                                              provider.hasAddress,
                                            ),
                                            isUploaded:
                                                provider.isSectionUploaded(
                                              'address',
                                            ),
                                            statusLabel:
                                                provider.statusLabelFor(
                                              'address',
                                              provider.hasAddress,
                                            ),
                                            documentUrls:
                                                provider.addressDocumentUrls,
                                            showUpdate:
                                                provider.canUpdateSection(
                                              'address',
                                            ),
                                            onUpdate: provider.tapOnEditAddress,
                                            rejectReason: provider
                                                    .sectionStatus('address')
                                                    ?.docsRejectReason ??
                                                provider
                                                    .sectionStatus('address')
                                                    ?.permissionRejectReason,
                                          ),
                                        if (provider.hasBank)
                                          _DocInfoCard(
                                            title: AppStrings.bankDetails.tr(),
                                            line1: provider.bankName,
                                            line2: provider.bankMasked,
                                            isVerified:
                                                provider.isSectionVerified(
                                              'bank',
                                              provider.hasBank,
                                            ),
                                            isUploaded:
                                                provider.isSectionUploaded(
                                              'bank',
                                            ),
                                            statusLabel:
                                                provider.statusLabelFor(
                                              'bank',
                                              provider.hasBank,
                                            ),
                                            documentUrls:
                                                provider.bankDocumentUrls,
                                            showUpdate:
                                                provider.canUpdateSection(
                                              'bank',
                                            ),
                                            onUpdate: provider.tapOnEditBank,
                                            rejectReason: provider
                                                    .sectionStatus('bank')
                                                    ?.docsRejectReason ??
                                                provider
                                                    .sectionStatus('bank')
                                                    ?.permissionRejectReason,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      if (provider.canSubmitDocumentChanges) ...[
                        AppSolidButton(
                          label: AppStrings.submitForVerification.tr(),
                          onTap: provider.tapOnSubmitDocumentChanges,
                          isLoading: provider.isSubmittingChange,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (provider.canRequestChange) ...[
                        AppSolidButton(
                          label: AppStrings.requestDocumentChange.tr(),
                          onTap: () => _showRequestChangeSheet(context, provider),
                          isLoading: provider.isRequestingChange,
                        ),
                        const SizedBox(height: 12),
                      ],
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

class _DocInfoCard extends StatelessWidget {
  const _DocInfoCard({
    required this.title,
    required this.line1,
    required this.line2,
    required this.isVerified,
    required this.statusLabel,
    required this.documentUrls,
    this.isUploaded = false,
    this.showUpdate = false,
    this.onUpdate,
    this.rejectReason,
  });

  final String title;
  final String line1;
  final String line2;
  final bool isVerified;
  final bool isUploaded;
  final String statusLabel;
  final List<String> documentUrls;
  final bool showUpdate;
  final VoidCallback? onUpdate;
  final String? rejectReason;

  @override
  Widget build(BuildContext context) {
    final statusColor = isVerified
        ? AppColors.verified
        : isUploaded
        ? AppColors.verified
        : AppColors.accentOrange;
    final statusIcon = isVerified
        ? Icons.check_circle_rounded
        : isUploaded
        ? Icons.cloud_done_rounded
        : Icons.schedule_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.peachCard,
        borderRadius: BorderRadius.circular(14),
        border: isUploaded
            ? Border.all(color: AppColors.verified.withValues(alpha: 0.35))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUploaded
                      ? AppColors.performanceCard
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
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
          if (isUploaded && !isVerified && showUpdate) ...[
            const SizedBox(height: 8),
            Text(
              AppStrings.docChangeUploadedNote.tr(),
              style: AppTextStyles.style(
                fontSize: 12,
                color: AppColors.verified,
              ),
            ),
          ],
          if (!isUploaded && (rejectReason ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              rejectReason!.trim(),
              style: AppTextStyles.style(
                fontSize: 12,
                color: AppColors.accentOrange,
              ),
            ),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      line1,
                      style: AppTextStyles.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      line2,
                      style: AppTextStyles.style(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showUpdate && onUpdate != null) ...[
                      GestureDetector(
                        onTap: onUpdate,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.update.tr(),
                              style: AppTextStyles.style(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    GestureDetector(
                      onTap: () => _viewDocuments(
                        context,
                        title: title,
                        urls: documentUrls,
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
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
                          const SizedBox(width: 2),
                          Icon(
                            Icons.visibility_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
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
                      color: active ? AppColors.primary : AppColors.border,
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
    final isHttp =
        widget.url.startsWith('http://') || widget.url.startsWith('https://');

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
