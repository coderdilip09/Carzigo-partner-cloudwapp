import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  ShareService._();

  static final ShareService instance = ShareService._();

  Future<bool> shareText(String text, {String? subject}) async {
    final payload = text.trim();
    if (payload.isEmpty) return false;
    try {
      final result = await SharePlus.instance.share(
        ShareParams(text: payload, subject: subject),
      );
      return result.status != ShareResultStatus.unavailable;
    } catch (e, st) {
      debugPrint('Share text failed: $e\n$st');
      return false;
    }
  }

  Future<bool> shareApp() {
    return shareText(
      AppStrings.shareAppText.tr(),
      subject: AppStrings.shareAppSubject.tr(),
    );
  }
}
