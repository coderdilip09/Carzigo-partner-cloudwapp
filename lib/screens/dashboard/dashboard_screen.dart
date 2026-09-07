import 'package:carzigo_partner/common_widgets/app_bottom_nav_bar.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_job_card.dart';
import 'package:carzigo_partner/screens/dashboard/dashboard_provider.dart';
import 'package:carzigo_partner/screens/notifications/notifications_screen.dart';
import 'package:carzigo_partner/screens/profile/profile_screen.dart';
import 'package:carzigo_partner/screens/refer_earn/refer_earn_screen.dart';
import 'package:carzigo_partner/screens/schedule/schedule_provider.dart';
import 'package:carzigo_partner/screens/schedule/schedule_screen.dart';
import 'package:carzigo_partner/screens/schedule/service_details/service_details_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/mock_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider(),
      child: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          final pages = [
            _DashboardHome(
              onNotificationTap: () =>
                  AppNavigation.to(const NotificationsScreen()),
              onOpenSchedule: provider.openSchedule,
            ),
            ScheduleScreen(
              showBottomNav: false,
              initialTab: provider.scheduleTab,
            ),
            const ReferEarnScreen(showBottomNav: false),
            const ProfileScreen(showBottomNav: false),
          ];
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AppBg(child: pages[provider.currentIndex]),
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: provider.currentIndex,
              onTap: (index) {
                if (index == 1) {
                  provider.openSchedule(ScheduleTab.upcoming);
                } else {
                  provider.setIndex(index);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome({
    required this.onNotificationTap,
    required this.onOpenSchedule,
  });

  final VoidCallback onNotificationTap;
  final void Function([ScheduleTab tab]) onOpenSchedule;

  Widget _smallCircleArrow({required String asset, required Color color}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1),
      ),
      alignment: Alignment.center,
      child: AppIcon(asset, size: 8, color: color),
    );
  }

  Widget _performanceCard({
    required String icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.performanceCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AppIcon(icon, size: 20, color: AppColors.destructive),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: AppTextStyles.style(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    label,
                    style: AppTextStyles.style(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: AppImageView(
                    AppAssets.dummyProfile,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppStrings.helloName.tr(args: [MockData.userName]),
                            style: AppTextStyles.style(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const AppIcon(AppAssets.hand, size: 18),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            AppStrings.mockLocation.tr(),
                            style: AppTextStyles.style(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          AppIcon(AppAssets.chevronDown, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onNotificationTap,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const AppIcon(AppAssets.notification, size: 22),
                        Positioned(
                          right: 0,
                          top: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.destructive,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pinkSection,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: AppIcon(
                          AppAssets.logoCar,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.mockDashboardDate.tr(),
                            style: AppTextStyles.style(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            AppStrings.mockDashboardTime.tr(),
                            style: AppTextStyles.style(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatChip(
                        value: '02',
                        label: AppStrings.completed.tr(),
                        leadingAsset: AppAssets.progressCheck,
                        trailingAsset: AppAssets.chevronRight,
                        onTap: () => onOpenSchedule(ScheduleTab.completed),
                      ),
                      const SizedBox(width: 12),
                      _StatChip(
                        value: '01',
                        label: AppStrings.inProgress.tr(),
                        leadingAsset: AppAssets.progressDown,
                        trailingAsset: AppAssets.chevronRight,
                        onTap: () => onOpenSchedule(ScheduleTab.upcoming),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  AppStrings.todaysSchedule.tr(),
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.sectionTitle,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => onOpenSchedule(),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text(
                        AppStrings.viewAll.tr(),
                        style: AppTextStyles.style(
                          color: AppColors.viewAll,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _smallCircleArrow(
                        asset: AppAssets.chevronRight,
                        color: AppColors.viewAll,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.peachCard),
              ),
              child: Column(
                children: List.generate(3, (i) {
                  return AppJobCard(
                    status: AppStrings.upcoming.tr(),
                    embedded: true,
                    showBottomDivider: i < 2,
                    onTap: () => AppNavigation.to(const ServiceDetailsScreen()),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  AppStrings.performanceSummary.tr(),
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.sectionTitle,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      AppStrings.thisMonth.tr(),
                      style: AppTextStyles.style(
                        color: AppColors.accentOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _smallCircleArrow(
                      asset: AppAssets.chevronDown,
                      color: AppColors.accentOrange,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _performanceCard(
                  icon: AppAssets.logoCar,
                  value: '14',
                  label: AppStrings.completed.tr(),
                ),
                const SizedBox(width: 12),
                _performanceCard(
                  icon: AppAssets.star,
                  value: '4.8',
                  label: AppStrings.avgRating.tr(),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
    required this.leadingAsset,
    required this.trailingAsset,
    required this.onTap,
  });

  final String value;
  final String label;
  final String leadingAsset;
  final String trailingAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.destructive,
                  shape: BoxShape.circle,
                ),
                child: AppIcon(leadingAsset, size: 24, color: AppColors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: AppTextStyles.style(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.style(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppIcon(trailingAsset, size: 16, color: AppColors.black),
            ],
          ),
        ),
      ),
    );
  }
}
