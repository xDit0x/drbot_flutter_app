import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning/domain/entities/appointments/doctor.dart';
import 'package:flutter_learning/domain/models/appointments/slots_request.dart';

abstract class DoctorFirebaseService {
  Future<Either> getDoctorsByCenter(String centerCode);
  Future<Either> getBookedSlots(SlotsRequest request);
}

class DoctorFirebaseServiceImpl extends DoctorFirebaseService {
  @override
  Future<Either<dynamic, dynamic>> getBookedSlots(SlotsRequest request) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Slots')
          .where('doctorId', isEqualTo: request.doctorId)
          .where('dateKey', isEqualTo: request.dateKey)
          .get();

      final booked = snap.docs
          .map((d) => (d.data()['time'] ?? '').toString())
          .where((t) => t.isNotEmpty)
          .toSet();

      return Right(booked);
    } on FirebaseException catch (e) {
      if (e.code == 'permission.-denied') {
        return Left('Sin permiso. Revisa las reglas de Firestore');
      }
      return left('No se pudieron cargar los médicos');
    } catch (e) {
      debugPrint('Error getting doctors by center code $e');
      return Left('Error inesperado al cargar los doctores.');
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
      if (e.code == 'permission.-denied') {
        return Left('Sin permiso. Revisa las reglas de Firestore');
      }
      return left('No se pudieron cargar los médicos');
    } catch (e) {
      debugPrint('Error getting doctors by center code $e');
      return Left('Error inesperado al cargar los doctores.');
    }
  }
}
