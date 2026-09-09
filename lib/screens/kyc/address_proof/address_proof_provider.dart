import 'dart:io';

import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_document_number.dart';
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

class AddressProofProvider extends BaseProvider {
  AddressProofProvider({this.loadSaved = false}) {
    if (loadSaved) loadSavedData();
  }

  final bool loadSaved;
  final formKey = GlobalKey<FormState>();
  final numberController = TextEditingController();

  int selectedDoc = 0;
  int _savedDoc = 0;
  File? documentImage;
  String? documentUrl;
  String _savedNumber = '';
  bool submitted = false;
  bool isLoading = false;
  bool isFetching = false;

  final docs = [
    AppStrings.aadhaarCard,
    AppStrings.panCard,
    AppStrings.drivingLicense,
  ];

  bool get hasDocument =>
      documentImage != null || (documentUrl?.isNotEmpty ?? false);

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

      final address = res.data?.address;
      if (address == null || !address.isDone) return;

      selectedDoc = KycDocNumber.indexFromApi(address.docType);
      _savedDoc = selectedDoc;
      documentUrl = address.documentUrl;
      final number = address.maskedNumber?.trim() ?? '';
      if (number.isNotEmpty) {
        numberController.text = number;
      }
      _savedNumber = numberController.text.trim();
    } catch (e, st) {
      debugPrint('Load saved address failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isFetching = false;
      safeNotifyListeners();
    }
  }

  void selectDoc(int index) {
    if (selectedDoc == index) return;
    selectedDoc = index;
    numberController.clear();
    submitted = false;
    documentImage = null;
    documentUrl = null;
    safeNotifyListeners();
  }

  String? validateDocumentNumber(String? value) {
    final replacing = documentImage != null;
    final hasSaved = documentUrl != null;
    if (!replacing && hasSaved && KycDocNumber.isPlaceholder(value)) {
      return null;
    }
    return KycDocNumber.validate(selectedDoc, value);
  }

  Future<void> pickDocument(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null) return;
    documentImage = file;
    safeNotifyListeners();
  }

  bool _validate() {
    if (!hasDocument) {
      AppToast.error(AppStrings.documentImageRequired.tr());
      return false;
    }
    return true;
  }

  bool _hasChanges() {
    if (documentImage != null) return true;
    if (loadSaved && selectedDoc != _savedDoc) return true;
    final number = numberController.text.trim();
    if (KycDocNumber.validate(selectedDoc, number) != null) return false;
    if (KycDocNumber.isPlaceholder(_savedNumber)) return true;
    return number != _savedNumber;
  }

  void _goToBank() {
    KycStatus.markAddressDone();
    AppNavigation.to(const BankDetailsScreen(loadSaved: true));
  }

  Future<void> tapOnSubmit() async {
    if (isLoading || isFetching) return;
    submitted = true;
    final fieldsOk = formKey.currentState?.validate() ?? false;
    safeNotifyListeners();
    if (!fieldsOk) return;
    if (!_validate()) return;

    if (!_hasChanges()) {
      _goToBank();
      return;
    }

    isLoading = true;
    safeNotifyListeners();

    try {
      var nextUrl = documentUrl;
      if (documentImage != null) {
        final uploadRes = await Api.uploadImage(
          file: documentImage!,
          folder: RequestKeys.addressFolder,
        );
        if (!uploadRes.isSuccess || !(uploadRes.data?.hasFullUrl ?? false)) {
          AppToast.error(uploadRes.message ?? AppStrings.uploadFailed.tr());
          return;
        }
        nextUrl = uploadRes.data!.resolvedUrl;
      }
      if (nextUrl == null || nextUrl.isEmpty) {
        AppToast.error(AppStrings.requestFailed.tr());
        return;
      }

      final res = await Api.uploadAddress(
        docType: KycDocNumber.apiType(selectedDoc),
        docNumber: numberController.text.trim(),
        docUrl: nextUrl,
      );
      if (!res.isSuccess) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }

      AppToast.success(res.message ?? AppStrings.profileCompleted.tr());
      _goToBank();
    } catch (e, st) {
      debugPrint('Address KYC failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    numberController.dispose();
    super.dispose();
  }
}
