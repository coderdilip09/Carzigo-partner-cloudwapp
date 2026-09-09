import 'package:carzigo_partner/models/json_parsers.dart';

class UploadDataModel {
  UploadDataModel({
    this.url,
    this.fullUrl,
    this.key,
    this.folder,
    this.mime,
    this.size,
    this.storage,
  });

  final String? url;
  final String? fullUrl;
  final String? key;
  final String? folder;
  final String? mime;
  final int? size;
  final String? storage;

  String? get resolvedUrl {
    final value = fullUrl ?? url;
    if (value == null || value.isEmpty) return null;
    return value;
  }

  bool get hasFullUrl => resolvedUrl != null;

  factory UploadDataModel.fromJson(Map<String, dynamic> json) {
    return UploadDataModel(
      url: asString(json['url']),
      fullUrl: asString(json['full_url'] ?? json['fullUrl'] ?? json['url']),
      key: asString(json['key']),
      folder: asString(json['folder']),
      mime: asString(json['mime']),
      size: asInt(json['size']),
      storage: asString(json['storage']),
    );
  }
}
