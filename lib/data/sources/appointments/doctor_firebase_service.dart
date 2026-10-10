import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning/core/utils/date_time_keys.dart';
import 'package:flutter_learning/domain/entities/appointments/doctor.dart';
import 'package:flutter_learning/domain/models/appointments/slots_request.dart';

abstract class DoctorFirebaseService {
  Future<Either> getDoctorsByCenter(String centerCode);
  Future<Either> getBookedSlots(SlotsRequest request);
}

class DoctorFirebaseServiceImpl implements DoctorFirebaseService {
  @override
  Future<Either<dynamic, dynamic>> getBookedSlots(SlotsRequest request) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final booked = <String>{};

      final slotSnap = await firestore
          .collection('Slots')
          .where('doctorId', isEqualTo: request.doctorId)
          .where('dateKey', isEqualTo: request.dateKey)
          .get();
      booked.addAll(
        slotSnap.docs
            .map((d) => (d.data()['time'] ?? '').toString())
            .where((t) => t.isNotEmpty),
      );

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final appSnap = await firestore
            .collection('Users')
            .doc(uid)
            .collection('appointments')
            .where('doctorId', isEqualTo: request.doctorId)
            .get();
        for (final d in appSnap.docs) {
          final raw = d.data();
          if (raw['status'] == 'cancelled') continue;

          final rawDate = raw['date'];
          final date = rawDate is Timestamp
              ? rawDate.toDate()
              : rawDate is DateTime
              ? rawDate
              : DateTime.tryParse(rawDate?.toString() ?? '');
          if (date != null && date.dateKey == request.dateKey) {
            booked.add(date.timeKey);
          }
        }
      }

      return Right(booked);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left('Sin permiso. Revisa las reglas de Firestore');
      }
      return Left('No se pudo consultar la disponibilidad');
    } catch (e) {
      debugPrint('Slots read error $e');
      return Left('Error inesperado al consultar la disponibilidad.');
    }
  }

  @override
  Future<Either<dynamic, dynamic>> getDoctorsByCenter(String centerCode) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Doctors')
          .where('centerCode', isEqualTo: centerCode)
          .get();
      final list =
          snap.docs
              .map(
                (d) =>
                    Doctor.fromMap(d.id, Map<String, dynamic>.from(d.data())),
              )
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

      return Right(list);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left('Sin permiso. Revisa las reglas de Firestore');
      }
      return Left('No se pudieron cargar los médicos');
    } catch (e) {
      debugPrint('Error getting doctors by center code $e');
      return Left('Error inesperado al cargar los doctores.');
    }
  }
}
