import 'package:flutter/material.dart';
import 'package:flutter_learning/common/widgets/snackbar/snack_bar_root.dart';

import 'package:flutter_learning/data/sources/clinical/assigned_center_service.dart';
import 'package:flutter_learning/data/sources/clinical/medical_center_csv.dart';

import 'package:flutter_learning/domain/entities/clinical/medical_center.dart';

import 'package:flutter_learning/presentation/profile/widgets/medical_center_picker.dart';

class ClinicInfoView extends StatefulWidget {
  const ClinicInfoView({super.key});

  @override
  State<ClinicInfoView> createState() => _ClinicInfoViewState();
}

class _ClinicInfoViewState extends State<ClinicInfoView> {
  final MedicalCenterCsv _csvService = MedicalCenterCsv();
  final AssignedCenterService _assignedService = AssignedCenterService();

  MedicalCenter? _healthCenter;
  MedicalCenter? _hospital;

  bool _loadingAssignedCenters = true;
  bool _savingCenter = false;
  String? _assignedCentersError;

  @override
  void initState() {
    super.initState();
    _loadAssignedCenters();
  }

  Future<void> _loadAssignedCenters() async {
    try {
      final assigned = await _assignedService.load();

      if (!mounted) return;

      setState(() {
        _healthCenter = assigned.healthCenter;
        _hospital = assigned.hospital;
        _loadingAssignedCenters = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _assignedCentersError = error.toString();
        _loadingAssignedCenters = false;
      });
    }
  }

  Future<void> _chooseCenter({required bool hospital}) async {
    setState(() => _savingCenter = true);

    try {
      final List<MedicalCenter> centers = hospital
          ? await _csvService.loadHospitals()
          : await _csvService.loadHealthCenters();

      if (!mounted) return;

      final selectedCenter = await showDialog<MedicalCenter>(
        context: context,
        builder: (context) =>
            MedicalCenterPicker(centers: centers, hospitals: hospital),
      );

      if (!mounted || selectedCenter == null) return;

      if (hospital) {
        await _assignedService.saveHospital(selectedCenter);
      } else {
        await _assignedService.saveHealthCenter(selectedCenter);
      }

      if (!mounted) return;

      setState(() {
        if (hospital) {
          _hospital = selectedCenter;
        } else {
          _healthCenter = selectedCenter;
        }
      });

      _showMessage(
        hospital
            ? 'Hospital de referencia guardado.'
            : 'Centro de salud de referencia guardado.',
        SnackbarRootType.ok,
      );
    } catch (error) {
      _showMessage(
        'No se pudo cargar o guardar el centro: $error',
        SnackbarRootType.bad,
      );
    } finally {
      if (mounted) {
        setState(() => _savingCenter = false);
      }
    }
  }

  void _showMessage(String message, SnackbarRootType selection) {
    SnackbarRoot.show(context, message, selection: selection);
  }

  // Widget _buildClinicalInfo(AsyncSnapshot<Either> snapshot) {
  //   if (snapshot.connectionState == ConnectionState.waiting) {
  //     return const Padding(
  //       padding: EdgeInsets.all(20),
  //       child: Center(
  //         child: CircularProgressIndicator(
  //           color: AppColors.primary,
  //           strokeWidth: 1.4,
  //         ),
  //       ),
  //     );
  //   }

  //   if (snapshot.hasError) {
  //     return Text('Error inesperado: ${snapshot.error}');
  //   }

  //   final result = snapshot.data;
  //   if (result == null) return const SizedBox.shrink();
  // }

  Widget _buildReferenceTile({
    required String title,
    required IconData icon,
    required MedicalCenter? center,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        center == null
            ? 'Sin asignar'
            : '${center.name} · ${center.municipality}, ${center.province}',
      ),
    );
  }

  Widget _buildReferenceButton({required bool hospital}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _savingCenter
            ? null
            : () => _chooseCenter(hospital: hospital),
        icon: _savingCenter
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.search),
        label: Text(
          hospital
              ? 'Elegir hospital de referencia'
              : 'Elegir centro de salud de referencia',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 72),
      children: [
        const Text(
          'Centros de referencia',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (_loadingAssignedCenters)
                  const LinearProgressIndicator()
                else ...[
                  if (_assignedCentersError != null)
                    Text(
                      'No se cargaron las referencias: $_assignedCentersError',
                    ),
                  _buildReferenceTile(
                    title: 'Centro de salud de referencia',
                    icon: Icons.medical_services_outlined,
                    center: _healthCenter,
                  ),
                  const SizedBox(height: 8),
                  _buildReferenceButton(hospital: false),
                  const Divider(),
                  _buildReferenceTile(
                    title: 'Hospital de referencia',
                    icon: Icons.local_hospital_outlined,
                    center: _hospital,
                  ),
                ],
                const SizedBox(height: 8),
                _buildReferenceButton(hospital: true),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Busca por nombre, municipio o provincia o código REGCESS. ',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
