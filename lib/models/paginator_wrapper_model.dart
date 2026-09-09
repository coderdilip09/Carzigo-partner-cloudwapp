import 'package:carzigo_partner/models/json_parsers.dart';

class PaginatorWrapperModel<T> {
  PaginatorWrapperModel({
    this.list = const [],
    this.page,
    this.lastPage,
    this.total,
    this.hasMore,
  });

  final List<T> list;
  final int? page;
  final int? lastPage;
  final int? total;
  final bool? hasMore;

  factory PaginatorWrapperModel.fromJson(
    dynamic json,
    T Function(Map<String, dynamic> item) fromJson,
  ) {
    final map = asMap(json);
    if (map == null) {
      return PaginatorWrapperModel<T>(list: asModelList(json, fromJson));
    }

    final rawList =
        map['list'] ??
        map['data'] ??
        map['items'] ??
        map['jobs'] ??
        map['notifications'] ??
        map['customers'];

    final page = asInt(
      map['page'] ?? map['current_page'] ?? map['currentPage'],
    );
    final lastPage = asInt(
      map['last_page'] ?? map['lastPage'] ?? map['total_pages'],
    );
    final total = asInt(map['total'] ?? map['count']);
    final hasMore =
        asBool(map['has_more'] ?? map['hasMore']) ??
        (page != null && lastPage != null ? page < lastPage : null);

    return PaginatorWrapperModel<T>(
      list: asModelList(rawList, fromJson),
      page: page,
      lastPage: lastPage,
      total: total,
      hasMore: hasMore,
    );
  }
}
