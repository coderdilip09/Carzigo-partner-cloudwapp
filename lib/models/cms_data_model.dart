import 'package:carzigo_partner/models/json_parsers.dart';

class CmsDataModel {
  CmsDataModel({
    this.type,
    this.slug,
    this.title,
    this.body,
    this.updatedAt,
  });

  final String? type;
  final String? slug;
  final String? title;
  final String? body;
  final String? updatedAt;

  factory CmsDataModel.fromJson(Map<String, dynamic> json) {
    return CmsDataModel(
      type: asString(json['type']),
      slug: asString(json['slug']),
      title: asString(json['title']),
      body: asString(json['body'] ?? json['content'] ?? json['html']),
      updatedAt: asString(json['updated_at'] ?? json['updatedAt']),
    );
  }
}
