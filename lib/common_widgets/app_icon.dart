import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.asset, {
    super.key,
    this.size = 24,
    this.color,
  });

  final String asset;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (asset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn),
        placeholderBuilder: (_) => SizedBox(width: size, height: size),
      );
    }
    return Image.asset(
      asset,
      width: size,
      height: size,
      color: color,
      errorBuilder: (context, error, stackTrace) =>
          SizedBox(width: size, height: size),
    );
  }
}
