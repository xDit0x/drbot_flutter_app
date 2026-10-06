import 'package:dartz/dartz.dart';
import 'package:flutter_learning/domain/models/contact/update_contact_request.dart';

abstract class ContactRepository {
  Future<Either> getContactInfo();
  Future<Either> updateContactInfo(UpdateContactRequest req);
}
