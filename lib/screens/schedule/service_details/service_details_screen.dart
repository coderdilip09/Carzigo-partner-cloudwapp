import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_dialogs.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_network_image.dart';
import 'package:carzigo_partner/common_widgets/app_shimmer.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/common_widgets/app_vehicle_image.dart';
import 'package:carzigo_partner/models/job_data_model.dart';
import 'package:carzigo_partner/screens/schedule/service_details/service_details_provider.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key, this.jobId, this.job});

  final String? jobId;
  final JobDataModel? job;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ServiceDetailsProvider(jobId: jobId ?? job?.id, initialJob: job),
      child: Consumer<ServiceDetailsProvider>(
        builder: (context, provider, _) {
          final isPageLoading = provider.isLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: AppBg(
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: AppBackHeader(
                        title: AppStrings.serviceDetails.tr(),
                        showBackText: false,
                        titleInline: true,
                      ),
                    ),
                    Expanded(
                      child: AppShimmer(
                        enabled: isPageLoading,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _ScheduleCard(),
                              const SizedBox(height: 16),
                              const _CustomerDetailsCard(),
                              const SizedBox(height: 16),
                              const _VehicleDetailsCard(),
                              if (provider.needsKeyHandover &&
                                  provider.job?.keyVerified != true &&
                                  provider.currentStep < 4) ...[
                                const SizedBox(height: 16),
                                const _KeyFindNote(),
                              ],
                              const SizedBox(height: 16),
                              const _ServiceAddressCard(),
                              if (provider.job?.isNotComplete == true) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4E5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE67E22),
                                    ),
                                  ),
                                  child: Text(
                                    AppStrings.washDayEndedContactAdmin.tr(),
                                    style: AppTextStyles.style(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF9A5B00),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              Text(
                                AppStrings.updateStatus.tr(),
                                style: AppTextStyles.style(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.sectionTitle,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._buildSteps(context, provider),
                              const SizedBox(height: 16),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: _NoteCard(
                                        title: AppStrings.serviceNotes.tr(),
                                        text: isPageLoading
                                            ? 'Service notes placeholder text'
                                            : provider.displayNotes.isEmpty
                                            ? AppStrings.noData.tr()
                                            : provider.displayNotes,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _NoteCard(
                                        title: AppStrings.customerInstructions
                                            .tr(),
                                        text: isPageLoading
                                            ? 'Customer instructions text'
                                            : provider
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: AppShimmer(
                        enabled: isPageLoading,
                        child: AppSolidButton(
                          label: AppStrings.addToCalendar.tr(),
                          onTap: isPageLoading
                              ? null
                              : provider.tapOnAddToCalendar,
                          isLoading: provider.isAddingToCalendar,
                          leading: AppIcon(
                            AppAssets.calendar,
                            size: 18,
                            color: AppColors.white,
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

  List<Widget> _buildSteps(
    BuildContext context,
    ServiceDetailsProvider provider,
  ) {
    final steps = [
      (
        AppStrings.statusAssigned.tr(),
        AppStrings.statusAssignedDesc.tr(),
        AppAssets.calendar,
        provider.isLoading
            ? '00 Sep 0000, 09:00 AM'
            : provider.displayAssignedAt,
        null,
        null,
      ),
      (
        AppStrings.statusOnTheWay.tr(),
        AppStrings.statusOnTheWayDesc.tr(),
        AppAssets.location,
        null,
        null,
        JobWorkflowStatus.onTheWay,
      ),
      (
        AppStrings.statusOnSite.tr(),
        AppStrings.statusOnSiteDesc.tr(),
        AppAssets.location,
        null,
        null,
        JobWorkflowStatus.onSite,
      ),
      if (provider.needsKeyHandover)
        (
          AppStrings.statusKeyHandover.tr(),
          AppStrings.statusKeyHandoverDesc.tr(),
          AppAssets.shieldFilled,
          null,
          'key',
          null,
        ),
      (
        AppStrings.statusUploadBefore.tr(),
        AppStrings.statusUploadBeforeDesc.tr(),
        AppAssets.camera,
        null,
        'before',
        null,
      ),
      (
        AppStrings.statusInProgress.tr(),
        AppStrings.statusInProgressDesc.tr(),
        AppAssets.headset,
        null,
        null,
        JobWorkflowStatus.inProgress,
      ),
      (
        AppStrings.statusUploadAfter.tr(),
        AppStrings.statusUploadAfterDesc.tr(),
        AppAssets.camera,
        null,
        'after',
        null,
      ),
      (
        AppStrings.statusCompleted.tr(),
        AppStrings.statusCompletedDesc.tr(),
        AppAssets.doubleCheck,
        null,
        null,
        JobWorkflowStatus.completed,
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
      final photoKind = steps[i].$5;
      final statusApi = steps[i].$6;
      final isKeyStep = photoKind == 'key';
      final photoBusy =
          photoKind != null &&
          provider.isUploadingPhoto &&
          provider.uploadingPhotoKind == photoKind;
      final photoUrl = photoKind == 'before'
          ? (provider.job?.beforePhoto ?? '')
          : photoKind == 'after'
          ? (provider.job?.afterPhoto ?? '')
          : '';
      final canPickPhoto = photoKind == 'before'
          ? provider.canEditBeforePhoto
          : photoKind == 'after'
          ? provider.canEditAfterPhoto
          : false;

      return Stack(
        children: [
          if (!isLast)
            Positioned(
              left: 13,
              top: 32,
              bottom: 4,
              width: 2,
              child: ColoredBox(
                color: isDone ? AppColors.primary : AppColors.border,
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    ? AppIcon(AppAssets.check, size: 14, color: AppColors.white)
                    : (isNext && provider.isUpdating) || photoBusy
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.6,
                          color: AppColors.primary,
                        ),
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
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: Material(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap:
                          !isKeyStep &&
                              !provider.isUpdating &&
                              !provider.isLoading &&
                              !provider.isUploadingPhoto &&
                              (canPickPhoto || (statusApi != null && isNext))
                          ? () {
                              if (photoKind == 'before' ||
                                  photoKind == 'after') {
                                provider.pickWashPhoto(context, photoKind!);
                                return;
                              }
                              _confirmAndMarkStep(
                                context,
                                provider,
                                stepNum,
                                title,
                                statusApi!,
                              );
                            }
                          : null,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (photoKind == 'before' ||
                                photoKind == 'after') ...[
                              _StepPhoto(
                                url: photoUrl,
                                busy: photoBusy,
                                canAdd: canPickPhoto,
                                onView: photoUrl.trim().isEmpty
                                    ? null
                                    : () => _showFullPhoto(context, photoUrl),
                              ),
                              const SizedBox(height: 10),
                            ],
                            if (isKeyStep && isDone)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  AppStrings.keyVerified.tr(),
                                  style: AppTextStyles.style(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            Row(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: AppTextStyles.style(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: AppColors.sectionTitle,
                                        ),
                                      ),
                                      if (!(isKeyStep && isNext))
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
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
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
                            if (isKeyStep && isNext) ...[
                              const SizedBox(height: 10),
                              const _KeyOtpBox(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Future<void> _confirmAndMarkStep(
    BuildContext context,
    ServiceDetailsProvider provider,
    int stepNum,
    String statusTitle,
    String statusApi,
  ) async {
    if (provider.isUpdating || provider.isLoading) return;

    // Duty can only start for today's scheduled jobs.
    final isDutyStart =
        statusApi == JobWorkflowStatus.onTheWay ||
        statusApi == JobWorkflowStatus.onSite ||
        statusApi == JobWorkflowStatus.arrived ||
        statusApi == JobWorkflowStatus.inProgress ||
        statusApi == JobWorkflowStatus.serviceStarted;
    if (isDutyStart && !provider.isScheduledToday) {
      AppToast.error(AppStrings.onTheWayNotTodayBody.tr());
      return;
    }

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: AppStrings.updateStatusConfirmTitle.tr(),
      body: AppStrings.updateStatusConfirmBody.tr(args: [statusTitle]),
      confirmLabel: AppStrings.markAs.tr(args: [statusTitle]),
    );
    if (!confirmed || !context.mounted) return;
    final completed = await provider.markStep(stepNum, statusApi);
    if (!completed || !context.mounted) return;
    AppToast.success(AppStrings.statusCompletedDesc.tr());
    AppNavigation.back(true);
  }
}

void _showFullPhoto(BuildContext context, String url) {
  final resolved = url.trim();
  if (resolved.isEmpty) return;
  showDialog<void>(
    context: context,
    builder: (ctx) {
      final size = MediaQuery.sizeOf(ctx);
      return Dialog(
        backgroundColor: AppColors.black,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SizedBox(
          width: size.width,
          height: size.height * 0.72,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.network(
                    resolved,
                    fit: BoxFit.contain,
                    width: size.width,
                    height: size.height * 0.72,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceDetailsProvider>();
    final loading = provider.isLoading;
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
                    loading
                        ? 'CZG-000000'
                        : provider.displayScheduleId.isEmpty
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
                      loading
                          ? '00 Sep 0000'
                          : provider.displayDate.isEmpty
                          ? '-'
                          : provider.displayDate,
                      style: AppTextStyles.style(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      loading
                          ? '09:00 AM - 10:00 AM'
                          : provider.displayTimeRange.isEmpty
                          ? '-'
                          : provider.displayTimeRange,
                      style: AppTextStyles.style(
                        color: AppColors.white,
                        fontSize: 13,
                      ),
                    ),
                    if (!loading && provider.displayPayout.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        provider.displayServiceName.isEmpty
                            ? provider.displayPayout
                            : '${provider.displayServiceName} · ${provider.displayPayout}',
                        style: AppTextStyles.style(
                          color: AppColors.white.withValues(alpha: 0.95),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
                  loading ? 'Upcoming' : provider.displayStatus,
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
    final loading = provider.isLoading;
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
                    loading
                        ? 'CN'
                        : provider.displayCustomerInitials.isEmpty
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
                        loading
                            ? 'Customer Name'
                            : provider.displayCustomerName.isEmpty
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
                              loading
                                  ? '+91 00000 00000'
                                  : provider.displayPhone.isEmpty
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
                              loading
                                  ? 'name@email.com'
                                  : provider.displayEmail.isEmpty
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
                if (!loading && provider.displayPhone.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: provider.openPhone,
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

class _VehicleDetailsCard extends StatelessWidget {
  const _VehicleDetailsCard();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceDetailsProvider>();
    final model = provider.displayVehicleModel;
    final plate = provider.displayPlateNumber;
    final label = provider.displayCar;
    final isLoading = provider.isLoading;

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
            iconAsset: AppAssets.logoCar,
            title: AppStrings.vehicleDetails.tr(),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.customerCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AppVehicleImage(
                  image: provider.displayVehicleImage,
                  width: 44,
                  height: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoading
                            ? 'Vehicle model name'
                            : (model.isNotEmpty
                                  ? model
                                  : (label.isNotEmpty ? label : '-')),
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.w600,
                          color: AppColors.navigateText,
                        ),
                      ),
                      if (isLoading || plate.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          isLoading
                              ? '${AppStrings.plateNumber.tr()}: XX00XX0000'
                              : '${AppStrings.plateNumber.tr()}: $plate',
                          style: AppTextStyles.style(
                            fontSize: 12,
                            color: AppColors.phoneNumber,
                          ),
                        ),
                      ] else if (!isLoading &&
                          model.isEmpty &&
                          label.isEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.noData.tr(),
                          style: AppTextStyles.style(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
    final loading = provider.isLoading;
    final address = provider.displayAddress;
    final canNavigate =
        loading ||
        address.isNotEmpty ||
        (provider.displayLat != null && provider.displayLng != null);
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
            loading
                ? 'Service address placeholder, City, PIN'
                : address.isEmpty
                ? '-'
                : address,
            style: AppTextStyles.style(
              fontSize: 13,
              color: AppColors.phoneNumber,
            ),
          ),
          if (canNavigate) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: loading ? null : provider.openMaps,
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

class _KeyFindNote extends StatelessWidget {
  const _KeyFindNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Text(
        AppStrings.keyHandoverPartnerNote.tr(),
        style: AppTextStyles.style(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _KeyOtpBox extends StatefulWidget {
  const _KeyOtpBox();

  @override
  State<_KeyOtpBox> createState() => _KeyOtpBoxState();
}

class _KeyOtpBoxState extends State<_KeyOtpBox> {
  String _code = '';

  static const _findSteps = [
    AppStrings.keyFindApp,
    AppStrings.keyFindSchedule,
    AppStrings.keyFindScreen,
    AppStrings.keyFindNotification,
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServiceDetailsProvider>();
    const steps = [
      AppStrings.keyStepMeet,
      AppStrings.keyStepAsk,
      AppStrings.keyStepEnter,
    ];
    final hasError = provider.keyOtpError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${i + 1}. ',
                style: AppTextStyles.style(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: Text(
                  steps[i].tr(),
                  style: AppTextStyles.style(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (i < steps.length - 1) const SizedBox(height: 4),
        ],
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final cellWidth = (constraints.maxWidth - spacing * 3) / 4;
            return MaterialPinField(
              length: 4,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _code = value;
                if (provider.keyOtpError != null) {
                  provider.setKeyOtp(value);
                }
              },
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              theme: MaterialPinTheme(
                shape: MaterialPinShape.outlined,
                cellSize: Size(cellWidth, 48),
                spacing: spacing,
                borderRadius: BorderRadius.circular(10),
                fillColor: const Color(0xFFF3F3F3),
                focusedFillColor: const Color(0xFFF3F3F3),
                filledFillColor: const Color(0xFFF3F3F3),
                followingFillColor: const Color(0xFFF3F3F3),
                completeFillColor: const Color(0xFFF3F3F3),
                borderColor: hasError
                    ? AppColors.destructive
                    : AppColors.border,
                focusedBorderColor: hasError
                    ? AppColors.destructive
                    : AppColors.primary,
                filledBorderColor: hasError
                    ? AppColors.destructive
                    : AppColors.primary,
                followingBorderColor: hasError
                    ? AppColors.destructive
                    : AppColors.border,
                completeBorderColor: hasError
                    ? AppColors.destructive
                    : AppColors.primary,
                errorColor: AppColors.destructive,
                errorBorderColor: AppColors.destructive,
                cursorColor: AppColors.primary,
                hintCharacter: '-',
                hintStyle: AppTextStyles.style(
                  fontSize: 18,
                  color: AppColors.textHint,
                ),
                textStyle: AppTextStyles.style(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            provider.keyOtpError!,
            style: AppTextStyles.style(
              fontSize: 11,
              color: AppColors.destructive,
            ),
          ),
        ],
        const SizedBox(height: 8),
        AppSolidButton(
          label: AppStrings.verifyKey.tr(),
          onTap: provider.isUpdating
              ? null
              : () => provider.verifyKeyOtp(_code),
          isLoading: provider.isUpdating,
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.keyFindTitle.tr(),
          style: AppTextStyles.style(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.sectionTitle,
          ),
        ),
        const SizedBox(height: 6),
        for (var i = 0; i < _findSteps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${i + 1}. ',
                style: AppTextStyles.style(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: Text(
                  _findSteps[i].tr(),
                  style: AppTextStyles.style(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (i < _findSteps.length - 1) const SizedBox(height: 4),
        ],
      ],
    );
  }
}

class _StepPhoto extends StatelessWidget {
  const _StepPhoto({
    required this.url,
    required this.busy,
    required this.canAdd,
    this.onView,
  });

  final String url;
  final bool busy;
  final bool canAdd;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final resolved = url.trim();
    return Container(
      height: 140,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.customerCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: busy
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : resolved.isEmpty
          ? Center(
              child: Text(
                canAdd ? AppStrings.addPhoto.tr() : '—',
                style: AppTextStyles.style(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : GestureDetector(
              onTap: onView,
              child: AppNetworkImage(
                url: resolved,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 140,
                borderRadius: 10,
                error: const Center(child: Icon(Icons.broken_image_outlined)),
              ),
            ),
    );
  }
}
