import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppNavigation {
  AppNavigation._();

  static BuildContext? get context => navigatorKey.currentContext;

  static bool get isReady => navigatorKey.currentState != null;

  static NavigatorState? get _nav => navigatorKey.currentState;

  static Future<T?> to<T>(Widget page) {
    return _nav?.push<T>(MaterialPageRoute(builder: (_) => page)) ?? Future.value();
  }

  static Future<T?> off<T>(Widget page) {
    return _nav?.pushReplacement<T, void>(
          MaterialPageRoute(builder: (_) => page),
        ) ??
        Future.value();
  }

  static Future<T?> offAll<T>(Widget page) {
    return _nav?.pushAndRemoveUntil<T>(
          MaterialPageRoute(builder: (_) => page),
          (_) => false,
        ) ??
        Future.value();
  }

  static void back<T>([T? result]) {
    _nav?.pop(result);
  }
}
