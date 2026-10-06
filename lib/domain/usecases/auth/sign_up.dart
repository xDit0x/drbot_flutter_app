import 'package:dartz/dartz.dart';
import 'package:flutter_learning/core/usecase/usecase.dart';
import 'package:flutter_learning/domain/models/auth/create_user_request.dart';
import 'package:flutter_learning/domain/repository/auth/auth.dart';
import 'package:flutter_learning/service_locator.dart';

class SignUpUseCase implements UseCase<Either, CreateUserReq> {
  @override
  Future<Either<dynamic, dynamic>> call({CreateUserReq? params}) {
    return sl<AuthRepository>().signUp(params!);
  }
}
