import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Page shell with a pinned back header (stays visible while [body] scrolls).
class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.body,
    this.title,
    this.showBackText = false,
    this.titleInline = true,
    this.onBack,
    this.headerPadding = const EdgeInsets.fromLTRB(20, 12, 20, 8),
    this.headerExtra,
    this.bottomBar,
    this.backgroundColor = AppColors.background,
  });

  final Widget body;
  final String? title;
  final bool showBackText;
  final bool titleInline;
  final VoidCallback? onBack;
  final EdgeInsetsGeometry headerPadding;
  final Widget? headerExtra;
  final Widget? bottomBar;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: AppBg(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: headerPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBackHeader(
                      title: title,
                      showBackText: showBackText,
                      titleInline: titleInline,
                      onBack: onBack,
                    ),
                    if (headerExtra != null) headerExtra!,
                  ],
                ),
              ),
              Expanded(child: body),
              if (bottomBar != null) bottomBar!,
            ],
          ),
        ),
      ),
    );
  }
}
