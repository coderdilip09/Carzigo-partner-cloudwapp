import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_job_card.dart';
import 'package:carzigo_partner/common_widgets/app_shimmer.dart';
import 'package:carzigo_partner/common_widgets/app_stat_card.dart';
import 'package:carzigo_partner/models/job_data_model.dart';
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
          String jobStatusLabel(JobDataModel job) {
            final tag = (job.displayTag ?? '').toLowerCase().trim();
            if (tag == 'not_complete') return AppStrings.notComplete.tr();
            if (tag == 'rejected') return AppStrings.reject.tr();
            if (tag == 'cancelled') return AppStrings.cancelled.tr();
            if (tag == 'completed') return AppStrings.completed.tr();

            final ui = (job.uiStatus ?? '').trim().toLowerCase();
            if (ui == 'not complete' || ui == 'not_complete') {
              return AppStrings.notComplete.tr();
            }
            if (ui == 'reject' || ui == 'rejected') {
              return AppStrings.reject.tr();
            }
            if (ui == 'cancelled' || ui == 'canceled') {
              return AppStrings.cancelled.tr();
            }
            if (job.uiStatus?.trim().isNotEmpty == true) {
              return job.uiStatus!.trim();
            }
            return statusLabel;
          }
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

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: AppBg(
              child: SafeArea(
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
                        InkWell(
                          onTap: provider.toggleSearch,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: provider.isSearchOpen
                                ? const Icon(
                                    Icons.close,
                                    size: 22,
                                    color: AppColors.textPrimary,
                                  )
                                : const AppIcon(AppAssets.search),
                          ),
                        ),
                      ],
                    ),
                    if (provider.isSearchOpen) ...[
                      const SizedBox(height: 12),
                      _ScheduleSearchField(
                        initialValue: provider.searchQuery,
                        onChanged: provider.onSearchChanged,
                        onClear: provider.clearSearch,
                      ),
                    ],
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
                    AppShimmer(
                      enabled: provider.isLoading && provider.data == null,
                      child: provider.isLoading && provider.data == null
                          ? Column(
                              children: [
                                for (var i = 0; i < 3; i++)
                                  AppJobCard(
                                    compact: false,
                                    showPrice: true,
                                    status: statusLabel,
                                    timeLabel: '09:00 AM - 10:00 AM',
                                    serviceName: 'Exterior Wash Service',
                                    customerName: 'Customer Name',
                                    carName: 'Car Model Name',
                                    price: '₹999',
                                  ),
                              ],
                            )
                          : provider.jobs.isEmpty
                          ? Padding(
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
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final group in provider.groupedJobs) ...[
                                  if (group.$1.isNotEmpty) ...[
                                    _DateChip(label: group.$1),
                                    const SizedBox(height: 12),
                                  ],
                                  for (final job in group.$2)
                                    AppJobCard(
                                      compact: false,
                                      showPrice: true,
                                      status: jobStatusLabel(job),
                                      timeLabel: job.timeRange,
                                      serviceName: job.serviceName,
                                      customerName: job.customerName,
                                      carName: job.car,
                                      vehicleImage: job.vehicleImage,
                                      price: job.price,
                                      onTap: () => AppNavigation.to(
                                        ServiceDetailsScreen(job: job),
                                      ),
                                    ),
                                ],
                              ],
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

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.dateChipBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.left,
          style: AppTextStyles.style(
            fontSize: 11,
            color: AppColors.viewAll,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ScheduleSearchField extends StatefulWidget {
  const _ScheduleSearchField({
    required this.initialValue,
    required this.onChanged,
    required this.onClear,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<_ScheduleSearchField> createState() => _ScheduleSearchFieldState();
}

class _ScheduleSearchFieldState extends State<_ScheduleSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const AppIcon(AppAssets.search, size: 20, color: AppColors.black),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (value) {
                setState(() {});
                widget.onChanged(value);
              },
              style: AppTextStyles.style(fontSize: 14, color: AppColors.black),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: AppStrings.search.tr(),
                hintStyle: AppTextStyles.style(
                  fontSize: 14,
                  color: AppColors.textHint,
                ),
                filled: true,
                fillColor: AppColors.textFieldFill,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onClear();
                setState(() {});
              },
              child: const Icon(Icons.close, size: 18, color: AppColors.black),
            ),
        ],
      ),
    );
  }
}
