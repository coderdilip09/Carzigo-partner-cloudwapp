import 'package:carzigo_partner/common_widgets/app_back_header.dart';
import 'package:carzigo_partner/common_widgets/app_bg.dart';
import 'package:carzigo_partner/common_widgets/app_shimmer.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Page shell with a pinned back header (stays visible while [body] scrolls).
class AppPageScaffold extends StatefulWidget {
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
    this.isLoading = false,
    this.showLoadingShimmer = true,
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

  /// Explicit loading (API / fetch). Shown in addition to the first-open shimmer.
  final bool isLoading;

  /// First-open skeleton of this screen's real layout. Off for splash / success.
  final bool showLoadingShimmer;

  @override
  State<AppPageScaffold> createState() => _AppPageScaffoldState();
}

class _AppPageScaffoldState extends State<AppPageScaffold> {
  static const _initialLoadDuration = Duration(milliseconds: 500);

  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    if (!widget.showLoadingShimmer) {
      _initialLoading = false;
      return;
    }
    _finishInitialLoad();
  }

  Future<void> _finishInitialLoad() async {
    await Future<void>.delayed(_initialLoadDuration);
    if (!mounted) return;
    setState(() => _initialLoading = false);
  }

  bool get _showShimmer => widget.isLoading || _initialLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: AppBg(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: widget.headerPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBackHeader(
                      title: widget.title,
                      showBackText: widget.showBackText,
                      titleInline: widget.titleInline,
                      onBack: widget.onBack,
                    ),
                    if (widget.headerExtra != null) widget.headerExtra!,
                  ],
                ),
              ),
              Expanded(
                child: AppShimmer(
                  enabled: _showShimmer,
                  child: widget.body,
                ),
              ),
              if (widget.bottomBar != null) widget.bottomBar!,
            ],
          ),
        ),
      ),
    );
  }
}
