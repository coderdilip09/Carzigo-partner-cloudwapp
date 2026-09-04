import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/screens/auth/otp_verify/otp_verify_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/mock_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.phone,
    this.isChangeNumber = false,
  });

  final String phone;
  final bool isChangeNumber;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OtpVerifyProvider(
        phone: widget.phone,
        isChangeNumber: widget.isChangeNumber,
      )..startTimer(),
      child: Consumer<OtpVerifyProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                const Positioned.fill(
                  child: AppImageView(AppAssets.bg, fit: BoxFit.cover),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppBackHeader(showBackText: false),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.verifyYourNumber.tr(),
                                    style: AppTextStyles.style(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: AppTextStyles.style(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${AppStrings.enterOtpSentTo.tr()} ',
                                        ),
                                        TextSpan(
                                          text: widget.isChangeNumber
                                              ? '+91 ${widget.phone}'
                                              : MockData.userPhoneMasked,
                                          style: AppTextStyles.style(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const AppImageView(
                              AppAssets.otpIllustration,
                              width: 90,
                              height: 90,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.peach,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              AppIcon(
                                AppAssets.shield,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: _OtpValidForText()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              const spacing = 10.0;
                              final cellWidth =
                                  (constraints.maxWidth - spacing * 5) / 6;
                              final hasError = provider.otpError != null;
                              return MaterialPinField(
                                length: 6,
                                onChanged: provider.setOtp,
                                onTapOutside: (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                                theme: MaterialPinTheme(
                                  shape: MaterialPinShape.filled,
                                  cellSize: Size(cellWidth, 48),
                                  spacing: spacing,
                                  borderRadius: BorderRadius.circular(10),
                                  fillColor: const Color(0xFFF3F3F3),
                                  focusedFillColor: const Color(0xFFF3F3F3),
                                  filledFillColor: const Color(0xFFF3F3F3),
                                  followingFillColor: const Color(0xFFF3F3F3),
                                  completeFillColor: const Color(0xFFF3F3F3),
                                  borderColor: hasError
                                      ? AppColors.destructive
                                      : null,
                                  focusedBorderColor: hasError
                                      ? AppColors.destructive
                                      : AppColors.primary,
                                  followingBorderColor: hasError
                                      ? AppColors.destructive
                                      : null,
                                  errorColor: AppColors.destructive,
                                  errorBorderColor: AppColors.destructive,
                                  cursorColor: AppColors.primary,
                                  hintCharacter: '-',
                                  hintStyle: AppTextStyles.style(
                                    fontSize: 18,
                                    color: AppColors.textHint,
                                  ),
                                  textStyle: AppTextStyles.style(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (provider.otpError != null) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              provider.otpError!,
                              style: AppTextStyles.style(
                                fontSize: 12,
                                color: AppColors.destructive,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppIcon(
                                AppAssets.clock,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              _CodeExpiresText(time: provider.formattedTime),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _ResendCard(provider: provider),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.peach,
                                  shape: BoxShape.circle,
                                ),
                                child: const AppIcon(
                                  AppAssets.lock,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.secureAndPrivate.tr(),
                                      style: AppTextStyles.style(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      AppStrings.neverShareNumber.tr(),
                                      style: AppTextStyles.style(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppIcon(AppAssets.chevronRight),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppSolidButton(
                          label: AppStrings.verifyAndContinue.tr(),
                          onTap: provider.tapOnVerify,
                        ),
                      ],
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

class _CodeExpiresText extends StatelessWidget {
  const _CodeExpiresText({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    const marker = '§TIME§';
    final translated = AppStrings.codeExpiresIn.tr(args: [marker]);
    final parts = translated.split(marker);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: parts.first,
            style: AppTextStyles.style(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          TextSpan(
            text: time,
            style: AppTextStyles.style(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (parts.length > 1)
            TextSpan(
              text: parts[1],
              style: AppTextStyles.style(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

class _OtpValidForText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final time = AppStrings.otpValidDuration.tr();
    const marker = '§TIME§';
    final translated = AppStrings.otpValidFor.tr(args: [marker]);
    final parts = translated.split(marker);
    final baseStyle = AppTextStyles.style(fontSize: 12);

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: parts.first),
          TextSpan(
            text: time,
            style: AppTextStyles.style(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}

class _ResendCard extends StatelessWidget {
  const _ResendCard({required this.provider});

  final OtpVerifyProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.peach,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: AppIcon(
                    AppAssets.send,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.didntReceiveCode.tr(),
                      style: AppTextStyles.style(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      AppStrings.mayTakeMinutes.tr(),
                      style: AppTextStyles.style(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: provider.tapOnResend,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.peach,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: AppIcon(
                        AppAssets.resend,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppStrings.resendCode.tr(),
                    style: AppTextStyles.style(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    AppStrings.resendIn.tr(args: [provider.formattedTime]),
                    style: AppTextStyles.style(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
