import 'package:flutter_learning/domain/entities/clinical/medical_center.dart';

class CreateUserReq {
  final String fullName;
  final String email;
  final String password;

  final bool publicCoverty;
  final bool privateCoverty;
  final String? privateCompany;

  final MedicalCenter? healthCenter;
  final MedicalCenter? hospital;

  CreateUserReq({
    required this.fullName,
    required this.email,
    required this.password,
    required this.publicCoverty,
    required this.privateCoverty,
    required this.privateCompany,
    this.healthCenter,
    this.hospital
  });
}
