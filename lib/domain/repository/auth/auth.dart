import 'package:dartz/dartz.dart';
import 'package:flutter_learning/domain/models/auth/create_user_request.dart';
import 'package:flutter_learning/domain/models/auth/signin_user_request.dart';

abstract class AuthRepository {
  Future<Either> signUp(CreateUserReq createUserRequest);
  Future<Either> signIn(SigninUserRequest signinUserRequest);
  Future<Either> sendPasswordResetEmail(String email);
  Future<Either> deleteAccount(String password);
}
