import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/common_widgets/app_stat_card.dart';
import 'package:carzigo_partner/screens/refer_earn/refer_earn_provider.dart';
import 'package:carzigo_partner/screens/refer_earn/referred_customers/referred_customers_screen.dart';
import 'package:carzigo_partner/screens/refer_earn/widgets/referred_customer_card.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReferEarnScreen extends StatelessWidget {
  const ReferEarnScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReferEarnProvider(),
      child: Consumer<ReferEarnProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, showBottomNav ? 80 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.referAndEarn.tr(),
                              style: AppTextStyles.style(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              AppStrings.referEarnSubtitle.tr(),
                              style: AppTextStyles.style(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.howItWorksText,
                          side: const BorderSide(color: AppColors.howItWorksText),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          textStyle: AppTextStyles.style(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.howItWorksText,
                          ),
                        ),
                        icon: AppIcon(
                          AppAssets.help,
                          size: 14,
                          color: AppColors.howItWorksText,
                        ),
                        label: Text(AppStrings.howItWorks.tr()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE53935), Color(0xFF1A0500)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.referMoreEarnMore.tr(),
                                style: AppTextStyles.style(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppStrings.referRewardBody.tr(),
                                style: AppTextStyles.style(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppImageView(
                          AppAssets.handShake,
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        AppStrings.yourReferralSummary.tr(),
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.w700,
                          color: AppColors.sectionTitle,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<ReferralSummaryPeriod>(
                        padding: EdgeInsets.zero,
                        offset: const Offset(0, 28),
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onSelected: provider.setSummaryPeriod,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: ReferralSummaryPeriod.month,
                            child: Text(AppStrings.thisMonth.tr()),
                          ),
                          PopupMenuItem(
                            value: ReferralSummaryPeriod.week,
                            child: Text(AppStrings.thisWeek.tr()),
                          ),
                        ],
                        child: Row(
                          children: [
                            Text(
                              provider.summaryPeriodLabel.tr(),
                              style: AppTextStyles.style(
                                color: AppColors.accentOrange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.accentOrange,
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: AppIcon(
                                AppAssets.chevronDown,
                                size: 10,
                                color: AppColors.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppStatCard(
                          iconAsset: AppAssets.calendar,
                          value: provider.totalReferred,
                          label: AppStrings.totalReferred.tr(),
                        ),
                        const SizedBox(width: 8),
                        AppStatCard(
                          iconAsset: AppAssets.logoCar,
                          value: provider.onboarded,
                          label: AppStrings.onboarded.tr(),
                        ),
                        const SizedBox(width: 8),
                        AppStatCard(
                          iconAsset: AppAssets.clock,
                          value: provider.completedFirstWash,
                          label: AppStrings.completedFirstWash.tr(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.howItWorksQ.tr(),
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.w700,
                      color: AppColors.sectionTitle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.15,
                    children: provider.howItWorks.isNotEmpty
                        ? [
                            for (final step in provider.howItWorks)
                              _HowItWorksCard(
                                title: step.title ?? '',
                                desc: step.description ?? '',
                              ),
                          ]
                        : [
                            _HowItWorksCard(
                              title: AppStrings.stepReferCustomer.tr(),
                              desc: AppStrings.stepShareCode.tr(),
                            ),
                            _HowItWorksCard(
                              title: AppStrings.stepCustomerOnboards.tr(),
                              desc: AppStrings.stepTheySignup.tr(),
                            ),
                            _HowItWorksCard(
                              title: AppStrings.stepFirstWashTitle.tr(),
                              desc: AppStrings.stepFirstWash.tr(),
                            ),
                            _HowItWorksCard(
                              title: AppStrings.stepYouEarnTitle.tr(),
                              desc: AppStrings.stepYouEarn.tr(),
                            ),
                          ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.yourReferralCode.tr(),
                          style: AppTextStyles.style(
                            fontWeight: FontWeight.w700,
                            color: AppColors.sectionTitle,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          AppStrings.shareCodeOrLinkHint.tr(),
                          textAlign: TextAlign.right,
                          style: AppTextStyles.style(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _CopyField(
                            label: AppStrings.referralCode.tr(),
                            value: provider.code,
                            onCopy: () => provider.copyCode(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.yourReferralLink.tr(),
                                style: AppTextStyles.style(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.navigateText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: _CopyField(
                                  value: provider.link,
                                  valueColor: AppColors.primary,
                                  onCopy: () => provider.copyLink(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSolidButton(
                    label: AppStrings.shareNow.tr(),
                    onTap: () {},
                    leading: AppIcon(
                      AppAssets.share,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        AppStrings.referredCustomer.tr(),
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.w700,
                          color: AppColors.sectionTitle,
                        ),
                      ),
                      if (provider.customers.isNotEmpty) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: () => AppNavigation.to(
                            const ReferredCustomersScreen(),
                          ),
                          behavior: HitTestBehavior.opaque,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppStrings.viewAll.tr(),
                                style: AppTextStyles.style(
                                  color: AppColors.viewAllLink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.viewAllLink,
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: AppIcon(
                                  AppAssets.chevronRight,
                                  size: 10,
                                  color: AppColors.viewAllLink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!provider.isLoading && provider.customers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          AppStrings.noData.tr(),
                          style: AppTextStyles.style(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    ...provider.previewCustomers.map(
                      (c) => ReferredCustomerCard(
                        initials: c.displayInitials,
                        name: c.displayName,
                        phone: c.displayPhone,
                        status: c.displayStatus,
                        amount: c.amount ?? provider.rewardLabel,
                      ),
                    ),
                ],
              ),
            ),
                if (provider.isLoading)
                  const Positioned.fill(
                    child: AbsorbPointer(
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard({required this.title, required this.desc});

  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.notificationCircle,
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              AppAssets.notificationFilled,
              size: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.howItWorksText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 10,
              color: AppColors.howItWorksText,
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyField extends StatelessWidget {
  const _CopyField({
    this.label,
    required this.value,
    required this.onCopy,
    this.valueColor,
  });

  final String? label;
  final String value;
  final VoidCallback onCopy;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.referralCopyBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.completedCardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (label != null) ...[
                  Text(
                    label!,
                    style: AppTextStyles.style(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.style(
                    fontSize: label != null ? 15 : 13,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppColors.navigateText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCopy,
            child: AppIcon(
              AppAssets.copy,
              size: 18,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
