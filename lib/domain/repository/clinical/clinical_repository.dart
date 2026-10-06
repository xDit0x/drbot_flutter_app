import 'package:dartz/dartz.dart';

abstract class ClinicalRepository {
  Future<Either> getClinicalInfo();
}
