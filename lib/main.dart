import 'package:carzigo_partner/screens/splash/splash_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/theme/app_theme.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppStrings.appName.tr(),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          navigatorKey: navigatorKey,
          localizationsDelegates: [
            ...context.localizationDelegates,
            CountryLocalizations.delegate,
          ],
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: const SplashScreen(),
        );
      },
    );
  }
}
