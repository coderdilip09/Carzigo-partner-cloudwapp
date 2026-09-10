import 'dart:io';

import 'package:carzigo_partner/screens/kyc/address_proof/address_proof_screen.dart';
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

class IdentityProofProvider extends BaseProvider {
  IdentityProofProvider({
    this.loadSaved = false,
    this.editOnly = false,
  }) {
    if (loadSaved) loadSavedData();
  }

  final bool loadSaved;

  /// Profile Documents / Review edit: save then pop back (no Address next).
  final bool editOnly;
  final formKey = GlobalKey<FormState>();
  final numberController = TextEditingController();

  int selectedDoc = 0;
  int _savedDoc = 0;
  File? frontImage;
  File? backImage;
  String? frontUrl;
  String? backUrl;
  String _savedNumber = '';
  bool submitted = false;
  bool isLoading = false;
  bool isFetching = false;

  final docs = [
    AppStrings.aadhaarCard,
    AppStrings.panCard,
    AppStrings.drivingLicense,
  ];

  bool get hasFront => frontImage != null || (frontUrl?.isNotEmpty ?? false);
  bool get hasBack => backImage != null || (backUrl?.isNotEmpty ?? false);

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

      final identity = res.data?.identity;
      if (identity == null || !identity.isDone) return;

      selectedDoc = KycDocNumber.indexFromApi(identity.docType);
      _savedDoc = selectedDoc;
      frontUrl = identity.frontUrl;
      backUrl = identity.backUrl;
      final number = identity.maskedNumber?.trim() ?? '';
      if (number.isNotEmpty) {
        numberController.text = number;
      }
      _savedNumber = numberController.text.trim();
    } catch (e, st) {
      debugPrint('Load saved identity failed: $e\n$st');
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
    frontImage = null;
    backImage = null;
    frontUrl = null;
    backUrl = null;
    safeNotifyListeners();
  }

  String? validateDocumentNumber(String? value) {
    final replacing = frontImage != null || backImage != null;
    final hasSaved = frontUrl != null && backUrl != null;
    if (!replacing && hasSaved && KycDocNumber.isPlaceholder(value)) {
      return null;
    }
    return KycDocNumber.validate(selectedDoc, value);
  }

  Future<void> pickFront(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null) return;
    frontImage = file;
    safeNotifyListeners();
  }

  Future<void> pickBack(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null) return;
    backImage = file;
    safeNotifyListeners();
  }

  bool _validate() {
    if (!hasFront) {
      AppToast.error(AppStrings.frontImageRequired.tr());
      return false;
    }
    if (!hasBack) {
      AppToast.error(AppStrings.backImageRequired.tr());
      return false;
    }
    return true;
  }

  Future<String?> _upload(File file) async {
    final res = await Api.uploadImage(
      file: file,
      folder: RequestKeys.identityFolder,
    );
    if (!res.isSuccess || !(res.data?.hasFullUrl ?? false)) {
      AppToast.error(res.message ?? AppStrings.uploadFailed.tr());
      return null;
    }
    return res.data!.resolvedUrl;
  }

  bool _hasChanges() {
    if (frontImage != null || backImage != null) return true;
    if (loadSaved && selectedDoc != _savedDoc) return true;
    final number = numberController.text.trim();
    if (KycDocNumber.validate(selectedDoc, number) != null) return false;
    if (KycDocNumber.isPlaceholder(_savedNumber)) return true;
    return number != _savedNumber;
  }

  void _finishSuccess() {
    KycStatus.markIdentityDone();
    if (editOnly) {
      AppNavigation.back();
      return;
    }
    AppNavigation.to(const AddressProofScreen(loadSaved: true));
  }

  Future<void> tapOnSubmit() async {
    if (isLoading || isFetching) return;
    submitted = true;
    final fieldsOk = formKey.currentState?.validate() ?? false;
    safeNotifyListeners();
    if (!fieldsOk) return;
    if (!_validate()) return;

    if (!_hasChanges()) {
      _finishSuccess();
      return;
    }

    isLoading = true;
    safeNotifyListeners();

    try {
      var nextFront = frontUrl;
      if (frontImage != null) {
        nextFront = await _upload(frontImage!);
        if (nextFront == null) return;
      }
      var nextBack = backUrl;
      if (backImage != null) {
        nextBack = await _upload(backImage!);
        if (nextBack == null) return;
      }
      if (nextFront == null || nextBack == null) {
        AppToast.error(AppStrings.requestFailed.tr());
        return;
      }

      final res = await Api.uploadIdentity(
        docType: KycDocNumber.apiType(selectedDoc),
        docNumber: numberController.text.trim(),
        frontUrl: nextFront,
        backUrl: nextBack,
      );
      if (!res.isSuccess) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }

      AppToast.success(res.message ?? AppStrings.profileCompleted.tr());
      _finishSuccess();
    } catch (e, st) {
      debugPrint('Identity KYC failed: $e\n$st');
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
