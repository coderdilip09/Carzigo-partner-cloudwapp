import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchUri(Uri uri) async {
    final ok = await canLaunchUrl(uri);
    if (!ok) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _callSupport() async {
    final raw = AppStrings.supportPhone.tr().replaceAll(RegExp(r'[^\d+]'), '');
    await _launchUri(Uri.parse('tel:$raw'));
  }

  Future<void> _emailSupport() async {
    final email = AppStrings.supportEmail.tr().trim();
    final subject = Uri.encodeComponent('Carzigo Partner Support');
    await _launchUri(Uri.parse('mailto:$email?subject=$subject'));
  }

  List<(String, String)> get _allTopics => [
    (AppStrings.topicBooking.tr(), AppStrings.topicBookingDesc.tr()),
    (AppStrings.topicPayments.tr(), AppStrings.topicPaymentsDesc.tr()),
    (AppStrings.topicMembership.tr(), AppStrings.topicMembershipDesc.tr()),
    (AppStrings.topicAccount.tr(), AppStrings.topicAccountDesc.tr()),
    (AppStrings.topicOffers.tr(), AppStrings.topicOffersDesc.tr()),
    (AppStrings.topicGeneral.tr(), AppStrings.topicGeneralDesc.tr()),
  ];

  List<(String, String)> get _filteredTopics {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _allTopics;
    return _allTopics
        .where(
          (t) =>
              t.$1.toLowerCase().contains(q) || t.$2.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final topics = _filteredTopics;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBg(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBackHeader(
                  title: AppStrings.helpSupport.tr(),
                  showBackText: false,
                  titleInline: true,
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.helpHere.tr(),
                            style: AppTextStyles.style(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppStrings.helpSubtitle.tr(),
                            style: AppTextStyles.style(
                              fontSize: 12,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.notification,
                                      foregroundColor: AppColors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const AppIcon(
                                          AppAssets.headset,
                                          size: 16,
                                          color: AppColors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            AppStrings.contactSupport.tr(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.style(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 40,
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textPrimary,
                                      backgroundColor: AppColors.white,
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      AppStrings.emailUs.tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.style(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const AppImageView(
                      AppAssets.headphone,
                      width: 110,
                      height: 113,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.textFieldFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const AppIcon(
                        AppAssets.search,
                        size: 20,
                        color: AppColors.black,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          style: AppTextStyles.style(
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                            hintText: AppStrings.searchForHelp.tr(),
                            hintStyle: AppTextStyles.style(
                              fontSize: 14,
                              color: AppColors.black,
                            ),
                            filled: true,
                            fillColor: AppColors.textFieldFill,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.black,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.faqTitle.tr(),
                  style: AppTextStyles.style(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (topics.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      AppStrings.noResultsFound.tr(),
                      style: AppTextStyles.style(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ...List.generate(topics.length, (i) {
                    final t = topics[i];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.$1,
                                      style: AppTextStyles.style(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      t.$2,
                                      style: AppTextStyles.style(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const AppIcon(
                                AppAssets.chevronRight,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                            ],
                          ),
                        ),
                        if (i < topics.length - 1)
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.border,
                          ),
                      ],
                    );
                  }),
                const SizedBox(height: 20),
                Text(
                  AppStrings.otherWays.tr(),
                  style: AppTextStyles.style(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _ContactCard(
                  iconAsset: AppAssets.phone,
                  title: AppStrings.callUs.tr(),
                  value: AppStrings.supportPhone.tr(),
                  action: AppStrings.callNow.tr(),
                  actionIcon: AppAssets.personCall,
                  onAction: _callSupport,
                ),
                _ContactCard(
                  iconAsset: AppAssets.email,
                  title: AppStrings.emailUsTitle.tr(),
                  value: AppStrings.supportEmail.tr(),
                  action: AppStrings.sendEmail.tr(),
                  outlined: true,
                  onAction: _emailSupport,
                ),
                _ContactCard(
                  iconAsset: AppAssets.clock,
                  title: AppStrings.supportHours.tr(),
                  value: AppStrings.supportHoursValue.tr(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.iconAsset,
    required this.title,
    required this.value,
    this.action,
    this.actionIcon,
    this.outlined = false,
    this.onAction,
  });

  final String iconAsset;
  final String title;
  final String value;
  final String? action;
  final String? actionIcon;
  final bool outlined;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.contactCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.notification,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppIcon(iconAsset, color: AppColors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.style(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (action != null && action!.isNotEmpty) ...[
            const SizedBox(width: 8),
            outlined
                ? SizedBox(
                    height: 34,
                    child: OutlinedButton(
                      onPressed: onAction,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(
                          color: AppColors.sendEmailBorder,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        action!,
                        style: AppTextStyles.style(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.notification,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (actionIcon != null) ...[
                            AppIcon(
                              actionIcon!,
                              size: 14,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            action!,
                            style: AppTextStyles.style(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}
