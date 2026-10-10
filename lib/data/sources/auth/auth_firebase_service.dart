import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning/domain/models/auth/create_user_request.dart';
import 'package:flutter_learning/domain/models/auth/signin_user_request.dart';

abstract class AuthFirebaseService {
  Future<Either> signUp(CreateUserReq createUserRequest);
  Future<Either> signIn(SigninUserRequest signinUserRequest);
  Future<Either> sendPasswordResetEmail(String email);
  Future<Either> deleteAccount(String password);
}

class AuthFirebaseServieImpl extends AuthFirebaseService {
  @override
  Future<Either> signIn(SigninUserRequest signinUserRequest) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: signinUserRequest.email,
        password: signinUserRequest.password,
      );

      return Right('El inicio de sesión fue completqado');
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'invalid-email') {
        message = 'No existe una cuenta con ese correo';
      } else if (e.code == 'invalid-credential') {
        message = 'Contraseña incorrecta para esa cuenta';
      }
      return Left(message);
    }
  }

  @override
  Future<Either> signUp(CreateUserReq createUserRequest) async {
    try {
      var data = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: createUserRequest.email,
        password: createUserRequest.password,
      );
      final uid = data.user!.uid;
      await FirebaseFirestore.instance.collection('Users').doc(uid).set({
        'fullName': createUserRequest.fullName,
        'email': data.user?.email,
        'publicCoverage': createUserRequest.publicCoverty,
        'privateCoverage': createUserRequest.privateCoverty,
        'privateCompany': createUserRequest.privateCompany,
        'referenceHealthCenter': createUserRequest.healthCenter?.toMap(),
        'referenceHospital': createUserRequest.hospital?.toMap(),
      }, SetOptions(merge: true));
      return Right('El registro fue completado');
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'weak-password') {
        message = 'La contraseña introducida es muy débil';
      } else if (e.code == 'email-already-in-use') {
        message = 'Ya existe una cuenta con ese correo';
      }
      return Left(message);
    }
  }

  @override
  Future<Either<dynamic, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      return Right('Correo de recuperación enviado');
    } on FirebaseException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'El correo no es válido';
      } else if (e.code == 'user-not-found') {
        message = 'No existe una cuenta con ese correo';
      } else if (e.code == 'user-disabled') {
        message = 'Esa cuenta está deshabilitada';
      } else if (e.code == 'too-many-requests') {
        message = 'Demasiados intentos, inténtalo más tarde';
      } else if (e.code == 'network-request-failed') {
        message = 'Sin conexión, revisa tu red';
      } else {
        message = 'No se pudo enviar el correo';
      }
      return Left(message);
    } catch (e) {
      debugPrint('Error sending Password Reset Email $e');
      return Left('Error de conexión');
    }
  }

  @override
  Future<Either<dynamic, dynamic>> deleteAccount(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (user == null || email == null) {
      return Left('No hay una sesión iniciada');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      final userDoc = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid);
      final savedData = (await userDoc.get()).data();
      await userDoc.delete();

      try {
        await user.delete();
      } catch (e) {
        if (savedData != null && FirebaseAuth.instance.currentUser != null) {
          await userDoc.set(savedData, SetOptions(merge: true));
        }
        rethrow;
      }
      return Right('La cuenta se ha eliminado correctamente');
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'wrong-password' ||
        'invalid-credential' => 'La contraseña no es correcta',
        'requires-recent-login' =>
          'Vuelve a iniciar sesión e inténtalo de nuevo',
        'network-request-failed' => 'Sin conexión, revisa tu red',
        'too-many-requests' => 'Demasiados intentos, inténtalo más tarde',
        _ => 'No se ha podido eliminar la cuenta',
      };
      return Left(message);
    } catch (e) {
      debugPrint('Error deleting account $e');
      return Left('Error de conexión');
    }
  }
}
