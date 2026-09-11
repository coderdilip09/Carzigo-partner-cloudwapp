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
    this.expiresInSeconds = 600,
    this.isChangeNumber = false,
  })  : resendSecondsLeft = resendAfterSeconds,
        expiresSecondsLeft = expiresInSeconds;

  final String phone;
  final String countryCode;
  final int resendAfterSeconds;
  final int expiresInSeconds;
  final bool isChangeNumber;
  String otp = '';
  String? otpError;
  bool isLoading = false;
  int resendSecondsLeft;
  int expiresSecondsLeft;
  Timer? _timer;

  /// e.g. 9876543210 → ******3210
  String get maskedPhone {
    final digits = phone.trim();
    if (digits.length <= 4) return digits;
    final last4 = digits.substring(digits.length - 4);
    return '${'*' * (digits.length - 4)}$last4';
  }

  String get maskedPhoneWithCode => '$countryCode $maskedPhone';

  void setOtp(String value) {
    otp = value;
    if (otpError != null) {
      otpError = null;
    }
    safeNotifyListeners();
  }

  void startTimers({int? resendSeconds, int? expiresSeconds}) {
    _timer?.cancel();
    resendSecondsLeft = resendSeconds ?? resendAfterSeconds;
    expiresSecondsLeft = expiresSeconds ?? expiresInSeconds;
    safeNotifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      var changed = false;
      if (resendSecondsLeft > 0) {
        resendSecondsLeft--;
        changed = true;
      }
      if (expiresSecondsLeft > 0) {
        expiresSecondsLeft--;
        changed = true;
      }
      if (changed) {
        safeNotifyListeners();
      }
      if (resendSecondsLeft <= 0 && expiresSecondsLeft <= 0) {
        t.cancel();
      }
    });
  }

  String get formattedResendTime => _formatMmSs(resendSecondsLeft);

  String get formattedExpiresTime => _formatMmSs(expiresSecondsLeft);

  String _formatMmSs(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
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
    if (resendSecondsLeft != 0 || isLoading || isChangeNumber) return;

    isLoading = true;
    safeNotifyListeners();

    final res = await Api.resendOtp(countryCode: countryCode, mobile: phone);

    isLoading = false;
    safeNotifyListeners();

    if (!res.isSuccess) {
      AppToast.error(res.message ?? AppStrings.otpInvalid.tr());
      return;
    }

    startTimers(
      resendSeconds: res.data?.resendAfterSeconds ?? resendAfterSeconds,
      expiresSeconds: res.data?.expiresInSeconds ?? expiresInSeconds,
    );
    AppToast.success(res.message ?? AppStrings.otpResent.tr());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
