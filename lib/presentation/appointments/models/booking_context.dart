import 'package:flutter_learning/domain/entities/clinical/medical_center.dart';

class BookingContext {
  final MedicalCenter center;
  final bool isPublic;
  final String privateCompany;

  const BookingContext({
    required this.center,
    required this.isPublic,
    this.privateCompany = '',
  });
}
