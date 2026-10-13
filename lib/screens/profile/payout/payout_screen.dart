import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/common_widgets/app_text_field.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PayoutProvider extends BaseProvider {
  PayoutProvider() {
    load();
  }

  static const int minimumRequestAmount = 1;
  static const int maximumRequestAmount = 10000;

  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  bool submitted = false;

  bool isLoading = true;
  bool isLoadingMore = false;
  bool isSubmitting = false;
  bool hasMore = false;
  int page = 1;
  static const int pageSize = 15;
  int revenue = 0;
  int pending = 0;
  int paid = 0;
  int available = 0;
  List<Map<String, dynamic>> requests = [];

  Future<void> load({bool reset = true}) async {
    if (reset) {
      page = 1;
      hasMore = false;
      isLoading = true;
      safeNotifyListeners();
    } else {
      if (isLoadingMore || !hasMore || isLoading) return;
      isLoadingMore = true;
      safeNotifyListeners();
    }
    try {
      final res = await Api.getPayouts(page: page, limit: pageSize);
      if (!res.isSuccess || res.data == null) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }
      final data = res.data!;
      revenue = _asInt(data['revenue']);
      pending = _asInt(data['pending']);
      paid = _asInt(data['paid']);
      available = _asInt(data['available']);
      final raw = data['requests'];
      final incoming = raw is List
          ? raw
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
          : <Map<String, dynamic>>[];
      if (reset) {
        requests = incoming;
      } else {
        requests = [...requests, ...incoming];
      }
      hasMore = data['has_more'] == true || data['hasMore'] == true;
      page = _asInt(data['page']) + 1;
      if (page < 2) page = 2;
    } catch (e, st) {
      debugPrint('Payout load failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      isLoadingMore = false;
      safeNotifyListeners();
    }
  }

  Future<void> loadMore() => load(reset: false);

  String? validateAmount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppStrings.payoutAmountRequired.tr();

    final amount = int.tryParse(text);
    if (amount == null || amount <= 0) {
      return AppStrings.payoutAmountGreaterThanZero.tr();
    }

    if (amount < minimumRequestAmount) {
      return AppStrings.payoutAmountMinimum.tr(
        namedArgs: {'amount': '$minimumRequestAmount'},
      );
    }

    if (amount > available) {
      return AppStrings.payoutAmountMaximum.tr(
        namedArgs: {'amount': '$available'},
      );
      return AppStrings.payoutAmountExceedsBalance.tr();
    }
    if (amount > maximumRequestAmount) {
      return AppStrings.payoutAmountMaximum.tr(
        namedArgs: {'amount': '$maximumRequestAmount'},
      );
    }

    return null;
  }

  Future<void> submit() async {
    submitted = true;
    safeNotifyListeners();
    if (formKey.currentState?.validate() != true) return;
    final amount = int.parse(amountController.text.trim());
    isSubmitting = true;
    safeNotifyListeners();
    try {
      final res = await Api.requestPayout(
        amount: amount,
        note: noteController.text,
      );
      if (!res.isSuccess) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }
      submitted = false;
      formKey.currentState?.reset();
      amountController.clear();
      noteController.clear();
      AppToast.success(res.message ?? AppStrings.payoutRequested.tr());
      await load();
    } catch (e, st) {
      debugPrint('Payout request failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isSubmitting = false;
      safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse('$value') ?? 0;
}

class PayoutScreen extends StatelessWidget {
  const PayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PayoutProvider(),
      child: Consumer<PayoutProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AppBg(
              child: SafeArea(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => provider.load(),
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.pixels <
                                notification.metrics.maxScrollExtent - 240) {
                              return false;
                            }
                            provider.loadMore();
                            return false;
                          },
                          child: Form(
                            key: provider.formKey,
                            autovalidateMode: provider.submitted
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            child: ListView(
                              padding: const EdgeInsets.all(20),
                              children: [
                                AppBackHeader(
                                  title: AppStrings.requestPayout.tr(),
                                ),
                                const SizedBox(height: 16),
                                _BalanceCard(provider: provider),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: provider.amountController,
                                  hint: AppStrings.payoutAmount.tr(),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validator: provider.validateAmount,
                                  errorMaxLines: 2,
                                ),
                                const SizedBox(height: 12),
                                AppTextField(
                                  controller: provider.noteController,
                                  hint: AppStrings.payoutNote.tr(),
                                ),
                                const SizedBox(height: 16),
                                AppSolidButton(
                                  label: AppStrings.submitPayout.tr(),
                                  isLoading: provider.isSubmitting,
                                  onTap: provider.available < 1
                                      ? null
                                      : provider.submit,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  AppStrings.payoutHistory.tr(),
                                  style: AppTextStyles.style(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (provider.requests.isEmpty)
                                  Text(
                                    '—',
                                    style: AppTextStyles.style(
                                      color: AppColors.textSecondary,
                                    ),
                                  )
                                else
                                  ...provider.requests.map(_RequestTile.new),
                                if (provider.isLoadingMore)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.provider});

  final PayoutProvider provider;

  @override
  Widget build(BuildContext context) {
    String rupee(int value) => '₹$value';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.availableBalance.tr(),
            style: AppTextStyles.style(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${provider.available}',
            style: AppTextStyles.style(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text('${AppStrings.partnerRevenue.tr()}: ${rupee(provider.revenue)}'),
          Text('${AppStrings.pendingPayout.tr()}: ${rupee(provider.pending)}'),
          Text('${AppStrings.paidOut.tr()}: ${rupee(provider.paid)}'),
        ],
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile(this.row);

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final status = (row['status'] ?? '').toString();
    final amount = _asInt(row['amount']);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '₹$amount',
              style: AppTextStyles.style(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            status,
            style: AppTextStyles.style(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
