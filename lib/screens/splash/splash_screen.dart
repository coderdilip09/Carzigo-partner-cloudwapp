import 'dart:async';

import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_logo.dart';
import 'package:carzigo_partner/services/auth_route_service/auth_route_service.dart';
import 'package:carzigo_partner/services/firebase_service/firebase_service.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_assets.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleNavigation());
  }

  void _scheduleNavigation() {
    unawaited(
      _askNotificationPermission().timeout(
        const Duration(seconds: 8),
        onTimeout: () {},
      ),
    );
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      await _navigateNext();
    });
  }

  Future<void> _askNotificationPermission() async {
    await FirebaseService().init();
    await FirebaseService().requestNotificationPermission();
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    // Re-register push token on every cold start while logged in.
    // A stuck APNs handshake must not keep the splash on screen.
    try {
      await FirebaseService().syncFcmTokenToServer().timeout(
        const Duration(seconds: 8),
      );
    } catch (_) {}

    final next = await _nextScreen();
    if (!mounted) return;

    if (AppNavigation.isReady) {
      AppNavigation.offAll(next);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => next),
        (_) => false,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseService().openPendingNotification();
    });
  }

  Future<Widget> _nextScreen() => AuthRouteService.resolveStart();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: AppImageView(
              AppAssets.bgSplash,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          const Center(child: AppLogo(size: 280, showPartner: true)),
        ],
      ),
    );
  }
}
