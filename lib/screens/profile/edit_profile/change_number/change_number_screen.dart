import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_phone_field.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/screens/profile/edit_profile/change_number/change_number_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeNumberScreen extends StatelessWidget {
  const ChangeNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangeNumberProvider(),
      child: Consumer<ChangeNumberProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: AppBg(
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppBackHeader(
                              title: AppStrings.changeNumber.tr(),
                              showBackText: true,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.changeNumberSubtitle.tr(),
                              style: AppTextStyles.style(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 28),
                            AppPhoneField(
                              onChanged: provider.setPhone,
                              onCountryChanged: provider.setCountry,
                              initialCountryCode: provider.country.countryCode,
                              borderColor: provider.phoneError != null
                                  ? AppColors.destructive
                                  : null,
                            ),
                            if (provider.phoneError != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                provider.phoneError!,
                                style: AppTextStyles.style(
                                  fontSize: 12,
                                  color: AppColors.destructive,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.peach,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  AppIcon(
                                    AppAssets.shield,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AppStrings.changeNumberOtpHint.tr(),
                                      style: AppTextStyles.style(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        children: [
                          AppSolidButton(
                            label: AppStrings.sendOtp.tr(),
                            onTap: provider.tapOnSendOtp,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppIcon(
                                AppAssets.lock,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  AppStrings.infoSafe.tr(),
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.style(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
