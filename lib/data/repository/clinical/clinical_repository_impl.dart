import 'package:dartz/dartz.dart';
import 'package:flutter_learning/domain/repository/clinical/clinical_repository.dart';
import 'package:flutter_learning/data/sources/clinical/clinical_firebase_service.dart';
import 'package:flutter_learning/service_locator.dart';

class ClinicalRepositoryImpl extends ClinicalRepository {
  @override
  Future<Either<dynamic, dynamic>> getClinicalInfo() async {
    return await sl<ClinicalFirebaseService>().getClinicalInfo();
  }
}
