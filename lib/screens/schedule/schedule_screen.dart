import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_job_card.dart';
import 'package:carzigo_partner/common_widgets/app_stat_card.dart';
import 'package:carzigo_partner/screens/schedule/schedule_provider.dart';
import 'package:carzigo_partner/screens/schedule/service_details/service_details_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({
    super.key,
    this.showBottomNav = true,
    this.initialTab = ScheduleTab.upcoming,
  });

  final bool showBottomNav;
  final ScheduleTab initialTab;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScheduleProvider(initialTab: initialTab),
      child: Consumer<ScheduleProvider>(
        builder: (context, provider, _) {
          final tabLabel = switch (provider.currentTab) {
            ScheduleTab.upcoming => AppStrings.upcomingJobs.tr(),
            ScheduleTab.completed => AppStrings.completedJobs.tr(),
            ScheduleTab.cancelled => AppStrings.cancelledJobs.tr(),
          };
          final statusLabel = switch (provider.currentTab) {
            ScheduleTab.upcoming => AppStrings.upcoming.tr(),
            ScheduleTab.completed => AppStrings.completed.tr(),
            ScheduleTab.cancelled => AppStrings.cancelled.tr(),
          };
          final tabMeta = {
            ScheduleTab.upcoming: (
              AppStrings.upcoming.tr(),
              AppAssets.calendar,
            ),
            ScheduleTab.completed: (
              AppStrings.completed.tr(),
              AppAssets.progressCheck,
            ),
            ScheduleTab.cancelled: (
              AppStrings.cancelled.tr(),
              AppAssets.cancel,
            ),
          };

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => provider.load(silent: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  showBottomNav ? 80 : 16,
                ),
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
                                AppStrings.scheduleJobs.tr(),
                                style: AppTextStyles.style(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                AppStrings.scheduleSubtitle.tr(),
                                style: AppTextStyles.style(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const AppIcon(AppAssets.search),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: ScheduleTab.values.map((tab) {
                        final isActive = provider.currentTab == tab;
                        final meta = tabMeta[tab]!;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => provider.setTab(tab),
                            child: Container(
                              margin: EdgeInsets.only(
                                right: tab == ScheduleTab.cancelled ? 0 : 6,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppIcon(
                                    meta.$2,
                                    size: 14,
                                    color: isActive
                                        ? AppColors.white
                                        : AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      meta.$1,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.style(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isActive
                                            ? AppColors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        AppStatCard(
                          iconAsset: AppAssets.calendar,
                          value: provider.totalJobs,
                          label: AppStrings.totalJobs.tr(),
                        ),
                        const SizedBox(width: 8),
                        AppStatCard(
                          iconAsset: AppAssets.logoCar,
                          value: provider.completed,
                          label: AppStrings.completed.tr(),
                        ),
                        const SizedBox(width: 8),
                        AppStatCard(
                          iconAsset: AppAssets.refresh,
                          value: provider.inProgress,
                          label: AppStrings.inProgress.tr(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tabLabel,
                      style: AppTextStyles.style(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    if (provider.isLoading && provider.data == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
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
                      )
                    else if (provider.jobs.isEmpty)
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
                      for (final group in provider.groupedJobs) ...[
                        if (group.$1.isNotEmpty) ...[
                          _DateChip(label: group.$1),
                          const SizedBox(height: 12),
                        ],
                        for (final job in group.$2)
                          AppJobCard(
                            compact: false,
                            showPrice: true,
                            status: statusLabel,
                            timeLabel: job.timeRange,
                            serviceName: job.serviceName,
                            customerName: job.customerName,
                            carName: job.car,
                            price: job.price,
                            onTap: () => AppNavigation.to(
                              ServiceDetailsScreen(job: job),
                            ),
                          ),
                      ],
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

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.dateChipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.style(
          fontSize: 11,
          color: AppColors.viewAll,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
