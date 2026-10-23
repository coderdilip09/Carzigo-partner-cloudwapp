import 'package:carzigo_partner/models/earning_item_model.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

class EarningsProvider extends BaseProvider {
  EarningsProvider() {
    load();
  }

  static const filters = <String>[
    'all',
    'exterior',
    'interior',
    'referral',
  ];

  String selectedType = 'all';
  bool isInitialLoading = true;
  bool isListLoading = false;
  bool isLoadingMore = false;
  bool hasMore = false;
  int page = 1;
  static const int pageSize = 30;

  EarningsSummaryModel summary = const EarningsSummaryModel();
  List<EarningGroupModel> groups = [];

  Future<void> load({bool reset = true}) async {
    if (reset) {
      page = 1;
      hasMore = false;
      if (isInitialLoading) {
        // First open: full-page spinner.
      } else {
        isListLoading = true;
        groups = [];
      }
      safeNotifyListeners();
    } else {
      if (isLoadingMore || !hasMore || isInitialLoading || isListLoading) {
        return;
      }
      isLoadingMore = true;
      safeNotifyListeners();
    }

    try {
      final res = await Api.getEarnings(
        type: selectedType,
        page: page,
        limit: pageSize,
      );
      if (!res.isSuccess || res.data == null) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }
      final data = res.data!;
      summary = data.summary;
      if (reset) {
        groups = data.groups;
      } else {
        groups = _mergeGroups(groups, data.groups);
      }
      hasMore = data.hasMore;
      page = data.page + 1;
      if (page < 2) page = 2;
    } catch (e, st) {
      debugPrint('Earnings load failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isInitialLoading = false;
      isListLoading = false;
      isLoadingMore = false;
      safeNotifyListeners();
    }
  }

  Future<void> loadMore() => load(reset: false);

  Future<void> setType(String type) async {
    final next = type.trim().toLowerCase();
    if (next == selectedType || !filters.contains(next)) return;
    selectedType = next;
    await load();
  }

  List<EarningGroupModel> _mergeGroups(
    List<EarningGroupModel> existing,
    List<EarningGroupModel> incoming,
  ) {
    if (incoming.isEmpty) return existing;
    final map = <String, EarningGroupModel>{};
    for (final group in existing) {
      final key = group.date ?? group.label ?? '';
      map[key] = group;
    }
    for (final group in incoming) {
      final key = group.date ?? group.label ?? '';
      final prev = map[key];
      if (prev == null) {
        map[key] = group;
        continue;
      }
      final ids = prev.items.map((e) => e.id).toSet();
      final mergedItems = [
        ...prev.items,
        ...group.items.where((e) => !ids.contains(e.id)),
      ];
      map[key] = EarningGroupModel(
        date: prev.date ?? group.date,
        label: prev.label ?? group.label,
        total: mergedItems.fold<int>(0, (sum, item) => sum + item.amount),
        items: mergedItems,
      );
    }
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return keys.map((key) => map[key]!).toList();
  }
}
