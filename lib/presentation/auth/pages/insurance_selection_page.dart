import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_learning/presentation/auth/pages/center_selection_page.dart';

class InsuranceSelection 
{
  final bool publicCoverty;
  final bool privateCoverty;
  final String? privateCompany;
  final String? publicCardNumber;
  final String? privateCardNumber;

  const InsuranceSelection(
    {
      required this.publicCoverty,
      required this.privateCoverty,
      this.privateCompany,
      this.publicCardNumber,
      this.privateCardNumber
    });
}

class InsuranceSelectionPage extends StatefulWidget
{
  const InsuranceSelectionPage({super.key});

  @override
  State<InsuranceSelectionPage> createState() => _InsuranceSelectionPageState();
}

class _InsuranceSelectionPageState extends State<InsuranceSelectionPage>
{

    final _formKey = GlobalKey<FormState>();


  bool _hasPublic = false;
  bool _hasPrivate = false;
  String? _privateCompany;
  String? _errorMessage;
  final _publicCardController = TextEditingController();
  final _privateCardController = TextEditingController();

  @override
  void dispose()
  {
    _publicCardController.dispose();
    _privateCardController.dispose();
    super.dispose();
  }

  static const List<String> _companies = 
  [
    'DKV',
    'Sanitas',
    'ASISA',
    'Adeslas',
  ];

  String? _validatePrivateCard(String? value) 
  {
    final number = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');

    if (number.isEmpty) 
    {
      return 'Introduce el número de tarjeta o póliza';
    }

    switch (_privateCompany?.toLowerCase()) 
    {
      case 'sanitas':
        return RegExp(r'^\d{18}$').hasMatch(number) ? null : 'La tarjeta Sanitas debe tener 18 dígitos';

      case 'asisa':
        return RegExp(r'^\d{18}$').hasMatch(number) ? null : 'La tarjeta ASISA debe tener 18 dígitos';

      case 'adeslas':
        return RegExp(r'^(?:\d{16})$').hasMatch(number) ? null : 'La tarjeta Adeslas debe tener 16 dígitos';

      case 'dkv':
        // No fijaría una longitud exacta sin confirmar el tipo de tarjeta.
        return RegExp(r'^(?:\d{16})$').hasMatch(number) ? null : 'La tarjeta DKV debe tener 16 dígitos';

      default:
        return 'Selecciona primero una aseguradora';
    }
  }

  Future<void> _continue() async
  {
    if(!_hasPublic && !_hasPrivate)
    {
      setState(() { _errorMessage = 'Seleccione al menos una cobertura sanitaria';});
    }

    if(!_formKey.currentState!.validate()) { return; }
    
    if(!_hasPublic && !_hasPrivate)
    {
      setState(() { _errorMessage = 'Seleccione al menos una cobertura sanitaria.'; });
      return;
    }

    if(_hasPrivate && _privateCompany == null)
    {
      setState(() { _errorMessage = 'Seleccione su compañía de seguro privado'; });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if(user == null)
    {
      setState(() { _errorMessage = 'No hay sesión iniciada'; });
      return;
    }

    final selection = InsuranceSelection
    (
        publicCoverty: _hasPublic, 
        privateCoverty: _hasPrivate,
        privateCompany: _hasPrivate ? _privateCompany : null,
        publicCardNumber: _hasPublic ? _publicCardController.text.trim() : null,
        privateCardNumber: _hasPrivate ? _privateCardController.text.trim() : null,
    );

    try
    {
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).set(
        {
          'publicCoverage' : selection.publicCoverty,
          'privateCoverage': selection.privateCoverty,
          'privateCompany': selection.privateCompany,
          'publicCardNumber' : selection.publicCardNumber,
          'privateCardNumber' : selection.privateCardNumber
        }, SetOptions(merge: true));

      if(!mounted) { return; }

      await Navigator.pushReplacement
      (
        context,
        MaterialPageRoute(builder: (_) => CenterSelectionPage(coverage: selection))
      );
    }
    catch (error)
    {
      if(!mounted) { return; }

      setState(() { _errorMessage = 'No se pudo guardar la cobertura sanitaria'; });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      appBar: AppBar(title: const Text('Coberturas sanitarias')),

      body: Form
      (
        key: _formKey,
        child: ListView
        (
          padding: const EdgeInsets.all(20),
          children: 
          [
            const Text('Seleccione las coberturas sanitarias que tiene. Puedes elegir una o las dos.'),
            const SizedBox(height: 16),
            Card
            (
              child: CheckboxListTile
              (
                value: _hasPublic,
                title: const Text('Seguridad social'),
                subtitle:  const Text('Cobertura sanitaria pública'),
                secondary: const Icon(Icons.health_and_safety_outlined),
                onChanged: (value) 
                {
                  setState(() 
                  {
                    _hasPublic = value ?? false;
                    _errorMessage = null;
                  }
                  );
                }
              ),
            ),
            if(_hasPublic)
              TextFormField
              (
                controller: _publicCardController,
                decoration: const InputDecoration
                (
                  labelText: 'Número de tarjeta sanitaria pública',
                  border: OutlineInputBorder()
                ),
                validator: (value) 
                {
                  if(value == null || value.trim().isEmpty)
                  {
                    return 'Introduce el número de la tarjeta sanitaria';
                  }

                  if(!RegExp(r'^[0-9 -]{6,25}$').hasMatch(value.trim()))
                  {
                    return 'Revisa el formato del número de la tarjeta';
                  }
                  return null;
                }
              ),

            const SizedBox(height: 16),

            Card
            (
              child: CheckboxListTile
              (
                value: _hasPrivate,
                title: const Text('Seguro privado'),
                subtitle:  const Text('Cobertura sanitaria privada'),
                secondary: const Icon(Icons.medical_services_outlined),
                onChanged: (value)
                {
                  setState(()
                  {
                    _hasPrivate = value ?? false;
                    if(!_hasPrivate)
                    {
                      _privateCompany = null;
                    }
                    _errorMessage = null;
                  });
                }
              ),
            ),

            if(_hasPrivate) ...
            [
              const SizedBox(height: 16),
              DropdownButtonFormField<String>
              (
                value: _privateCompany,
                decoration: const InputDecoration
                (
                  labelText: 'Compañía aseguradora',
                  border: OutlineInputBorder()
                ),
                hint: const Text('Seleccione su compañía'),
                items: _companies.map((company) 
                {
                  return DropdownMenuItem
                  (
                    value: company,
                    child: Text(company)
                  );
                }).toList(),
                onChanged: (value) { setState(() 
                {
                  _privateCompany = value;
                  _errorMessage = null;
                });},
              ),

              const SizedBox(height: 12),
              
              TextFormField
              (
                  controller: _privateCardController,
                  validator: _validatePrivateCard,
                  decoration: const InputDecoration
                  (
                    labelText: 'Número de tarjeta',
                    border: OutlineInputBorder(), 
                  ),
              )
            ],

            if(_errorMessage != null) ...
            [
              const SizedBox(height: 12),
              Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error))
            ],

            const SizedBox(height: 24),
            FilledButton(onPressed: _continue, child: const Text('Continuar')),
          ],

        )
      )
    );
  }

}
