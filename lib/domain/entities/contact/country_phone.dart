enum CountryPhone {
  spain('España', 'ES', '+34', 9, 9), // fijos y móviles: 9
  mexico('México', 'MX', '+52', 10, 10),
  colombia('Colombia', 'CO', '+57', 10, 10), // móviles 3xx: 10
  usa('Estados Unidos', 'US', '+1', 10, 10), // NANP: 10
  chile('Chile', 'CL', '+56', 9, 9), // móviles 9xx: 9
  peru('Perú', 'PE', '+51', 9, 9),
  portugal('Portugal', 'PT', '+351', 9, 9),
  argentina('Argentina', 'AR', '+54', 10, 11); // variable: área + 15 móvil

  final String name;
  final String iso;
  final String dialCode;
  final int minLenght;
  final int maxLenght;

  const CountryPhone(
    this.name,
    this.iso,
    this.dialCode,
    this.minLenght,
    this.maxLenght,
  );

  static const CountryPhone defaultCountry = spain;

  static CountryPhone? fromName(String? name) {
    if (name == null) {
      return null;
    }
    for (final country in CountryPhone.values) {
      if (country.name == name) return country;
    }
    return null;
  }

  String get flag {
    const regionalBase = 0x1F1E6;
    const asciiA = 0X41;

    return String.fromCharCodes(
      iso.codeUnits.map((c) => regionalBase + (c - asciiA)),
    );
  }
}
