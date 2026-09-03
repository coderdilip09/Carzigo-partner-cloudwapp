import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppJobCard extends StatelessWidget {
  const AppJobCard({
    super.key,
    this.onTap,
    this.showPrice = false,
    this.status,
    this.timeLabel,
    this.compact = true,
    this.embedded = false,
    this.showBottomDivider = false,
  });

  final VoidCallback? onTap;
  final bool showPrice;
  final String? status;
  final String? timeLabel;
  final bool compact;
  final bool embedded;
  final bool showBottomDivider;

  @override
  Widget build(BuildContext context) {
    final resolvedTime = timeLabel ??
        (compact
            ? AppStrings.defaultJobTime.tr()
            : AppStrings.mockJobTimeRange.tr());

    final content = compact
        ? _buildCompact(resolvedTime)
        : _buildScheduleCard(resolvedTime);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            margin: embedded ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: embedded
                ? null
                : BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: compact ? AppColors.peachCard : AppColors.cardBorder,
                    ),
                  ),
            child: content,
          ),
          if (showBottomDivider)
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border,
            ),
        ],
      ),
    );
  }

  Widget _buildCompact(String resolvedTime) {
    final parts = resolvedTime.trim().split(RegExp(r'\s+'));
    final timePart = parts.isNotEmpty ? parts.first : resolvedTime;
    final periodPart = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return Row(
      children: [
        Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.pendingBadge,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timePart,
                textAlign: TextAlign.center,
                style: AppTextStyles.style(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              if (periodPart.isNotEmpty)
                Text(
                  periodPart,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.style(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.mockJobService.tr(),
                style: AppTextStyles.style(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.mockJobCustomer.tr(),
                style: AppTextStyles.style(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  AppIcon(
                    AppAssets.logoCar,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      AppStrings.mockJobCar.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.style(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (status != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.pendingBadge,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  AppAssets.clock,
                  size: 12,
                  color: AppColors.black,
                ),
                const SizedBox(width: 4),
                Text(
                  status!,
                  style: AppTextStyles.style(
                    fontSize: 10,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          AppIcon(
            AppAssets.chevronRight,
            size: 16,
            color: AppColors.black,
          ),
        ],
      ],
    );
  }

  Widget _buildScheduleCard(String resolvedTime) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.peachLight,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(6),
              child: const AppImageView(
                AppAssets.dummyCar,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.mockJobService.tr(),
                  style: AppTextStyles.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.mockJobCustomer.tr(),
                  style: AppTextStyles.style(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.mockJobCar.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.style(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.timeBadge,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppIcon(
                            AppAssets.clock,
                            size: 12,
                            color: AppColors.black,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            resolvedTime,
                            maxLines: 1,
                            softWrap: false,
                            style: AppTextStyles.style(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showPrice)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.mockJobPrice.tr(),
                      style: AppTextStyles.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const AppIcon(
                      AppAssets.chevronRight,
                      size: 16,
                      color: AppColors.black,
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.peach,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status!,
                    style: AppTextStyles.style(
                      fontSize: 10,
                      color: AppColors.accentOrange,
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
