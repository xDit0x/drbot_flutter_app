import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning/presentation/auth/pages/signin.dart';
import 'package:flutter_learning/presentation/root/pages/root.dart';
import 'package:flutter_learning/presentation/settings/widgets/biometric_lock_gate.dart';

class AuthGate extends StatelessWidget
{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
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