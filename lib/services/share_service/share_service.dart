import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  ShareService._();

  static final ShareService instance = ShareService._();

  bool _busy = false;

  Future<bool> shareText(
    String text, {
    String? subject,
    BuildContext? context,
  }) async {
    final payload = text.trim();
    if (payload.isEmpty || _busy) return false;
    _busy = true;

    // Capture origin before the loader covers the button.
    final origin = _shareOrigin(context);
    final loader = _showBlockingLoader(context);

    try {
      // Let the loader paint before opening the native sheet.
      await Future<void>.delayed(Duration.zero);

      final shareFuture = SharePlus.instance.share(
        ShareParams(
          text: payload,
          subject: subject,
          sharePositionOrigin: origin,
        ),
      );

      // Keep UI blocked until the sheet appears or share fails/returns.
      // On iOS the Future often completes only after dismiss, so also clear
      // the loader after a short wait once the sheet should be visible.
      await Future.any([
        shareFuture,
        Future<void>.delayed(const Duration(milliseconds: 700)),
      ]);
      _removeLoader(loader);

      await shareFuture;
      return true;
    } catch (e, st) {
      debugPrint('Share text failed: $e\n$st');
      return false;
    } finally {
      _removeLoader(loader);
      _busy = false;
    }
  }

  Future<bool> shareApp({BuildContext? context}) {
    return shareText(
      AppStrings.shareAppText.tr(),
      subject: AppStrings.shareAppSubject.tr(),
      context: context,
    );
  }

  OverlayEntry? _showBlockingLoader(BuildContext? context) {
    if (context == null || !context.mounted) return null;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return null;

    final entry = OverlayEntry(
      builder: (_) => PopScope(
        canPop: false,
        child: AbsorbPointer(
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.35),
            child: const Center(
              child: SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    return entry;
  }

  void _removeLoader(OverlayEntry? entry) {
    if (entry == null || !entry.mounted) return;
    try {
      entry.remove();
    } catch (_) {}
  }

  Rect? _shareOrigin(BuildContext? context) {
    final fromContext = _originFromContext(context);
    if (fromContext != null) return fromContext;
    if (kIsWeb) return null;
    if (defaultTargetPlatform != TargetPlatform.iOS) return null;
    return _fallbackOrigin();
  }

  Rect? _originFromContext(BuildContext? context) {
    if (context == null || !context.mounted) return null;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final origin = box.localToGlobal(Offset.zero);
    final size = box.size;
    final width = size.width <= 0 ? 1.0 : size.width;
    final height = size.height <= 0 ? 1.0 : size.height;
    return Rect.fromLTWH(origin.dx, origin.dy, width, height);
  }

  Rect _fallbackOrigin() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    return Rect.fromLTWH(size.width / 2 - 1, size.height / 4, 2, 2);
  }
}
