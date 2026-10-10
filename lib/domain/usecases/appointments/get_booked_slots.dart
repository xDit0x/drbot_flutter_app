import 'package:dartz/dartz.dart';
import 'package:flutter_learning/core/usecase/usecase.dart';
import 'package:flutter_learning/domain/models/appointments/slots_request.dart';
import 'package:flutter_learning/domain/repository/appointments/doctor_repository.dart';
import 'package:flutter_learning/service_locator.dart';

class GetBookedSlotsUseCase implements UseCase<Either, SlotsRequest> {
  @override
  Future<Either<dynamic, dynamic>> call({SlotsRequest? params}) {
    return sl<DoctorRepository>().getBookedSlots(params!);
  }
}
