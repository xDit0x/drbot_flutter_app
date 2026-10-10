import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning/common/widgets/snackbar/snack_bar_root.dart';
import 'package:flutter_learning/domain/entities/clinical/medical_center.dart';
import 'package:url_launcher/url_launcher.dart';


class ClinicInfoView extends StatefulWidget 
{
  const ClinicInfoView({super.key});

  @override
  State<ClinicInfoView> createState() => _ClinicInfoViewState();
}

class _ClinicInfoViewState extends State<ClinicInfoView> 
{
  late final Future<Map<String, dynamic>?> _userData = _loadUserData();

  Future<Map<String, dynamic>?> _loadUserData() async
  {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if(uid == null) { return null; }

    final document = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    return document.data();

  }
  MedicalCenter? _readCenter(Object? value)
  {
    if(value is! Map) { return null; }
    return MedicalCenter.fromMap(Map<String, dynamic>.from(value));
  }


  Future<void> _requestCenterChange({required bool hospital, required MedicalCenter? center}) async
  {
    const emailAdmin = 'correo_admin@drbot.com';
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

  Widget _buildCenterSection
  (
    {
      required String title,
      required IconData icon,
      required MedicalCenter? center,
      required bool hospital
    }) 
    {
      return Column
      (
        children: 
        [
          ListTile
          (
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text
            (
              center == null ? 'Sin asignar' : '${center.name}\n${center.municipality}, ${center.province} - ${center.region}',
            ),
            isThreeLine: center != null,
          ),
          Align
          (
            alignment: Alignment.centerLeft,
            child: TextButton.icon
            (
              onPressed: () { _requestCenterChange(hospital: hospital, center: center);}, 
              icon: const Icon(Icons.email_outlined),
              label: const Text('Contactar con administración')
            ),
          )
        ]
      );
    }

  @override
  Widget build(BuildContext context) 
  {
    return FutureBuilder<Map<String, dynamic>?>
    (
      future: _userData,
      builder: (context, snapshot)
      {
        if(snapshot.connectionState == ConnectionState.waiting)
        {
          return const Center(child: CircularProgressIndicator());
        }

        if(snapshot.hasError)
        {
          return Center(child: Text('No se pudieron los datos de centros de referencia'));
        }
        
        final data = snapshot.data;

        if(data == null)
        {
          return Center(child: Text('No se encotraron los datos del usuario'));
        }

        final hasPublicCoverage = data['publicCoverage'] == true;
        final hasPrivateCoverage = data['privateCoverage'] == true;
        final privateCompany = data['privateCompany'] as String?;

        final healthCenter = _readCenter(data['referenceHealthCenter']);
        final hospital = _readCenter(data['referenceHospital']);

        final coverages = <String>
        [
          if(hasPublicCoverage) 'Seguridad Social',
          if(hasPrivateCoverage) 'Seguro privado${privateCompany == null ? '' : ' - $privateCompany'}'
        ];

        return ListView
        (
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 72),
          children: 
          [
            const Text('Cobertura sanitaria', style: TextStyle(fontWeight: FontWeight.bold)),
            Card
            (
              child: Padding
              (
                padding: const EdgeInsets.all(12),
                child: Text(coverages.isEmpty ? 'Sin cobertura registrada' : coverages.join('\n'))
              ),
            ),
            const SizedBox(height: 16,),
            const Text('Centros de Referencia', style: TextStyle(fontWeight: FontWeight.bold)),
            Card
            (
              child: Padding
              (
                padding: const EdgeInsets.all(12),
                child: Column 
                (
                  children: 
                  [ 
                    _buildCenterSection
                    (
                      title: 'Centro de salud de referencia',
                      icon: Icons.medical_services_outlined,
                      center: healthCenter,
                      hospital: false
                    ),
                    const Divider(),
                    _buildCenterSection(
                      title: 'Hospital de referencia', 
                      icon: Icons.local_hospital_outlined, 
                      center: hospital, 
                      hospital: true)
                  ]
                ),
                
              ),
            ),
          ],
        );
      }
    );   
  }
}
