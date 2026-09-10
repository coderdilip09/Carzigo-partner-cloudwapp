import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  Future<void> _setLocale(BuildContext context, Locale locale) async {
    if (context.locale.languageCode == locale.languageCode) return;
    await context.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    final code = context.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBg(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBackHeader(
                  title: AppStrings.selectLanguage.tr(),
                  showBackText: false,
                  titleInline: true,
                ),
                Text(
                  AppStrings.languageSubtitle.tr(),
                  style: AppTextStyles.style(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                _LanguageTile(
                  title: AppStrings.languageEnglish.tr(),
                  subtitle: AppStrings.languageEn.tr(),
                  selected: code == 'en',
                  onTap: () => _setLocale(context, const Locale('en')),
                ),
                _LanguageTile(
                  title: AppStrings.languageHi.tr(),
                  subtitle: 'HI',
                  selected: code == 'hi',
                  onTap: () => _setLocale(context, const Locale('hi')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.cardBorder,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.peach,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.translate,
                    size: 22,
                    color: selected ? AppColors.primary : AppColors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.sectionTitle,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.style(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  AppIcon(
                    AppAssets.check,
                    size: 22,
                    color: AppColors.primary,
                  )
                else
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
