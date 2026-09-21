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
  return showModalBottomSheet<AppImageSourceChoice>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: false,
    enableDrag: false,
    isDismissible: true,
    backgroundColor: AppColors.white,
    barrierColor: Colors.black54,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
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
  return showModalBottomSheet<AppDocumentSourceChoice>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: false,
    enableDrag: false,
    isDismissible: true,
    backgroundColor: AppColors.white,
    barrierColor: Colors.black54,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
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
    return SafeArea(
      child: AbsorbPointer(
        absorbing: !_ready,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: AppIcon(AppAssets.folder, color: AppColors.primary),
                title: Text(
                  AppStrings.chooseFromGallery.tr(),
                  style: AppTextStyles.style(fontWeight: FontWeight.w600),
                ),
                onTap: () => _select(AppImageSourceChoice.gallery),
              ),
              ListTile(
                leading: AppIcon(AppAssets.camera, color: AppColors.primary),
                title: Text(
                  AppStrings.takePhoto.tr(),
                  style: AppTextStyles.style(fontWeight: FontWeight.w600),
                ),
                onTap: () => _select(AppImageSourceChoice.camera),
              ),
              ListTile(
                title: Text(
                  AppStrings.cancel.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style(color: AppColors.textSecondary),
                ),
                onTap: () {
                  if (!_ready) return;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
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
    return SafeArea(
      child: AbsorbPointer(
        absorbing: !_ready,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: AppIcon(AppAssets.folder, color: AppColors.primary),
                title: Text(
                  AppStrings.chooseFromGallery.tr(),
                  style: AppTextStyles.style(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  AppStrings.imageFormatsHint.tr(),
                  style: AppTextStyles.style(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () => _select(AppDocumentSourceChoice.gallery),
              ),
              ListTile(
                leading: AppIcon(AppAssets.camera, color: AppColors.primary),
                title: Text(
                  AppStrings.takePhoto.tr(),
                  style: AppTextStyles.style(fontWeight: FontWeight.w600),
                ),
                onTap: () => _select(AppDocumentSourceChoice.camera),
              ),
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: AppColors.primary,
                ),
                title: Text(
                  AppStrings.choosePdfOrFile.tr(),
                  style: AppTextStyles.style(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  AppStrings.documentFormatsHint.tr(),
                  style: AppTextStyles.style(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                onTap: () => _select(AppDocumentSourceChoice.file),
              ),
              ListTile(
                title: Text(
                  AppStrings.cancel.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style(color: AppColors.textSecondary),
                ),
                onTap: () {
                  if (!_ready) return;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
