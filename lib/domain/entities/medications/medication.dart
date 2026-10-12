import 'prescription.dart';

class Medication 
{
  const Medication
  ({
      required this.id,
      required this.cimaNregistro,
      required this.name,
      required this.activeIngredients,
      required this.patientCodes,
      required this.activePatientCodes,
  });

  final String id;
  final String cimaNregistro;
  final String name;
  final String activeIngredients;
  final List<String> patientCodes;
  final List<String> activePatientCodes;

  static List<Medication> groupPrescriptions (Iterable<Prescription> prescriptions)
  {
    final grouped = <String, List<Prescription>> {};

    for(final prescription in prescriptions)
    {
      grouped.putIfAbsent(prescription.medicationId, () => []).add(prescription);
    }

    return grouped.entries.map((entry) 
    {
      final items = entry.value;
      final first = items.first;

      final patientCodes = items.map((item) => item.patientUid).where((uid) => uid.isNotEmpty).toSet().toList()..sort();
      final activePatientCodes = items.where((item) => item.status == 'active').map((item) => item.patientUid).where((uid) => uid.isNotEmpty).toSet().toList()..sort();
    
      return Medication
      (
        id: entry.key,
        cimaNregistro: first.cimaNregistro,
        name: first.medicationName,
        activeIngredients: first.activeIngredients,
        patientCodes: patientCodes,
        activePatientCodes: activePatientCodes
      );
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

}