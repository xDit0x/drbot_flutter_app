import 'package:dartz/dartz.dart';
import 'package:flutter_learning/core/usecase/usecase.dart';
import 'package:flutter_learning/domain/models/appointments/book_appointment_request.dart';
import 'package:flutter_learning/domain/repository/appointments/appointment_repository.dart';
import 'package:flutter_learning/service_locator.dart';

class CreateAppointmentUseCase extends UseCase<Either, BookAppointmentRequest> {
  @override
  Future<Either<dynamic, dynamic>> call({BookAppointmentRequest? params}) {
    return sl<AppointmentRepository>().createAppointment(params!);
  }
}
