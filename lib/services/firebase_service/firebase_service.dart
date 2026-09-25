import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carzigo_partner/firebase_options.dart';
import 'package:carzigo_partner/models/notification_data_model.dart';
import 'package:carzigo_partner/screens/kyc/kyc_overview/kyc_overview_screen.dart';
import 'package:carzigo_partner/screens/notifications/notifications_screen.dart';
import 'package:carzigo_partner/screens/profile/documents/documents_screen.dart';
import 'package:carzigo_partner/screens/refer_earn/refer_earn_screen.dart';
import 'package:carzigo_partner/screens/schedule/service_details/service_details_screen.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
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
  Map<String, dynamic> _pendingData = const {};

  Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      await _initCrashlytics();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _initPush();
    } catch (e, st) {
      debugPrint('FirebaseService.init failed: $e\n$st');
    }
  }

  Future<void> _initCrashlytics() async {
    try {
      final enabled = !kDebugMode;
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
      if (!enabled) return;

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    } catch (e, st) {
      debugPrint('FirebaseService crashlytics init failed: $e\n$st');
    }
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
      onDidReceiveNotificationResponse: (response) {
        _queueOpen(_decodePayload(response.payload));
      },
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
      unawaited(syncFcmTokenToServer(fcmToken!));
    }

    messaging.onTokenRefresh.listen((token) {
      fcmToken = token;
      unawaited(PrefsService().saveFcmToken(token));
      unawaited(syncFcmTokenToServer(token));
    });
  }

  /// Upload FCM token when the partner is logged in.
  Future<void> syncFcmTokenToServer([String? token]) async {
    final value = (token ?? fcmToken ?? await PrefsService().getFcmToken())
        ?.trim();
    if (value == null || value.isEmpty) return;
    if (!await PrefsService().isLoggedIn) return;
    try {
      await Api.registerDeviceToken(value);
    } catch (e, st) {
      debugPrint('FCM token sync failed: $e\n$st');
    }
  }

  void _listenToMessages() {
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _queueOpen(Map<String, dynamic>.from(message.data));
    });
  }

  Future<void> _checkInitialMessage() async {
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _queueOpen(Map<String, dynamic>.from(initial.data));
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    if (Platform.isIOS) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      payload: jsonEncode(message.data),
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

  void _queueOpen(Map<String, dynamic>? data) {
    _pendingData = data ?? const {};
    _pendingNotificationOpen = true;
    unawaited(openPendingNotification());
  }

  Future<void> openPendingNotification() async {
    if (!_pendingNotificationOpen) return;
    if (!AppNavigation.isReady) return;
    if (!await PrefsService().isLoggedIn) return;

    _pendingNotificationOpen = false;
    final data = _pendingData;
    _pendingData = const {};
    await openFromPayload(data);
  }

  static Future<void> openFromNotification(NotificationDataModel item) {
    return openFromPayload({
      'type': item.type ?? '',
      'service_id': item.serviceId ?? '',
      'screen': item.screen ?? '',
    });
  }

  static Future<void> openFromPayload(Map<String, dynamic> data) async {
    if (!AppNavigation.isReady) return;

    final screen = (data['screen'] ?? '').toString().toLowerCase().trim();
    final type = (data['type'] ?? data['notification_type'] ?? '')
        .toString()
        .toLowerCase()
        .trim();
    final serviceId = (data['service_id'] ??
            data['schedule_id'] ??
            data['job_id'] ??
            '')
        .toString()
        .trim();

    final opensJob = screen == 'job_detail' ||
        type == 'job_assigned' ||
        type == 'day_before_reminder' ||
        type == 'wash_day_reminder' ||
        type == 'booking_rescheduled' ||
        type == 'schedule_cancelled';

    if (opensJob && serviceId.isNotEmpty) {
      await AppNavigation.to(ServiceDetailsScreen(jobId: serviceId));
      return;
    }
    if (screen == 'refer_earn' || type.startsWith('referral')) {
      await AppNavigation.to(const ReferEarnScreen(showBottomNav: false));
      return;
    }
    if (screen == 'documents' || type.contains('doc_change')) {
      await AppNavigation.to(const DocumentsScreen());
      return;
    }
    if (screen == 'kyc_overview' || type.contains('kyc')) {
      await AppNavigation.to(const KycOverviewScreen());
      return;
    }
    await AppNavigation.to(const NotificationsScreen());
  }

  static Map<String, dynamic>? _decodePayload(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }
}
