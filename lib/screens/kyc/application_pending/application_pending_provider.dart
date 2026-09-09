import 'package:carzigo_partner/screens/dashboard/dashboard_screen.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ApplicationPendingProvider extends BaseProvider {
  bool isLoading = false;

  Future<void> tapOnCheckStatus() async {
    if (isLoading) return;

    isLoading = true;
    safeNotifyListeners();

    try {
      final res = await Api.getKycAccountStatus();
      if (!res.isSuccess || res.data == null) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }

      if (res.data!.isApproved) {
        AppNavigation.offAll(const DashboardScreen());
        return;
      }

      AppToast.success(res.data!.message ?? res.message ?? '');
    } catch (e, st) {
      debugPrint('Get KYC account status failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }
}
