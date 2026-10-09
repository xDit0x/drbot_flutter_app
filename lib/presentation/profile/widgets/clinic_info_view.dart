import 'package:flutter/material.dart';
import 'package:flutter_learning/common/widgets/snackbar/snack_bar_root.dart';

import 'package:flutter_learning/data/sources/clinical/assigned_center_service.dart';
import 'package:flutter_learning/data/sources/clinical/medical_center_csv.dart';

import 'package:flutter_learning/domain/entities/clinical/medical_center.dart';

import 'package:flutter_learning/presentation/profile/widgets/medical_center_picker.dart';
import 'package:url_launcher/url_launcher.dart';


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

      setState(() 
      {
        _healthCenter = assigned.healthCenter;
        _hospital = assigned.hospital;
        _loadingAssignedCenters = false;
      });
    } 
    catch (error) 
    {
      if (!mounted) return;

      setState(() 
      {
        _assignedCentersError = error.toString();
        _loadingAssignedCenters = false;
      });
    }
  }

  Future<void> _chooseCenter({required bool hospital}) async 
  {
    setState(() => _savingCenter = true);

    try 
    {
      final alreadySelected = hospital ? _hospital : _healthCenter;

      if(alreadySelected != null)
      {
        _showMessage('Para cambiar el centro de salud, solicita el cambio a los administradores', SnackbarRootType.bad);
        return;
      }
      if(hospital && _healthCenter == null)
      {
        _showMessage('Primero seleccione un centro de salud de referencia', SnackbarRootType.bad);
        return;
      }

      final List<MedicalCenter> loadedCenters = hospital ? await _csvService.loadHospitals() : await _csvService.loadHealthCenters();
      final List<MedicalCenter> centers = [];
      
      for(final center in loadedCenters)
      {
        final mismaComunidad = _healthCenter != null && center.region.trim().toLowerCase() == _healthCenter!.region.trim().toLowerCase();

        if(!hospital || mismaComunidad)
        {
          centers.add(center);
        }
      }

      if (!mounted) return;

      final selectedCenter = await showDialog<MedicalCenter>
      (
        context: context,
        builder: (context) => MedicalCenterPicker(centers: centers, hospitals: hospital),
      );

      if (!mounted || selectedCenter == null) return;

      if (hospital) 
      {
        await _assignedService.saveHospital(selectedCenter);
      } 
      else 
      {
        await _assignedService.saveHealthCenter(selectedCenter);
      }

      if (!mounted) return;

      setState(() 
      {
        if (hospital) 
        {
          _hospital = selectedCenter;
        } 
        else 
        {
          _healthCenter = selectedCenter;
        }
      });

      _showMessage( hospital ? 'Hospital de referencia guardado.' : 'Centro de salud de referencia guardado.', SnackbarRootType.ok);
    } 
    catch (error) 
    {
      _showMessage('No se pudo cargar o guardar el centro: $error', SnackbarRootType.bad);
    } 
    finally 
    {
      if (mounted) { setState(() => _savingCenter = false); }
    }
  }

  Future<void> _requestCenterChange({required bool hospital}) async
  {
    const emailAdmin = 'correo_admin@drbot.com';
    final center = hospital ? _hospital : _healthCenter;
    final centerType = hospital ? 'hospital' : 'centro de salud';

    final uri = Uri
    (
      scheme: 'mailto',
      path: emailAdmin,
      query: 'subject=${Uri.encodeComponent('Solicitud de cambio de centro')}'
      '&body=${Uri.encodeComponent('Solicito cambiar mi $centerType de referencia. ')}'
      '\nCentro actual: ${center?.name ?? 'Sin asignar'}'
      '\nComunidad autónoma: ${center?.region ?? ''}'
    );

    if(!await launchUrl(uri) && mounted)
    {
      _showMessage('No se pudo abrir la aplicación de correo', SnackbarRootType.bad);
    }
  }

  void _showMessage(String message, SnackbarRootType selection) { SnackbarRoot.show(context, message, selection: selection); }

  
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

  Widget _buildReferenceTile
  (
    {
      required String title,
      required IconData icon,
      required MedicalCenter? center,
    }) 
    {
      return ListTile
      (
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text
        (
          center == null ? 'Sin asignar' : '${center.name} · ${center.municipality}, ${center.province}',
        ),
      );
    }

  Widget _buildReferenceButton({required bool hospital}) 
  {
    final selectedCenter = hospital ? _hospital : _healthCenter;

    if(selectedCenter != null)
    {
      return TextButton.icon
      (
        onPressed: () => _requestCenterChange(hospital: hospital), 
        icon: Icon(Icons.email_outlined), 
        label: const Text('Solicitar cambio al administrador')
      );
    }

    return IconButton
    (
      tooltip: hospital ? 'Elegir hospital de referncia' : 'Elegir centro de salud de referencia', 
      onPressed: _savingCenter ? null : () => _chooseCenter(hospital: hospital),
      icon: _savingCenter ? const SizedBox
      (
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2,),
      ) : const Icon(Icons.search)
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
