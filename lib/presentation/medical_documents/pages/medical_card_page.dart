import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MedicalCardPage extends StatefulWidget {
  const MedicalCardPage({super.key});

  @override
  State<MedicalCardPage> createState() => _MedicalCardsPageState();
}

class _MedicalCardsPageState extends State<MedicalCardPage> {
  late final Future<Map<String, dynamic>?> _userData = _loadUserData();

  Future<Map<String, dynamic>?> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return null;
    }

    final document = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get();

    return document.data();
  }

  String _privateCompanyCard(String? company) {
    switch (company?.trim().toUpperCase()) {
      case 'DKV':
        return 'assets/images/cards/dkv.jpg';
      case 'SANITAS':
        return 'assets/images/cards/sanitas.jpg';
      case 'ASISA':
        return 'assets/images/cards/asisa.jpg';
      case 'ADESLAS':
        return 'assets/images/cards/adeslas.jpg';
      default:
        return 'assets/images/cards/publica.jpg';
    }
  }

  BoxDecoration _cardDecoration(ColorScheme scheme) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: scheme.shadow.withValues(alpha: 0.35),
          offset: const Offset(0, 6),
          blurRadius: 14,
        ),
      ],
      border: Border.all(
        color: scheme.inversePrimary.withValues(alpha: 0.5),
        width: 0.5,
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String asset,
    required String? number,
  }) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: 190,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              asset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: Colors.blue,
                child: Icon(Icons.credit_card, color: Colors.white, size: 48),
              ),
            ),
            ColoredBox(color: Colors.black.withValues(alpha: 0.3)),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: scheme.inversePrimary,
                      shadows: [
                        Shadow(
                          offset: Offset(0.8, 0.8),
                          color: Colors.black,
                          blurRadius: 2,
                        ),
                      ],
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    number?.isNotEmpty == true
                        ? number!
                        : 'Número no registrado',
                    style: TextStyle(
                      color: scheme.inversePrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          offset: Offset(0.4, 0.4),
                          color: Colors.black,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('No se pudieron cargar tus tarjetas'),
          );
        }

        final data = snapshot.data;

        if (data == null) {
          return const Center(
            child: Text('No se encontraron datos del usuario'),
          );
        }

        final hasPublic = data['publicCoverage'] == true;
        final hasPrivate = data['privateCoverage'] == true;
        final company = data['privateCompany'] as String?;
        final publicNumber = data['publicCardNumber'] as String?;
        final privateNumber = data['privateCardNumber'] as String?;
        final companyName = company?.trim();

        if (!hasPublic && !hasPrivate) {
          return const Center(
            child: Text('No tienes coberturas sanitarias registradas'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(14),
          children: [
            if (hasPublic)
              Container(
                decoration: _cardDecoration(scheme),
                child: _buildCard(
                  title: 'Tarjeta sanitaria pública',
                  asset: 'assets/images/cards/publica.jpg',
                  number: publicNumber,
                ),
              ),

            if (hasPublic && hasPrivate) const SizedBox(height: 16),

            if (hasPrivate)
              Container(
                decoration: _cardDecoration(scheme),
                child: _buildCard(
                  title: companyName == null || companyName.isEmpty
                      ? 'Seguro privado'
                      : companyName,
                  asset: _privateCompanyCard(companyName),
                  number: privateNumber,
                ),
              ),
          ],
        );
      },
    );
  }
}
