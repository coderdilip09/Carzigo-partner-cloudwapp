import 'dart:async';
import 'dart:io';

import 'package:carzigo_partner/firebase_options.dart';
import 'package:carzigo_partner/screens/notifications/notifications_screen.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/services/prefs_service/prefs_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

class FirebaseService {
  FirebaseService._();

  static final FirebaseService _instance = FirebaseService._();

  factory FirebaseService() => _instance;

  static const String androidChannelId = 'carzigo_partner_high_importance';
  static const String _androidChannelName = 'High Importance Notifications';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? fcmToken;
  bool _pendingNotificationOpen = false;

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _initCrashlytics();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _initPush();
  }

  Future<void> _initCrashlytics() async {
    final enabled = !kDebugMode;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
    if (!enabled) return;

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  void recordError(Object error, StackTrace stack, {bool fatal = false}) {
    if (kDebugMode) {
      debugPrint('FirebaseService.recordError (debug ignored): $error\n$stack');
      return;
    }
    unawaited(
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal),
    );
  }

  Future<void> _initPush() async {
    try {
      await _initLocalNotifications();
      await _requestPushPermission();
      await _loadFcmToken();
      _listenToMessages();
      await _checkInitialMessage();
    } catch (e, st) {
      debugPrint('FirebaseService push init failed: $e\n$st');
    }
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (_) => _markPendingOpen(),
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        androidChannelId,
        _androidChannelName,
        importance: Importance.high,
      ),
    );
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _requestPushPermission() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _loadFcmToken() async {
    final messaging = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      for (var i = 0; i < 10; i++) {
        final apns = await messaging.getAPNSToken();
        if (apns != null) break;
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
    }

    fcmToken = await messaging.getToken();
    debugPrint('FCM token: $fcmToken');
    if (fcmToken != null && fcmToken!.isNotEmpty) {
      await PrefsService().saveFcmToken(fcmToken!);
    }

    messaging.onTokenRefresh.listen((token) {
      fcmToken = token;
      unawaited(PrefsService().saveFcmToken(token));
    });
  }

  void _listenToMessages() {
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((_) => _markPendingOpen());
  }

  Future<void> _checkInitialMessage() async {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _markPendingOpen();
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    if (Platform.isIOS) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannelId,
          _androidChannelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  void _markPendingOpen() {
    _pendingNotificationOpen = true;
    unawaited(openPendingNotification());
  }

  Future<void> openPendingNotification() async {
    if (!_pendingNotificationOpen) return;
    if (!AppNavigation.isReady) return;
    if (!await PrefsService().isLoggedIn) return;

    _pendingNotificationOpen = false;
    await AppNavigation.to(const NotificationsScreen());
  }
}
