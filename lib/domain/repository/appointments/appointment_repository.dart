import 'package:dartz/dartz.dart';
import 'package:flutter_learning/domain/models/appointments/book_appointment_request.dart';

abstract class AppointmentRepository {
  Future<Either> getAppointments();
  Future<Either> removeAppointment(String id);
  Future<Either> createAppointment(BookAppointmentRequest request);
}
