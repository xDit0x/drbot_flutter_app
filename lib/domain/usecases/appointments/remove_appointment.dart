import 'package:dartz/dartz.dart';
import 'package:flutter_learning/core/usecase/usecase.dart';
import 'package:flutter_learning/domain/repository/appointments/appointment_repository.dart';
import 'package:flutter_learning/service_locator.dart';

class RemoveAppointmentUseCase implements UseCase<Either, String> {
  @override
  Future<Either<dynamic, dynamic>> call({String? params}) {
    return sl<AppointmentRepository>().removeAppointment(params!);
  }
}
