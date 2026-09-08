import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum KycStep { identity, address, bank }

class AppKycStepper extends StatelessWidget {
  const AppKycStepper({super.key, required this.currentStep});

  final KycStep currentStep;

  static const double _dotSize = 8;
  /// Clear gap between each dot edge and the connector line.
  static const double _lineGap = 10;

  @override
  Widget build(BuildContext context) {
    final steps = [
      AppStrings.stepIdentity.tr(),
      AppStrings.stepAddress.tr(),
      AppStrings.stepBank.tr(),
    ];
    final currentIndex = currentStep.index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segment = constraints.maxWidth / steps.length;

          return Column(
            children: [
            SizedBox(
              height: _dotSize,
              child: Stack(
                children: [
                  for (var i = 0; i < steps.length - 1; i++)
                    Builder(
                      builder: (_) {
                        // Line starts after left dot + gap, ends before right dot - gap.
                        final left =
                            segment * i +
                            segment / 2 +
                            _dotSize / 2 +
                            _lineGap;
                        final right =
                            segment * (i + 1) +
                            segment / 2 -
                            _dotSize / 2 -
                            _lineGap;
                        final width = (right - left).clamp(0.0, double.infinity);
                        return Positioned(
                          left: left,
                          width: width,
                          top: (_dotSize - 2) / 2,
                          child: Container(
                            height: 2,
                            color: i + 1 <= currentIndex
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                        );
                      },
                    ),
                  for (var i = 0; i < steps.length; i++)
                    Positioned(
                      left: segment * i + segment / 2 - _dotSize / 2,
                      top: 0,
                      child: Container(
                        width: _dotSize,
                        height: _dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= currentIndex
                              ? AppColors.primary
                              : AppColors.textHint,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(steps.length, (i) {
                final isActive = i <= currentIndex;
                return Expanded(
                  child: Text(
                    steps[i],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.style(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
      ),
    );
  }
}
