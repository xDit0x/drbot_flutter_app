import 'package:dartz/dartz.dart';
import 'package:flutter_learning/data/sources/appointments/appointment_firebase_service.dart';
import 'package:flutter_learning/domain/repository/appointments/appointment_repository.dart';
import 'package:flutter_learning/service_locator.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  @override
  Future<Either<dynamic, dynamic>> getAppointments() {
    return sl<AppointmentFirebaseService>().getAppointments();
  }

  @override
  Future<Either<dynamic, dynamic>> removeAppointment(String id) {
    return sl<AppointmentFirebaseService>().removeAppointment(id);
  }
}
