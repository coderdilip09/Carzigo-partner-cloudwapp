import 'package:carzigo_partner/common_widgets/app_bottom_nav_bar.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_job_card.dart';
import 'package:carzigo_partner/common_widgets/app_user_avatar.dart';
import 'package:carzigo_partner/models/job_data_model.dart';
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
              provider: provider,
              onNotificationTap: () =>
                  AppNavigation.to(const NotificationsScreen()),
            ),
            ScheduleScreen(
              showBottomNav: true,
              initialTab: provider.scheduleTab,
            ),
            const ReferEarnScreen(showBottomNav: true),
            const ProfileScreen(showBottomNav: true),
          ];
          return Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
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
    required this.provider,
    required this.onNotificationTap,
  });

  final DashboardProvider provider;
  final VoidCallback onNotificationTap;

  String _padCount(int value) => value.toString().padLeft(2, '0');

  String _ratingLabel(double? rating) {
    if (rating == null) return '-';
    return rating.toStringAsFixed(1);
  }

  String _jobStatusLabel(JobDataModel job) {
    final raw = (job.listStatus ?? job.workflowStatus ?? '').toLowerCase();
    if (raw.contains('complete')) return AppStrings.completed.tr();
    if (raw.contains('cancel')) return AppStrings.cancelled.tr();
    if (raw.contains('progress')) return AppStrings.inProgress.tr();
    return AppStrings.upcoming.tr();
  }

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
    final dashboard = provider.dashboard;
    final nextJob = dashboard?.nextJob;
    final jobs = dashboard?.todaySchedule ?? const [];
    final previewJobs = jobs.take(3).toList();
    final serviceArea = provider.serviceArea;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => provider.loadDashboard(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppUserAvatar(url: provider.user?.photoUrl, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                AppStrings.helloName.tr(
                                  args: [provider.helloName],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.style(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const AppIcon(AppAssets.hand, size: 18),
                          ],
                        ),
                        if (serviceArea != null)
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  serviceArea,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.style(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const AppIcon(AppAssets.chevronDown, size: 16),
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
                      child: const AppIcon(AppAssets.notification, size: 22),
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
                    if (nextJob != null) ...[
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
                              if (nextJob.date != null)
                                Text(
                                  nextJob.date!,
                                  style: AppTextStyles.style(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              if (nextJob.timeRange != null)
                                Text(
                                  nextJob.timeRange!,
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
                    ],
                    Row(
                      children: [
                        _StatChip(
                          value: _padCount(dashboard?.todayCompleted ?? 0),
                          label: AppStrings.completed.tr(),
                          leadingAsset: AppAssets.progressCheck,
                          trailingAsset: AppAssets.chevronRight,
                          onTap: () =>
                              provider.openSchedule(ScheduleTab.completed),
                        ),
                        const SizedBox(width: 12),
                        _StatChip(
                          value: _padCount(dashboard?.todayInProgress ?? 0),
                          label: AppStrings.inProgress.tr(),
                          leadingAsset: AppAssets.progressDown,
                          trailingAsset: AppAssets.chevronRight,
                          onTap: () =>
                              provider.openSchedule(ScheduleTab.upcoming),
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
                    onTap: () => provider.openSchedule(),
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
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.peachCard),
                ),
                child: provider.isLoading && dashboard == null
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : jobs.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
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
                    : Column(
                        children: [
                          for (var i = 0; i < previewJobs.length; i++)
                            AppJobCard(
                              status: _jobStatusLabel(previewJobs[i]),
                              timeLabel: previewJobs[i].timeRange,
                              serviceName: previewJobs[i].serviceName,
                              customerName: previewJobs[i].customerName,
                              carName: previewJobs[i].car,
                              embedded: true,
                              showBottomDivider: i < previewJobs.length - 1,
                              onTap: () => AppNavigation.to(
                                const ServiceDetailsScreen(),
                              ),
                            ),
                        ],
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
                  PopupMenuButton<PerformancePeriod>(
                    padding: EdgeInsets.zero,
                    offset: const Offset(0, 28),
                    color: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSelected: provider.setPerformancePeriod,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: PerformancePeriod.month,
                        child: Text(AppStrings.thisMonth.tr()),
                      ),
                      PopupMenuItem(
                        value: PerformancePeriod.week,
                        child: Text(AppStrings.thisWeek.tr()),
                      ),
                    ],
                    child: Row(
                      children: [
                        Text(
                          provider.performancePeriodLabel.tr(),
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
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _performanceCard(
                    icon: AppAssets.logoCar,
                    value: '${provider.performanceCompleted}',
                    label: AppStrings.completed.tr(),
                  ),
                  const SizedBox(width: 12),
                  _performanceCard(
                    icon: AppAssets.star,
                    value: _ratingLabel(provider.performanceAvgRating),
                    label: AppStrings.avgRating.tr(),
                  ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
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
