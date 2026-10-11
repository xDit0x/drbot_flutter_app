import 'package:dartz/dartz.dart';
import 'package:flutter_learning/domain/entities/appointments/check_in_request.dart';
import 'package:flutter_learning/domain/models/appointments/book_appointment_request.dart';

abstract class AppointmentRepository {
  Future<Either> getAppointments();
  Future<Either> cancelAppointment(String id);
  Future<Either> createAppointment(BookAppointmentRequest request);
  Future<Either> checkInAppointment(CheckInRequest request);
}
