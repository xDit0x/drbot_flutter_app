import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_learning/data/sources/clinical/medical_center_csv.dart';
import 'package:flutter_learning/domain/entities/clinical/medical_center.dart';
import 'package:flutter_learning/presentation/auth/pages/insurance_selection_page.dart';
import 'package:flutter_learning/presentation/profile/widgets/medical_center_picker.dart';
import 'package:flutter_learning/presentation/auth/pages/signin.dart';

class CenterSelection
{
  final MedicalCenter? healthCenter;
  final MedicalCenter? hospital;

  const CenterSelection
  ({
      this.healthCenter,
      this.hospital
  });
}

class CenterSelectionPage extends StatefulWidget
{
  final InsuranceSelection coverage;

  const CenterSelectionPage
  ({
      super.key,
      required this.coverage
  });

  @override
  State<CenterSelectionPage> createState() => _CenterSelectionPageState();
}

class _CenterSelectionPageState extends State<CenterSelectionPage>
{
  final MedicalCenterCsv _csvService = MedicalCenterCsv();

  List<MedicalCenter> _healthCenters = [];
  List<MedicalCenter> _hospitals = [];

  MedicalCenter? _selectedHealthCenter;
  MedicalCenter? _selectedHospital;

  bool _loading = true;
  bool _openingPicker = false;
  bool _saving = false;
  String? _loadError;
  String? _selectionError;

  @override
  void initState()
  {
    super.initState();
    _loadCenters();
  }

  Future<void> _loadCenters() async
  {
    try
    {
      final healthCenters = await _csvService.loadHealthCenters();
      final hospitals = await _csvService.loadHospitals();

      if(!mounted) { return; }

      setState(() 
      {
        _healthCenters = _filterByCoverty(healthCenters);
        _hospitals = _filterByCoverty(hospitals);
        _loading = false;
      });
    }
    catch(error)
    {
      if(!mounted) { return; }

      setState(() 
      {
        _loadError = 'No se puedieron cargar los centros';
        _loading = false;
      });
    }
  }

  List<MedicalCenter> _filterByCoverty(List<MedicalCenter> loadedCenters)
  {
    final result = <MedicalCenter>[];
    final selectedCompany = widget.coverage.privateCompany?.trim().toUpperCase();

    for(final center in loadedCenters)
    {
      final dependece = center.dependence.trim().toLowerCase();

      final isPublicAndCovered = widget.coverage.publicCoverty && dependece == 'publicos';

      final isPrivateAndCovered = widget.coverage.privateCoverty && dependece == 'privados' && selectedCompany != null && center.insurers.any
      (
        (company) => company.trim().toUpperCase() == selectedCompany,
      );

      if(isPublicAndCovered || isPrivateAndCovered)
      {
        result.add(center);
      }
    }
    return result;
  }
  
  Future<void> _chooseCenter({required bool hospital}) async 
  {
    if(_openingPicker) { return; }

    final centers = hospital ? _hospitals : _healthCenters;

    if(centers.isEmpty)
    {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay centros disponibles para la cobertura seleccionada')));
      return;
    }

    setState(() => _openingPicker = true);

    try 
    {
      final center = await showDialog<MedicalCenter>
      (
        context: context , 
        builder: (dialogContext) => MedicalCenterPicker(centers: centers , hospitals: hospital));

        if(!mounted || center == null) { return; }

        setState(() 
        {
          if(hospital)
          {
            _selectedHospital = center;
          }
          else 
          {
            _selectedHealthCenter = center;
          }
          _selectionError = null;
        });
    }
    finally
    {
      if(mounted) { setState(() => _openingPicker = false);}
    }
  }
  Future<void> _continue() async
  {
      if(_selectedHealthCenter == null || _selectedHospital == null)
      {
        setState(() { _selectionError = 'Seleccione un centro de salud y un hospital para continuar.'; });
        return;
      }

      final user = FirebaseAuth.instance.currentUser;

      if(user == null)
      {
        setState(() { _selectionError = 'No hay sesión iniciada'; });
        return;
      }

      setState(() 
      {
        _saving = true;
        _selectionError = null;
      });

      try 
      {
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set(
        {
          'referenceHealthCenter' : _selectedHealthCenter!.toMap(),
          'referenceHospital': _selectedHospital!.toMap(),
        }, SetOptions(merge: true));

        if(!mounted) { return; }

        await FirebaseAuth.instance.signOut();

        if(!mounted) { return; }

        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => const SignInPage()), (route) => false);
      } 
      catch (error)
      {
        if(!mounted) { return; }

        setState(() { _selectionError = 'No se pudo guardar los centros seleccionados.'; });
      }
      finally
      {
        if(mounted) { setState(() => _saving = false); }
      }
  }

  Widget _centerOption(
    {
      required String title,
      required IconData icon,
      required MedicalCenter? selectedCenter,
      required bool hospital
    })
      {
        return Card
        (
            child: ListTile
            (
              leading: Icon(icon),
              title: Text(title),
              subtitle: Text(selectedCenter == null ? 'Toca para elegir' : '${selectedCenter.name}\n ${selectedCenter.municipality}, ${selectedCenter.province} - ${selectedCenter.region}' ),
              isThreeLine: selectedCenter != null,
              trailing: _openingPicker ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
              onTap: _openingPicker ? null : () => _chooseCenter(hospital: hospital),
            ),
        );
      }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      appBar: (AppBar( title: const Text('Centros de referencia'))),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _loadError != null ? Center(child: Text(_loadError!)) 
      : ListView
      (
        padding: const EdgeInsets.all(16),
        children: 
        [
          const Text('Seleccione un centro de salud y un hospital para continuar.'),
          const SizedBox(height: 16),
          _centerOption(title: 'Centro de salud', icon: Icons.medical_services_outlined, selectedCenter: _selectedHealthCenter, hospital: false),
          _centerOption(title: 'Hospital', icon: Icons.local_hospital_outlined, selectedCenter: _selectedHospital, hospital: true),
          if(_selectionError != null)...
          [
            const SizedBox(height: 8),
            Text
            (
              _selectionError!, 
              style: TextStyle(color: Theme.of(context).colorScheme.error,)
            )
          ],
          const SizedBox(height: 20),
          FilledButton
          (
            onPressed: _saving ? null : _continue, 
            child: _saving ? const CircularProgressIndicator() : const Text('Continuar')
          )
        ], 
      )
    );
  }
}