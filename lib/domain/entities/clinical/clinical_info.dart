import 'package:flutter_learning/domain/entities/clinical/allergy.dart';
import 'package:flutter_learning/domain/entities/clinical/blood_group.dart';

class ClinicalInfo {
  final BloodGroup? bloodGroup;
  final List<Allergy> allergies;
  const ClinicalInfo({this.bloodGroup, this.allergies = const []});

  factory ClinicalInfo.fromMap(Map<String, dynamic> map) {
    return ClinicalInfo(
      bloodGroup: BloodGroup.fromName(map['bloodGroup'] as String?),
      allergies: (map['allergies'] as List? ?? [])
          .map(
            ((e) => Allergy(
              type: _allergyTypeFrom(e['type']),
              severity: _allergySeverityFrom(e['severity']),
              agent: (e['agent'] ?? '').toString(),
              reaction: (e['reaction'] ?? '').toString(),
            )),
          )
          .toList(),
    );
  }

  static AllergySeverity _allergySeverityFrom(Object? value) {
    for (final severity in AllergySeverity.values) {
      if (severity.name == value) return severity;
    }
    return AllergySeverity.moderate;
  }

  static AllergyType _allergyTypeFrom(Object? value) {
    for (final type in AllergyType.values) {
      if (type.name == value) return type;
    }
    return AllergyType.other;
  }
}
