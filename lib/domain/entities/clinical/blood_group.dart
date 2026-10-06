enum BloodGroup {
  aPos('A+'),
  aNeg('A-'),
  bPos('B+'),
  bNeg('B-'),
  abPos('AB+'),
  abNeg('AB-'),
  oPos('O+'),
  oNeg('O-');

  final String label;
  const BloodGroup(this.label);

  static BloodGroup? fromName(String? name) {
    if (name == null) {
      return null;
    }
    for (final group in BloodGroup.values) {
      if (group.name == name) {
        return group;
      }
    }
    return null;
  }
}
