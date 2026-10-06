import 'package:carzigo_partner/models/referral_data_model.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/share_service/share_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ReferralSummaryPeriod { week, month, year }

class ReferEarnProvider extends BaseProvider {
  ReferEarnProvider() {
    load();
  }

  ReferralDataModel? data;
  bool isLoading = true;
  ReferralSummaryPeriod summaryPeriod = ReferralSummaryPeriod.month;

  List<ReferredCustomerDataModel> get customers => data?.customers ?? [];
  List<ReferralHowItWorksStepModel> get howItWorks => data?.howItWorks ?? [];

  String get code => data?.code ?? '';
  String get link => data?.link ?? '';
  String get rewardLabel => data?.rewardLabel ?? '';

  ReferralStatsModel get _activeStats {
    switch (summaryPeriod) {
      case ReferralSummaryPeriod.week:
        return data?.weekStats ?? const ReferralStatsModel();
      case ReferralSummaryPeriod.year:
        return data?.yearStats ?? const ReferralStatsModel();
      case ReferralSummaryPeriod.month:
        return data?.stats ?? const ReferralStatsModel();
    }
  }

  String get summaryPeriodLabel {
    switch (summaryPeriod) {
      case ReferralSummaryPeriod.week:
        return AppStrings.thisWeek;
      case ReferralSummaryPeriod.year:
        return AppStrings.thisYear;
      case ReferralSummaryPeriod.month:
        return AppStrings.thisMonth;
    }
  }

  String get totalReferred =>
      ReferralDataModel.pad(_activeStats.totalReferred);
  String get onboarded => ReferralDataModel.pad(_activeStats.onboarded);
  String get completedFirstWash =>
      ReferralDataModel.pad(_activeStats.completedFirstWash);

  List<ReferredCustomerDataModel> get previewCustomers =>
      customers.take(3).toList();

  void setSummaryPeriod(ReferralSummaryPeriod period) {
    if (summaryPeriod == period) return;
    summaryPeriod = period;
    safeNotifyListeners();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      safeNotifyListeners();
    }

    try {
      final res = await Api.getReferral();
      if (!res.isSuccess || res.data == null) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }
      data = res.data;
    } catch (e, st) {
      debugPrint('Get referrals failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  void copyCode() {
    if (code.isEmpty) return;
    Clipboard.setData(ClipboardData(text: code));
    AppToast.success(AppStrings.referralCodeCopied.tr());
  }

  void copyLink() {
    if (link.isEmpty) return;
    Clipboard.setData(ClipboardData(text: link));
    AppToast.success(AppStrings.referralLinkCopied.tr());
  }

  String get shareText {
    final reward = rewardLabel.isEmpty ? '₹300' : rewardLabel;
    final parts = <String>[
      'Join Carzigo with my referral code $code and complete your first wash.',
      'I earn $reward after your first wash.',
    ];
    if (link.isNotEmpty) parts.add(link);
    return parts.join(' ');
  }

  Future<void> shareNow([BuildContext? context]) async {
    if (code.isEmpty && link.isEmpty) return;
    final shared = await ShareService.instance.shareText(
      shareText,
      subject: AppStrings.shareAppSubject.tr(),
      context: context,
    );
    if (!shared) {
      await Clipboard.setData(ClipboardData(text: shareText));
      AppToast.success(AppStrings.referralLinkCopied.tr());
    }
  }
}
