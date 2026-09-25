import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_shimmer.dart';
import 'package:carzigo_partner/screens/refer_earn/referred_customers/referred_customers_provider.dart';
import 'package:carzigo_partner/screens/refer_earn/widgets/referred_customer_card.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReferredCustomersScreen extends StatelessWidget {
  const ReferredCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReferredCustomersProvider(),
      child: const _ReferredCustomersView(),
    );
  }
}

class _ReferredCustomersView extends StatefulWidget {
  const _ReferredCustomersView();

  @override
  State<_ReferredCustomersView> createState() => _ReferredCustomersViewState();
}

class _ReferredCustomersViewState extends State<_ReferredCustomersView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels < _scroll.position.maxScrollExtent - 240) {
      return;
    }
    context.read<ReferredCustomersProvider>().loadMore();
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReferredCustomersProvider>();
    final isLoading = provider.isLoading && provider.customers.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBg(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: AppBackHeader(
                  title: AppStrings.referredCustomer.tr(),
                  showBackText: false,
                  titleInline: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: _FilterSegments(provider: provider),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.load(reset: true),
                  child: !isLoading && provider.customers.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Center(
                                child: Text(
                                  AppStrings.noData.tr(),
                                  style: AppTextStyles.style(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : AppShimmer(
                          enabled: isLoading,
                          child: ListView.builder(
                            controller: _scroll,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                            itemCount: isLoading
                                ? 6
                                : provider.customers.length +
                                    (provider.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (isLoading) {
                                return const ReferredCustomerCard(
                                  initials: 'AB',
                                  name: 'Customer Name Placeholder',
                                  phone: '+91 00000 00000',
                                  status: 'Pending',
                                  amount: '₹100',
                                );
                              }
                              if (index >= provider.customers.length) {
                                return const Padding(
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
                                );
                              }
                              final c = provider.customers[index];
                              return ReferredCustomerCard(
                                initials: c.displayInitials,
                                name: c.displayName,
                                phone: c.displayPhone,
                                status: c.displayStatus,
                                statusKey: c.statusKey,
                                amount: c.amount ?? provider.rewardLabel,
                              );
                            },
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSegments extends StatelessWidget {
  const _FilterSegments({required this.provider});

  final ReferredCustomersProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _chip(
            ReferredCustomerFilter.total,
            AppStrings.referralFilterTotal.tr(),
          ),
          _chip(
            ReferredCustomerFilter.onboard,
            AppStrings.referralFilterOnboard.tr(),
          ),
          _chip(
            ReferredCustomerFilter.complete,
            AppStrings.referralFilterComplete.tr(),
          ),
        ],
      ),
    );
  }

  Widget _chip(ReferredCustomerFilter value, String label) {
    final selected = provider.filter == value;
    final count = provider.countFor(value);
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setFilter(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            count > 0 ? '$label ($count)' : label,
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.white : AppColors.navigateText,
            ),
          ),
        ),
      ),
    );
  }
}
