import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:flutter/material.dart';

/// Full-screen soft peach background used across app screens.
class AppBg extends StatelessWidget {
  const AppBg({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: AppImageView(AppAssets.bg, fit: BoxFit.cover)),
        child,
      ],
    );
  }
}
