enum AppointmentStatus {
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

  const Appointment({
    required this.id,
    required this.doctorName,
    required this.status,
    required this.specialty,
    this.date,
    this.doctorId,
  });

  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['date'];
    DateTime? date;
    if (rawDate is DateTime) {
      date = rawDate;
    } else if (rawDate is String) {
      date = DateTime.tryParse(rawDate);
    }
    return Appointment(
      id: id,
      doctorName: (map['doctorName'] ?? '').toString(),
      status: AppointmentStatus.fromName((map['status'] as String?)),
      date: date,
      specialty: (map['specialty'] ?? '').toString(),
    );
  }
}
