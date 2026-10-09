import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  late final Stream<User?> _authStateChanges =
      FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) 
        {
          return const Center(child: CircularProgressIndicator());
        } 
        else if (snapshot.hasError) 
        {
          return const Center(child: Text('Ha ocurrido un error'));
        }
        else if (snapshot.hasData) 
        {
          return const BiometricLockGate(child: RootPage());
        } 
        else 
        {
          return const SignInPage();
        }
      },
    );
  }
}