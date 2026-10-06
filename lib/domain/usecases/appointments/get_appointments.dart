import 'package:dartz/dartz.dart';
import 'package:flutter_learning/core/usecase/usecase.dart';
import 'package:flutter_learning/domain/repository/appointments/appointment_repository.dart';
import 'package:flutter_learning/service_locator.dart';

class GetAppointmentsUseCase implements UseCase<Either, NoParams> {
  @override
  Future<Either<dynamic, dynamic>> call({NoParams? params}) {
    return sl<AppointmentRepository>().getAppointments();
  }
}
