import 'package:dartz/dartz.dart';
import 'package:flutter_learning/core/usecase/usecase.dart';
import 'package:flutter_learning/domain/repository/auth/auth.dart';
import 'package:flutter_learning/service_locator.dart';

class DeleteAccountUseCase extends UseCase<Either, String> {
  @override
  Future<Either<dynamic, dynamic>> call({String? params}) {
    return sl<AuthRepository>().deleteAccount(params!);
  }
}
