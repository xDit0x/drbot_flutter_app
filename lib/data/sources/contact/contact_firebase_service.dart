import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_learning/domain/models/contact/update_contact_request.dart';

import 'package:flutter_learning/domain/entities/contact/contact_info.dart';

abstract class ContactFirebaseService {
  Future<Either> getContactInfo();
  Future<Either> updateContactInfo(UpdateContactRequest req);
}

class ContactFirebaseServiceImpl extends ContactFirebaseService {
  @override
  Future<Either<dynamic, dynamic>> getContactInfo() async {
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
        return Right(const ContactInfo());
      }
      debugPrint(
        'Contact read ← raw countryPhone=${doc.data()?['countryPhone']}',
      );
      return Right(ContactInfo.fromMap(doc.data() ?? {}));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left('Sin permiso. Revisa las reglas de Firestore.');
      }
      return Left('No se pudo cargar la información de contacto.');
    } catch (e) {
      debugPrint('Contact read error: $e');
      return Left('Error inesperado al cargar la información de contacto.');
    }
  }

  @override
  Future<Either<dynamic, dynamic>> updateContactInfo(
    UpdateContactRequest req,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Left('Sesión no válida. Vuelve a iniciar sesión.');
      }
      if (req.email?.trim() != (user.email ?? '')) {
        await user.verifyBeforeUpdateEmail(req.email!.trim());
      }
      debugPrint('Contact save > countryPhone=${req.countryPhone?.name}');
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
        'email': req.email?.trim(),
        'countryPhone': req.countryPhone?.name,
        'phoneNumber': int.tryParse(req.phoneNumber!.trim()),
      }, SetOptions(merge: true));
      return Right('Contacto actualizado');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return Left('Ese correo ya tiene una cuenta.');
      } else if (e.code == 'invalid-email') {
        return Left('Ese correo no es válido.');
      } else if (e.code == 'requires-recent-login') {
        return Left('Vuelve a iniciar sesión e inténtalo de nuevo.');
      }
      return Left('No se pudo actualizar el contacto.');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return Left('Sin permiso. Revisa las reglas de Firestore.');
      }
      return Left('No se pudo guardar el contacto.');
    } catch (e) {
      debugPrint('Contact save error: $e');
      return Left('Error inesperado al guardar el contacto.');
    }
  }
}
