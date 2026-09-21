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
    this.rejectedAddressReason,
    this.rejectedBankReason,
    this.message,
  });

  final String? kycStatus;
  final String? partnerStatus;
  final String? approval;
  final String? partnerKycStatus;
  final String? submittedAt;
  final String? rejectionReason;
  final String? rejectedAddressReason;
  final String? rejectedBankReason;
  final String? message;

  String? get _approval => approval?.toLowerCase();
  String? get _partnerStatus => partnerStatus?.toLowerCase();
  String? get _kycStatus => kycStatus?.toLowerCase();

  /// Partner account approved — only then open Dashboard.
  bool get isApproved =>
      _approval == KycOverallStatus.approved ||
      _partnerStatus == KycOverallStatus.approved ||
      _partnerStatus == KycOverallStatus.active;

  bool get isRejected =>
      _kycStatus == KycOverallStatus.rejected ||
      partnerKycStatus?.toLowerCase() == KycOverallStatus.rejected;

  /// KYC has been submitted and is waiting on review / partner approval.
  /// Draft / rejected / in-progress KYC must stay on KYC Overview.
  bool get isSubmittedForReview {
    if (isApproved) return false;
    if (isRejected) return false;

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
    final rejectedSections = asMap(
      json['rejected_sections'] ?? json['rejectedSections'],
    );
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
      rejectedAddressReason: asString(rejectedSections?['address']),
      rejectedBankReason: asString(rejectedSections?['bank']),
      message: asString(json['message']),
    );
  }
}
