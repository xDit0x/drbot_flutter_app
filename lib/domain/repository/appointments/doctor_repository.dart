import 'package:dartz/dartz.dart';
import 'package:flutter_learning/domain/models/appointments/slots_request.dart';

abstract class DoctorRepository {
  Future<Either> getDoctorsByCenter(String centerCode);
  Future<Either> getBookedSlots(SlotsRequest request);
}
