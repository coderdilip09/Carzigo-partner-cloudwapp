import 'dart:convert';
import 'dart:io';

import 'package:carzigo_partner/models/kyc_status_model.dart';
import 'package:carzigo_partner/screens/kyc/bank_details/bank_details_screen.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/api_service/request_keys.dart';
import 'package:carzigo_partner/services/image_pick_service/image_pick_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/services/prefs_service/prefs_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:carzigo_partner/utils/india_locations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class LocalAddressProvider extends BaseProvider {
  LocalAddressProvider({
    this.editOnly = false,
    this.forDocumentChange = false,
  }) {
    loadSavedData();
  }

  /// Overview / review edit: save then pop back (no Bank next).
  final bool editOnly;

  /// Save into document-change draft APIs (post-KYC update flow).
  final bool forDocumentChange;
  final formKey = GlobalKey<FormState>();
  final lineController = TextEditingController();
  final landmarkController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  String? selectedState;
  String? selectedCity;

  /// Yes = same as document address (default). No = enter different address.
  bool sameAsDocument = true;

  File? documentImage;
  String? documentUrl;
  String? documentFileName;
  bool documentIsPdf = false;

  /// Previously saved separate upload (same_as_document = false).
  bool separateUploadSaved = false;

  /// Address already on KYC (e.g. Digilocker) — used when Yes is selected.
  String? _docLine;
  String? _docLandmark;
  String? _docCity;
  String? _docState;
  String? _docPincode;

  bool submitted = false;
  bool isLoading = false;
  bool isFetching = false;
  bool isVerifyingPincode = false;
  String? pincodeStateError;

  List<String> get states => IndiaLocations.states;

  List<String> get citiesForState => IndiaLocations.citiesOf(selectedState);

  bool get showAddressForm => !sameAsDocument;

  /// Digilocker doc alone does not count when address differs — need a fresh upload.
  bool get hasDocument {
    if (sameAsDocument) return true;
    return documentImage != null ||
        (separateUploadSaved && (documentUrl?.isNotEmpty ?? false));
  }

  bool get hasDocumentAddress =>
      (_docLine?.trim().isNotEmpty ?? false) &&
      (_docCity?.trim().isNotEmpty ?? false) &&
      (_docState?.trim().isNotEmpty ?? false) &&
      (_docPincode?.trim().isNotEmpty ?? false);

  void _applyAddress({
    required String line,
    String? landmark,
    required String city,
    required String state,
    required String pincode,
  }) {
    lineController.text = line;
    landmarkController.text = landmark?.trim() ?? '';
    pincodeController.text = pincode;

    final matchedState = IndiaLocations.matchState(state) ??
        (IndiaLocations.hasState(state) ? state : null);
    if (matchedState == null) return;
    selectedState = matchedState;
    stateController.text = matchedState;
    if (IndiaLocations.hasCity(matchedState, city)) {
      selectedCity = city;
      cityController.text = city;
    }
  }

  Future<void> loadSavedData() async {
    isFetching = true;
    safeNotifyListeners();

    try {
      await IndiaLocations.ensureLoaded();

      final res = await Api.getKycReview();
      if (res.isSuccess && res.data != null) {
        final data = res.data!;
        final address = data.address;
        final local = data.localAddress;

        // Admin rejection: force a fresh fill — do not prefill old address/doc.
        if (data.isAddressRejected) {
          await PrefsService().clearLocalAddress();
          final digilockerAddress =
              data.identity?.verifiedVia == 'digilocker' &&
              data.addressSameAsDocument != false &&
              local != null &&
              (local.addressLine?.trim().isNotEmpty ?? false) &&
              (local.city?.trim().isNotEmpty ?? false) &&
              (local.state?.trim().isNotEmpty ?? false) &&
              (local.pincode?.trim().isNotEmpty ?? false);
          if (digilockerAddress) {
            _docLine = local.addressLine?.trim();
            _docLandmark = local.landmark?.trim();
            _docCity = local.city?.trim();
            _docState = local.state?.trim();
            _docPincode = local.pincode?.trim();
          }
          sameAsDocument = false;
          return;
        }

        if (address != null) {
          final isSeparate =
              data.addressSameAsDocument == false &&
              (address.documentUrl?.isNotEmpty ?? false) &&
              address.verifiedVia != 'digilocker';
          if (isSeparate) {
            separateUploadSaved = true;
            documentUrl = address.documentUrl;
            documentIsPdf =
                (documentUrl?.toLowerCase().contains('.pdf') ?? false);
            documentFileName = documentIsPdf
                ? AppStrings.pdfDocument.tr()
                : null;
          }
        }

        if (local != null) {
          _docLine = local.addressLine?.trim();
          _docLandmark = local.landmark?.trim();
          _docCity = local.city?.trim();
          _docState = local.state?.trim();
          _docPincode = local.pincode?.trim();
          if (local.isDone) {
            _applyAddress(
              line: _docLine ?? '',
              landmark: _docLandmark,
              city: _docCity ?? '',
              state: _docState ?? '',
              pincode: _docPincode ?? '',
            );
          }
        }

        // Yes only when Digilocker/document address fields exist on the server.
        if (hasDocumentAddress && data.addressSameAsDocument != false) {
          sameAsDocument = data.addressSameAsDocument ?? true;
        } else {
          sameAsDocument = false;
        }

        if (local?.isDone == true) return;
      }

      final saved = await PrefsService().getLocalAddress();
      if (saved == null) return;
      _applyAddress(
        line: saved.line,
        landmark: saved.landmark,
        city: saved.city,
        state: saved.state,
        pincode: saved.pincode,
      );
      sameAsDocument = false;
    } catch (e, st) {
      debugPrint('Load local address failed: $e\n$st');
    } finally {
      // Digilocker often verifies identity without a usable address payload.
      // Defaulting to Yes then blocks submit with "Document address not found".
      if (!hasDocumentAddress) {
        sameAsDocument = false;
      }
      isFetching = false;
      safeNotifyListeners();
    }
  }

  void setSameAsDocument(bool value) {
    if (sameAsDocument == value) return;
    if (value && !hasDocumentAddress) {
      AppToast.error(AppStrings.sameAddressUnavailable.tr());
      return;
    }
    sameAsDocument = value;
    submitted = false;
    pincodeStateError = null;

    // Switching to different address: Digilocker proof is not enough — clear
    // digilocker preview unless a prior separate upload exists.
    if (!value && !separateUploadSaved) {
      documentImage = null;
      documentUrl = null;
      documentFileName = null;
      documentIsPdf = false;
    }
    safeNotifyListeners();
  }

  Future<void> pickDocument(ImageSource source) async {
    final file = await ImagePickService.pickAndCrop(source);
    if (file == null) return;
    _setDocumentFile(file);
  }

  Future<void> pickDocumentFile() async {
    final file = await ImagePickService.pickDocumentFile();
    if (file == null) return;
    _setDocumentFile(file);
  }

  void _setDocumentFile(File file) {
    final name = file.path.replaceAll('\\', '/').split('/').last;
    final lower = name.toLowerCase();
    documentImage = file;
    documentFileName = name;
    documentIsPdf = lower.endsWith('.pdf');
    documentUrl = null;
    separateUploadSaved = false;
    safeNotifyListeners();
  }

  void clearDocument() {
    documentImage = null;
    documentFileName = null;
    documentIsPdf = false;
    documentUrl = null;
    separateUploadSaved = false;
    safeNotifyListeners();
  }

  void selectState(String state) {
    if (selectedState == state) return;
    selectedState = state;
    stateController.text = state;
    selectedCity = null;
    cityController.clear();
    pincodeStateError = null;
    safeNotifyListeners();
    _revalidateForm();
  }

  void selectCity(String city) {
    if (selectedCity == city) return;
    selectedCity = city;
    cityController.text = city;
    safeNotifyListeners();
    _revalidateForm();
  }

  void onPincodeChanged(String _) {
    pincodeStateError = null;
    safeNotifyListeners();
  }

  void _revalidateForm() {
    if (!submitted) return;
    formKey.currentState?.validate();
  }

  String? validateLine(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return AppStrings.addressLineRequired.tr();
    }
    return null;
  }

  String? validateState(String? value) {
    if (selectedState == null || selectedState!.isEmpty) {
      return AppStrings.selectState.tr();
    }
    return null;
  }

  String? validateCity(String? value) {
    if (selectedCity == null || selectedCity!.isEmpty) {
      return AppStrings.selectCity.tr();
    }
    return null;
  }

  String? validatePincode(String? value) {
    final pin = (value ?? '').trim();
    if (pin.isEmpty) return AppStrings.pincodeRequired.tr();
    if (!RegExp(r'^[1-9]\d{5}$').hasMatch(pin)) {
      return AppStrings.pincodeInvalid.tr();
    }
    if (pincodeStateError != null) return pincodeStateError;
    return null;
  }

  Future<bool> verifyPincodeAgainstState(String pin) async {
    if (selectedState == null || selectedState!.isEmpty) return true;
    isVerifyingPincode = true;
    pincodeStateError = null;
    safeNotifyListeners();

    try {
      final uri = Uri.parse('https://api.postalpincode.in/pincode/$pin');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return true;
      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty) return true;
      final first = decoded.first;
      if (first is! Map) return true;
      if (first['Status'] != 'Success') {
        pincodeStateError = AppStrings.pincodeInvalid.tr();
        return false;
      }
      final offices = first['PostOffice'];
      if (offices is! List || offices.isEmpty) return true;
      final office = offices.first;
      if (office is! Map) return true;
      final apiState = (office['State'] ?? '').toString();
      final matched = IndiaLocations.matchState(apiState);
      if (matched != null &&
          matched.toLowerCase() != selectedState!.toLowerCase()) {
        pincodeStateError = AppStrings.pincodeStateMismatch.tr();
        return false;
      }
      return true;
    } catch (e, st) {
      debugPrint('Pincode verify failed: $e\n$st');
      pincodeStateError = null;
      return true;
    } finally {
      isVerifyingPincode = false;
      safeNotifyListeners();
      _revalidateForm();
    }
  }

  Future<void> tapOnSubmit() async {
    if (isLoading || isFetching || isVerifyingPincode) return;
    submitted = true;
    safeNotifyListeners();

    final statusRes = await Api.getKycStatus();
    final identityDone =
        forDocumentChange ||
        (statusRes.isSuccess && statusRes.data?.isIdentityDone == true);
    if (!identityDone) {
      AppToast.error(AppStrings.completeIdentityFirst.tr());
      return;
    }

    String? line;
    String? landmark;
    String? city;
    String? state;
    String? pin;
    String? nextDocUrl;

    if (sameAsDocument && !hasDocumentAddress) {
      // Digilocker verified without address fields — force manual entry.
      sameAsDocument = false;
      safeNotifyListeners();
      AppToast.error(AppStrings.sameAddressUnavailable.tr());
      return;
    }

    if (sameAsDocument) {
      line = _docLine!.trim();
      landmark = _docLandmark?.trim();
      city = _docCity!.trim();
      state = _docState!.trim();
      pin = _docPincode!.trim();
    } else {
      if (!hasDocument) {
        AppToast.error(AppStrings.documentImageRequired.tr());
        return;
      }

      final fieldsOk = formKey.currentState?.validate() ?? false;
      if (!fieldsOk) return;

      pin = pincodeController.text.trim();
      final pinOk = await verifyPincodeAgainstState(pin);
      if (!pinOk) {
        formKey.currentState?.validate();
        return;
      }
      line = lineController.text.trim();
      landmark = landmarkController.text.trim();
      city = selectedCity!.trim();
      state = selectedState!.trim();
    }

    isLoading = true;
    safeNotifyListeners();

    try {
      if (!sameAsDocument) {
        if (documentImage != null) {
          final uploadRes = await Api.uploadImage(
            file: documentImage!,
            folder: RequestKeys.addressFolder,
          );
          if (!uploadRes.isSuccess || !(uploadRes.data?.hasFullUrl ?? false)) {
            AppToast.error(uploadRes.message ?? AppStrings.uploadFailed.tr());
            return;
          }
          nextDocUrl = uploadRes.data!.resolvedUrl;
          if (nextDocUrl == null || nextDocUrl.isEmpty) {
            AppToast.error(AppStrings.uploadFailed.tr());
            return;
          }
        } else if (separateUploadSaved &&
            documentUrl != null &&
            documentUrl!.isNotEmpty) {
          nextDocUrl = documentUrl;
        } else {
          AppToast.error(AppStrings.documentImageRequired.tr());
          return;
        }
      }

      final res = forDocumentChange
          ? await Api.saveDocumentChangeSection(
              section: 'address',
              body: {
                RequestKeys.sameAsDocument: sameAsDocument,
                RequestKeys.addressLine: line,
                RequestKeys.landmark:
                    landmark == null || landmark.isEmpty ? '' : landmark,
                RequestKeys.city: city,
                RequestKeys.state: state,
                RequestKeys.pincode: pin,
                if (!sameAsDocument) ...{
                  RequestKeys.docType: KycDocType.aadhaar,
                  RequestKeys.docUrl: nextDocUrl,
                },
              },
            )
          : await Api.saveAddressProof(
              sameAsDocument: sameAsDocument,
              addressLine: sameAsDocument ? null : line,
              landmark: sameAsDocument
                  ? null
                  : (landmark == null || landmark.isEmpty ? '' : landmark),
              city: sameAsDocument ? null : city,
              state: sameAsDocument ? null : state,
              pincode: sameAsDocument ? null : pin,
              // Doc type/number UI is hidden; API still requires a type when address differs.
              docType: sameAsDocument ? null : KycDocType.aadhaar,
              docNumber: null,
              docUrl: sameAsDocument ? null : nextDocUrl,
            );
      if (!res.isSuccess) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }

      await PrefsService().saveLocalAddress(
        LocalAddressData(
          line: line!,
          landmark: landmark,
          city: city!,
          state: state!,
          pincode: pin!,
        ),
      );

      AppToast.success(res.message ?? AppStrings.localAddressSaved.tr());
      if (editOnly || forDocumentChange) {
        AppNavigation.back();
        return;
      }
      AppNavigation.to(const BankDetailsScreen(loadSaved: true));
    } catch (e, st) {
      debugPrint('Save address proof failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    lineController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.dispose();
  }
}
