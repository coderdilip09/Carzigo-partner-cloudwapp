import 'package:carzigo_partner/utils/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Native in-app review (iOS / Android) with a store-listing fallback.
class AppRatingService {
  AppRatingService._();

  static final AppRatingService instance = AppRatingService._();

  static const _promptedAtKey = 'in_app_review_prompted_at';
  static const _cooldown = Duration(days: 30);

  final InAppReview _review = InAppReview.instance;

  /// Profile "Rate App" — always tries the native sheet, then the store.
  Future<void> rateFromMenu() async {
    try {
      if (await _review.isAvailable()) {
        await _review.requestReview();
        await _markPrompted();
        return;
      }
    } catch (e, st) {
      debugPrint('In-app review request failed: $e\n$st');
    }
    await openStoreListing();
  }

  /// After a happy moment (job completed). Respects cooldown.
  Future<void> maybePrompt() async {
    if (!await _canPrompt()) return;
    try {
      if (await _review.isAvailable()) {
        await _review.requestReview();
        await _markPrompted();
      }
    } catch (e, st) {
      debugPrint('In-app review prompt failed: $e\n$st');
    }
  }

  Future<void> openStoreListing() async {
    try {
      final appStoreId = AppConstants.appStoreId;
      await _review.openStoreListing(
        appStoreId: appStoreId.isEmpty ? null : appStoreId,
      );
      return;
    } catch (e, st) {
      debugPrint('Open store listing failed: $e\n$st');
    }

    final uri = Uri.parse(AppConstants.storeListingUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e, st) {
      debugPrint('Open store URL failed: $e\n$st');
    }
  }

  Future<bool> _canPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getInt(_promptedAtKey);
    if (raw == null) return true;
    final last = DateTime.fromMillisecondsSinceEpoch(raw);
    return DateTime.now().difference(last) >= _cooldown;
  }

  Future<void> _markPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_promptedAtKey, DateTime.now().millisecondsSinceEpoch);
  }
}
