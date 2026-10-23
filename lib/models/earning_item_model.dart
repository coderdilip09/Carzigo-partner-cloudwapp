import 'package:carzigo_partner/models/json_parsers.dart';

class EarningsSummaryModel {
  const EarningsSummaryModel({
    this.total = 0,
    this.wash = 0,
    this.exterior = 0,
    this.interior = 0,
    this.referral = 0,
  });

  final int total;
  final int wash;
  final int exterior;
  final int interior;
  final int referral;

  factory EarningsSummaryModel.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return EarningsSummaryModel(
      total: _asInt(map['total']),
      wash: _asInt(map['wash']),
      exterior: _asInt(map['exterior']),
      interior: _asInt(map['interior']),
      referral: _asInt(map['referral']),
    );
  }
}

class EarningItemModel {
  const EarningItemModel({
    this.id,
    this.type,
    this.title,
    this.amount = 0,
    this.date,
    this.at,
    this.subtitle,
    this.status,
    this.scheduleCode,
  });

  final String? id;
  final String? type;
  final String? title;
  final int amount;
  final String? date;
  final String? at;
  final String? subtitle;
  final String? status;
  final String? scheduleCode;

  bool get isReferral => (type ?? '').toLowerCase() == 'referral';
  bool get isInterior => (type ?? '').toLowerCase() == 'interior';
  bool get isExterior => (type ?? '').toLowerCase() == 'exterior';

  factory EarningItemModel.fromJson(Map<String, dynamic> json) {
    final meta = asMap(json['meta']) ?? const <String, dynamic>{};
    return EarningItemModel(
      id: asString(json['id']),
      type: asString(json['type']),
      title: asString(json['title']),
      amount: _asInt(json['amount']),
      date: asString(json['date']),
      at: asString(json['at']),
      subtitle: asString(json['subtitle']),
      status: asString(meta['status'] ?? json['status']),
      scheduleCode: asString(meta['schedule_code'] ?? meta['scheduleCode']),
    );
  }
}

class EarningGroupModel {
  const EarningGroupModel({
    this.date,
    this.label,
    this.total = 0,
    this.items = const [],
  });

  final String? date;
  final String? label;
  final int total;
  final List<EarningItemModel> items;

  factory EarningGroupModel.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = raw is List
        ? raw
              .whereType<Map>()
              .map((e) => EarningItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <EarningItemModel>[];
    return EarningGroupModel(
      date: asString(json['date']),
      label: asString(json['label']),
      total: _asInt(json['total']),
      items: items,
    );
  }
}

class EarningsDataModel {
  const EarningsDataModel({
    this.type = 'all',
    this.summary = const EarningsSummaryModel(),
    this.groups = const [],
    this.hasMore = false,
    this.page = 1,
  });

  final String type;
  final EarningsSummaryModel summary;
  final List<EarningGroupModel> groups;
  final bool hasMore;
  final int page;

  factory EarningsDataModel.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    final rawGroups = map['groups'];
    final groups = rawGroups is List
        ? rawGroups
              .whereType<Map>()
              .map((e) => EarningGroupModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : <EarningGroupModel>[];
    return EarningsDataModel(
      type: asString(map['type']) ?? 'all',
      summary: EarningsSummaryModel.fromJson(asMap(map['summary'])),
      groups: groups,
      hasMore: map['has_more'] == true || map['hasMore'] == true,
      page: _asInt(map['page'], fallback: 1),
    );
  }
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse('$value') ?? fallback;
}
