import 'package:flutter/foundation.dart';

String? asString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text == 'null') return null;
  return text;
}

int? asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool? asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().toLowerCase().trim();
  if (text == 'true' || text == '1' || text == 'yes') return true;
  if (text == 'false' || text == '0' || text == 'no') return false;
  return null;
}

Map<String, dynamic>? asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<T> asModelList<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) return [];
  final list = <T>[];
  for (final item in value) {
    final map = asMap(item);
    if (map == null) continue;
    try {
      list.add(fromJson(map));
    } catch (e, st) {
      debugPrint('Model list parse failed: $e\n$st');
    }
  }
  return list;
}
