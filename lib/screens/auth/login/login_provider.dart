import 'package:carzigo_partner/screens/auth/otp_verify/otp_verify_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_status.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginProvider extends BaseProvider {
  String phone = '';
  String? phoneError;
  bool isLoading = false;
  Country country = CountryParser.parseCountryCode('IN');

  String get formattedCountryCode {
    final code = country.phoneCode.replaceAll('+', '');
    return '+$code';
  }

  void setPhone(String value) {
    phone = value;
    if (phoneError != null) {
      phoneError = null;
    }
    safeNotifyListeners();
  }

  void setCountry(Country value) {
    country = value;
    if (phoneError != null) {
      phoneError = null;
    }
    safeNotifyListeners();
  }

  bool _validatePhone() {
    final digits = phone.trim();
    if (digits.isEmpty) {
      phoneError = AppStrings.phoneRequired.tr();
      safeNotifyListeners();
      return false;
    }
    final isIndia = country.countryCode == 'IN';
    if (isIndia && digits.length != 10) {
      phoneError = AppStrings.phoneInvalid.tr();
      safeNotifyListeners();
      return false;
    }
    if (!isIndia && digits.length < 6) {
      phoneError = AppStrings.phoneInvalid.tr();
      safeNotifyListeners();
      return false;
    }
    phoneError = null;
    safeNotifyListeners();
    return true;
  }

  Future<void> tapOnSubmit() async {
    if (isLoading) return;
    if (!_validatePhone()) return;

    isLoading = true;
    safeNotifyListeners();

    final res = await Api.sendOtp(
      countryCode: formattedCountryCode,
      mobile: phone.trim(),
    );

    isLoading = false;
    safeNotifyListeners();

    if (!res.isSuccess) {
      AppToast.error(res.message ?? AppStrings.phoneInvalid.tr());
      return;
    }

    AppToast.success(res.message ?? AppStrings.otpResent.tr());
    KycStatus.resetForNewNumber();
    AppNavigation.to(
      OtpVerifyScreen(
        phone: phone.trim(),
        countryCode: formattedCountryCode,
        resendAfterSeconds: res.data?.resendAfterSeconds ?? 45,
        expiresInSeconds: res.data?.expiresInSeconds ?? 600,
      ),
    );
  }
}
