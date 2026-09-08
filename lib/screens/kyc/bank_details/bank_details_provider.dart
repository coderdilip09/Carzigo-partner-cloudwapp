import 'dart:io';

import 'package:carzigo_partner/screens/kyc/kyc_review/kyc_review_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_status.dart';
import 'package:carzigo_partner/services/image_pick_service/image_pick_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BankDetailsProvider extends BaseProvider {
  final formKey = GlobalKey<FormState>();

  String holderName = '';
  String accountNumber = '';
  String ifsc = '';
  File? chequeImage;
  bool submitted = false;

  void setHolderName(String value) {
    holderName = value;
  }

  void setAccountNumber(String value) {
    accountNumber = value;
  }

  void setIfsc(String value) {
    ifsc = value;
  }

  Future<void> pickCheque(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null) return;
    chequeImage = file;
    safeNotifyListeners();
  }

  String? validateHolderName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.accountHolderRequired.tr();
    }
    return null;
  }

  String? validateAccountNumber(String? value) {
    final account = value?.trim() ?? '';
    if (account.isEmpty) {
      return AppStrings.accountNumberRequired.tr();
    }
    if (!RegExp(r'^\d{9,18}$').hasMatch(account)) {
      return AppStrings.accountNumberInvalid.tr();
    }
    return null;
  }

  String? validateIfsc(String? value) {
    final code = (value ?? '').trim().toUpperCase();
    if (code.isEmpty) {
      return AppStrings.ifscRequired.tr();
    }
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(code)) {
      return AppStrings.ifscInvalid.tr();
    }
    return null;
  }

  void tapOnSubmit() {
    submitted = true;
    final fieldsOk = formKey.currentState?.validate() ?? false;
    safeNotifyListeners();
    if (!fieldsOk) return;
    if (chequeImage == null) {
      AppToast.error(AppStrings.chequeImageRequired.tr());
      return;
    }
    KycStatus.markBankDone();
    AppNavigation.to(const KycReviewScreen());
  }
}
