import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:flutter/material.dart';

class AppUserAvatar extends StatelessWidget {
  const AppUserAvatar({super.key, this.url, this.size = 44});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photo = url?.trim() ?? '';
    final fallback = AppImageView(
      AppAssets.dummyProfile,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );

    final image = photo.startsWith('http://') || photo.startsWith('https://')
        ? Image.network(
            photo,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, error, stackTrace) => fallback,
          )
        : fallback;

    return ClipOval(child: image);
  }
}
