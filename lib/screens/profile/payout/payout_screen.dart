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
  int exteriorRate = 50;
  int interiorRate = 80;
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
      final rates = data['wash_rates'] ?? data['washRates'];
      if (rates is Map) {
        exteriorRate = _asInt(rates['exterior'], fallback: exteriorRate);
        interiorRate = _asInt(rates['interior'], fallback: interiorRate);
      }
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

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse('$value') ?? fallback;
}

String _statusLabel(String status) {
  switch (status.toLowerCase().trim()) {
    case 'approved':
      return AppStrings.payoutStatusApproved.tr();
    case 'paid':
      return AppStrings.payoutStatusPaid.tr();
    case 'rejected':
      return AppStrings.payoutStatusRejected.tr();
    case 'requested':
    default:
      return AppStrings.payoutStatusRequested.tr();
  }
}

Color _statusColor(String status) {
  switch (status.toLowerCase().trim()) {
    case 'approved':
      return AppColors.viewAllLink;
    case 'paid':
      return AppColors.verified;
    case 'rejected':
      return AppColors.destructive;
    case 'requested':
    default:
      return AppColors.primary;
  }
}

Color _statusBg(String status) {
  switch (status.toLowerCase().trim()) {
    case 'approved':
      return const Color(0xFFE8F1FF);
    case 'paid':
      return AppColors.greenLight;
    case 'rejected':
      return AppColors.redLight;
    case 'requested':
    default:
      return AppColors.peach;
  }
}

String _formatWhen(dynamic value) {
  if (value == null) return '';
  final parsed = DateTime.tryParse(value.toString());
  if (parsed == null) return value.toString();
  return DateFormat('dd MMM yyyy, h:mm a').format(parsed.toLocal());
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
                                const SizedBox(height: 6),
                                Text(
                                  AppStrings.requestPayoutSubtitle.tr(),
                                  style: AppTextStyles.style(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _BalanceCard(provider: provider),
                                const SizedBox(height: 16),
                                _RequestCard(provider: provider),
                                const SizedBox(height: 24),
                                Text(
                                  AppStrings.payoutHistory.tr(),
                                  style: AppTextStyles.style(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (provider.requests.isEmpty)
                                  const _EmptyHistory()
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.availableBalance.tr(),
            style: AppTextStyles.style(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${provider.available}',
            style: AppTextStyles.style(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  label: AppStrings.partnerRevenue.tr(),
                  value: '₹${provider.revenue}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BalanceStat(
                  label: AppStrings.pendingPayout.tr(),
                  value: '₹${provider.pending}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _BalanceStat(
                  label: AppStrings.paidOut.tr(),
                  value: '₹${provider.paid}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.washPayoutRates.tr(),
                  style: AppTextStyles.style(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.exteriorWashPayout.tr(
                    namedArgs: {'amount': '${provider.exteriorRate}'},
                  ),
                  style: AppTextStyles.style(
                    fontSize: 12,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  AppStrings.interiorWashPayout.tr(
                    namedArgs: {'amount': '${provider.interiorRate}'},
                  ),
                  style: AppTextStyles.style(
                    fontSize: 12,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.style(
              fontSize: 10,
              color: AppColors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.style(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.provider});

  final PayoutProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.payoutRequestSection.tr(),
            style: AppTextStyles.style(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: provider.amountController,
            hint: AppStrings.payoutAmount.tr(),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: provider.validateAmount,
            errorMaxLines: 2,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: provider.noteController,
            hint: AppStrings.payoutNoteOptional.tr(),
          ),
          const SizedBox(height: 16),
          AppSolidButton(
            label: AppStrings.submitPayout.tr(),
            isLoading: provider.isSubmitting,
            onTap: provider.available < 1 ? null : provider.submit,
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 32,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.payoutEmptyHistory.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
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
    final when = _formatWhen(row['processed_at'] ?? row['created_at']);
    final note = (row['note'] ?? '').toString().trim();
    final adminNote = (row['admin_note'] ?? '').toString().trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '₹$amount',
                  style: AppTextStyles.style(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBg(status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(status),
                  style: AppTextStyles.style(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),
          if (when.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              when,
              style: AppTextStyles.style(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              note,
              style: AppTextStyles.style(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
          if (adminNote.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              adminNote,
              style: AppTextStyles.style(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
