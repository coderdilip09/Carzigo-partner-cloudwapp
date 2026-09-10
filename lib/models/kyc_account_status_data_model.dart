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

  String? get _approval => approval?.toLowerCase();
  String? get _partnerStatus => partnerStatus?.toLowerCase();
  String? get _kycStatus => kycStatus?.toLowerCase();

  /// Partner account approved — only then open Dashboard.
  bool get isApproved =>
      _approval == KycOverallStatus.approved ||
      _partnerStatus == KycOverallStatus.approved ||
      _partnerStatus == KycOverallStatus.active;

  /// KYC has been submitted and is waiting on review / partner approval.
  /// Draft / in-progress KYC must stay on KYC Overview even if approval is pending.
  bool get isSubmittedForReview {
    if (isApproved) return false;

    final kyc = _kycStatus;
    if (kyc == KycOverallStatus.pendingReview ||
        kyc == KycOverallStatus.submitted) {
      return true;
    }

    if (_approval == KycOverallStatus.pending ||
        _partnerStatus == KycOverallStatus.pending) {
      if (kyc == KycOverallStatus.approved ||
          kyc == KycOverallStatus.verified ||
          kyc == KycOverallStatus.pending ||
          (submittedAt ?? '').trim().isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  bool get isPendingReview => isSubmittedForReview;

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
