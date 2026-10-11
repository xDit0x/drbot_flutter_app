import 'package:dartz/dartz.dart';
import 'package:flutter_learning/core/usecase/usecase.dart';
import 'package:flutter_learning/domain/entities/appointments/check_in_request.dart';
import 'package:flutter_learning/domain/repository/appointments/appointment_repository.dart';
import 'package:flutter_learning/service_locator.dart';

class CheckInAppointmentUseCase implements UseCase<Either, CheckInRequest> {
  @override
  Future<Either<dynamic, dynamic>> call({CheckInRequest? params}) {
    return sl<AppointmentRepository>().checkInAppointment(params!);
  }
}
