import 'package:flutter_learning/domain/entities/contact/country_phone.dart';

String? validatePhoneNumber(String? value, CountryPhone country) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  if (digits.length < country.minLenght || digits.length > country.maxLenght) {
    if (country.minLenght == country.maxLenght) {
      return "Debe tener ${country.minLenght} dígitos.";
    }
    return "${country.name} ${country.minLenght}-${country.maxLenght}.";
  }
  return null;
}
