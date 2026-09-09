import 'package:carzigo_partner/models/json_parsers.dart';

class DeleteAccountDataModel {
  DeleteAccountDataModel({this.id, this.status});

  final String? id;
  final String? status;

  bool get isDeleted => status?.toLowerCase() == 'deleted';

  factory DeleteAccountDataModel.fromJson(Map<String, dynamic> json) {
    return DeleteAccountDataModel(
      id: asString(json['id']),
      status: asString(json['status']),
    );
  }
}
