import 'dart:io';

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
  }) {
    return _postParsed(
      ApiUrls.verifyOtpUrl(),
      _otpBody(countryCode: countryCode, mobile: mobile, otp: otp),
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

  static Future<ResponseWrapperModel<dynamic>> changePhoneSendOtp({
    required String countryCode,
    required String phone,
  }) {
    return _post(ApiUrls.changePhoneSendOtpUrl(), {
      RequestKeys.countryCode: countryCode,
      RequestKeys.phone: phone,
    });
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
        RequestKeys.phone: phone,
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

  static Future<ResponseWrapperModel<KycStatusModel?>> uploadBank({
    required String holderName,
    required String accountNumber,
    required String ifsc,
    required String bankName,
    required String chequeUrl,
  }) {
    return _putParsed(ApiUrls.kycBankUrl(), {
      RequestKeys.holderName: holderName,
      RequestKeys.accountNumber: accountNumber,
      RequestKeys.ifsc: ifsc,
      RequestKeys.bankName: bankName,
      RequestKeys.chequeUrl: chequeUrl,
    }, (data) => KycStatusModel.fromJson(asMap(data) ?? {}));
  }

  static Future<ResponseWrapperModel<KycSubmitDataModel?>> submitKyc() {
    return _postParsed(
      ApiUrls.kycSubmitUrl(),
      {},
      (data) => KycSubmitDataModel.fromJson(asMap(data) ?? {}),
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

  static Future<ResponseWrapperModel<CmsDataModel?>> getLegalPage(
    String slug,
  ) async {
    final json = await ApiClientMethods.getMethod(
      url: ApiUrls.legalUrl(slug),
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
