import 'package:carzigo_partner/models/referral_data_model.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum ReferredCustomerFilter { total, onboard, complete }

class ReferredCustomersProvider extends BaseProvider {
  ReferredCustomersProvider() {
    load(reset: true);
  }

  static const int pageSize = 15;

  ReferredCustomerFilter filter = ReferredCustomerFilter.total;
  final List<ReferredCustomerDataModel> customers = [];
  Map<String, int> counts = const {};
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = false;
  int page = 1;
  String rewardLabel = '';

  int countFor(ReferredCustomerFilter value) {
    switch (value) {
      case ReferredCustomerFilter.total:
        return counts['total'] ?? 0;
      case ReferredCustomerFilter.onboard:
        return counts['onboard'] ?? 0;
      case ReferredCustomerFilter.complete:
        return counts['complete'] ?? 0;
    }
  }

  Future<void> setFilter(ReferredCustomerFilter value) async {
    if (filter == value) return;
    filter = value;
    await load(reset: true);
  }

  Future<void> load({bool reset = false}) async {
    if (reset) {
      page = 1;
      hasMore = false;
      isLoading = true;
      safeNotifyListeners();
    } else {
      if (isLoadingMore || !hasMore) return;
      isLoadingMore = true;
      safeNotifyListeners();
    }

    try {
      final res = await Api.getReferralCustomers(
        filter: filter.name,
        page: page,
        limit: pageSize,
      );
      if (!res.isSuccess || res.data == null) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }
      final data = res.data!;
      if (reset) customers.clear();
      customers.addAll(data.items);
      counts = data.counts;
      hasMore = data.hasMore;
      page = data.page + 1;
      if (rewardLabel.isEmpty) {
        final firstAmount = data.items
            .map((e) => e.amount)
            .firstWhere((e) => e != null && e.isNotEmpty, orElse: () => '');
        rewardLabel = firstAmount ?? '';
      }
    } catch (e, st) {
      debugPrint('Get referral customers failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      isLoadingMore = false;
      safeNotifyListeners();
    }
  }

  Future<void> loadMore() => load();
}
