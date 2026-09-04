import 'package:carzigo_partner/screens/auth/otp_verify/otp_verify_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';

class ChangeNumberProvider extends BaseProvider {
  String phone = '';
  String? phoneError;
  Country country = CountryParser.parseCountryCode('IN');

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

  Future<void> tapOnSendOtp() async {
    if (!_validatePhone()) return;

    final verified = await AppNavigation.to<bool>(
      OtpVerifyScreen(phone: phone.trim(), isChangeNumber: true),
    );
    if (verified == true) {
      AppNavigation.back(phone.trim());
    }
  }
}
