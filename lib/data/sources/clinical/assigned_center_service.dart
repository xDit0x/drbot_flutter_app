import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_learning/domain/entities/clinical/medical_center.dart';

class AssignedMedicalCenters
{
  final MedicalCenter? healthCenter;
  final MedicalCenter? hospital;

  const AssignedMedicalCenters({
    this.healthCenter,
    this.hospital,
  });
}

class AssignedCenterService
  {
    final FirebaseAuth _auth;
    final FirebaseFirestore _firestore;

    AssignedCenterService({FirebaseAuth? auth, FirebaseFirestore? firestore}) 
    : _auth = auth ?? FirebaseAuth.instance, _firestore = firestore ?? FirebaseFirestore.instance;
    
    Future<AssignedMedicalCenters> load() async {
      final uid = _auth.currentUser?.uid;

      if(uid == null) {
        return const AssignedMedicalCenters();
      }

      final document = await _firestore.collection('Users').doc(uid).get();
      final data = document.data() ?? {};

      return AssignedMedicalCenters(
        healthCenter: _readCenter(data['referenceHealthCenter']),
        hospital: _readCenter(data['referenceHospital']),
      );
    }

    Future<void> saveHealthCenter(MedicalCenter center) { return _save('referenceHealthCenter', center); }
    Future<void> saveHospital(MedicalCenter center) { return _save('referenceHospital', center); }

    Future<void> _save(String field, MedicalCenter center) async 
    {
      final uid = _auth.currentUser?.uid;

      if(uid == null) { throw StateError('No hay una sesión iniciada'); }

      await _firestore.collection('Users').doc(uid).set({field: center.toMap()}, SetOptions(merge: true));
    }

    MedicalCenter? _readCenter(Object? value)
      {
        if (value is! Map) return null;
        return MedicalCenter.fromMap(Map<String, dynamic>.from(value));
      }
  }