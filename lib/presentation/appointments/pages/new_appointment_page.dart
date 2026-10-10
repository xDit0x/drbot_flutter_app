import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning/data/sources/clinical/medical_center_csv.dart';
import 'package:flutter_learning/domain/entities/clinical/medical_center.dart';
import 'package:flutter_learning/presentation/appointments/models/booking_context.dart';
import 'package:flutter_learning/presentation/appointments/pages/specialty_doctor_page.dart';
import 'package:flutter_learning/presentation/profile/widgets/medical_center_picker.dart';

enum _Coverage { public, private }

class _NewAppointmentData {
  final List<MedicalCenter> hospitals;
  final bool hasPublic;
  final bool hasPrivate;
  final String privateCompany;
  final MedicalCenter? referenceHospital;

  const _NewAppointmentData({
    required this.hospitals,
    required this.hasPublic,
    required this.hasPrivate,
    required this.privateCompany,
    this.referenceHospital,
  });
}

class NewAppointmentPage extends StatefulWidget {
  const NewAppointmentPage({super.key});

  @override
  State<NewAppointmentPage> createState() => _NewAppointmentPageState();
}

class _NewAppointmentPageState extends State<NewAppointmentPage> {
  late final Future<_NewAppointmentData?> _future = _load();

  _Coverage _coverage = _Coverage.public;
  MedicalCenter? _selectedCenter;

  Future<_NewAppointmentData?> _load() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();
      final data = doc.data();
      if (data == null) return null;

      final rawHospital = data['referenceHospital'];
      final hospitals = await MedicalCenterCsv().loadHospitals();

      return _NewAppointmentData(
        hospitals: hospitals,
        hasPublic: data['publicCoverage'] == true,
        hasPrivate: data['privateCoverage'] == true,
        privateCompany: (data['privateCompany'] as String?) ?? '',
        referenceHospital: rawHospital is Map
            ? MedicalCenter.fromMap(Map<String, dynamic>.from(rawHospital))
            : null,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickHospital(List<MedicalCenter> candidates) async {
    final selected = await showDialog<MedicalCenter>(
      context: context,
      builder: (_) => MedicalCenterPicker(centers: candidates, hospitals: true),
    );
    if (selected != null) {
      setState(() => _selectedCenter = selected);
    }
  }

  void _continue(_NewAppointmentData data, MedicalCenter center) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpecialtyDoctorPage(
          booking: BookingContext(
            center: center,
            isPublic: _coverage == _Coverage.public,
            privateCompany: data.privateCompany,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<_NewAppointmentData?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data;
        if (data == null) {
          return const Center(
            child: Text('No se pudieron cargar tus datos de cobertura'),
          );
        }

        if (!data.hasPublic && !data.hasPrivate) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Completa tu perfil (cobertura y centros de referencia) '
                'antes de pedir una cita.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
            ),
          );
        }

        final showSelector = data.hasPublic && data.hasPrivate;
        final privateHospitals = data.hospitals
            .where((h) => h.insurers.contains(data.privateCompany))
            .toList();

        final effectiveCenter =
            _selectedCenter ??
            (_coverage == _Coverage.public ? data.referenceHospital : null);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showSelector) ...[
                SegmentedButton<_Coverage>(
                  segments: const [
                    ButtonSegment(
                      value: _Coverage.public,
                      label: Text('Seguridad Social'),
                      icon: Icon(Icons.account_balance_outlined),
                    ),
                    ButtonSegment(
                      value: _Coverage.private,
                      label: Text('Seguro privado'),
                      icon: Icon(Icons.verified_user_outlined),
                    ),
                  ],
                  selected: {_coverage},
                  onSelectionChanged: (selection) => setState(() {
                    _coverage = selection.first;
                    _selectedCenter = null;
                  }),
                ),
                const SizedBox(height: 16),
              ],

              Text(
                _coverage == _Coverage.public
                    ? 'Hospital de referencia'
                    : 'Elegir hospital de tu cuadro médico',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              if (_coverage == _Coverage.private &&
                  data.privateCompany.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Solo se muestran hospitales concertados con ${data.privateCompany}.',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),

              Card(
                color: scheme.surfaceContainer,
                child: ListTile(
                  leading: const Icon(Icons.local_hospital_outlined),
                  title: Text(
                    effectiveCenter?.name ?? 'Elegir hospital',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: effectiveCenter == null
                      ? null
                      : Text(
                          '${effectiveCenter.region}\n'
                          '${effectiveCenter.insurers.join(', ')}',
                        ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickHospital(
                    _coverage == _Coverage.public
                        ? data.hospitals
                        : privateHospitals,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: effectiveCenter == null
                    ? null
                    : () => _continue(data, effectiveCenter),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
