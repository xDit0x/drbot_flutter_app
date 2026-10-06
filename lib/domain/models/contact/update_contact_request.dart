import 'package:flutter_learning/domain/entities/contact/country_phone.dart';

class UpdateContactRequest {
  final String? email;
  final String? phoneNumber;
  final CountryPhone? countryPhone;
  const UpdateContactRequest({
    required this.email,
    required this.phoneNumber,
    required this.countryPhone,
  });
}
