import 'dart:async';

import 'package:carzigo_partner/screens/auth/create_profile/create_profile_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/base_provider.dart';

class OtpVerifyProvider extends BaseProvider {
  OtpVerifyProvider({required this.phone});

  final String phone;
  int secondsLeft = 45;
  Timer? _timer;

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

  void tapOnVerify() {
    AppNavigation.to(const CreateProfileScreen());
  }

  void tapOnResend() {
    if (secondsLeft == 0) startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
