import 'package:carzigo_partner/models/json_parsers.dart';

class OtpDataModel {
  OtpDataModel({
    this.mobile,
    this.countryCode,
    this.expiresInSeconds,
    this.resendAfterSeconds,
  });

  final String? mobile;
  final String? countryCode;
  final int? expiresInSeconds;
  final int? resendAfterSeconds;

  factory OtpDataModel.fromJson(Map<String, dynamic> json) {
    return OtpDataModel(
      mobile: asString(json['mobile'] ?? json['phone']),
      countryCode: asString(json['country_code'] ?? json['countryCode']),
      expiresInSeconds: asInt(
        json['expires_in_seconds'] ?? json['expiresInSeconds'],
      ),
      resendAfterSeconds: asInt(
        json['resend_after_seconds'] ?? json['resendAfterSeconds'],
      ),
    );
  }
}
