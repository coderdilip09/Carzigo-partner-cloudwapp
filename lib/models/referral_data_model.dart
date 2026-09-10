import 'package:carzigo_partner/models/json_parsers.dart';

class ReferralHowItWorksStepModel {
  ReferralHowItWorksStepModel({this.step, this.title, this.description});

  final int? step;
  final String? title;
  final String? description;

  factory ReferralHowItWorksStepModel.fromJson(Map<String, dynamic> json) {
    return ReferralHowItWorksStepModel(
      step: asInt(json['step']),
      title: asString(json['title']),
      description: asString(json['description'] ?? json['desc']),
    );
  }
}

class ReferralStatsModel {
  ReferralStatsModel({
    this.totalReferred,
    this.onboarded,
    this.completedFirstWash,
  });

  final int? totalReferred;
  final int? onboarded;
  final int? completedFirstWash;

  factory ReferralStatsModel.fromJson(Map<String, dynamic> json) {
    return ReferralStatsModel(
      totalReferred: asInt(json['total_referred'] ?? json['totalReferred']),
      onboarded: asInt(json['onboarded']),
      completedFirstWash: asInt(
        json['completed_first_wash'] ?? json['completedFirstWash'],
      ),
    );
  }
}

class ReferredCustomerDataModel {
  ReferredCustomerDataModel({
    this.id,
    this.initials,
    this.name,
    this.phone,
    this.status,
    this.amount,
  });

  final String? id;
  final String? initials;
  final String? name;
  final String? phone;
  final String? status;
  final String? amount;

  String get displayName => name ?? '';

  String get displayPhone => phone ?? '';

  String get displayStatus => status ?? '';

  String get displayInitials {
    final saved = initials?.trim();
    if (saved != null && saved.isNotEmpty) return saved.toUpperCase();
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  factory ReferredCustomerDataModel.fromJson(Map<String, dynamic> json) {
    return ReferredCustomerDataModel(
      id: asString(json['id'] ?? json['_id']),
      initials: asString(json['initials']),
      name: asString(json['name'] ?? json['full_name'] ?? json['fullName']),
      phone: asString(json['phone'] ?? json['mobile']),
      status: asString(json['status'] ?? json['label']),
      amount: asString(
        json['amount'] ?? json['reward'] ?? json['reward_amount'] ?? json['rewardAmount'],
      ),
    );
  }
}

class ReferralDataModel {
  ReferralDataModel({
    this.code,
    this.link,
    this.rewardAmount,
    this.howItWorks = const [],
    this.stats,
    this.weekStats,
    this.customers = const [],
  });

  final String? code;
  final String? link;
  final int? rewardAmount;
  final List<ReferralHowItWorksStepModel> howItWorks;
  final ReferralStatsModel? stats;
  final ReferralStatsModel? weekStats;
  final List<ReferredCustomerDataModel> customers;

  String get rewardLabel {
    if (rewardAmount == null) return '';
    return '₹$rewardAmount';
  }

  static String pad(int? value) => (value ?? 0).toString().padLeft(2, '0');

  factory ReferralDataModel.fromJson(Map<String, dynamic> json) {
    final statsMap = asMap(json['stats'] ?? json['month_stats'] ?? json['monthStats']);
    final weekStatsMap = asMap(json['week_stats'] ?? json['weekStats']);
    final rawCustomers =
        json['referred_customers'] ??
        json['referredCustomers'] ??
        json['customers'] ??
        json['list'];
    return ReferralDataModel(
      code: asString(
        json['referral_code'] ?? json['referralCode'] ?? json['code'],
      ),
      link: asString(
        json['referral_link'] ?? json['referralLink'] ?? json['link'],
      ),
      rewardAmount: asInt(json['reward_amount'] ?? json['rewardAmount']),
      howItWorks: asModelList(
        json['how_it_works'] ?? json['howItWorks'],
        ReferralHowItWorksStepModel.fromJson,
      ),
      stats: statsMap == null ? null : ReferralStatsModel.fromJson(statsMap),
      weekStats:
          weekStatsMap == null ? null : ReferralStatsModel.fromJson(weekStatsMap),
      customers: asModelList(rawCustomers, ReferredCustomerDataModel.fromJson),
    );
  }
}
