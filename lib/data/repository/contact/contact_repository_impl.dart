import 'package:dartz/dartz.dart';
import 'package:flutter_learning/domain/models/contact/update_contact_request.dart';
import 'package:flutter_learning/data/sources/contact/contact_firebase_service.dart';
import 'package:flutter_learning/domain/repository/contact/contact_repository.dart';
import 'package:flutter_learning/service_locator.dart';

class ContactRepositoryImpl implements ContactRepository {
  @override
  Future<Either<dynamic, dynamic>> getContactInfo() async {
    return sl<ContactFirebaseService>().getContactInfo();
  }

  @override
  Future<Either<dynamic, dynamic>> updateContactInfo(
    UpdateContactRequest req,
  ) async {
    return sl<ContactFirebaseService>().updateContactInfo(req);
  }
}
