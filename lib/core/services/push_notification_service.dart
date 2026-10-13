import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_learning/data/sources/notifications/notification_firebase_service.dart';

import 'package:flutter_learning/domain/models/notifications/register_push_token_request.dart';
import 'package:flutter_learning/domain/models/notifications/save_alert_request.dart';
import 'package:flutter_learning/domain/usecases/notifications/register_push_token.dart';
import 'package:flutter_learning/service_locator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpened);
    final initial = await _messaging.getInitialMessage();
    if (initial != null) await _handleOpened(initial);

    await _initLocalNotifications();
    _messaging.onTokenRefresh.listen(_save);
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) return;
      await _save(await _messaging.getToken());
    });
  }

  Future<void> _initLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false,
      ),
    );
    await _local.initialize(settings: settings);

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'drbot_alerts',
            'Alertas',
            description: 'Avisos y recordatorios de DRBOT',
            importance: Importance.high,
          ),
        );

    FirebaseMessaging.onMessage.listen((message) async {
      final title =
          message.notification?.title ?? message.data['title'] as String?;
      final body =
          message.notification?.body ?? message.data['body'] as String?;
      if (title == null && body == null) return;

      await _local.show(
        id:
            (message.messageId?.hashCode ??
                DateTime.now().millisecondsSinceEpoch) &
            0x7fffffff,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'drbot_alerts',
            'Alertas',
            channelDescription: 'Avisos y recordatorios de DrBot',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data['route'] as String?,
      );

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await sl<NotificationFirebaseService>().saveAlert(
          SaveAlertRequest(
            uid: uid,
            title: title ?? '',
            body: body ?? '',
            type: message.data['type'] as String? ?? 'general',
            route: message.data['route'] as String?,
            messageId: message.messageId,
          ),
        );
      }
    });
  }

  Future<void> _save(String? token) async {
    if (token == null || token.isEmpty) return;
    final result = await sl<RegisterPushTokenUseCase>()(
      params: RegisterPushTokenRequest(
        token: token,
        platform: defaultTargetPlatform.name,
      ),
    );

    result.fold((l) => debugPrint('token: $l'), (r) => debugPrint('token: $r'));
  }

  Future<void> _handleOpened(RemoteMessage message) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await sl<NotificationFirebaseService>().saveAlert(
        SaveAlertRequest(
          uid: uid,
          title:
              message.notification?.title ??
              (message.data['title'] as String? ?? ''),
          body:
              message.notification?.body ??
              (message.data['body'] as String? ?? ''),
          type: message.data['type'] as String? ?? 'general',
          route: message.data['route'] as String?,
          messageId: message.messageId,
        ),
      );
    }
  }
}
