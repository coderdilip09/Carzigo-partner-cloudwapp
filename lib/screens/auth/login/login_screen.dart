import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_phone_field.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/screens/auth/login/login_provider.dart';
import 'package:carzigo_partner/screens/profile/privacy/privacy_screen.dart';
import 'package:carzigo_partner/screens/profile/terms/terms_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild login when locale changes (EN / HI toggle).
    context.locale;
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: Consumer<LoginProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                const Positioned.fill(child: AppImageView(AppAssets.bg, fit: BoxFit.cover)),
                SafeArea(
                  right: false,
                  child: Column(
                    children: [
                      // Language toggle (temporarily disabled)
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(right: 16, top: 4),
                      //     child: Material(
                      //       color: Colors.transparent,
                      //       child: InkWell(
                      //         onTap: () {
                      //           final next = context.locale.languageCode == 'en'
                      //               ? const Locale('hi')
                      //               : const Locale('en');
                      //           context.setLocale(next);
                      //         },
                      //         borderRadius: BorderRadius.circular(20),
                      //         child: Container(
                      //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      //           decoration: BoxDecoration(
                      //             color: AppColors.white,
                      //             borderRadius: BorderRadius.circular(20),
                      //             border: Border.all(color: AppColors.border),
                      //           ),
                      //           child: Row(
                      //             mainAxisSize: MainAxisSize.min,
                      //             children: [
                      //               const Icon(Icons.translate, size: 16, color: AppColors.primary),
                      //               const SizedBox(width: 4),
                      //               Text(
                      //                 context.locale.languageCode == 'en'
                      //                     ? AppStrings.languageEn.tr()
                      //                     : AppStrings.languageHi.tr(),
                      //                 style: AppTextStyles.style(
                      //                   color: AppColors.primary,
                      //                   fontWeight: FontWeight.w600,
                      //                   fontSize: 12,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 25),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: logo + welcome left, car 116x155 flush right (Figma)
                              SizedBox(
                                width: double.infinity,
                                height: 155,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Positioned(
                                      right: 0,
                                      top: 0,
                                      child: AppImageView(
                                        AppAssets.homeSideCar,
                                        width: 140,
                                        height: 155,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.centerRight,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20, right: 148),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const AppImageView(
                                            AppAssets.logo,
                                            height: 52,
                                            fit: BoxFit.contain,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            AppStrings.heyWelcomeBack.tr(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.style(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                              height: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            AppStrings.signInToContinue.tr(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.style(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.textSecondary,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                    const SizedBox(height: 24),
                                    _FeatureRow(),
                                    const SizedBox(height: 20),
                                    _BenefitsCard(),
                                    const SizedBox(height: 24),
                                    AppSolidButton(
                                      label: AppStrings.submit.tr(),
                                      onTap: provider.tapOnSubmit,
                                      isLoading: provider.isLoading,
                                    ),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: Builder(
                                        builder: (context) {
                                          final legal = AppStrings.termsAndPrivacy.tr();
                                          final split = RegExp(
                                            r'\s*&\s*|\s+और\s+',
                                          ).firstMatch(legal);
                                          final termsLabel = split == null
                                              ? legal
                                              : legal.substring(0, split.start).trim();
                                          final privacyLabel = split == null
                                              ? AppStrings.privacyPolicy.tr()
                                              : legal.substring(split.end).trim();
                                          final joiner =
                                              split?.group(0) ?? ' ${AppStrings.and.tr()} ';
                                          return RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                              style: AppTextStyles.style(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: '${AppStrings.byContinuingAgree.tr()} ',
                                                ),
                                                TextSpan(
                                                  text: termsLabel,
                                                  style: AppTextStyles.style(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () =>
                                                        AppNavigation.to(const TermsScreen()),
                                                ),
                                                TextSpan(
                                                  text: joiner,
                                                  style: AppTextStyles.style(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: privacyLabel,
                                                  style: AppTextStyles.style(
                                                    color: AppColors.primary,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () =>
                                                        AppNavigation.to(const PrivacyScreen()),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  @override
  Widget build(BuildContext context) {
    // Read locale so this widget rebuilds when language changes.
    context.locale;
    final items = [
      (AppAssets.lock, AppStrings.secureSafe.tr(), AppStrings.dataProtected.tr()),
      (AppAssets.rocket, AppStrings.quickAccess.tr(), AppStrings.loginInSeconds.tr()),
      (AppAssets.headset, AppStrings.support247.tr(), AppStrings.weAreHereToHelp.tr()),
    ];
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const VerticalDivider(width: 16, thickness: 1, color: AppColors.border),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppColors.peach, shape: BoxShape.circle),
                    child: AppIcon(items[i].$1, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[i].$2,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.style(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    items[i].$3,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.style(fontSize: 8, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard();

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.peach, shape: BoxShape.circle),
            child: const AppIcon(AppAssets.privacy, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.oneAccountManyBenefits.tr(),
                  style: AppTextStyles.style(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  AppStrings.manageVehicleBookings.tr(),
                  style: AppTextStyles.style(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
