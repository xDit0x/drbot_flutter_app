import 'package:dartz/dartz.dart';
import 'package:flutter_learning/domain/models/notifications/register_push_token_request.dart';
import 'package:flutter_learning/domain/models/notifications/save_alert_request.dart';

abstract class NotificationRepository {
  Future<Either> registerPushToken(RegisterPushTokenRequest request);
  Future<Either> saveAlert(SaveAlertRequest request);
}
