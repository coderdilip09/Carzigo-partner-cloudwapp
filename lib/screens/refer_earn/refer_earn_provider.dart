import 'package:carzigo_partner/models/referral_data_model.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ReferralSummaryPeriod { month, week }

class ReferEarnProvider extends BaseProvider {
  ReferEarnProvider() {
    load();
  }

  ReferralDataModel? data;
  bool isLoading = false;
  ReferralSummaryPeriod summaryPeriod = ReferralSummaryPeriod.month;

  List<ReferredCustomerDataModel> get customers => data?.customers ?? [];
  List<ReferredCustomerDataModel> get previewCustomers =>
      customers.take(3).toList();
  List<ReferralHowItWorksStepModel> get howItWorks => data?.howItWorks ?? [];

  String get code => data?.code ?? '';
  String get link => data?.link ?? '';
  String get rewardLabel => data?.rewardLabel ?? '';

  ReferralStatsModel? get _activeStats =>
      summaryPeriod == ReferralSummaryPeriod.week
      ? data?.weekStats
      : data?.stats;

  String get summaryPeriodLabel =>
      summaryPeriod == ReferralSummaryPeriod.week
      ? AppStrings.thisWeek
      : AppStrings.thisMonth;

  String get totalReferred =>
      ReferralDataModel.pad(_activeStats?.totalReferred);
  String get onboarded => ReferralDataModel.pad(_activeStats?.onboarded);
  String get completedFirstWash =>
      ReferralDataModel.pad(_activeStats?.completedFirstWash);

  void setSummaryPeriod(ReferralSummaryPeriod period) {
    if (summaryPeriod == period) return;
    summaryPeriod = period;
    safeNotifyListeners();
  }

  Future<void> load() async {
    isLoading = true;
    safeNotifyListeners();

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
}
