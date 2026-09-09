import 'package:carzigo_partner/models/json_parsers.dart';

class KycSubmitDataModel {
  KycSubmitDataModel({this.kycStatus, this.submittedAt, this.message});

  final String? kycStatus;
  final String? submittedAt;
  final String? message;

  factory KycSubmitDataModel.fromJson(Map<String, dynamic> json) {
    return KycSubmitDataModel(
      kycStatus: asString(json['kyc_status'] ?? json['kycStatus']),
      submittedAt: asString(json['submitted_at'] ?? json['submittedAt']),
      message: asString(json['message']),
    );
  }
}
