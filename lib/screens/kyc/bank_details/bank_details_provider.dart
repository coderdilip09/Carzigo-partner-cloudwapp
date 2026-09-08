import 'dart:io';

import 'package:carzigo_partner/screens/kyc/kyc_review/kyc_review_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_status.dart';
import 'package:carzigo_partner/services/image_pick_service/image_pick_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

class BankDetailsProvider extends BaseProvider {
  String holderName = '';
  String accountNumber = '';
  String ifsc = '';
  File? chequeImage;

  void setHolderName(String value) {
    holderName = value;
    safeNotifyListeners();
  }

  void setAccountNumber(String value) {
    accountNumber = value;
    safeNotifyListeners();
  }

  void setIfsc(String value) {
    ifsc = value;
    safeNotifyListeners();
  }

  Future<void> pickCheque(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null) return;
    chequeImage = file;
    safeNotifyListeners();
  }

  bool _isValidIfsc(String value) {
    return RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value);
  }

  bool _validate() {
    if (holderName.trim().isEmpty) {
      AppToast.error(AppStrings.accountHolderRequired.tr());
      return false;
    }

    final account = accountNumber.trim();
    if (account.isEmpty) {
      AppToast.error(AppStrings.accountNumberRequired.tr());
      return false;
    }
    if (!RegExp(r'^\d{9,18}$').hasMatch(account)) {
      AppToast.error(AppStrings.accountNumberInvalid.tr());
      return false;
    }

    final code = ifsc.trim().toUpperCase();
    if (code.isEmpty) {
      AppToast.error(AppStrings.ifscRequired.tr());
      return false;
    }
    if (!_isValidIfsc(code)) {
      AppToast.error(AppStrings.ifscInvalid.tr());
      return false;
    }

    if (chequeImage == null) {
      AppToast.error(AppStrings.chequeImageRequired.tr());
      return false;
    }

    return true;
  }

  void tapOnSubmit() {
    if (!_validate()) return;
    KycStatus.markBankDone();
    AppNavigation.to(const KycReviewScreen());
  }
}
