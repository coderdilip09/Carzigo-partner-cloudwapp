import 'package:carzigo_partner/screens/profile/legal/legal_page_screen.dart';
import 'package:carzigo_partner/services/api_service/api_urls.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPageScreen(
      slug: ApiUrls.legalPrivacySlug,
      fallbackTitle: AppStrings.privacyPolicy.tr(),
    );
  }
}
