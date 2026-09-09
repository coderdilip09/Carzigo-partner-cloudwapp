import 'package:carzigo_partner/models/json_parsers.dart';

class NotificationDataModel {
  NotificationDataModel({
    this.id,
    this.title,
    this.body,
    this.time,
    this.isRead,
  });

  final String? id;
  final String? title;
  final String? body;
  final String? time;
  final bool? isRead;

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) {
    return NotificationDataModel(
      id: asString(json['id'] ?? json['_id']),
      title: asString(json['title']),
      body: asString(json['body'] ?? json['message'] ?? json['description']),
      time: asString(
        json['time'] ?? json['createdAt'] ?? json['created_at'] ?? json['ago'],
      ),
      isRead: asBool(json['isRead'] ?? json['is_read'] ?? json['read']),
    );
  }
}
