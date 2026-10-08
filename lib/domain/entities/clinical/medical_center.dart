class MedicalCenter
{
  final String code;
  final String name;
  final String region;
  final String province;
  final String municipality;
  final String type;
  final String dependence;

  const MedicalCenter({
    required this.code,
    required this.name,
    required this.region,
    required this.province,
    required this.municipality,
    required this.type,
    required this.dependence,
  });

  Map<String, dynamic> toMap()
  {
    return {
      'code': code,
      'name': name,
      'region': region,
      'province': province,
      'municipality': municipality,
      'type': type,
      'dependence': dependence,
    };
  }

  factory MedicalCenter.fromMap(Map<String, dynamic> map)
  {
    return MedicalCenter(
      code: (map['code'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      region: (map['region'] ?? '').toString(),
      province: (map['province'] ?? '').toString(),
      municipality: (map['municipality'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      dependence: (map['dependence'] ?? '').toString(),
    );
  }
}