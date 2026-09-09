import 'package:carzigo_partner/models/json_parsers.dart';
import 'package:carzigo_partner/models/kyc_status_model.dart';

class UserDataModel {
  UserDataModel({
    this.id,
    this.role,
    this.name,
    this.fullName,
    this.email,
    this.phone,
    this.countryCode,
    this.photoUrl,
    this.status,
    this.approval,
    this.isProfileComplete,
    this.kycStatus,
  });

  final String? id;
  final String? role;
  final String? name;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? countryCode;
  final String? photoUrl;
  final String? status;
  final String? approval;
  final bool? isProfileComplete;
  final String? kycStatus;

  String get displayName => fullName ?? name ?? '';

  String get displayPhone {
    final p = phone?.trim() ?? '';
    if (p.isEmpty) return '';
    final cc = countryCode?.trim() ?? '';
    if (cc.isEmpty || p.startsWith('+') || (cc.isNotEmpty && p.startsWith(cc))) {
      return p;
    }
    return '$cc $p';
  }

  bool get hasCompletedProfile => isProfileComplete == true;

  UserDataModel copyWith({
    String? id,
    String? role,
    String? name,
    String? fullName,
    String? email,
    String? phone,
    String? countryCode,
    String? photoUrl,
    String? status,
    String? approval,
    bool? isProfileComplete,
    String? kycStatus,
  }) {
    return UserDataModel(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      approval: approval ?? this.approval,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      kycStatus: kycStatus ?? this.kycStatus,
    );
  }

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: asString(
        json['id'] ?? json['_id'] ?? json['userId'] ?? json['user_id'],
      ),
      role: asString(json['role']),
      name: asString(json['name'] ?? json['firstName'] ?? json['first_name']),
      fullName: asString(json['fullName'] ?? json['full_name'] ?? json['name']),
      email: asString(json['email']),
      phone: asString(json['phone'] ?? json['mobile'] ?? json['phoneNumber']),
      countryCode: asString(json['countryCode'] ?? json['country_code']),
      photoUrl: asString(
        json['photoUrl'] ??
            json['photo_url'] ??
            json['profilePhoto'] ??
            json['profile_photo'] ??
            json['avatar'] ??
            json['photo'],
      ),
      status: asString(json['status']),
      approval: asString(json['approval']),
      isProfileComplete: asBool(
        json['isProfileComplete'] ??
            json['is_profile_complete'] ??
            json['profile_complete'],
      ),
      kycStatus: asString(json['kycStatus'] ?? json['kyc_status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'name': name,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'countryCode': countryCode,
      'photoUrl': photoUrl,
      'status': status,
      'approval': approval,
      'isProfileComplete': isProfileComplete,
      'kycStatus': kycStatus,
    };
  }
}

class AuthDataModel {
  AuthDataModel({
    this.token,
    this.isNew,
    this.needsProfile,
    this.role,
    this.user,
    this.kyc,
  });

  final String? token;
  final bool? isNew;
  final bool? needsProfile;
  final String? role;
  final UserDataModel? user;
  final KycStatusModel? kyc;

  factory AuthDataModel.fromJson(Map<String, dynamic> json) {
    final userMap = asMap(json['user'] ?? json['partner']);
    final kycMap = asMap(json['kyc']);

    return AuthDataModel(
      token: asString(
        json['token'] ?? json['accessToken'] ?? json['access_token'],
      ),
      isNew: asBool(json['is_new'] ?? json['isNew']),
      needsProfile: asBool(json['needs_profile'] ?? json['needsProfile']),
      role: asString(json['role']),
      user: userMap == null ? null : UserDataModel.fromJson(userMap),
      kyc: kycMap == null ? null : KycStatusModel.fromJson(kycMap),
    );
  }
}
