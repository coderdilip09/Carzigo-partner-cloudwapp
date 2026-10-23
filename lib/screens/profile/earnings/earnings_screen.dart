import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/models/earning_item_model.dart';
import 'package:carzigo_partner/screens/profile/earnings/earnings_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EarningsProvider(),
      child: Consumer<EarningsProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AppBg(
              child: SafeArea(
                child: provider.isInitialLoading
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
                          child: ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              AppBackHeader(title: AppStrings.earnings.tr()),
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.earningsSubtitle.tr(),
                                style: AppTextStyles.style(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _SummaryCard(summary: provider.summary),
                              const SizedBox(height: 14),
                              _FilterChips(provider: provider),
                              const SizedBox(height: 16),
                              if (provider.isListLoading)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ),
                                )
                              else if (provider.groups.isEmpty)
                                const _EmptyState()
                              else
                                ...provider.groups.map(_DateGroup.new),
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
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final EarningsSummaryModel summary;

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
            AppStrings.totalEarnings.tr(),
            style: AppTextStyles.style(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${summary.total}',
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
                child: _MiniStat(
                  label: AppStrings.washEarnings.tr(),
                  value: '₹${summary.wash}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  label: AppStrings.referralEarnings.tr(),
                  value: '₹${summary.referral}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.style(
              fontSize: 11,
              color: AppColors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.style(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.provider});

  final EarningsProvider provider;

  String _label(String type) {
    switch (type) {
      case 'exterior':
        return AppStrings.earningFilterExterior.tr();
      case 'interior':
        return AppStrings.earningFilterInterior.tr();
      case 'referral':
        return AppStrings.earningFilterReferral.tr();
      case 'all':
      default:
        return AppStrings.earningFilterAll.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final type in EarningsProvider.filters) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_label(type)),
                selected: provider.selectedType == type,
                onSelected: (_) => provider.setType(type),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.white,
                labelStyle: AppTextStyles.style(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: provider.selectedType == type
                      ? AppColors.white
                      : AppColors.textPrimary,
                ),
                side: BorderSide(
                  color: provider.selectedType == type
                      ? AppColors.primary
                      : AppColors.border,
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateGroup extends StatelessWidget {
  const _DateGroup(this.group);

  final EarningGroupModel group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.label?.isNotEmpty == true
                      ? group.label!
                      : (group.date ?? '—'),
                  style: AppTextStyles.style(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '₹${group.total}',
                style: AppTextStyles.style(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...group.items.map(_EarningTile.new),
        ],
      ),
    );
  }
}

class _EarningTile extends StatelessWidget {
  const _EarningTile(this.item);

  final EarningItemModel item;

  String get _typeLabel {
    switch ((item.type ?? '').toLowerCase()) {
      case 'exterior':
        return AppStrings.earningFilterExterior.tr();
      case 'interior':
        return AppStrings.earningFilterInterior.tr();
      case 'referral':
        return AppStrings.earningFilterReferral.tr();
      default:
        return item.title ?? '—';
    }
  }

  Color get _badgeBg {
    switch ((item.type ?? '').toLowerCase()) {
      case 'interior':
        return AppColors.peach;
      case 'referral':
        return AppColors.greenLight;
      case 'exterior':
      default:
        return AppColors.pendingBadge;
    }
  }

  Color get _badgeFg {
    switch ((item.type ?? '').toLowerCase()) {
      case 'referral':
        return AppColors.verified;
      case 'interior':
        return AppColors.primaryDark;
      case 'exterior':
      default:
        return AppColors.primary;
    }
  }

  String? get _statusLabel {
    final status = (item.status ?? '').toLowerCase();
    if (status == 'pending_payout') {
      return AppStrings.earningStatusPending.tr();
    }
    if (status == 'paid') return AppStrings.earningStatusPaid.tr();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title?.isNotEmpty == true ? item.title! : _typeLabel,
                  style: AppTextStyles.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((item.subtitle ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle!,
                    style: AppTextStyles.style(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if ((item.scheduleCode ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.scheduleCode!,
                    style: AppTextStyles.style(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _typeLabel,
                        style: AppTextStyles.style(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _badgeFg,
                        ),
                      ),
                    ),
                    if (status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.peachLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: AppTextStyles.style(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '₹${item.amount}',
            style: AppTextStyles.style(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.payments_outlined,
            size: 34,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.earningsEmpty.tr(),
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
