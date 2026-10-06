import 'package:flutter_learning/domain/entities/contact/country_phone.dart';

class ContactInfo {
  final String? email;
  final String? fullName;
  final int? phoneNumber;
  final CountryPhone? countryPhone;

  const ContactInfo({
    this.email,
    this.fullName,
    this.phoneNumber,
    this.countryPhone,
  });

  factory ContactInfo.fromMap(Map<String, dynamic> map) {
    final phone = map['phoneNumber'];
    return ContactInfo(
      fullName: map['fullName']?.toString(),
      email: map['email']?.toString(),
      phoneNumber: phone is int ? phone : int.tryParse('$phone'),
      countryPhone: CountryPhone.fromName(map['countryPhone'] as String?),
    );
  }
}
