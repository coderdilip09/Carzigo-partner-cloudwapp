import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Soft text/icon skeleton. Card chrome stays so loading matches the layout.
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  static const effect = ShimmerEffect(
    baseColor: AppColors.shimmerBase,
    highlightColor: AppColors.shimmerHighlight,
    duration: Duration(milliseconds: 1400),
  );

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      ignorePointers: enabled,
      ignoreContainers: true,
      justifyMultiLineText: true,
      enableSwitchAnimation: false,
      textBoneBorderRadius: TextBoneBorderRadius.fromHeightFactor(0.45),
      effect: effect,
      child: child,
    );
  }
}
