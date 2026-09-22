import 'dart:async';
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
  BankDetailsProvider({
    this.loadSaved = false,
    this.editOnly = false,
  }) {
    if (loadSaved) loadSavedData();
  }

  final bool loadSaved;

  /// Profile Documents / Review edit: save then pop back (no Review next).
  final bool editOnly;
  final formKey = GlobalKey<FormState>();
  final holderNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final confirmAccountController = TextEditingController();
  final ifscController = TextEditingController();

  File? chequeImage;
  String? chequeUrl;
  String? resolvedBankName;
  String? resolvedBranch;
  bool ifscFromMock = false;
  String _savedHolder = '';
  String _savedBankName = '';
  String _savedBranch = '';
  String _savedIfsc = '';
  String _savedAccount = '';
  bool submitted = false;
  bool isLoading = false;
  bool isFetching = false;
  bool isLookingUpIfsc = false;
  String? ifscError;
  Timer? _ifscDebounce;
  int _ifscLookupToken = 0;

  bool get hasCheque =>
      chequeImage != null || (chequeUrl?.isNotEmpty ?? false);

  bool get hasVerifiedIfsc =>
      resolvedBankName != null &&
      resolvedBankName!.trim().isNotEmpty &&
      ifscError == null;

  Future<void> loadSavedData() async {
    if (!loadSaved) return;

    isFetching = true;
    safeNotifyListeners();

    try {
      final res = await Api.getKycReview();
      if (!res.isSuccess) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }

      // Admin rejection: force a fresh fill — do not prefill old bank details.
      if (res.data?.isBankRejected == true) return;

      final bank = res.data?.bank;
      if (bank == null || !bank.isDone) return;

      holderNameController.text = bank.holderName ?? '';
      ifscController.text = bank.ifsc ?? '';
      resolvedBankName = bank.bankName?.trim().isNotEmpty == true
          ? bank.bankName!.trim()
          : null;
      resolvedBranch = bank.bankBranch?.trim().isNotEmpty == true
          ? bank.bankBranch!.trim()
          : null;
      chequeUrl = bank.chequeUrl;
      final account = bank.accountNumber ?? bank.accountNumberMasked ?? '';
      if (account.isNotEmpty) {
        accountNumberController.text = account;
        confirmAccountController.text = account;
      }
      _savedHolder = holderNameController.text.trim();
      _savedBankName = resolvedBankName ?? '';
      _savedBranch = resolvedBranch ?? '';
      _savedIfsc = ifscController.text.trim().toUpperCase();
      _savedAccount = accountNumberController.text.trim();

      if (_savedIfsc.isNotEmpty &&
          (resolvedBankName == null || resolvedBranch == null)) {
        await lookupIfsc(force: true);
      }
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

  void onIfscChanged(String value) {
    final code = value.trim().toUpperCase();
    ifscError = null;
    if (code != _savedIfsc ||
        resolvedBankName == null ||
        resolvedBankName!.isEmpty) {
      resolvedBankName = null;
      resolvedBranch = null;
      ifscFromMock = false;
    }
    safeNotifyListeners();

    _ifscDebounce?.cancel();
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(code)) {
      isLookingUpIfsc = false;
      safeNotifyListeners();
      return;
    }

    _ifscDebounce = Timer(const Duration(milliseconds: 450), () {
      lookupIfsc();
    });
  }

  Future<void> lookupIfsc({bool force = false}) async {
    final code = ifscController.text.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(code)) {
      ifscError = AppStrings.ifscInvalid.tr();
      resolvedBankName = null;
      resolvedBranch = null;
      safeNotifyListeners();
      return;
    }

    if (!force &&
        code == _savedIfsc &&
        resolvedBankName != null &&
        resolvedBankName!.isNotEmpty) {
      return;
    }

    final token = ++_ifscLookupToken;
    isLookingUpIfsc = true;
    ifscError = null;
    safeNotifyListeners();

    try {
      final res = await Api.lookupIfsc(code);
      if (token != _ifscLookupToken) return;
      if (!res.isSuccess || res.data == null) {
        resolvedBankName = null;
        resolvedBranch = null;
        ifscFromMock = false;
        ifscError = res.message ?? AppStrings.ifscInvalid.tr();
        return;
      }

      final bank = (res.data!['bank_name'] ?? res.data!['BANK'] ?? '')
          .toString()
          .trim();
      final branch = (res.data!['branch'] ??
              res.data!['bank_branch'] ??
              res.data!['BRANCH'] ??
              '')
          .toString()
          .trim();
      if (bank.isEmpty) {
        resolvedBankName = null;
        resolvedBranch = null;
        ifscFromMock = false;
        ifscError = AppStrings.ifscInvalid.tr();
        return;
      }
      resolvedBankName = bank;
      resolvedBranch = branch.isEmpty ? null : branch;
      ifscFromMock = res.data!['mock'] == true;
      ifscError = null;
    } catch (e, st) {
      debugPrint('IFSC lookup failed: $e\n$st');
      if (token != _ifscLookupToken) return;
      resolvedBankName = null;
      resolvedBranch = null;
      ifscFromMock = false;
      ifscError = AppStrings.requestFailed.tr();
    } finally {
      if (token == _ifscLookupToken) {
        isLookingUpIfsc = false;
        safeNotifyListeners();
      }
    }
  }

  String? validateHolderName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.accountHolderRequired.tr();
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

  String? validateConfirmAccount(String? value) {
    final account = accountNumberController.text.trim();
    final confirm = value?.trim() ?? '';
    final replacing = chequeImage != null;
    final hasSaved = chequeUrl != null;
    if (!replacing &&
        hasSaved &&
        KycDocNumber.isPlaceholder(account) &&
        (confirm.isEmpty || confirm == account)) {
      return null;
    }
    if (confirm.isEmpty) {
      return AppStrings.confirmAccountRequired.tr();
    }
    if (confirm != account) {
      return AppStrings.accountNumberMismatch.tr();
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
    if (isLookingUpIfsc) {
      return AppStrings.ifscLookingUp.tr();
    }
    if (!hasVerifiedIfsc) {
      return ifscError ?? AppStrings.ifscNotVerified.tr();
    }
    return null;
  }

  bool _hasChanges() {
    if (chequeImage != null) return true;
    if (holderNameController.text.trim() != _savedHolder) return true;
    if ((resolvedBankName ?? '').trim() != _savedBankName) return true;
    if ((resolvedBranch ?? '').trim() != _savedBranch) return true;
    if (ifscController.text.trim().toUpperCase() != _savedIfsc) return true;
    final account = accountNumberController.text.trim();
    if (KycDocNumber.isPlaceholder(account)) return false;
    return account != _savedAccount;
  }

  Future<void> tapOnSubmit() async {
    if (isLoading || isFetching || isLookingUpIfsc) return;
    submitted = true;

    final code = ifscController.text.trim().toUpperCase();
    if (RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(code) &&
        !hasVerifiedIfsc) {
      await lookupIfsc(force: true);
    }

    final fieldsOk = formKey.currentState?.validate() ?? false;
    safeNotifyListeners();
    if (!fieldsOk) return;
    if (!hasVerifiedIfsc) {
      AppToast.error(ifscError ?? AppStrings.ifscNotVerified.tr());
      return;
    }
    if (!hasCheque) {
      AppToast.error(AppStrings.chequeImageRequired.tr());
      return;
    }

    if (!_hasChanges()) {
      _finishSuccess();
      return;
    }

    final account = accountNumberController.text.trim();
    if (KycDocNumber.isPlaceholder(account) ||
        !RegExp(r'^\d{9,18}$').hasMatch(account)) {
      AppToast.error(AppStrings.accountNumberRequired.tr());
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
        bankName: resolvedBankName!.trim(),
        bankBranch: resolvedBranch?.trim(),
        chequeUrl: nextCheque,
      );
      if (!res.isSuccess) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }

      AppToast.success(res.message ?? AppStrings.profileCompleted.tr());
      _finishSuccess();
    } catch (e, st) {
      debugPrint('Bank KYC failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  void _finishSuccess() {
    KycStatus.markBankDone();
    if (editOnly) {
      AppNavigation.back();
      return;
    }
    AppNavigation.to(const KycReviewScreen());
  }

  @override
  void dispose() {
    _ifscDebounce?.cancel();
    holderNameController.dispose();
    accountNumberController.dispose();
    confirmAccountController.dispose();
    ifscController.dispose();
    super.dispose();
  }
}
