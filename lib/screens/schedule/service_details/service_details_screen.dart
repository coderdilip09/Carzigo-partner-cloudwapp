import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/models/job_data_model.dart';
import 'package:carzigo_partner/screens/schedule/service_details/service_details_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key, this.jobId, this.job});

  final String? jobId;
  final JobDataModel? job;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServiceDetailsProvider(
        jobId: jobId ?? job?.id,
        initialJob: job,
      ),
      child: Consumer<ServiceDetailsProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AppBg(
              child: SafeArea(
                child: provider.isLoading && provider.job == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: AppBackHeader(
                              title: AppStrings.serviceDetails.tr(),
                              showBackText: false,
                              titleInline: true,
                            ),
                          ),
                          const Expanded(
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
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppBackHeader(
                                    title: AppStrings.serviceDetails.tr(),
                                    showBackText: false,
                                    titleInline: true,
                                  ),
                                  const SizedBox(height: 16),
                                  const _ScheduleCard(),
                                  const SizedBox(height: 16),
                                  const _CustomerDetailsCard(),
                                  const SizedBox(height: 16),
                                  const _ServiceAddressCard(),
                                  const SizedBox(height: 20),
                                  Text(
                                    AppStrings.updateStatus.tr(),
                                    style: AppTextStyles.style(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.sectionTitle,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ..._buildSteps(provider),
                                  const SizedBox(height: 16),
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: _NoteCard(
                                            title:
                                                AppStrings.serviceNotes.tr(),
                                            text: provider.displayNotes.isEmpty
                                                ? AppStrings.noData.tr()
                                                : provider.displayNotes,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _NoteCard(
                                            title: AppStrings
                                                .customerInstructions
                                                .tr(),
                                            text: provider
                                                    .displayInstructions
                                                    .isEmpty
                                                ? AppStrings.noData.tr()
                                                : provider.displayInstructions,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: AppSolidButton(
                              label: AppStrings.addToCalendar.tr(),
                              onTap: provider.tapOnAddToCalendar,
                              isLoading: provider.isAddingToCalendar,
                              leading: AppIcon(
                                AppAssets.calendar,
                                size: 18,
                                color: AppColors.white,
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

  List<Widget> _buildSteps(ServiceDetailsProvider provider) {
    final steps = [
      (
        AppStrings.statusAssigned.tr(),
        AppStrings.statusAssignedDesc.tr(),
        AppAssets.calendar,
        provider.displayAssignedAt,
      ),
      (
        AppStrings.statusOnTheWay.tr(),
        AppStrings.statusOnTheWayDesc.tr(),
        AppAssets.logoCar,
        null,
      ),
      (
        AppStrings.statusOnSite.tr(),
        AppStrings.statusOnSiteDesc.tr(),
        AppAssets.location,
        null,
      ),
      (
        AppStrings.statusInProgress.tr(),
        AppStrings.statusInProgressDesc.tr(),
        AppAssets.headset,
        null,
      ),
      (
        AppStrings.statusCompleted.tr(),
        AppStrings.statusCompletedDesc.tr(),
        AppAssets.doubleCheck,
        null,
      ),
    ];

    return List.generate(steps.length, (i) {
      final stepNum = i + 1;
      final isDone = stepNum <= provider.currentStep;
      final isNext = stepNum == provider.currentStep + 1;
      final isLast = i == steps.length - 1;
      final title = steps[i].$1;
      final desc = steps[i].$2;
      final icon = steps[i].$3;
      final datetime = steps[i].$4;

      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? AppColors.primary : AppColors.white,
                      border: Border.all(
                        color: isDone || isNext
                            ? AppColors.primary
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: isDone
                        ? AppIcon(
                            AppAssets.check,
                            size: 14,
                            color: AppColors.white,
                          )
                        : Text(
                            '$stepNum',
                            style: AppTextStyles.style(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isNext
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isDone ? AppColors.primary : AppColors.border,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: Material(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: isNext ? () => provider.markStep(stepNum) : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isNext
                              ? AppColors.primary
                              : AppColors.peachCard,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.peach,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: AppIcon(
                              icon,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: AppTextStyles.style(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppColors.sectionTitle,
                                  ),
                                ),
                                Text(
                                  desc,
                                  style: AppTextStyles.style(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (datetime != null &&
                                    datetime.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      datetime,
                                      style: AppTextStyles.style(
                                        fontSize: 10,
                                        color: AppColors.navigateText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceDetailsProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppIcon(
                  AppAssets.calendar,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.scheduleId.tr(),
                    style: AppTextStyles.style(
                      color: AppColors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    provider.displayScheduleId.isEmpty
                        ? '-'
                        : provider.displayScheduleId,
                    style: AppTextStyles.style(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppIcon(
                          AppAssets.clock,
                          size: 14,
                          color: AppColors.white.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.dateTime.tr(),
                          style: AppTextStyles.style(
                            color: AppColors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.displayDate.isEmpty ? '-' : provider.displayDate,
                      style: AppTextStyles.style(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      provider.displayTimeRange.isEmpty
                          ? '-'
                          : provider.displayTimeRange,
                      style: AppTextStyles.style(
                        color: AppColors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.upcomingBadge,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppStrings.upcoming.tr(),
                  style: AppTextStyles.style(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerDetailsCard extends StatelessWidget {
  const _CustomerDetailsCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceDetailsProvider>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.peachCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            iconAsset: AppAssets.person,
            title: AppStrings.customerDetails.tr(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.customerCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.white,
                  child: Text(
                    provider.displayCustomerInitials.isEmpty
                        ? '?'
                        : provider.displayCustomerInitials,
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.w600,
                      color: AppColors.sectionTitle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.displayCustomerName.isEmpty
                            ? '-'
                            : provider.displayCustomerName,
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.w600,
                          color: AppColors.navigateText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          AppIcon(
                            AppAssets.phone,
                            size: 12,
                            color: AppColors.phoneNumber,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              provider.displayPhone.isEmpty
                                  ? '-'
                                  : provider.displayPhone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.style(
                                fontSize: 12,
                                color: AppColors.phoneNumber,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          AppIcon(
                            AppAssets.email,
                            size: 12,
                            color: AppColors.phoneNumber,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              provider.displayEmail.isEmpty
                                  ? '-'
                                  : provider.displayEmail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.style(
                                fontSize: 12,
                                color: AppColors.phoneNumber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (provider.displayPhone.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri(
                        scheme: 'tel',
                        path: provider.displayPhone,
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.destructiveLight,
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon(
                        AppAssets.phoneFilled,
                        size: 18,
                        color: AppColors.destructive,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceAddressCard extends StatelessWidget {
  const _ServiceAddressCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceDetailsProvider>();
    final address = provider.displayAddress;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.peachCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            iconAsset: AppAssets.location,
            title: AppStrings.serviceAddress.tr(),
          ),
          const SizedBox(height: 12),
          Text(
            address.isEmpty ? '-' : address,
            style: AppTextStyles.style(
              fontSize: 13,
              color: AppColors.phoneNumber,
            ),
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.navigateText,
                  backgroundColor: AppColors.customerCard,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: AppIcon(
                  AppAssets.send,
                  size: 16,
                  color: AppColors.navigateText,
                ),
                label: Text(
                  AppStrings.navigate.tr(),
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.w500,
                    color: AppColors.navigateText,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.iconAsset, required this.title});

  final String iconAsset;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcon(iconAsset, size: 18, color: AppColors.sectionTitle),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTextStyles.style(
            fontWeight: FontWeight.w500,
            color: AppColors.sectionTitle,
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(
                AppAssets.shieldFilled,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.sectionTitle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.style(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
