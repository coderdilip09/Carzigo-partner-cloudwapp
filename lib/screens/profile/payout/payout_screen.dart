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

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  bool isLoading = true;
  bool isSubmitting = false;
  int revenue = 0;
  int pending = 0;
  int paid = 0;
  int available = 0;
  List<Map<String, dynamic>> requests = const [];

  Future<void> load() async {
    isLoading = true;
    safeNotifyListeners();
    try {
      final res = await Api.getPayouts();
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
      requests = raw is List
          ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
          : const [];
    } catch (e, st) {
      debugPrint('Payout load failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  Future<void> submit() async {
    final amount = int.tryParse(amountController.text.trim()) ?? 0;
    if (amount < 1 || amount > available) {
      AppToast.error(AppStrings.payoutAmountInvalid.tr());
      return;
    }
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
                        onRefresh: provider.load,
                        child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            AppBackHeader(title: AppStrings.requestPayout.tr()),
                            const SizedBox(height: 16),
                            _BalanceCard(provider: provider),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: provider.amountController,
                              hint: AppStrings.payoutAmount.tr(),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                              onTap: provider.available < 1 ? null : provider.submit,
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
                          ],
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
            style: AppTextStyles.style(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${provider.available}',
            style: AppTextStyles.style(fontSize: 28, fontWeight: FontWeight.w700),
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
            style: AppTextStyles.style(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
