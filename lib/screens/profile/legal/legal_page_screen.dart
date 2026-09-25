import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_shimmer.dart';
import 'package:carzigo_partner/screens/profile/legal/legal_page_provider.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalPageScreen extends StatelessWidget {
  const LegalPageScreen({
    super.key,
    required this.slug,
    required this.fallbackTitle,
  });

  final String slug;
  final String fallbackTitle;

  Future<void> _openLink(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LegalPageProvider(slug)..load(),
      child: Consumer<LegalPageProvider>(
        builder: (context, provider, _) {
          final isPageLoading = provider.isLoading && provider.page == null;
          final title = provider.page?.title?.trim().isNotEmpty == true
              ? provider.page!.title!
              : fallbackTitle;

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
                        title: title,
                        showBackText: false,
                        titleInline: true,
                      ),
                      Expanded(
                        child: isPageLoading
                            ? const AppShimmer(child: _LegalPageSkeleton())
                            : SingleChildScrollView(
                                padding: const EdgeInsets.only(top: 16),
                                child: Html(
                                  data: provider.page?.body ?? '',
                                  style: {
                                    'body': Style(
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                      fontSize: FontSize(14),
                                      lineHeight: const LineHeight(1.6),
                                      color: AppColors.textPrimary,
                                      fontFamily: AppTextStyles.fontFamily,
                                    ),
                                    'p': Style(
                                      margin: Margins.only(bottom: 10),
                                    ),
                                    'ol': Style(
                                      margin: Margins.only(bottom: 8),
                                    ),
                                    'a': Style(
                                      color: AppColors.primary,
                                    ),
                                  },
                                  onLinkTap: (url, _, _) => _openLink(url),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LegalPageSkeleton extends StatelessWidget {
  const _LegalPageSkeleton();

  static const _sections = <(double, List<double>)>[
    (0.42, [1, 1, 0.94, 0.72]),
    (0.58, [1, 0.96, 1, 0.88, 0.64]),
    (0.5, [1, 1, 0.9, 0.76]),
    (0.46, [1, 0.98, 1, 0.7]),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16),
      children: [
        _line('Updated on 00 Month 0000', widthFactor: 0.48, fontSize: 12),
        const SizedBox(height: 20),
        for (final section in _sections) ...[
          _line(
            'Section heading placeholder',
            widthFactor: section.$1,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 10),
          for (final width in section.$2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _line(
                'Legal policy body line placeholder content',
                widthFactor: width,
              ),
            ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }

  Widget _line(
    String text, {
    required double widthFactor,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: AppTextStyles.style(
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: 1.55,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
