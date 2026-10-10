import 'package:flutter_learning/domain/entities/appointments/weekly_schedule.dart';

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final List<String> insurers;
  final String centerCode;
  final String centerName;
  final String region;
  final int slotMinutes;
  final WeeklySchedule schedule;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.centerCode,
    required this.slotMinutes,
    required this.schedule,
    this.insurers = const [],
    this.centerName = '',
    this.region = '',
  });

  factory Doctor.fromMap(String id, Map<String, dynamic> map) {
    final rawInsurers = map['insurers'];
    final rawWeekly = map['weekly'];

    return Doctor(
      id: id,
      name: (map['name'] ?? '').toString(),
      specialty: (map['specialty'] ?? '').toString(),
      centerCode: (map['centerCode'] ?? '').toString(),
      centerName: (map['centerName'] ?? '').toString(),
      region: (map['region'] ?? '').toString(),
      slotMinutes: (map['slotMinutes'] as num?)?.toInt() ?? 20,
      schedule: rawWeekly is Map
          ? WeeklySchedule.fromMap(Map<String, dynamic>.from(rawWeekly))
          : const WeeklySchedule(),
      insurers: rawInsurers is List
          ? rawInsurers.map((value) => value.toString()).toList()
          : const [],
    );
  }
}
