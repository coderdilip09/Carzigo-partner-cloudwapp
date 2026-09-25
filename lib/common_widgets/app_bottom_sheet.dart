import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Extra space so the last action sits above the Android 3-button / gesture bar.
const double kAppSheetBottomGap = 20;

/// Raw system nav / home-indicator inset. Reads from the window, not the
/// (often zeroed) MediaQuery inside a modal sheet or ScreenUtil.
double appSystemBottomInset(BuildContext context) {
  return MediaQueryData.fromView(View.of(context)).viewPadding.bottom;
}

/// Keyboard + system nav inset for bottom sheets.
double appSheetBottomInset(
  BuildContext context, {
  double extra = kAppSheetBottomGap,
}) {
  final keyboard = MediaQuery.viewInsetsOf(context).bottom;
  return keyboard + appSystemBottomInset(context) + extra;
}

/// Wraps sheet content so buttons are never hidden under the system back bar
/// or the keyboard.
class AppBottomSheetBody extends StatelessWidget {
  const AppBottomSheetBody({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 20),
    this.scrollable = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final bottom = appSheetBottomInset(context, extra: padding.bottom);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    final content = Padding(
      padding: padding.copyWith(bottom: bottom),
      child: child,
    );

    if (!scrollable) return content;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        child: content,
      ),
    );
  }
}

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useRootNavigator = true,
  bool enableDrag = true,
  bool isDismissible = true,
  Color backgroundColor = AppColors.white,
  Color? barrierColor,
  double topRadius = 20,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: isScrollControlled,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
    useSafeArea: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
    ),
    builder: builder,
  );
}
