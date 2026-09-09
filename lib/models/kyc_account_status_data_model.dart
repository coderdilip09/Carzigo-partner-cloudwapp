import 'package:carzigo_partner/models/json_parsers.dart';
import 'package:carzigo_partner/models/kyc_status_model.dart';

class KycAccountStatusDataModel {
  KycAccountStatusDataModel({
    this.kycStatus,
    this.partnerStatus,
    this.approval,
    this.partnerKycStatus,
    this.submittedAt,
    this.rejectionReason,
    this.message,
  });

  final String? kycStatus;
  final String? partnerStatus;
  final String? approval;
  final String? partnerKycStatus;
  final String? submittedAt;
  final String? rejectionReason;
  final String? message;

  bool get isApproved =>
      kycStatus == KycOverallStatus.approved ||
      approval == KycOverallStatus.approved ||
      partnerKycStatus == KycOverallStatus.approved ||
      partnerStatus == KycOverallStatus.approved;

  bool get isPendingReview =>
      kycStatus == KycOverallStatus.pendingReview ||
      kycStatus == KycOverallStatus.pending ||
      kycStatus == KycOverallStatus.submitted ||
      approval == KycOverallStatus.pending ||
      partnerKycStatus == KycOverallStatus.pending;

  bool get isSubmittedForReview {
    final status = kycStatus?.toLowerCase();
    return status == KycOverallStatus.pendingReview ||
        status == KycOverallStatus.submitted;
  }

  factory KycAccountStatusDataModel.fromJson(Map<String, dynamic> json) {
    return KycAccountStatusDataModel(
      kycStatus: asString(json['kyc_status'] ?? json['kycStatus']),
      partnerStatus: asString(
        json['partner_status'] ?? json['partnerStatus'],
      ),
      approval: asString(json['approval']),
      partnerKycStatus: asString(
        json['partner_kyc_status'] ?? json['partnerKycStatus'],
      ),
      submittedAt: asString(json['submitted_at'] ?? json['submittedAt']),
      rejectionReason: asString(
        json['rejection_reason'] ??
            json['rejectReason'] ??
            json['reject_reason'],
      ),
      message: asString(json['message']),
    );
  }
}
