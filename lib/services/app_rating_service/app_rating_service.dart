import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_constants.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
  bool _busy = false;

  /// Profile "Rate App". Five stars are selected. A loader blocks extra taps.
  Future<void> rateFromMenu(BuildContext context) async {
    if (_busy) return;
    _busy = true;
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _RateAppDialog(onSubmit: _requestOrOpenStore),
      );
    } finally {
      _busy = false;
    }
  }

  Future<void> _requestOrOpenStore() async {
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

class _RateAppDialog extends StatefulWidget {
  const _RateAppDialog({required this.onSubmit});

  final Future<void> Function() onSubmit;

  @override
  State<_RateAppDialog> createState() => _RateAppDialogState();
}

class _RateAppDialogState extends State<_RateAppDialog> {
  static const _filled = Color(0xFFFFB800);
  static const _empty = Color(0xFFD9D9D9);

  int _rating = 5;
  bool _submitting = false;

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await widget.onSubmit();
    } finally {
      if (mounted) AppNavigation.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.rateApp.tr(),
                    style: AppTextStyles.style(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.rateAppSubtitle.tr(),
                    style: AppTextStyles.style(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return GestureDetector(
                        onTap: _submitting
                            ? null
                            : () => setState(() => _rating = star),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.only(right: i == 4 ? 0 : 6),
                          child: Icon(
                            Icons.star,
                            size: 32,
                            color: star <= _rating ? _filled : _empty,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(AppStrings.submit.tr()),
                    ),
                  ),
                ],
              ),
            ),
            if (_submitting)
              const Positioned.fill(
                child: AbsorbPointer(
                  child: ColoredBox(color: Color(0x66FFFFFF)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
