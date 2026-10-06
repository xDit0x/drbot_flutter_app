import 'package:dartz/dartz.dart';
import 'package:flutter_learning/domain/models/auth/create_user_request.dart';
import 'package:flutter_learning/domain/models/auth/signin_user_request.dart';
import 'package:flutter_learning/data/sources/auth/auth_firebase_service.dart';
import 'package:flutter_learning/domain/repository/auth/auth.dart';
import 'package:flutter_learning/service_locator.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either> signIn(SigninUserRequest signinUserRequest) async {
    return await sl<AuthFirebaseService>().signIn(signinUserRequest);
  }

  @override
  Future<Either> signUp(CreateUserReq createUserRequest) async {
    return await sl<AuthFirebaseService>().signUp(createUserRequest);
  }
}
