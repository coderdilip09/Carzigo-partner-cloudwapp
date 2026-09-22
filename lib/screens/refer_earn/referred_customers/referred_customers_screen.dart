import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_shimmer.dart';
import 'package:carzigo_partner/screens/refer_earn/refer_earn_provider.dart';
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
      create: (_) => ReferEarnProvider(),
      child: Consumer<ReferEarnProvider>(
        builder: (context, provider, _) {
          final isLoading =
              provider.isLoading && provider.customers.isEmpty;

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
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: provider.load,
                        child: !isLoading && provider.customers.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.4,
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
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    20,
                                  ),
                                  itemCount: isLoading
                                      ? 6
                                      : provider.customers.length,
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
                                    final c = provider.customers[index];
                                    return ReferredCustomerCard(
                                      initials: c.displayInitials,
                                      name: c.displayName,
                                      phone: c.displayPhone,
                                      status: c.displayStatus,
                                      amount:
                                          c.amount ?? provider.rewardLabel,
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
        },
      ),
    );
  }
}
