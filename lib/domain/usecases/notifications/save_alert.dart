import 'package:dartz/dartz.dart';
import 'package:flutter_learning/core/usecase/usecase.dart';
import 'package:flutter_learning/domain/models/notifications/save_alert_request.dart';
import 'package:flutter_learning/domain/repository/notifications/notification_repository.dart';
import 'package:flutter_learning/service_locator.dart';

class SaveAlertUseCase implements UseCase<Either, SaveAlertRequest> {
  @override
  Future<Either<dynamic, dynamic>> call({SaveAlertRequest? params}) {
    return sl<NotificationRepository>().saveAlert(params!);
  }
}
