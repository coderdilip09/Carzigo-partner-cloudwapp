import 'package:carzigo_partner/models/referral_data_model.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReferEarnProvider extends BaseProvider {
  ReferEarnProvider() {
    load();
  }

  ReferralDataModel? data;
  bool isLoading = false;

  List<ReferredCustomerDataModel> get customers => data?.customers ?? [];
  List<ReferralHowItWorksStepModel> get howItWorks => data?.howItWorks ?? [];

  String get code => data?.code ?? '';
  String get link => data?.link ?? '';
  String get rewardLabel => data?.rewardLabel ?? '';
  String get totalReferred => data?.totalReferredLabel ?? '00';
  String get onboarded => data?.onboardedLabel ?? '00';
  String get completedFirstWash => data?.completedFirstWashLabel ?? '00';

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
