import 'package:dartz/dartz.dart';
import 'package:flutter_learning/data/sources/appointments/doctor_firebase_service.dart';
import 'package:flutter_learning/domain/models/appointments/slots_request.dart';
import 'package:flutter_learning/domain/repository/appointments/doctor_repository.dart';
import 'package:flutter_learning/service_locator.dart';

class DoctorRepositoryImpl extends DoctorRepository {
  @override
  Future<Either<dynamic, dynamic>> getBookedSlots(SlotsRequest request) {
    return sl<DoctorFirebaseService>().getBookedSlots(request);
  }

  @override
  Future<Either<dynamic, dynamic>> getDoctorsByCenter(String centerCode) {
    return sl<DoctorFirebaseService>().getDoctorsByCenter(centerCode);
  }
}
