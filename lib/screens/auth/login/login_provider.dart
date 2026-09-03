import 'package:carzigo_partner/screens/auth/otp_verify/otp_verify_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:carzigo_partner/utils/mock_data.dart';
import 'package:country_picker/country_picker.dart';

class LoginProvider extends BaseProvider {
  String phone = '';
  Country country = CountryParser.parseCountryCode('IN');

  void setPhone(String value) {
    phone = value;
    safeNotifyListeners();
  }

  void setCountry(Country value) {
    country = value;
    safeNotifyListeners();
  }

  void tapOnSubmit() {
    AppNavigation.to(
      OtpVerifyScreen(phone: phone.isEmpty ? MockData.demoPhone : phone),
    );
  }
}
