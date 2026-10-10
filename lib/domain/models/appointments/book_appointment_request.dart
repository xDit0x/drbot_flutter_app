import 'package:flutter_learning/core/utils/date_time_keys.dart';
import 'package:flutter_learning/domain/entities/appointments/appointment.dart';
import 'package:flutter_learning/domain/entities/clinical/medical_center.dart';

class BookAppointmentRequest {
  final String doctorId;
  final String doctorName;
  final String specialty;
  final MedicalCenter medicalCenter;
  final DateTime date;
  final AppointmentStatus status;
  final bool referralConfirmed;

  const BookAppointmentRequest({
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.medicalCenter,
    required this.date,
    required this.status,
    this.referralConfirmed = false,
  });
  Map<String, dynamic> toMap() => {
    'doctorId': doctorId,
    'doctorName': doctorName,
    'specialty': specialty,
    'medicalCenter': medicalCenter.toMap(),
    'centerCode': medicalCenter.code,
    'date': date,
    'status': status.name,
    'referralConfirmed': referralConfirmed,
  };

  String get dateKey => date.dateKey;
  String get time => date.timeKey;
  String get slotId => '${doctorId}_${dateKey}_$time';
}
