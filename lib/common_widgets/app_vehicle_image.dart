import 'dart:io';

import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Shows the customer-uploaded vehicle image when available, otherwise [AppAssets.logo].
class AppVehicleImage extends StatelessWidget {
  const AppVehicleImage({
    super.key,
    this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 10,
  });

  final String? image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (Skeletonizer.maybeOf(context)?.enabled == true) {
      return Bone(
        width: width,
        height: height,
        borderRadius: BorderRadius.circular(borderRadius),
      );
    }
    final path = image?.trim() ?? '';
    final child = path.isEmpty
        ? _fallback()
        : path.startsWith('http://') || path.startsWith('https://')
        ? _network(path)
        : path.startsWith('assets/')
        ? AppImageView(path, width: width, height: height, fit: fit)
        : _file(path);

    if (borderRadius <= 0) return child;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: child,
    );
  }

  Widget _fallback() {
    return AppImageView(
      AppAssets.logo,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  Widget _network(String url) {
    return Skeleton.leaf(
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _fallback(),
      ),
    );
  }

  Widget _file(String path) {
    return Skeleton.leaf(
      child: Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _fallback(),
      ),
    );
  }
}
