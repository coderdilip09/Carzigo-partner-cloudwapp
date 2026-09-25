import 'dart:io';

import 'package:carzigo_partner/models/document_change_request_model.dart';
import 'package:carzigo_partner/models/cms_data_model.dart';
import 'package:carzigo_partner/models/delete_account_data_model.dart';
import 'package:carzigo_partner/models/dashboard_data_model.dart';
import 'package:carzigo_partner/models/job_data_model.dart';
import 'package:carzigo_partner/models/json_parsers.dart';
import 'package:carzigo_partner/models/kyc_account_status_data_model.dart';
import 'package:carzigo_partner/models/kyc_status_model.dart';
import 'package:carzigo_partner/models/kyc_submit_data_model.dart';
import 'package:carzigo_partner/models/notification_data_model.dart';
import 'package:carzigo_partner/models/otp_data_model.dart';
import 'package:carzigo_partner/models/paginator_wrapper_model.dart';
import 'package:carzigo_partner/models/referral_data_model.dart';
import 'package:carzigo_partner/models/response_wrapper_model.dart';
import 'package:carzigo_partner/models/upload_data_model.dart';
import 'package:carzigo_partner/models/user_data_model.dart';
import 'package:carzigo_partner/services/api_service/api_client_methods.dart';
import 'package:carzigo_partner/services/api_service/api_urls.dart';
import 'package:carzigo_partner/services/api_service/request_keys.dart';
import 'package:carzigo_partner/services/device_service/device_service.dart';
import 'package:carzigo_partner/services/prefs_service/prefs_service.dart';

class Api {
  Api._();

  static Future<ResponseWrapperModel<OtpDataModel?>> sendOtp({
    required String countryCode,
    required String mobile,
  }) {
    return _postParsed(
      ApiUrls.sendOtpUrl(),
      _otpBody(countryCode: countryCode, mobile: mobile),
      (data) => OtpDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<AuthDataModel?>> verifyOtp({
    required String countryCode,
    required String mobile,
    required String otp,
  }) async {
    final fcm = await PrefsService().getFcmToken();
    final device = await DeviceService().getInfo();
    return _postParsed(
      ApiUrls.verifyOtpUrl(),
      {
        ..._otpBody(countryCode: countryCode, mobile: mobile, otp: otp),
        if (fcm != null && fcm.isNotEmpty) RequestKeys.fcmToken: fcm,
        RequestKeys.deviceType: device.type,
        RequestKeys.deviceId: device.id,
      },
      (data) => AuthDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<OtpDataModel?>> resendOtp({
    required String countryCode,
    required String mobile,
  }) {
    return _postParsed(
      ApiUrls.resendOtpUrl(),
      _otpBody(countryCode: countryCode, mobile: mobile),
      (data) => OtpDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<dynamic>> logout() {
    return _post(ApiUrls.logoutUrl(), {});
  }

  static Future<ResponseWrapperModel<DeleteAccountDataModel?>>
      deleteAccount() async {
    final json = await ApiClientMethods.deleteMethod(
      url: ApiUrls.deleteAccountUrl(),
    );
    return ResponseWrapperModel.fromJson(
      json,
      (data) => DeleteAccountDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<UserDataModel?>> getProfile() async {
    final json = await ApiClientMethods.getMethod(url: ApiUrls.profileUrl());
    return ResponseWrapperModel.fromJson(
      json,
      (data) => UserDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<UploadDataModel?>> uploadImage({
    required File file,
    String folder = RequestKeys.profileFolder,
  }) {
    return _multipartParsed(
      ApiUrls.uploadsUrl(),
      fields: {RequestKeys.folder: folder},
      files: {RequestKeys.file: file},
      parse: (data) => UploadDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<UserDataModel?>> updateProfile({
    required String name,
    required String email,
    String? photo,
  }) {
    return _patchParsed(ApiUrls.profileUrl(), {
      RequestKeys.name: name,
      RequestKeys.email: email,
      if (photo != null && photo.isNotEmpty) RequestKeys.photo: photo,
    }, (data) => UserDataModel.fromJson(asMap(data) ?? {}));
  }

  static Future<ResponseWrapperModel<OtpDataModel?>> changePhoneSendOtp({
    required String countryCode,
    required String phone,
  }) {
    return _postParsed(
      ApiUrls.changePhoneSendOtpUrl(),
      {
        RequestKeys.countryCode: countryCode,
        RequestKeys.mobile: phone,
      },
      (data) => OtpDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<UserDataModel?>> changePhoneVerify({
    required String countryCode,
    required String phone,
    required String otp,
  }) {
    return _postParsed(
      ApiUrls.changePhoneVerifyUrl(),
      {
        RequestKeys.countryCode: countryCode,
        RequestKeys.mobile: phone,
        RequestKeys.otp: otp,
      },
      (data) => UserDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<KycStatusModel?>> getKycStatus() async {
    final json = await ApiClientMethods.getMethod(url: ApiUrls.kycStatusUrl());
    return ResponseWrapperModel.fromJson(
      json,
      (data) => KycStatusModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<KycAccountStatusDataModel?>>
  getKycAccountStatus() async {
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.kycAccountStatusUrl(),
    );
    return ResponseWrapperModel.fromJson(
      json,
      (data) => KycAccountStatusDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<KycStatusModel?>> getKycReview() async {
    final json = await ApiClientMethods.getMethod(url: ApiUrls.kycReviewUrl());
    return ResponseWrapperModel.fromJson(
      json,
      (data) => KycStatusModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<KycStatusModel?>> uploadIdentity({
    required String docType,
    required String docNumber,
    required String frontUrl,
    required String backUrl,
  }) {
    return _putParsed(
      ApiUrls.kycIdentityUrl(),
      {
        RequestKeys.docType: docType,
        RequestKeys.docNumber: docNumber,
        RequestKeys.frontUrl: frontUrl,
        RequestKeys.backUrl: backUrl,
      },
      (data) => KycStatusModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<KycStatusModel?>> uploadAddress({
    required String docType,
    required String docNumber,
    required String docUrl,
  }) {
    return _putParsed(ApiUrls.kycAddressUrl(), {
      RequestKeys.docType: docType,
      RequestKeys.docNumber: docNumber,
      RequestKeys.docUrl: docUrl,
    }, (data) => KycStatusModel.fromJson(asMap(data) ?? {}));
  }

  static Future<ResponseWrapperModel<LocalAddressDataModel?>>
  saveLocalAddress({
    required String addressLine,
    String? landmark,
    required String city,
    required String state,
    required String pincode,
  }) {
    return _putParsed(ApiUrls.kycLocalAddressUrl(), {
      RequestKeys.addressLine: addressLine,
      if (landmark != null) RequestKeys.landmark: landmark,
      RequestKeys.city: city,
      RequestKeys.state: state,
      RequestKeys.pincode: pincode,
    }, (data) => LocalAddressDataModel.fromJson(asMap(data) ?? {}));
  }

  /// Unified Address Proof: Yes = same_as_document true; No = fields + doc.
  static Future<ResponseWrapperModel<Map<String, dynamic>?>> saveAddressProof({
    required bool sameAsDocument,
    String? addressLine,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    String? docType,
    String? docNumber,
    String? docUrl,
  }) {
    return _putParsed(ApiUrls.kycAddressProofUrl(), {
      RequestKeys.sameAsDocument: sameAsDocument,
      if (!sameAsDocument) ...{
        RequestKeys.addressLine: addressLine,
        RequestKeys.landmark: landmark,
        RequestKeys.city: city,
        RequestKeys.state: state,
        RequestKeys.pincode: pincode,
        RequestKeys.docType: docType,
        RequestKeys.docNumber: docNumber,
        RequestKeys.docUrl: docUrl,
      },
    }, (data) => asMap(data));
  }

  static Future<ResponseWrapperModel<DigilockerStartDataModel?>>
  startDigilocker({String? redirectUrl}) {
    return _postParsed(ApiUrls.kycDigilockerStartUrl(), {
      if (redirectUrl != null && redirectUrl.isNotEmpty)
        RequestKeys.redirectUrl: redirectUrl,
    }, (data) => DigilockerStartDataModel.fromJson(asMap(data) ?? {}));
  }

  static Future<ResponseWrapperModel<KycStatusModel?>> completeDigilocker({
    required String clientId,
  }) {
    return _postParsed(ApiUrls.kycDigilockerCompleteUrl(), {
      RequestKeys.clientId: clientId,
    }, (data) => KycStatusModel.fromJson(asMap(data) ?? {}));
  }

  static Future<ResponseWrapperModel<KycStatusModel?>> uploadBank({
    required String holderName,
    required String accountNumber,
    required String ifsc,
    required String bankName,
    String? bankBranch,
    required String chequeUrl,
  }) {
    return _putParsed(ApiUrls.kycBankUrl(), {
      RequestKeys.holderName: holderName,
      RequestKeys.accountNumber: accountNumber,
      RequestKeys.ifsc: ifsc,
      RequestKeys.bankName: bankName,
      if (bankBranch != null && bankBranch.isNotEmpty)
        RequestKeys.bankBranch: bankBranch,
      RequestKeys.chequeUrl: chequeUrl,
    }, (data) => KycStatusModel.fromJson(asMap(data) ?? {}));
  }

  static Future<ResponseWrapperModel<Map<String, dynamic>?>> lookupIfsc(
    String code,
  ) async {
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.kycIfscUrl(code.trim().toUpperCase()),
    );
    return ResponseWrapperModel.fromJson(json, (data) => asMap(data));
  }

  static Future<ResponseWrapperModel<KycSubmitDataModel?>> submitKyc() {
    return _postParsed(
      ApiUrls.kycSubmitUrl(),
      {},
      (data) => KycSubmitDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<DocumentChangeRequestModel?>>
  getDocumentChangeCurrent() async {
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.documentChangeCurrentUrl(),
    );
    return ResponseWrapperModel.fromJson(json, (data) {
      final map = asMap(data);
      if (map == null || map.isEmpty) return null;
      return DocumentChangeRequestModel.fromJson(map);
    });
  }

  static Future<ResponseWrapperModel<DocumentChangeRequestModel?>>
  createDocumentChangeRequest({
    required List<String> sections,
    required String reason,
  }) {
    return _postParsed(
      ApiUrls.documentChangeRequestsUrl(),
      {
        RequestKeys.sections: sections,
        RequestKeys.reason: reason,
      },
      (data) => DocumentChangeRequestModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<Map<String, dynamic>?>>
  saveDocumentChangeSection({
    required String section,
    required Map<String, dynamic> body,
  }) {
    return _putParsed(
      ApiUrls.documentChangeSectionUrl(section),
      body,
      (data) => asMap(data),
    );
  }

  static Future<ResponseWrapperModel<DocumentChangeRequestModel?>>
  submitDocumentChange() {
    return _postParsed(
      ApiUrls.documentChangeSubmitUrl(),
      {},
      (data) => DocumentChangeRequestModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<DashboardDataModel?>>
  getDashboard() async {
    final json = await ApiClientMethods.getMethod(url: ApiUrls.dashboardUrl());
    return ResponseWrapperModel.fromJson(
      json,
      (data) => DashboardDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<ScheduleListDataModel?>> getJobs({
    String? tab,
    String? status,
    int? page,
    int? limit,
  }) async {
    final query = <String, String>{
      if (tab != null && tab.isNotEmpty) RequestKeys.tab: tab,
      if (status != null && status.isNotEmpty) RequestKeys.status: status,
      if (page != null) RequestKeys.page: '$page',
      if (limit != null) RequestKeys.limit: '$limit',
    };
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.servicesUrl(),
      query: query.isEmpty ? null : query,
    );
    return ResponseWrapperModel.fromJson(json, ScheduleListDataModel.fromJson);
  }

  static Future<ResponseWrapperModel<JobDataModel?>> getJobDetails(
    String id,
  ) async {
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.jobDetailsUrl(id),
    );
    return ResponseWrapperModel.fromJson(
      json,
      (data) => JobDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<JobDataModel?>> updateJobStatus({
    required String id,
    required String status,
  }) async {
    final json = await ApiClientMethods.patchMethod(
      url: ApiUrls.jobStatusUrl(id),
      body: {RequestKeys.status: status},
    );
    return ResponseWrapperModel.fromJson(
      json,
      (data) => JobDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<ReferralDataModel?>> getReferral() async {
    final json = await ApiClientMethods.getMethod(url: ApiUrls.referralsUrl());
    return ResponseWrapperModel.fromJson(
      json,
      (data) => ReferralDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<ReferralCustomersPage>>
  getReferralCustomers({
    String filter = 'total',
    int page = 1,
    int limit = 15,
  }) async {
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.referralCustomersUrl(),
      query: {
        RequestKeys.filter: filter,
        RequestKeys.page: '$page',
        RequestKeys.limit: '$limit',
      },
    );
    return ResponseWrapperModel.fromJson(
      json,
      (data) => ReferralCustomersPage.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<List<NotificationDataModel>>>
  getNotifications({int? page}) async {
    final query = <String, String>{if (page != null) RequestKeys.page: '$page'};
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.notificationsUrl(),
      query: query.isEmpty ? null : query,
    );
    return ResponseWrapperModel.fromJson(
      json,
      (data) => PaginatorWrapperModel.fromJson(
        data,
        NotificationDataModel.fromJson,
      ).list,
    );
  }

  static Future<ResponseWrapperModel<Map<String, dynamic>?>> registerDeviceToken(
    String fcmToken,
  ) async {
    final device = await DeviceService().getInfo();
    return _putParsed(
      ApiUrls.notificationsDeviceTokenUrl(),
      {
        RequestKeys.fcmToken: fcmToken,
        RequestKeys.deviceType: device.type,
        RequestKeys.deviceId: device.id,
      },
      (data) => asMap(data),
    );
  }

  static Future<ResponseWrapperModel<CmsDataModel?>> getLegalPage(
    String slug,
  ) async {
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.legalUrl(slug),
      query: _helpAudienceQuery,
    );
    return ResponseWrapperModel.fromJson(
      json,
      (data) => CmsDataModel.fromJson(asMap(data) ?? {}),
    );
  }

  static Future<ResponseWrapperModel<CmsDataModel?>> getTerms() {
    return getLegalPage(ApiUrls.legalTermsSlug);
  }

  static Future<ResponseWrapperModel<CmsDataModel?>> getPrivacy() {
    return getLegalPage(ApiUrls.legalPrivacySlug);
  }

  static Map<String, String> get _helpAudienceQuery => {
    RequestKeys.audience: RequestKeys.partnerAudience,
  };

  static Future<ResponseWrapperModel<Map<String, dynamic>?>> getHelp() async {
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.helpUrl(),
      query: _helpAudienceQuery,
    );
    return ResponseWrapperModel.fromJson(json, (data) => asMap(data));
  }

  static Future<ResponseWrapperModel<List<Map<String, dynamic>>>>
  getHelpTopics() async {
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.helpTopicsUrl(),
      query: _helpAudienceQuery,
    );
    return ResponseWrapperModel.fromJson(json, (data) {
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return <Map<String, dynamic>>[];
    });
  }

  static Future<ResponseWrapperModel<Map<String, dynamic>?>> getHelpTopic({
    required String key,
  }) async {
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.helpTopicUrl(key),
      query: _helpAudienceQuery,
    );
    return ResponseWrapperModel.fromJson(json, (data) => asMap(data));
  }

  static Future<ResponseWrapperModel<Map<String, dynamic>?>> searchHelp({
    required String query,
  }) async {
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.helpSearchUrl(),
      query: {RequestKeys.q: query, ..._helpAudienceQuery},
    );
    return ResponseWrapperModel.fromJson(json, (data) => asMap(data));
  }

  static Future<ResponseWrapperModel<Map<String, dynamic>?>>
  getHelpContact() async {
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.helpContactUrl(),
    );
    return ResponseWrapperModel.fromJson(json, (data) => asMap(data));
  }

  static Map<String, dynamic> _otpBody({
    required String countryCode,
    required String mobile,
    String? otp,
  }) {
    return {
      RequestKeys.role: RequestKeys.partnerRole,
      RequestKeys.countryCode: countryCode,
      RequestKeys.mobile: mobile,
      RequestKeys.otp: ?otp,
    };
  }

  static Future<ResponseWrapperModel<dynamic>> _post(
    String url,
    Map<String, dynamic> body,
  ) async {
    final json = await ApiClientMethods.postMethod(url: url, body: body);
    return ResponseWrapperModel.fromJson(json, null);
  }

  static Future<ResponseWrapperModel<T?>> _postParsed<T>(
    String url,
    Map<String, dynamic> body,
    T? Function(dynamic data) parse,
  ) async {
    final json = await ApiClientMethods.postMethod(url: url, body: body);
    return ResponseWrapperModel.fromJson(json, parse);
  }

  static Future<ResponseWrapperModel<T?>> _patchParsed<T>(
    String url,
    Map<String, dynamic> body,
    T? Function(dynamic data) parse,
  ) async {
    final json = await ApiClientMethods.patchMethod(url: url, body: body);
    return ResponseWrapperModel.fromJson(json, parse);
  }

  static Future<ResponseWrapperModel<T?>> _putParsed<T>(
    String url,
    Map<String, dynamic> body,
    T? Function(dynamic data) parse,
  ) async {
    final json = await ApiClientMethods.putMethod(url: url, body: body);
    return ResponseWrapperModel.fromJson(json, parse);
  }

  static Future<ResponseWrapperModel<T?>> _multipartParsed<T>(
    String url, {
    Map<String, String>? fields,
    Map<String, File>? files,
    required T? Function(dynamic data) parse,
  }) async {
    final json = await ApiClientMethods.postMultipart(
      url: url,
      fields: fields,
      files: files,
    );
    return ResponseWrapperModel.fromJson(json, parse);
  }
}
