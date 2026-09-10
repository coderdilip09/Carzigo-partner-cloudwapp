import 'package:carzigo_partner/models/json_parsers.dart';

class KycOverallStatus {
  KycOverallStatus._();

  static const String draft = 'draft';
  static const String notStarted = 'not_started';
  static const String inProgress = 'in_progress';
  static const String submitted = 'submitted';
  static const String pending = 'pending';
  static const String pendingReview = 'pending_review';
  static const String approved = 'approved';
  static const String verified = 'verified';
  static const String rejected = 'rejected';
  static const String active = 'active';
}

class KycStepKey {
  KycStepKey._();

  static const String identity = 'identity';
  static const String address = 'address';
  static const String bank = 'bank';
  static const String photo = 'photo';
}

class KycDocType {
  KycDocType._();

  static const String aadhaar = 'aadhaar';
  static const String pan = 'pan';
  static const String drivingLicense = 'driving_license';
}

class KycStepDataModel {
  KycStepDataModel({this.key, this.label, this.status});

  final String? key;
  final String? label;
  final String? status;

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending' || status == null;

  factory KycStepDataModel.fromJson(Map<String, dynamic> json) {
    return KycStepDataModel(
      key: asString(json['key']),
      label: asString(json['label']),
      status: asString(json['status']),
    );
  }
}

class KycDocumentDataModel {
  KycDocumentDataModel({
    this.docType,
    this.maskedNumber,
    this.frontUrl,
    this.backUrl,
    this.documentUrl,
    this.status,
    this.completed,
  });

  final String? docType;
  final String? maskedNumber;
  final String? frontUrl;
  final String? backUrl;
  final String? documentUrl;
  final String? status;
  final bool? completed;

  bool get isDone =>
      completed == true ||
      asBool(status) == true ||
      status == 'done' ||
      status == 'uploaded' ||
      status == 'approved' ||
      status == 'completed' ||
      frontUrl != null ||
      documentUrl != null;

  factory KycDocumentDataModel.fromJson(Map<String, dynamic> json) {
    return KycDocumentDataModel(
      docType: asString(json['docType'] ?? json['doc_type'] ?? json['type']),
      maskedNumber: asString(
        json['doc_number_masked'] ??
            json['maskedNumber'] ??
            json['masked_number'] ??
            json['number'],
      ),
      frontUrl: asString(
        json['frontUrl'] ?? json['front_url'] ?? json['front'],
      ),
      backUrl: asString(json['backUrl'] ?? json['back_url'] ?? json['back']),
      documentUrl: asString(
        json['doc_url'] ??
            json['documentUrl'] ??
            json['document_url'] ??
            json['url'],
      ),
      status: asString(json['status']),
      completed: asBool(json['completed']),
    );
  }
}

class BankDetailsDataModel {
  BankDetailsDataModel({
    this.holderName,
    this.accountNumber,
    this.accountNumberMasked,
    this.ifsc,
    this.bankName,
    this.chequeUrl,
    this.status,
    this.completed,
  });

  final String? holderName;
  final String? accountNumber;
  final String? accountNumberMasked;
  final String? ifsc;
  final String? bankName;
  final String? chequeUrl;
  final String? status;
  final bool? completed;

  bool get isDone =>
      completed == true ||
      asBool(status) == true ||
      status == 'done' ||
      status == 'uploaded' ||
      status == 'approved' ||
      status == 'completed' ||
      accountNumber != null ||
      accountNumberMasked != null;

  factory BankDetailsDataModel.fromJson(Map<String, dynamic> json) {
    return BankDetailsDataModel(
      holderName: asString(
        json['account_holder_name'] ??
            json['holderName'] ??
            json['holder_name'] ??
            json['accountHolderName'],
      ),
      accountNumber: asString(json['accountNumber'] ?? json['account_number']),
      accountNumberMasked: asString(
        json['accountNumberMasked'] ??
            json['account_number_masked'] ??
            json['maskedAccount'],
      ),
      ifsc: asString(json['ifsc'] ?? json['ifscCode'] ?? json['ifsc_code']),
      bankName: asString(json['bankName'] ?? json['bank_name']),
      chequeUrl: asString(
        json['chequeUrl'] ?? json['cheque_url'] ?? json['cheque'],
      ),
      status: asString(json['status']),
      completed: asBool(json['completed']),
    );
  }
}

class KycStatusModel {
  KycStatusModel({
    this.overallStatus,
    this.partnerKycStatus,
    this.approval,
    this.message,
    this.rejectReason,
    this.canSubmit,
    this.steps = const [],
    this.identityDone,
    this.addressDone,
    this.bankDone,
    this.profilePhotoDone,
    this.identity,
    this.address,
    this.bank,
    this.profile,
  });

  final String? overallStatus;
  final String? partnerKycStatus;
  final String? approval;
  final String? message;
  final String? rejectReason;
  final bool? canSubmit;
  final List<KycStepDataModel> steps;
  final bool? identityDone;
  final bool? addressDone;
  final bool? bankDone;
  final bool? profilePhotoDone;
  final KycDocumentDataModel? identity;
  final KycDocumentDataModel? address;
  final BankDetailsDataModel? bank;
  final KycProfileDataModel? profile;

  KycStepDataModel? stepByKey(String key) {
    for (final step in steps) {
      if (step.key == key) return step;
    }
    return null;
  }

  bool _isStepCompleted(String key, bool? fallback, bool nestedDone) {
    final step = stepByKey(key);
    if (step?.isCompleted == true) return true;
    return fallback == true || nestedDone;
  }

  bool get isIdentityDone => _isStepCompleted(
    KycStepKey.identity,
    identityDone,
    identity?.isDone ?? false,
  );
  bool get isAddressDone => _isStepCompleted(
    KycStepKey.address,
    addressDone,
    address?.isDone ?? false,
  );
  bool get isBankDone =>
      _isStepCompleted(KycStepKey.bank, bankDone, bank?.isDone ?? false);
  bool get isProfilePhotoDone => _isStepCompleted(
    KycStepKey.photo,
    profilePhotoDone,
    profile?.photo != null,
  );

  bool get isApproved =>
      overallStatus == KycOverallStatus.approved ||
      partnerKycStatus == KycOverallStatus.approved;
  bool get isRejected =>
      overallStatus == KycOverallStatus.rejected ||
      partnerKycStatus == KycOverallStatus.rejected;
  bool get isSubmitted => overallStatus == KycOverallStatus.submitted;
  bool get isDraft => overallStatus == KycOverallStatus.draft;
  bool get isInProgress => overallStatus == KycOverallStatus.inProgress;
  bool get isNotStarted =>
      overallStatus == null || overallStatus == KycOverallStatus.notStarted;

  factory KycStatusModel.fromJson(Map<String, dynamic> json) {
    final identityMap = asMap(json['identity'] ?? json['identityProof']);
    final addressMap = asMap(json['address'] ?? json['addressProof']);
    final bankMap = asMap(
      json['bank'] ?? json['bankDetails'] ?? json['bank_details'],
    );
    final profileMap = asMap(json['profile']);
    final stepsComplete = asMap(
      json['steps_complete'] ?? json['stepsComplete'],
    );

    return KycStatusModel(
      overallStatus: asString(
        json['kyc_status'] ??
            json['overallStatus'] ??
            json['overall_status'] ??
            json['kycStatus'],
      ),
      partnerKycStatus: asString(
        json['partner_kyc_status'] ?? json['partnerKycStatus'],
      ),
      approval: asString(json['approval']),
      message: asString(json['message']),
      rejectReason: asString(
        json['rejection_reason'] ??
            json['rejectReason'] ??
            json['reject_reason'] ??
            json['reason'],
      ),
      canSubmit: asBool(json['can_submit'] ?? json['canSubmit']),
      steps: asModelList(json['steps'], KycStepDataModel.fromJson),
      identityDone: asBool(
        json['identityDone'] ??
            json['identity_done'] ??
            stepsComplete?['identity'],
      ),
      addressDone: asBool(
        json['addressDone'] ??
            json['address_done'] ??
            stepsComplete?['address'],
      ),
      bankDone: asBool(
        json['bankDone'] ?? json['bank_done'] ?? stepsComplete?['bank'],
      ),
      profilePhotoDone: asBool(
        json['profilePhotoDone'] ??
            json['profile_photo_done'] ??
            stepsComplete?['photo'],
      ),
      identity: identityMap == null
          ? null
          : KycDocumentDataModel.fromJson(identityMap),
      address: addressMap == null
          ? null
          : KycDocumentDataModel.fromJson(addressMap),
      bank: bankMap == null ? null : BankDetailsDataModel.fromJson(bankMap),
      profile: profileMap == null
          ? null
          : KycProfileDataModel.fromJson(profileMap),
    );
  }
}

class KycProfileDataModel {
  KycProfileDataModel({this.name, this.email, this.mobile, this.photo});

  final String? name;
  final String? email;
  final String? mobile;
  final String? photo;

  factory KycProfileDataModel.fromJson(Map<String, dynamic> json) {
    return KycProfileDataModel(
      name: asString(json['name']),
      email: asString(json['email']),
      mobile: asString(json['mobile'] ?? json['phone']),
      photo: asString(json['photo'] ?? json['photo_url'] ?? json['photoUrl']),
    );
  }
}
