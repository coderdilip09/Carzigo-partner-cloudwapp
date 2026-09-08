import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 120, this.showPartner = true});

  final double size;
  final bool showPartner;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppImageView(
          AppAssets.logo,
          width: size,
          fit: BoxFit.contain,
        ),
        if (showPartner) ...[
          const SizedBox(height: 2),
          Text(
            AppStrings.partner.tr(),
            style: AppTextStyles.style(
              fontSize: size * 0.12,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              letterSpacing: 6,
              color: AppColors.black,
            ),
          ),
        ],
      ],
    );
  }
}

/// Small logo mark for headers (falls back to SVG car if needed).
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.height = 32});

  final double height;

  @override
  Widget build(BuildContext context) {
    return AppImageView(
      AppAssets.logo,
      height: height,
      fit: BoxFit.contain,
    );
  }
}

Widget appLogoOrIcon({double size = 48, Color? color}) {
  return AppImageView(
    AppAssets.logo,
    width: size,
    height: size,
    fit: BoxFit.contain,
  );
}

// Keep AppIcon available for chrome; logo mark helper for brand
Widget brandCarIcon({double size = 48, Color? color}) {
  return AppIcon(AppAssets.logoCar, size: size, color: color);
}
