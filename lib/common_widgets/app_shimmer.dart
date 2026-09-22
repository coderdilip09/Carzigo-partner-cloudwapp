import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Skeletonizes the real page layout so loading matches the design.
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  static const effect = ShimmerEffect(
    baseColor: AppColors.shimmerBase,
    highlightColor: AppColors.shimmerHighlight,
    duration: Duration(milliseconds: 1200),
  );

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      ignorePointers: enabled,
      ignoreContainers: true,
      effect: effect,
      child: child,
    );
  }
}
