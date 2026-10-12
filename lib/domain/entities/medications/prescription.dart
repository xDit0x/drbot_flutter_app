class Prescription 
{
  const Prescription(
    {
      required this.id,
      required this.medicationId,
      required this.patientUid,
      required this.appointmentId,
      required this.doctorId,
      required this.cimaNregistro,
      required this.medicationName,
      required this.activeIngredients,
      required this.dose,
      required this.frequency,
      required this.route,
      required this.startDate,
      required this.endDate,
      required this.instructions,
      required this.status
    }
  );

  final String id;
  final String medicationId;
  final String patientUid;
  final String appointmentId;
  final String doctorId;
  final String cimaNregistro;
  final String medicationName;
  final String activeIngredients;
  final String dose;
  final String frequency;
  final String route;
  final String startDate;
  final String endDate;
  final String instructions;
  final String status;

  factory Prescription.fromMap(String id, Map<String, dynamic> map)
  {
    return Prescription
    (
      id: id, 
      medicationId: (map['medicationId'] ?? '').toString(),
      patientUid: (map['patientUid'] ?? '').toString(),
      appointmentId: (map['appointmentId'] ?? '').toString(),
      doctorId: (map['doctorId'] ?? '').toString(),
      cimaNregistro: (map['cimaNregistro'] ?? '').toString(),
      medicationName: (map['medicationName'] ?? '').toString(),
      activeIngredients: (map['activeIngredients'] ?? '').toString(),
      dose: (map['dose'] ?? '').toString(),
      frequency: (map['frequency'] ?? '').toString(),
      route: (map['route'] ?? '').toString(),
      startDate: (map['startDate'] ?? '').toString(),
      endDate: (map['endDate'] ?? '').toString(),
      instructions: (map['instructions'] ?? '').toString(),
      status: (map['status'] ?? 'active').toString(),
    );  
  }
}