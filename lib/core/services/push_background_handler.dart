import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_learning/data/sources/notifications/notification_firebase_service.dart';
import 'package:flutter_learning/domain/models/notifications/save_alert_request.dart';
import 'package:flutter_learning/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationFirebaseServiceImpl().saveAlert(
    SaveAlertRequest(
      uid: message.data['uid'] as String? ?? '',
      title:
          message.notification?.title ??
          (message.data['title'] as String? ?? ''),
      body:
          message.notification?.body ?? (message.data['body'] as String? ?? ''),
      type: message.data['type'] as String? ?? 'general',
      route: message.data['route'] as String?,
      messageId: message.messageId,
    ),
  );
}
