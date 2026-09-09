import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _svgIcons = [
    AppAssets.home,
    AppAssets.calendar,
    AppAssets.refer,
    AppAssets.personIcon,
  ];

  @override
  Widget build(BuildContext context) {
    final labels = [
      AppStrings.dashboard.tr(),
      AppStrings.schedule.tr(),
      AppStrings.referAndEarn.tr(),
      AppStrings.profile.tr(),
    ];
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: AppColors.navBar, borderRadius: BorderRadius.circular(32)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (i) {
          final isActive = currentIndex == i;
          final color = isActive ? AppColors.black : AppColors.navUnselected;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(_svgIcons[i], size: 22, color: color),
                const SizedBox(height: 4),
                Text(
                  labels[i],
                  style: AppTextStyles.style(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 20,
                    height: 2,
                    color: AppColors.black,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
