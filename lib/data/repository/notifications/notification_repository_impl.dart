import 'package:dartz/dartz.dart';

import 'package:flutter_learning/data/sources/notifications/notification_firebase_service.dart';
import 'package:flutter_learning/domain/models/notifications/register_push_token_request.dart';
import 'package:flutter_learning/domain/models/notifications/save_alert_request.dart';
import 'package:flutter_learning/domain/repository/notifications/notification_repository.dart';
import 'package:flutter_learning/service_locator.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<Either<dynamic, dynamic>> registerPushToken(
    RegisterPushTokenRequest request,
  ) async {
    return sl<NotificationFirebaseService>().registerPushToken(request);
  }

  @override
  Future<Either<dynamic, dynamic>> saveAlert(SaveAlertRequest request) async {
    return sl<NotificationFirebaseService>().saveAlert(request);
  }
}
