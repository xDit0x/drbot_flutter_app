import 'package:flutter_learning/domain/entities/clinical/medical_center.dart';

enum AppointmentStatus {
  requested('Solicitada'),
  scheduled('Programada'),
  completed('Completada'),
  cancelled('Cancelada');

  const AppointmentStatus(this.label);
  final String label;

  static AppointmentStatus fromName(String? name) {
    for (final status in AppointmentStatus.values) {
      if (status.name == name) return status;
    }
    return AppointmentStatus.scheduled;
  }
}

class Appointment {
  final String id;
  final DateTime? date;
  final String doctorName;
  final String? doctorId;
  final String specialty;
  final AppointmentStatus status;
  final MedicalCenter medicalCenter;
  final String? centerCode;
  final bool referralConfirmed;
  final String? principalDisease;
  final String? medicalReport;

  const Appointment({
    required this.id,
    required this.doctorName,
    required this.status,
    required this.specialty,
    required this.medicalCenter,
    this.date,
    this.doctorId,
    this.centerCode,
    this.referralConfirmed = false,
    this.principalDisease,
    this.medicalReport,
  });

  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['date'];
    DateTime? date;
    if (rawDate is DateTime) {
      date = rawDate;
    } else if (rawDate is String) {
      date = DateTime.tryParse(rawDate);
    }

    final rawCenter = map['medicalCenter'];

    return Appointment(
      id: id,
      doctorName: (map['doctorName'] ?? '').toString(),
      doctorId: map['doctorId']?.toString(),
      status: AppointmentStatus.fromName(map['status'] as String?),
      date: date,
      specialty: (map['specialty'] ?? '').toString(),
      medicalCenter: rawCenter is Map
          ? MedicalCenter.fromMap(Map<String, dynamic>.from(rawCenter))
          : const MedicalCenter(
              code: '',
              name: '',
              region: '',
              province: '',
              municipality: '',
              type: '',
              dependence: '',
            ),
      centerCode: map['centerCode']?.toString(),
      referralConfirmed: map['referralConfirmed'] == true,
      principalDisease: map['principalDisease']?.toString(),
      medicalReport: map['medicalReport']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'date': date,
    'doctorName': doctorName,
    'doctorId': doctorId,
    'specialty': specialty,
    'status': status.name,
    'medicalCenter': medicalCenter.toMap(),
    'centerCode': centerCode,
    'referralConfirmed': referralConfirmed,
    'principalDisease': principalDisease,
    'medicalReport': medicalReport,
  };
}
