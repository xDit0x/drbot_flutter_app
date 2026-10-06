import 'package:dartz/dartz.dart';
import 'package:flutter_learning/core/usecase/usecase.dart';
import 'package:flutter_learning/domain/models/contact/update_contact_request.dart';
import 'package:flutter_learning/domain/repository/contact/contact_repository.dart';
import 'package:flutter_learning/service_locator.dart';

class UpdateContactInfoUseCase
    implements UseCase<Either, UpdateContactRequest> {
  @override
  Future<Either<dynamic, dynamic>> call({UpdateContactRequest? params}) {
    return sl<ContactRepository>().updateContactInfo(params!);
  }
}
