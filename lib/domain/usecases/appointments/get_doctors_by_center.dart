import 'package:dartz/dartz.dart';
import 'package:flutter_learning/core/usecase/usecase.dart';
import 'package:flutter_learning/data/repository/appointments/doctor_repository.dart';
import 'package:flutter_learning/service_locator.dart';

class GetDoctorsByCenterUseCase implements UseCase<Either, String> {
  @override
  Future<Either<dynamic, dynamic>> call({String? params}) async {
    return sl<DoctorRepositoryImpl>().getDoctorsByCenter(params!);
  }
}
