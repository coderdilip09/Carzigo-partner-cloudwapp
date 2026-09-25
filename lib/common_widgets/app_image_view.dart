import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppImageView extends StatelessWidget {
  const AppImageView(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    if (Skeletonizer.maybeOf(context)?.enabled == true) {
      return Bone(
        width: width,
        height: height,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
      );
    }
    final image = Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: width,
        height: height,
      ),
    );
    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
