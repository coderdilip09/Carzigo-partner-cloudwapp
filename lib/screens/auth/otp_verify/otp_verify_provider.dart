import 'dart:async';

import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/auth_route_service/auth_route_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/services/prefs_service/prefs_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class OtpVerifyProvider extends BaseProvider {
  OtpVerifyProvider({
    required this.phone,
    required this.countryCode,
    this.resendAfterSeconds = 45,
    this.isChangeNumber = false,
  }) : secondsLeft = resendAfterSeconds;

  final String phone;
  final String countryCode;
  final int resendAfterSeconds;
  final bool isChangeNumber;
  String otp = '';
  String? otpError;
  bool isLoading = false;
  int secondsLeft;
  Timer? _timer;

  void setOtp(String value) {
    otp = value;
    if (otpError != null) {
      otpError = null;
    }
    safeNotifyListeners();
  }

  void startTimer([int? seconds]) {
    _timer?.cancel();
    secondsLeft = seconds ?? resendAfterSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft > 0) {
        secondsLeft--;
        safeNotifyListeners();
      } else {
        t.cancel();
      }
    });
  }

  String get formattedTime {
    final m = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool _validateOtp() {
    final digits = otp.trim();
    if (digits.isEmpty) {
      otpError = AppStrings.otpRequired.tr();
      safeNotifyListeners();
      return false;
    }
    if (digits.length != 6) {
      otpError = AppStrings.otpInvalid.tr();
      safeNotifyListeners();
      return false;
    }
    otpError = null;
    safeNotifyListeners();
    return true;
  }

  Future<void> tapOnVerify() async {
    if (isLoading) return;
    if (!_validateOtp()) return;

    if (isChangeNumber) {
      AppToast.success(AppStrings.phoneUpdated.tr());
      AppNavigation.back(true);
      return;
    }

    isLoading = true;
    safeNotifyListeners();

    final res = await Api.verifyOtp(
      countryCode: countryCode,
      mobile: phone,
      otp: otp.trim(),
    );

    if (!res.isSuccess || res.data?.token == null) {
      isLoading = false;
      safeNotifyListeners();
      AppToast.error(res.message ?? AppStrings.otpInvalid.tr());
      return;
    }

    await PrefsService().saveAuth(res.data!);
    AppToast.success(res.message ?? AppStrings.otpVerified.tr());
    final next = await AuthRouteService.resolveLoggedIn(auth: res.data);
    isLoading = false;
    safeNotifyListeners();
    AppNavigation.offAll(next);
  }

  Future<void> tapOnResend() async {
    if (secondsLeft != 0 || isLoading || isChangeNumber) return;

    isLoading = true;
    safeNotifyListeners();

    final res = await Api.resendOtp(countryCode: countryCode, mobile: phone);

    isLoading = false;
    safeNotifyListeners();

    if (!res.isSuccess) {
      AppToast.error(res.message ?? AppStrings.otpInvalid.tr());
      return;
    }

    startTimer(res.data?.resendAfterSeconds ?? resendAfterSeconds);
    AppToast.success(res.message ?? AppStrings.otpResent.tr());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
