import 'package:dartz/dartz.dart';
import 'package:flutter_learning/core/usecase/usecase.dart';
import 'package:flutter_learning/domain/models/notifications/register_push_token_request.dart';
import 'package:flutter_learning/domain/repository/notifications/notification_repository.dart';
import 'package:flutter_learning/service_locator.dart';

class RegisterPushTokenUseCase
    implements UseCase<Either, RegisterPushTokenRequest> {
  @override
  Future<Either<dynamic, dynamic>> call({RegisterPushTokenRequest? params}) {
    return sl<NotificationRepository>().registerPushToken(params!);
  }
}
