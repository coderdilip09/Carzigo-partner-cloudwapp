import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
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
          final title = provider.page?.title?.trim().isNotEmpty == true
              ? provider.page!.title!
              : fallbackTitle;
          final html = provider.page?.body ?? '';

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
                        child: provider.isLoading && provider.page == null
                            ? const Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                child: Html(
                                  data: html,
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
