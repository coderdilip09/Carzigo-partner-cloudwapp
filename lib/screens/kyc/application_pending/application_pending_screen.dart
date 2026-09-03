import 'package:carzigo_partner/common_widgets/app_dialogs.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_solid_button.dart';
import 'package:carzigo_partner/screens/kyc/application_pending/application_pending_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApplicationPendingScreen extends StatelessWidget {
  const ApplicationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ApplicationPendingProvider(),
      child: Consumer<ApplicationPendingProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => showLogoutDialog(context),
                        child: Text(
                          AppStrings.logout.tr(),
                          style: AppTextStyles.style(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    const AppImageView(
                      AppAssets.reminder,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.applicationSubmitted.tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.style(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.applicationPendingBody.tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.style(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    AppSolidButton(
                      label: AppStrings.checkStatus.tr(),
                      onTap: provider.tapOnCheckStatus,
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
