import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/screens/refer_earn/refer_earn_provider.dart';
import 'package:carzigo_partner/screens/refer_earn/widgets/referred_customer_card.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/mock_data.dart';
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
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        itemCount: provider.allReferredCustomers.length,
                        itemBuilder: (context, index) {
                          final c = provider.allReferredCustomers[index];
                          return ReferredCustomerCard(
                            initials: c.$1,
                            name: c.$2,
                            phone: c.$3,
                            status: c.$4.tr(),
                            amount: MockData.referralRewardAmount,
                          );
                        },
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
