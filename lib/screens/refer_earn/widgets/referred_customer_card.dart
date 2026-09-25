import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ReferredCustomerCard extends StatelessWidget {
  const ReferredCustomerCard({
    super.key,
    required this.initials,
    required this.name,
    required this.phone,
    required this.status,
    required this.amount,
    this.statusKey,
    this.onTap,
  });

  final String initials;
  final String name;
  final String phone;
  final String status;
  final String amount;
  final String? statusKey;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = _StatusStyle.from(statusKey, status);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.peachCard),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: style.color,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: style.soft,
                        child: Text(
                          initials,
                          style: AppTextStyles.style(
                            fontWeight: FontWeight.w700,
                            color: style.color,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.style(
                                fontWeight: FontWeight.w700,
                                color: AppColors.navigateText,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                AppIcon(
                                  AppAssets.phone,
                                  size: 11,
                                  color: AppColors.phoneIcon,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    phone,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.style(
                                      fontSize: 11,
                                      color: AppColors.phoneNumber,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: style.soft,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    style.label,
                                    style: AppTextStyles.style(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: style.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            amount,
                            style: AppTextStyles.style(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.navigateText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            style.amountLabel,
                            style: AppTextStyles.style(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: style.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.amountLabel,
    required this.color,
    required this.soft,
  });

  final String label;
  final String amountLabel;
  final Color color;
  final Color soft;

  factory _StatusStyle.from(String? statusKey, String status) {
    final key = (statusKey ?? status).toLowerCase();
    if (key.contains('paid') && !key.contains('payout')) {
      return _StatusStyle(
        label: AppStrings.referralFilterComplete.tr(),
        amountLabel: AppStrings.referralRewardPaid.tr(),
        color: AppColors.verified,
        soft: AppColors.greenLight,
      );
    }
    if (key.contains('pending_payout') ||
        key.contains('payout') ||
        key.contains('complete')) {
      return _StatusStyle(
        label: AppStrings.referralFilterComplete.tr(),
        amountLabel: AppStrings.referralRewardToPay.tr(),
        color: AppColors.accentOrange,
        soft: AppColors.peach,
      );
    }
    return _StatusStyle(
      label: AppStrings.referralFilterOnboard.tr(),
      amountLabel: AppStrings.referralRewardPending.tr(),
      color: AppColors.viewAllLink,
      soft: const Color(0xFFEAF4FF),
    );
  }
}
