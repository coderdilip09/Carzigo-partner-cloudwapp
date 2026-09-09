import 'dart:io';

import 'package:carzigo_partner/screens/kyc/kyc_document_number.dart';
import 'package:carzigo_partner/screens/kyc/kyc_review/kyc_review_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_status.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/api_service/request_keys.dart';
import 'package:carzigo_partner/services/image_pick_service/image_pick_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BankDetailsProvider extends BaseProvider {
  BankDetailsProvider({this.loadSaved = false}) {
    if (loadSaved) loadSavedData();
  }

  final bool loadSaved;
  final formKey = GlobalKey<FormState>();
  final holderNameController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();

  File? chequeImage;
  String? chequeUrl;
  String _savedHolder = '';
  String _savedBankName = '';
  String _savedIfsc = '';
  String _savedAccount = '';
  bool submitted = false;
  bool isLoading = false;
  bool isFetching = false;

  bool get hasCheque =>
      chequeImage != null || (chequeUrl?.isNotEmpty ?? false);

  Future<void> loadSavedData() async {
    if (!loadSaved) return;

    isFetching = true;
    safeNotifyListeners();

    try {
      final res = await Api.getKycReview();
      final bank = res.data?.bank;
      if (!res.isSuccess || bank == null || !bank.isDone) {
        if (!res.isSuccess) {
          AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        }
        return;
      }

      holderNameController.text = bank.holderName ?? '';
      bankNameController.text = bank.bankName ?? '';
      ifscController.text = bank.ifsc ?? '';
      chequeUrl = bank.chequeUrl;
      final account = bank.accountNumber ?? bank.accountNumberMasked ?? '';
      if (account.isNotEmpty) {
        accountNumberController.text = account;
      }
      _savedHolder = holderNameController.text.trim();
      _savedBankName = bankNameController.text.trim();
      _savedIfsc = ifscController.text.trim().toUpperCase();
      _savedAccount = accountNumberController.text.trim();
    } catch (e, st) {
      debugPrint('Load saved bank failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isFetching = false;
      safeNotifyListeners();
    }
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

  String? validateBankName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.bankNameRequired.tr();
    }
    return null;
  }

  String? validateAccountNumber(String? value) {
    final replacing = chequeImage != null;
    final hasSaved = chequeUrl != null;
    if (!replacing && hasSaved && KycDocNumber.isPlaceholder(value)) {
      return null;
    }
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

  bool _hasChanges() {
    if (chequeImage != null) return true;
    if (holderNameController.text.trim() != _savedHolder) return true;
    if (bankNameController.text.trim() != _savedBankName) return true;
    if (ifscController.text.trim().toUpperCase() != _savedIfsc) return true;
    final account = accountNumberController.text.trim();
    if (KycDocNumber.isPlaceholder(account)) return false;
    return account != _savedAccount;
  }

  Future<void> tapOnSubmit() async {
    if (isLoading || isFetching) return;
    submitted = true;
    final fieldsOk = formKey.currentState?.validate() ?? false;
    safeNotifyListeners();
    if (!fieldsOk) return;
    if (!hasCheque) {
      AppToast.error(AppStrings.chequeImageRequired.tr());
      return;
    }

    if (!_hasChanges()) {
      KycStatus.markBankDone();
      AppNavigation.to(const KycReviewScreen());
      return;
    }

    isLoading = true;
    safeNotifyListeners();

    try {
      var nextCheque = chequeUrl;
      if (chequeImage != null) {
        final uploadRes = await Api.uploadImage(
          file: chequeImage!,
          folder: RequestKeys.bankFolder,
        );
        if (!uploadRes.isSuccess || !(uploadRes.data?.hasFullUrl ?? false)) {
          AppToast.error(uploadRes.message ?? AppStrings.uploadFailed.tr());
          return;
        }
        nextCheque = uploadRes.data!.resolvedUrl;
      }
      if (nextCheque == null || nextCheque.isEmpty) {
        AppToast.error(AppStrings.requestFailed.tr());
        return;
      }

      final res = await Api.uploadBank(
        holderName: holderNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        ifsc: ifscController.text.trim().toUpperCase(),
        bankName: bankNameController.text.trim(),
        chequeUrl: nextCheque,
      );
      if (!res.isSuccess) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }

      KycStatus.markBankDone();
      AppToast.success(res.message ?? AppStrings.profileCompleted.tr());
      AppNavigation.to(const KycReviewScreen());
    } catch (e, st) {
      debugPrint('Bank KYC failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    holderNameController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    super.dispose();
  }
}
