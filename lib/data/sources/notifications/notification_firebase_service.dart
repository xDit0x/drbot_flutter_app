import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_learning/domain/models/notifications/register_push_token_request.dart';
import 'package:flutter_learning/domain/models/notifications/save_alert_request.dart';

abstract class NotificationFirebaseService {
  Future<Either> registerPushToken(RegisterPushTokenRequest request);
  Future<Either> saveAlert(SaveAlertRequest request);
}

class NotificationFirebaseServiceImpl implements NotificationFirebaseService {
  @override
  Future<Either<dynamic, dynamic>> registerPushToken(
    RegisterPushTokenRequest request,
  ) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) return Left('Sesión no válida. Vuelva a iniciar sesión');

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('tokens')
          .doc(request.token)
          .set({
            'token': request.token,
            'platform': request.platform,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      return Right('Token registrado');
    } on FirebaseException catch (e) {
      debugPrint('Error registering push token: $e');
      return Left('No se pudo cargar el token de notificaciones.');
    } catch (e) {
      return Left('No se pudo cargar el token de notificaciones.');
    }
  }

  @override
  Future<Either<dynamic, dynamic>> saveAlert(SaveAlertRequest request) async {
    try {
      if (request.uid.isEmpty) return Left('uid ausente');

      final alerts = FirebaseFirestore.instance
          .collection('Users')
          .doc(request.uid)
          .collection('alerts');

      final ref = request.messageId != null && request.messageId!.isNotEmpty
          ? alerts.doc(request.messageId)
          : alerts.doc();

      await ref.set({
        'title': request.title,
        'body': request.body,
        'type': request.type,
        'route': request.route,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return Right('Alerta guardada');
    } on FirebaseException catch (e) {
      debugPrint('Error saving alert: $e');
      return Left('No se pudo guardar la alerta.');
    } catch (e) {
      return Left('No se pudo guardar la alerta.');
    }
  }
}
