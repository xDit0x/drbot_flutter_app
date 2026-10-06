enum AllergySeverity {
  mild('Leve'),
  moderate('Moderada'),
  severe('Grave');

  const AllergySeverity(this.label);
  final String label;
}

enum AllergyType {
  medication('Medicamentosa'), // fármacos — la tienes
  food('Alimentaria'), // la tienes
  respiratory('Respiratoria'), // polen, ácaros, epitelios, moho — la tienes
  insect(
    'Picadura de insecto',
  ), // abejas, avispas — riesgo de anafilaxia, no puede faltar
  contact(
    'Contacto',
  ), // níquel, cosméticos, detergentes, dermatitis de contacto
  latex(
    'Látex',
  ), // guantes, sondas, catéteres — crítico en hospital, merece tipo propio
  other('Otra');

  const AllergyType(this.label);
  final String label;
}

class Allergy {
  final AllergyType type;
  final AllergySeverity severity;
  final String agent;
  final String reaction;
  final DateTime? registeredAt;

  const Allergy({
    required this.type,
    required this.severity,
    required this.agent,
    required this.reaction,
    this.registeredAt,
  });
}
