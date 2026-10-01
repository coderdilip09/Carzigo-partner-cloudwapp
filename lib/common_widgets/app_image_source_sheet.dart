import 'package:carzigo_partner/common_widgets/app_bottom_sheet.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum AppImageSourceChoice { camera, gallery }

enum AppDocumentSourceChoice { camera, gallery, file }

/// Shows Take photo / Gallery sheet and returns the user's choice.
/// Never opens the system camera/gallery by itself.
Future<AppImageSourceChoice?> pickImageSourceChoice(
  BuildContext context, {
  bool useRootNavigator = true,
}) {
  return showAppBottomSheet<AppImageSourceChoice>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: true,
    enableDrag: false,
    barrierColor: Colors.black54,
    topRadius: 24,
    builder: (_) => const _ImageSourceSheetBody(),
  );
}

/// Shows the sheet, then runs camera/gallery only after an explicit choice.
Future<void> showImageSourceSheet(
  BuildContext context, {
  required Future<void> Function() onCamera,
  required Future<void> Function() onGallery,
  bool useRootNavigator = true,
}) async {
  final choice = await pickImageSourceChoice(
    context,
    useRootNavigator: useRootNavigator,
  );

  if (!context.mounted || choice == null) return;

  await Future<void>.delayed(const Duration(milliseconds: 300));
  if (!context.mounted) return;

  switch (choice) {
    case AppImageSourceChoice.camera:
      await onCamera();
    case AppImageSourceChoice.gallery:
      await onGallery();
  }
}

Future<AppDocumentSourceChoice?> pickDocumentSourceChoice(
  BuildContext context, {
  bool useRootNavigator = true,
}) {
  return showAppBottomSheet<AppDocumentSourceChoice>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: true,
    enableDrag: false,
    barrierColor: Colors.black54,
    topRadius: 24,
    builder: (_) => const _DocumentSourceSheetBody(),
  );
}

/// Camera / Gallery / File (PDF + images) picker sheet.
Future<void> showDocumentSourceSheet(
  BuildContext context, {
  required Future<void> Function() onCamera,
  required Future<void> Function() onGallery,
  required Future<void> Function() onFile,
  bool useRootNavigator = true,
}) async {
  final choice = await pickDocumentSourceChoice(
    context,
    useRootNavigator: useRootNavigator,
  );

  if (!context.mounted || choice == null) return;

  await Future<void>.delayed(const Duration(milliseconds: 300));
  if (!context.mounted) return;

  switch (choice) {
    case AppDocumentSourceChoice.camera:
      await onCamera();
    case AppDocumentSourceChoice.gallery:
      await onGallery();
    case AppDocumentSourceChoice.file:
      await onFile();
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SourceOptionTile extends StatelessWidget {
  const _SourceOptionTile({
    required this.leading,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final Widget leading;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.peach,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.style(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceSheetBody extends StatefulWidget {
  const _ImageSourceSheetBody();

  @override
  State<_ImageSourceSheetBody> createState() => _ImageSourceSheetBodyState();
}

class _ImageSourceSheetBodyState extends State<_ImageSourceSheetBody> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  void _select(AppImageSourceChoice choice) {
    if (!_ready || !mounted) return;
    Navigator.of(context).pop(choice);
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetBody(
      scrollable: false,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: AbsorbPointer(
        absorbing: !_ready,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            Text(
              AppStrings.choosePhoto.tr(),
              style: AppTextStyles.style(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _SourceOptionTile(
              leading: AppIcon(AppAssets.camera, color: AppColors.primary),
              label: AppStrings.takePhoto.tr(),
              onTap: () => _select(AppImageSourceChoice.camera),
            ),
            const SizedBox(height: 10),
            _SourceOptionTile(
              leading: AppIcon(AppAssets.folder, color: AppColors.primary),
              label: AppStrings.chooseFromGallery.tr(),
              onTap: () => _select(AppImageSourceChoice.gallery),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  if (!_ready) return;
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppStrings.cancel.tr(),
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentSourceSheetBody extends StatefulWidget {
  const _DocumentSourceSheetBody();

  @override
  State<_DocumentSourceSheetBody> createState() =>
      _DocumentSourceSheetBodyState();
}

class _DocumentSourceSheetBodyState extends State<_DocumentSourceSheetBody> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  void _select(AppDocumentSourceChoice choice) {
    if (!_ready || !mounted) return;
    Navigator.of(context).pop(choice);
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetBody(
      scrollable: false,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: AbsorbPointer(
        absorbing: !_ready,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            Text(
              AppStrings.uploadDocument.tr(),
              style: AppTextStyles.style(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _SourceOptionTile(
              leading: AppIcon(AppAssets.camera, color: AppColors.primary),
              label: AppStrings.takePhoto.tr(),
              onTap: () => _select(AppDocumentSourceChoice.camera),
            ),
            const SizedBox(height: 10),
            _SourceOptionTile(
              leading: AppIcon(AppAssets.folder, color: AppColors.primary),
              label: AppStrings.chooseFromGallery.tr(),
              subtitle: AppStrings.imageFormatsHint.tr(),
              onTap: () => _select(AppDocumentSourceChoice.gallery),
            ),
            const SizedBox(height: 10),
            _SourceOptionTile(
              leading: const Icon(
                Icons.picture_as_pdf_outlined,
                color: AppColors.primary,
              ),
              label: AppStrings.choosePdfOrFile.tr(),
              subtitle: AppStrings.documentFormatsHint.tr(),
              onTap: () => _select(AppDocumentSourceChoice.file),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  if (!_ready) return;
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppStrings.cancel.tr(),
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
