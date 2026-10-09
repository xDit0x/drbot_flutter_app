import 'package:dartz/dartz.dart';

abstract class AppointmentRepository {
  Future<Either> getAppointments();
  Future<Either> removeAppointment(String id);
}
