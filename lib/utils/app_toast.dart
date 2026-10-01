import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:toastification/toastification.dart';

class AppToast {
  AppToast._();

  /// When true, [error] is ignored unless [force] is set.
  static bool suppressErrors = false;

  static String? _lastErrorMessage;
  static DateTime? _lastErrorAt;

  static BuildContext? get _context {
    final ctx = AppNavigation.context;
    if (ctx != null && ctx.mounted) return ctx;
    return null;
  }

  static void show(String message) {
    info(message);
  }

  static void success(String message) {
    _show(
      message: message,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      primaryColor: AppColors.verified,
    );
  }

  static void error(String message, {bool force = false}) {
    // [force] only bypasses [suppressErrors] (e.g. session expired).
    if (suppressErrors && !force) return;
    final now = DateTime.now();
    if (_lastErrorMessage == message &&
        _lastErrorAt != null &&
        now.difference(_lastErrorAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastErrorMessage = message;
    _lastErrorAt = now;
    _show(
      message: message,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      primaryColor: const Color(0xFFD32F2F),
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static void info(String message) {
    _show(
      message: message,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      primaryColor: AppColors.primary,
    );
  }

  static void _show({
    required String message,
    required ToastificationType type,
    required ToastificationStyle style,
    required Color primaryColor,
    TextStyle? titleStyle,
  }) {
    if (message.trim().isEmpty) return;

    void present() {
      try {
        toastification.show(
          context: _context,
          title: Text(message, style: titleStyle),
          type: type,
          style: style,
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 3),
          primaryColor: primaryColor,
        );
      } catch (e, st) {
        debugPrint('AppToast failed: $e\n$st');
      }
    }

    final scheduler = SchedulerBinding.instance;
    if (scheduler.schedulerPhase == SchedulerPhase.persistentCallbacks ||
        scheduler.schedulerPhase == SchedulerPhase.midFrameMicrotasks) {
      scheduler.addPostFrameCallback((_) => present());
    } else {
      present();
    }
  }
}
