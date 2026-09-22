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
  static const String localAddress = 'local_address';
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
  bool get isRejected => status == 'rejected';

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
    this.fullName,
    this.verifiedVia,
    this.status,
    this.completed,
  });

  final String? docType;
  final String? maskedNumber;
  final String? frontUrl;
  final String? backUrl;
  final String? documentUrl;
  final String? fullName;
  final String? verifiedVia;
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
      documentUrl != null ||
      verifiedVia == 'digilocker';

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
      fullName: asString(json['full_name'] ?? json['fullName'] ?? json['name']),
      verifiedVia: asString(json['verified_via'] ?? json['verifiedVia']),
      status: asString(json['status']),
      completed: asBool(json['completed']),
    );
  }
}

class LocalAddressDataModel {
  LocalAddressDataModel({
    this.addressLine,
    this.landmark,
    this.city,
    this.state,
    this.pincode,
    this.completed,
  });

  final String? addressLine;
  final String? landmark;
  final String? city;
  final String? state;
  final String? pincode;
  final bool? completed;

  bool get isDone =>
      completed == true ||
      ((addressLine?.trim().isNotEmpty ?? false) &&
          (city?.trim().isNotEmpty ?? false) &&
          (state?.trim().isNotEmpty ?? false) &&
          (pincode?.trim().isNotEmpty ?? false));

  factory LocalAddressDataModel.fromJson(Map<String, dynamic> json) {
    return LocalAddressDataModel(
      addressLine: asString(
        json['address_line'] ?? json['addressLine'] ?? json['line'],
      ),
      landmark: asString(json['landmark']),
      city: asString(json['city']),
      state: asString(json['state']),
      pincode: asString(json['pincode'] ?? json['pin_code'] ?? json['pinCode']),
      completed: asBool(json['completed']),
    );
  }
}

class DigilockerStartDataModel {
  DigilockerStartDataModel({
    this.clientId,
    this.token,
    this.url,
    this.gateway,
    this.expirySeconds,
    this.mock = false,
  });

  final String? clientId;
  final String? token;
  final String? url;
  final String? gateway;
  final num? expirySeconds;
  final bool mock;

  bool get isMock =>
      mock || gateway == 'mock' || (clientId?.startsWith('mock_digilocker_') ?? false);

  factory DigilockerStartDataModel.fromJson(Map<String, dynamic> json) {
    return DigilockerStartDataModel(
      clientId: asString(json['client_id'] ?? json['clientId']),
      token: asString(json['token'] ?? json['sdk_token'] ?? json['sdkToken']),
      url: asString(
        json['url'] ??
            json['link'] ??
            json['redirect_url'] ??
            json['redirectUrl'],
      ),
      gateway: asString(json['gateway']),
      expirySeconds: json['expiry_seconds'] as num? ??
          json['expirySeconds'] as num?,
      mock: asBool(json['mock']) == true,
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
    this.bankBranch,
    this.chequeUrl,
    this.status,
    this.completed,
  });

  final String? holderName;
  final String? accountNumber;
  final String? accountNumberMasked;
  final String? ifsc;
  final String? bankName;
  final String? bankBranch;
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
      bankBranch: asString(
        json['bankBranch'] ?? json['bank_branch'] ?? json['branch'],
      ),
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
    this.rejectedAddressReason,
    this.rejectedBankReason,
    this.canSubmit,
    this.steps = const [],
    this.identityDone,
    this.addressDone,
    this.localAddressDone,
    this.bankDone,
    this.profilePhotoDone,
    this.identity,
    this.address,
    this.localAddress,
    this.addressSameAsDocument,
    this.bank,
    this.profile,
  });

  final String? overallStatus;
  final String? partnerKycStatus;
  final String? approval;
  final String? message;
  final String? rejectReason;
  final String? rejectedAddressReason;
  final String? rejectedBankReason;
  final bool? canSubmit;
  final List<KycStepDataModel> steps;
  final bool? identityDone;
  final bool? addressDone;
  final bool? localAddressDone;
  final bool? bankDone;
  final bool? profilePhotoDone;
  final KycDocumentDataModel? identity;
  final KycDocumentDataModel? address;
  final LocalAddressDataModel? localAddress;
  /// null = not answered yet; true = Yes; false = No.
  final bool? addressSameAsDocument;
  final BankDetailsDataModel? bank;
  final KycProfileDataModel? profile;

  KycStepDataModel? stepByKey(String key) {
    for (final step in steps) {
      if (step.key == key) return step;
    }
    return null;
  }

  bool get isAddressRejected =>
      (rejectedAddressReason != null &&
          rejectedAddressReason!.trim().isNotEmpty) ||
      stepByKey(KycStepKey.address)?.isRejected == true;

  bool get isBankRejected =>
      (rejectedBankReason != null && rejectedBankReason!.trim().isNotEmpty) ||
      stepByKey(KycStepKey.bank)?.isRejected == true;

  bool get hasSectionRejection => isAddressRejected || isBankRejected;

  bool _isStepCompleted(String key, bool? fallback, bool nestedDone) {
    final step = stepByKey(key);
    if (step?.isRejected == true) return false;
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
    (address?.isDone ?? false) && (localAddress?.isDone ?? false),
  );
  bool get isLocalAddressDone => _isStepCompleted(
    KycStepKey.localAddress,
    localAddressDone,
    localAddress?.isDone ?? false,
  );
  /// Address Proof card (unified doc + residential fields).
  bool get isAddressProofDone =>
      isAddressDone || (isLocalAddressDone && (address?.isDone ?? false));
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
    final localAddressMap = asMap(
      json['local_address'] ?? json['localAddress'],
    );
    final addressProofMap = asMap(
      json['address_proof'] ?? json['addressProof'],
    );
    final bankMap = asMap(
      json['bank'] ?? json['bankDetails'] ?? json['bank_details'],
    );
    final profileMap = asMap(json['profile']);
    final stepsComplete = asMap(
      json['steps_complete'] ?? json['stepsComplete'],
    );

    final rejectedSections = asMap(
      json['rejected_sections'] ?? json['rejectedSections'],
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
      rejectedAddressReason: asString(
        rejectedSections?['address'] ??
            json['address_rejection_reason'] ??
            json['addressRejectionReason'],
      ),
      rejectedBankReason: asString(
        rejectedSections?['bank'] ??
            json['bank_rejection_reason'] ??
            json['bankRejectionReason'],
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
      localAddressDone: asBool(
        json['localAddressDone'] ??
            json['local_address_done'] ??
            stepsComplete?['local_address'],
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
      localAddress: localAddressMap == null
          ? null
          : LocalAddressDataModel.fromJson(localAddressMap),
      addressSameAsDocument: asBool(
        addressProofMap?['same_as_document'] ??
            addressProofMap?['sameAsDocument'] ??
            json['address_same_as_document'] ??
            json['addressSameAsDocument'],
      ),
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
