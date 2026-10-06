import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_learning/presentation/auth/pages/singin.dart';

import 'package:flutter_learning/presentation/root/models/root_destination.dart';

class FeatureScaffold extends StatelessWidget {
  final RootDestination destination;
  const FeatureScaffold({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        forceMaterialTransparency: true,
        toolbarHeight: 56,
        centerTitle: true,
        title: Text(
          destination.label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inverseSurface,
            fontWeight: FontWeight.bold,
          ),
        ), // ← centrado
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => SignInPage()),
                (route) => false,
              );
            },
            child: Icon(
              Icons.logout_rounded,
              size: 24,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.only(
          right: 12,
        ), // ← tu padding derecho
        scrolledUnderElevation: 1,
      ),
      body: destination.page,
    );
  }
}
