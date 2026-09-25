import 'package:carzigo_partner/models/json_parsers.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationDataModel {
  NotificationDataModel({
    this.id,
    this.title,
    this.body,
    this.time,
    this.type,
    this.serviceId,
    this.screen,
    this.isRead,
  });

  final String? id;
  final String? title;
  final String? body;
  final String? time;
  final String? type;
  final String? serviceId;
  final String? screen;
  final bool? isRead;

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) {
    return NotificationDataModel(
      id: asString(json['id'] ?? json['_id']),
      title: asString(json['title']),
      body: asString(json['body'] ?? json['message'] ?? json['description']),
      time: _formatLocalTime(json),
      type: asString(json['type'] ?? json['notification_type']),
      serviceId: asString(
        json['service_id'] ?? json['serviceId'] ?? json['schedule_id'],
      ),
      screen: asString(json['screen']),
      isRead: asBool(json['isRead'] ?? json['is_read'] ?? json['read']),
    );
  }

  /// Device-local clock from ISO `created_at`; fallback to API relative label.
  static String? _formatLocalTime(Map<String, dynamic> json) {
    final created = _parseCreatedAt(json['created_at'] ?? json['createdAt']);
    if (created != null) {
      final local = created.toLocal();
      final now = DateTime.now();
      final sameDay = local.year == now.year &&
          local.month == now.month &&
          local.day == now.day;
      if (sameDay) {
        return DateFormat('h:mm a').format(local);
      }
      return DateFormat('dd MMM, h:mm a').format(local);
    }
    return asString(
      json['time'] ??
          json['relative_time'] ??
          json['relativeTime'] ??
          json['ago'],
    );
  }

  static DateTime? _parseCreatedAt(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    final text = raw.toString().trim();
    if (text.isEmpty) return null;

    DateTime? parsed = DateTime.tryParse(text);
    final hasZone = text.endsWith('Z') ||
        RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(text);
    if (parsed != null && !hasZone && !text.contains('T')) {
      parsed = DateTime.tryParse('${text.replaceFirst(' ', 'T')}Z');
    }
    return parsed;
  }
}
