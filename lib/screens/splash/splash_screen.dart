import 'package:carzigo_partner/common_widgets/app_image_view.dart';
import 'package:carzigo_partner/common_widgets/app_logo.dart';
import 'package:carzigo_partner/screens/auth/login/login_screen.dart';
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
    Future.delayed(const Duration(seconds: 2), _navigateToLogin);
  }

  void _navigateToLogin() {
    if (!mounted) return;

    if (AppNavigation.isReady) {
      AppNavigation.off(const LoginScreen());
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

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
          const Center(child: AppLogo(size: 200, showPartner: true)),
        ],
      ),
    );
  }
}
