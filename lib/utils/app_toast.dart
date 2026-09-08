import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppToast {
  AppToast._();

  static void show(
    String message, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast length = Toast.LENGTH_SHORT,
    Color backgroundColor = AppColors.black,
    Color textColor = AppColors.white,
  }) {
    if (message.trim().isEmpty) return;
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: length,
      gravity: gravity,
      timeInSecForIosWeb: 2,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 14,
    );
  }

  static void success(String message) {
    show(message, backgroundColor: AppColors.verified);
  }

  static void error(String message) {
    show(message, backgroundColor: AppColors.destructive);
  }
}
