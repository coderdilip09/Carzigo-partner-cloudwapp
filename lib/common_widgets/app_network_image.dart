import 'package:carzigo_partner/common_widgets/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Network photo that shimmers in its own shape until the image arrives.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.circle = false,
    required this.error,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final bool circle;
  final Widget error;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => error,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Skeletonizer(
          enabled: true,
          effect: AppShimmer.effect,
          child: circle
              ? Bone.circle(size: width ?? height ?? 48)
              : Bone(
                  width: width,
                  height: height,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
        );
      },
    );
  }
}
