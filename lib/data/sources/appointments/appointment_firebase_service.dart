import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_learning/domain/entities/appointments/appointment.dart';

abstract class AppointmentFirebaseService {
  Future<Either> getAppointments();
  Future<Either> removeAppointment(String id);
}

class AppointmentFirebaseServiceImpl implements AppointmentFirebaseService {
  @override
  Future<Either<dynamic, dynamic>> getAppointments() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return Left('Sesión no válida. Vuelve a iniciar sesión.');
      }
      final snap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('appointments')
          .get();
      final list =
          snap.docs.map((d) {
            final data = Map<String, dynamic>.from(d.data());
            final ts = data['date'];
            if (ts is Timestamp) data['date'] = ts.toDate();
            return Appointment.fromMap(d.id, data);
          }).toList()..sort((a, b) {
            if (a.date == null) return 1;
            if (b.date == null) return -1;
            return a.date!.compareTo(b.date!);
          });
      return Right(list);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left('Sin permiso. Revisa las reglas de Firestore');
      }
      return Left('No se pudieron cargar las citas');
    } catch (e) {
      debugPrint('Appointments read error $e');
      return Left('Error inesperado al cargar las citas.');
    }
  }

  @override
  Future<Either<dynamic, dynamic>> removeAppointment(String id) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return Left('Sesión no válida. Vuelve a iniciar sesión.');
      }
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('appointments')
          .doc(id)
          .delete();
      return Right(true);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left('Sin permiso. Revisa las reglas de Firestore');
      }
      return Left('No se pudo eliminar la cita.');
    } catch (e) {
      debugPrint('Appointments remove error $e');
      return Left('Error inesperado al eliminar la cita.');
    }
  }
}
