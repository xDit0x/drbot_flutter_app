import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_learning/core/utils/date_time_keys.dart';
import 'package:flutter_learning/domain/entities/appointments/appointment.dart';
import 'package:flutter_learning/domain/entities/appointments/check_in_request.dart';
import 'package:flutter_learning/domain/models/appointments/book_appointment_request.dart';

abstract class AppointmentFirebaseService {
  Future<Either> getAppointments();
  Future<Either> cancelAppointment(String id);
  Future<Either> createAppointment(BookAppointmentRequest request);
  Future<Either> checkInAppointment(CheckInRequest request);
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
  Future<Either<dynamic, dynamic>> cancelAppointment(String id) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return Left('Sesión no válida. Vuelve a iniciar sesión.');
      }

      final firestore = FirebaseFirestore.instance;
      final appointmentRef = firestore
          .collection('Users')
          .doc(uid)
          .collection('appointments')
          .doc(id);

      await firestore.runTransaction((transaction) async {
        final snap = await transaction.get(appointmentRef);
        if (!snap.exists) return;

        final data = snap.data()!;
        final status = data['status']?.toString();
        if (status != 'requested' && status != 'scheduled') return;

        transaction.update(appointmentRef, {'status': 'cancelled'});

        final doctorId = data['doctorId']?.toString();
        final rawDate = data['date'];
        final date = rawDate is Timestamp
            ? rawDate.toDate()
            : rawDate is DateTime
            ? rawDate
            : DateTime.tryParse(rawDate?.toString() ?? '');
        if (doctorId != null && doctorId.isNotEmpty && date != null) {
          final slotId = '${doctorId}_${date.dateKey}_${date.timeKey}';
          transaction.delete(firestore.collection('Slots').doc(slotId));
        }
      });
      return Right(true);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left('Sin permiso. Revisa las reglas de Firestore');
      }
      return Left('No se pudo cancelar la cita.');
    } catch (e) {
      debugPrint('Appointments remove error $e');
      return Left('Error inesperado al cancelar la cita.');
    }
  }

  @override
  Future<Either<dynamic, dynamic>> createAppointment(
    BookAppointmentRequest request,
  ) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) return Left('Sesión no válida. Vuelva a iniciar sesión');

      final slotRef = FirebaseFirestore.instance
          .collection('Slots')
          .doc(request.slotId);

      final appointmentRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('appointments')
          .doc();

      Map<String, dynamic>? session;
      try {
        final sessionId =
            '${request.doctorId}_${request.medicalCenter.code}_${request.dateKey}';

        final sessionSnap = await FirebaseFirestore.instance
            .collection('Sessions')
            .doc(sessionId)
            .get();

        session = sessionSnap.data();
      } on FirebaseException catch (e) {
        debugPrint('Session read skipped: $e');
      }

      final data = request.toMap();

      if (session != null) {
        data['roomCode'] = session['roomCode'];
        data['roomLabel'] = session['roomLabel'];
      }

      final result = await FirebaseFirestore.instance.runTransaction<String>((
        transaction,
      ) async {
        final existing = await transaction.get(slotRef);
        if (existing.exists) {
          return 'taken';
        }
        transaction.set(slotRef, {
          'doctorId': request.doctorId,
          'dateKey': request.dateKey,
          'time': request.time,
          'date': request.date,
          'uid': uid,
          'status': 'scheduled',
          'checkInAt': null,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.set(appointmentRef, data);

        return 'ok';
      });
      if (result == 'taken') {
        return Left('Esa hora ya está reservada. Elige otra');
      }
      return Right(true);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left('Sin permiso. Revisa las reglas de Firestore');
      }
      return Left('No se pudo crear la cita');
    } catch (e) {
      debugPrint('createAppointment error $e');
      return Left('Error inesperado al crear la cita');
    }
  }

  @override
  Future<Either<dynamic, dynamic>> checkInAppointment(
    CheckInRequest request,
  ) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return Left('Sesión no válida. Vuelve a iniciar sesión.');
      }

      final firestore = FirebaseFirestore.instance;
      final appointmentRef = firestore
          .collection('Users')
          .doc(uid)
          .collection('appointments')
          .doc(request.appointmentId);

      String? signatureData;
      final bytes = request.signatureBytes;
      if (bytes != null && bytes.isNotEmpty) {
        signatureData = base64Encode(bytes);
      }

      final result = await firestore.runTransaction<String>((
        transaction,
      ) async {
        final snap = await transaction.get(appointmentRef);
        if (!snap.exists) return 'missing';

        final data = snap.data()!;
        final status = data['status']?.toString();
        if (status != 'requested' && status != 'scheduled') return 'invalid';

        final doctorId = data['doctorId']?.toString();
        final centerCode =
            data['centerCode']?.toString() ??
            (data['medicalCenter'] is Map
                ? (data['medicalCenter'] as Map)['code']?.toString()
                : null);
        final rawDate = data['date'];
        final date = rawDate is Timestamp
            ? rawDate.toDate()
            : rawDate is DateTime
            ? rawDate
            : DateTime.tryParse(rawDate?.toString() ?? '');

        if (doctorId == null ||
            doctorId.isEmpty ||
            centerCode == null ||
            centerCode.isEmpty ||
            date == null) {
          return 'invalid';
        }

        final queueId = '${doctorId}_${centerCode}_${date.dateKey}';
        final queueRef = firestore.collection('Queues').doc(queueId);

        final queueSnap = await transaction.get(queueRef);
        final last = (queueSnap.data()?['lastNumber'] as num?)?.toInt() ?? 0;
        final next = last + 1;

        transaction.set(queueRef, {
          'doctorId': doctorId,
          'centerCode': centerCode,
          'dateKey': date.dateKey,
          'lastNumber': next,
        }, SetOptions(merge: true));

        transaction.update(appointmentRef, {
          'status': 'checkedIn',
          'checkedInAt': FieldValue.serverTimestamp(),
          'queueNumber': next,
          'checkInSignature': ?signatureData,
        });

        return 'ok';
      });

      switch (result) {
        case 'missing':
          return Left('La cita no existe.');
        case 'invalid':
          return Left('Esta cita no se puede registrar en la sala de espera.');
        default:
          return Right(true);
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left('Sin permiso. Revisa las reglas de Firestore');
      }
      return Left('No se pudo hacer el check-in.');
    } catch (e) {
      debugPrint('checkInAppointment error $e');
      return Left('Error inesperado al hacer el check-in.');
    }
  }
}
