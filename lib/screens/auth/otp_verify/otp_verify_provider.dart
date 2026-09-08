import 'dart:async';

import 'package:carzigo_partner/screens/auth/create_profile/create_profile_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class OtpVerifyProvider extends BaseProvider {
  OtpVerifyProvider({
    required this.phone,
    this.isChangeNumber = false,
  });

  final String phone;
  final bool isChangeNumber;
  String otp = '';
  String? otpError;
  int secondsLeft = 45;
  Timer? _timer;

  void setOtp(String value) {
    otp = value;
    if (otpError != null) {
      otpError = null;
    }
    safeNotifyListeners();
  }

  void startTimer() {
    _timer?.cancel();
    secondsLeft = 45;
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

  void tapOnVerify() {
    if (!_validateOtp()) return;
    if (isChangeNumber) {
      AppToast.success(AppStrings.phoneUpdated.tr());
      AppNavigation.back(true);
      return;
    }
    AppToast.success(AppStrings.otpVerified.tr());
    AppNavigation.to(const CreateProfileScreen());
  }

  void tapOnResend() {
    if (secondsLeft != 0) return;
    startTimer();
    AppToast.success(AppStrings.otpResent.tr());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
