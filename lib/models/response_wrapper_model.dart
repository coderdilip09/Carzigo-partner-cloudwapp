import 'package:carzigo_partner/models/json_parsers.dart';
import 'package:flutter/foundation.dart';

class ResponseWrapperModel<T> {
  ResponseWrapperModel({this.code, this.data, this.message, this.status});

  final int? code;
  final T? data;
  final String? message;
  final bool? status;

  bool get isSuccess {
    if (status == true) return true;
    return code == 200 || code == 201;
  }

  factory ResponseWrapperModel.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic json)? parseData,
  ) {
    T? parsed;
    try {
      final rawData = json['data'];
      if (parseData != null && rawData != null) {
        parsed = parseData(rawData);
      }
    } catch (e, st) {
      debugPrint('ResponseWrapperModel.fromJson failed: $e\n$st');
    }

    final rawStatus = json['status'];
    int? code = asInt(
      json['code'] ?? json['statusCode'] ?? json['status_code'],
    );
    bool? status;

    if (rawStatus is bool) {
      status = rawStatus;
    } else if (rawStatus is num) {
      code ??= rawStatus.toInt();
      status = rawStatus == 200 || rawStatus == 201;
    } else {
      status = asBool(json['success'] ?? rawStatus);
    }

    return ResponseWrapperModel<T>(
      code: code,
      data: parsed,
      message: asString(json['message'] ?? json['msg']),
      status: status,
    );
  }

  factory ResponseWrapperModel.error(String message, {int? code}) {
    return ResponseWrapperModel<T>(
      code: code ?? 0,
      message: message,
      status: false,
    );
  }
}
