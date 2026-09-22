import 'package:carzigo_partner/common_widgets/app_icon.dart';
import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_page_scaffold.dart';
import 'package:carzigo_partner/screens/profile/help_support/help_support_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HelpSupportProvider(),
      child: const _HelpSupportView(),
    );
  }
}

class _HelpSupportView extends StatelessWidget {
  const _HelpSupportView();

  Future<void> _launchUri(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) AppToast.error(AppStrings.requestFailed.tr());
    } catch (_) {
      AppToast.error(AppStrings.requestFailed.tr());
    }
  }

  Future<void> _callSupport(HelpSupportProvider provider) async {
    final raw = provider.supportPhone?.trim();
    if (raw == null || raw.isEmpty) {
      AppToast.error(AppStrings.requestFailed.tr());
      return;
    }
    final phone = raw.replaceAll(RegExp(r'[^\d+]'), '');
    await _launchUri(Uri.parse('tel:$phone'));
  }

  Future<void> _emailSupport(HelpSupportProvider provider) async {
    final email = provider.supportEmail?.trim();
    if (email == null || email.isEmpty) {
      AppToast.error(AppStrings.requestFailed.tr());
      return;
    }
    final subject = Uri.encodeComponent('Carzigo Partner Support');
    await _launchUri(Uri.parse('mailto:$email?subject=$subject'));
  }

  static const _placeholderTopics = [
    HelpTopicData(
      key: 'shimmer-1',
      title: 'Loading topic title here',
      subtitle: 'Loading subtitle text',
    ),
    HelpTopicData(
      key: 'shimmer-2',
      title: 'Loading second topic title',
      subtitle: 'Loading subtitle text',
    ),
    HelpTopicData(
      key: 'shimmer-3',
      title: 'Loading third topic title',
      subtitle: 'Loading subtitle text',
    ),
    HelpTopicData(
      key: 'shimmer-4',
      title: 'Loading fourth topic title',
      subtitle: 'Loading subtitle text',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HelpSupportProvider>();
    final showSearchResults =
        provider.isSearching && provider.searchQuery.length >= 2;
    final isPageLoading =
        provider.isLoading &&
        provider.topics.isEmpty &&
        provider.supportPhone == null;
    final showError =
        provider.loadError != null &&
        provider.topics.isEmpty &&
        provider.supportPhone == null;
    final topics = isPageLoading ? _placeholderTopics : provider.topics;

    return AppPageScaffold(
      title: AppStrings.helpSupport.tr(),
      showBackText: false,
      titleInline: true,
      isLoading: isPageLoading,
      showLoadingShimmer: false,
      body: showError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (provider.loadError?.trim().isNotEmpty == true)
                          ? provider.loadError!
                          : AppStrings.requestFailed.tr(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.style(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.loadHelp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                      child: Text(AppStrings.tryAgain.tr()),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          spacing: 6,
                          children: [
                            Text(
                              provider.headline?.isNotEmpty == true
                                  ? provider.headline!
                                  : AppStrings.helpHere.tr(),
                              style: AppTextStyles.style(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              provider.subtitle?.isNotEmpty == true
                                  ? provider.subtitle!
                                  : AppStrings.helpSubtitle.tr(),
                              style: AppTextStyles.style(
                                fontSize: 12,
                                height: 1.4,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const AppImageView(
                        AppAssets.headphone,
                        width: 110,
                        height: 113,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: isPageLoading
                                ? null
                                : () => _callSupport(provider),
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
                              mainAxisAlignment: MainAxisAlignment.center,
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
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: OutlinedButton(
                            onPressed: isPageLoading
                                ? null
                                : () => _emailSupport(provider),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              backgroundColor: AppColors.white,
                              side: const BorderSide(color: AppColors.primary),
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
                  const SizedBox(height: 16),
                  _HelpSearchField(
                    onChanged: provider.onSearchChanged,
                    hasQuery: provider.searchQuery.isNotEmpty,
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
                  if (showSearchResults && topics.isEmpty)
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
                  else if (!isPageLoading && topics.isEmpty)
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
                    ...topics.map(
                      (topic) => _TopicTile(
                        key: ValueKey('topic-${topic.key}'),
                        topic: topic,
                        expanded: provider.expandedTopicKey == topic.key,
                        onTap: isPageLoading
                            ? () {}
                            : () => provider.tapOnTopic(topic.key),
                      ),
                    ),
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
                  if (isPageLoading || provider.supportPhone?.isNotEmpty == true)
                    _ContactCard(
                      iconAsset: AppAssets.phone,
                      title: AppStrings.callUs.tr(),
                      value: provider.supportPhone?.isNotEmpty == true
                          ? provider.supportPhone!
                          : '+91 00000 00000',
                      action: AppStrings.callNow.tr(),
                      actionIcon: AppAssets.personCall,
                      onAction: isPageLoading
                          ? null
                          : () => _callSupport(provider),
                    ),
                  if (isPageLoading || provider.supportEmail?.isNotEmpty == true)
                    _ContactCard(
                      iconAsset: AppAssets.email,
                      title: AppStrings.emailUsTitle.tr(),
                      value: provider.supportEmail?.isNotEmpty == true
                          ? provider.supportEmail!
                          : 'support@carzigo.com',
                      action: AppStrings.sendEmail.tr(),
                      outlined: true,
                      onAction: isPageLoading
                          ? null
                          : () => _emailSupport(provider),
                    ),
                  if (isPageLoading || provider.supportHours?.isNotEmpty == true)
                    _ContactCard(
                      iconAsset: AppAssets.clock,
                      title: AppStrings.supportHours.tr(),
                      value: provider.supportHours?.isNotEmpty == true
                          ? provider.supportHours!
                          : 'Mon–Sat, 9 AM – 6 PM',
                    ),
                ],
              ),
            ),
    );
  }
}

class _HelpSearchField extends StatefulWidget {
  const _HelpSearchField({required this.onChanged, required this.hasQuery});

  final ValueChanged<String> onChanged;
  final bool hasQuery;

  @override
  State<_HelpSearchField> createState() => _HelpSearchFieldState();
}

class _HelpSearchFieldState extends State<_HelpSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.textFieldFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const AppIcon(AppAssets.search, size: 20, color: AppColors.black),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: AppTextStyles.style(fontSize: 14, color: AppColors.black),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
            ),
          ),
          if (widget.hasQuery)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onChanged('');
              },
              child: const Icon(Icons.close, size: 18, color: AppColors.black),
            ),
        ],
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    super.key,
    required this.topic,
    required this.expanded,
    required this.onTap,
  });

  final HelpTopicData topic;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    topic.title,
                    style: AppTextStyles.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const AppIcon(
                    AppAssets.chevronRight,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded && topic.subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12, right: 8),
            child: Text(
              topic.subtitle,
              style: AppTextStyles.style(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        const Divider(height: 1, thickness: 1, color: AppColors.border),
      ],
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
