import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_learning/domain/entities/clinical/clinical_info.dart';

abstract class ClinicalFirebaseService {
  Future<Either> getClinicalInfo();
}

class ClinicalFirebaseServiceImpl extends ClinicalFirebaseService {
  @override
  Future<Either<dynamic, dynamic>> getClinicalInfo() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return Left('Sesión no válida. Vuelve a iniciar sesión.');
      }
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();
      if (!doc.exists) {
        return Right(const ClinicalInfo());
      }
      return Right(ClinicalInfo.fromMap(doc.data() ?? {}));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left('Sin permiso. Revisa las reglas de Firestore.');
      }
      return Left('No se pudo cargar la información clínica.');
    } catch (e) {
      debugPrint('Clinical read error: $e');
      return Left('Error inesperado al cargar la información clínica.');
    }
  }
}
