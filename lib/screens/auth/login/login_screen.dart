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
          return ColoredBox(
            color: AppColors.background,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const AppImageView(
                  AppAssets.bg,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                Scaffold(
                  backgroundColor: Colors.transparent,
                  body: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const AppImageView(
                                        AppAssets.logo,
                                        width: 250,
                                        fit: BoxFit.contain,
                                        alignment: Alignment.centerLeft,
                                      ),
                                      const SizedBox(height: 18),
                                      Text(
                                        AppStrings.heyWelcomeBack.tr(),
                                        style: AppTextStyles.style(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        AppStrings.signInToContinue.tr(),
                                        style: AppTextStyles.style(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const AppImageView(
                                AppAssets.homeSideCar,
                                height: 250,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppPhoneField(
                                  onChanged: provider.setPhone,
                                  onCountryChanged: provider.setCountry,
                                  initialCountryCode:
                                      provider.country.countryCode,
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
                                const SizedBox(height: 40),
                                const _FeatureRow(),
                                const SizedBox(height: 40),
                                const _BenefitsCard(),
                                const SizedBox(height: 40),
                                AppSolidButton(
                                  label: AppStrings.submit.tr(),
                                  onTap: provider.isPhoneValid
                                      ? provider.tapOnSubmit
                                      : null,
                                  isLoading: provider.isLoading,
                                ),
                                const SizedBox(height: 20),
                                const SizedBox(
                                  width: double.infinity,
                                  child: _TermsPrivacyText(),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _TermsPrivacyText extends StatefulWidget {
  const _TermsPrivacyText();

  @override
  State<_TermsPrivacyText> createState() => _TermsPrivacyTextState();
}

class _TermsPrivacyTextState extends State<_TermsPrivacyText> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => AppNavigation.to(const TermsScreen());
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => AppNavigation.to(const PrivacyScreen());
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.locale;
    final baseStyle = AppTextStyles.style(
      color: AppColors.textSecondary,
      fontSize: 12,
    );
    final linkStyle = AppTextStyles.style(
      color: AppColors.primary,
      fontWeight: FontWeight.w700,
      fontSize: 12,
    );

    return Text.rich(
      TextSpan(
        text: '${AppStrings.byContinuingAgree.tr()} ',
        style: baseStyle,
        children: [
          TextSpan(
            text: AppStrings.termsConditions.tr(),
            style: linkStyle,
            recognizer: _termsRecognizer,
          ),
          TextSpan(text: ' & ', style: baseStyle),
          TextSpan(
            text: AppStrings.privacyPolicy.tr(),
            style: linkStyle,
            recognizer: _privacyRecognizer,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  @override
  Widget build(BuildContext context) {
    context.locale;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FeatureItem(
          icon: const AppIcon(AppAssets.lock, size: 20, color: AppColors.primary),
          title: AppStrings.secureSafe.tr(),
          subtitle: AppStrings.dataProtected.tr(),
        ),
        const _VerticalDivider(),
        _FeatureItem(
          icon: const AppIcon(
            AppAssets.rocket,
            size: 20,
            color: AppColors.primary,
          ),
          title: AppStrings.quickAccess.tr(),
          subtitle: AppStrings.loginInSeconds.tr(),
        ),
        const _VerticalDivider(),
        _FeatureItem(
          icon: const AppIcon(
            AppAssets.headset,
            size: 20,
            color: AppColors.primary,
          ),
          title: AppStrings.support247.tr(),
          subtitle: AppStrings.weAreHereToHelp.tr(),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      width: 1,
      margin: const EdgeInsets.only(top: 4),
      color: AppColors.border,
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Widget icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: const BoxDecoration(
                color: AppColors.peach,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: icon,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.style(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.style(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.25,
              ),
            ),
          ],
        ),
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: const BoxDecoration(
              color: AppColors.peach,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const AppIcon(AppAssets.privacy, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.oneAccountManyBenefits.tr(),
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.manageVehicleBookings.tr(),
                  style: AppTextStyles.style(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
