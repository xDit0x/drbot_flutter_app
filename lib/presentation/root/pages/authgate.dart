import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning/presentation/auth/pages/center_selection_page.dart';
import 'package:flutter_learning/presentation/auth/pages/insurance_selection_page.dart';
import 'package:flutter_learning/presentation/auth/pages/signin.dart';
import 'package:flutter_learning/presentation/root/pages/root.dart';
import 'package:flutter_learning/presentation/settings/widgets/biometric_lock_gate.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // El stream se crea UNA vez: si se creara en el build, cada rebuild
  // (p. ej. cambio de tema) generaría un objeto nuevo, el StreamBuilder
  // se re-suscribiría, pasaría por waiting (spinner) y remontaría RootPage
  // perdiendo todo su estado (incluida la pestaña del perfil).
  late final Stream<User?> _authStateChanges = FirebaseAuth.instance
      .authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Ha ocurrido un error'));
        } else if (snapshot.hasData) {
          final uid = snapshot.data!.uid;
          return _ProfileGate(key: ValueKey(uid), uid: uid);
        } else {
          return const SignInPage();
        }
      },
    );
  }
}

class _ProfileGate extends StatefulWidget {
  const _ProfileGate({super.key, required this.uid});

  final String uid;
  @override
  State<StatefulWidget> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  bool _editingCoverage = false;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _docStream =
      FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.uid)
          .snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _docStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Ha ocurrido un error."));
        }
        final d = snapshot.data?.data();

        final hasCoverage =
            d?['publicCoverage'] == true || d?['privateCoverage'] == true;

        final hasCenters =
            d?['referenceHealthCenter'] != null &&
            d?['referenceHospital'] != null;

        if (d == null || !hasCoverage || _editingCoverage) {
          return InsuranceSelectionPage(
            onSaved: () => setState(() => _editingCoverage = false),
          );
        }
        if (!hasCenters) {
          return CenterSelectionPage(
            coverage: InsuranceSelection(
              publicCoverty: d['publicCoverage'] == true,
              privateCoverty: d['privateCoverage'] == true,
              privateCompany: d['privateCompany'] as String?,
              publicCardNumber: d['publicCardNumber'] as String?,
              privateCardNumber: d['privateCardNumber'] as String?,
            ),
            onBack: () => setState(() => _editingCoverage = true),
          );
        }
        return const BiometricLockGate(child: RootPage());
      },
    );
  }
}
