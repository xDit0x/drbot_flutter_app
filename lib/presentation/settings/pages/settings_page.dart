import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_learning/presentation/auth/pages/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_learning/presentation/settings/pages/font_size_page.dart';
import 'package:flutter_learning/presentation/settings/pages/about_page.dart';
import 'package:flutter_learning/presentation/settings/pages/screen_reader_page.dart';
import 'package:flutter_learning/presentation/settings/widgets/biometric_service.dart';
import 'package:flutter_learning/presentation/settings/pages/change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _vibrationEnabled = true;
  final BiometricService _biometricService = BiometricService();
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    try {
      _loadVibration();
    } catch (_) {
      _vibrationEnabled = true;
    }
    try {
      _loadBiometricPreference();
    } catch (_) {
      _biometricEnabled = false;
    }
  }

  Future<void> _loadVibration() async {
    try {
      final preference = await SharedPreferences.getInstance();

      if (!mounted) {
        return;
      }

      setState(() {
        _vibrationEnabled = preference.getBool('vibrationEnabled') ?? true;
      });
    } catch (_) {
      _vibrationEnabled = true;
    }
  }

  Future<void> _setVibration(bool value) async {
    if (!mounted) return;
    setState(() {
      _vibrationEnabled = value;
    });

    try {
      final preference = await SharedPreferences.getInstance();
      await preference.setBool('vibrationEnabled', value);
    } catch (_) {}

    if (value) {
      await HapticFeedback.selectionClick();
    }
  }

  Future<void> _loadBiometricPreference() async {
    try {
      final preference = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _biometricEnabled = preference.getBool('biometricEnabled') ?? false;
      });
    } catch (_) {}
  }

  Future<void> _onBiometricChanged(bool enabled) async {
    if (enabled) {
      final available = await _biometricService.hasEnrolledBiometrics();

      if (!available) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Configura una huella o reconocimiento facial en el dispositivo',
            ),
          ),
        );

        return;
      }

      final authenticated = await _biometricService.authenticated();
      if (!authenticated) {
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _biometricEnabled = enabled;
    });

    try {
      final preference = await SharedPreferences.getInstance();
      await preference.setBool('biometricEnabled', enabled);
    } catch (_) {}
  }

  Future<void> _deleteAccount() async
  {
    final confirm = await showDialog<bool>
    (
      context: context,
      builder: (dialogContext) => AlertDialog
      (
        title: const Text('¿Desea darse de baja?'),
        actions: 
        [
          TextButton
          (
            onPressed: () => Navigator.pop(dialogContext, false), 
            child: const Text('Cancelar'),
          ),
          TextButton
          (
            onPressed: () => Navigator.pop(dialogContext, true), 
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    
    if(confirm != true) { return; }

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if(user == null || email == null) { return; }

    String password = '';

    final passw = await showDialog<String>
    (
      context: context,
      builder: (dialogContext) => AlertDialog
      (
        title: const Text('Verifique su identidad'),
        content: TextField
        (
          obscureText: true,
          decoration: const InputDecoration
          (
            labelText: 'Contraseña actual'
          ),
          onChanged: (value) => password = value,
        ),
        actions: 
        [
          TextButton
          (
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text('Cancelar'),
          ),
          TextButton
          (
            onPressed: () => Navigator.pop(dialogContext, password), 
            child: const Text('Eliminar cuenta'),
          ),
        ], 
      ),
    );


    if(passw == null || passw.isEmpty) { return; }

    try
    {
      final credencialUser = EmailAuthProvider.credential(email: email, password: passw);

      await user.reauthenticateWithCredential(credencialUser);

      final userDoc = FirebaseFirestore.instance.collection('Users').doc(user.uid);

      final document = await userDoc.get();
      final savedData = document.data();

      await userDoc.delete();

      try 
      {
        await user.delete();
      } 
      catch (_) 
      {
        if (savedData != null && FirebaseAuth.instance.currentUser != null) 
        {
          await userDoc.set(savedData, SetOptions(merge: true));
        }
        
        rethrow;
      }

      if (!mounted) { return; }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La cuenta se ha eliminado correctamente')));

      Navigator.of(context).pushAndRemoveUntil
      (
        MaterialPageRoute<void>
        (
          builder: (_) => const SignInPage(),
        ),
        (route) => false,
      );
    }
    on FirebaseAuthException catch (e)
    {
      if(!mounted) { return; }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se ha podido eliminar la cuenta: ${e.message} ?? e.code')));
    }
    catch (e)
    {
      if(!mounted) { return; }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se han podido eliminar los datos: $e')));
    }
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),

          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _option
  ({
      required IconData icon,
      required String title,
      String? subtitle,
      VoidCallback? onTap,
  })
    {
      return ListTile
      (
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );
    }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('Ajustes'),
      ),

      body: ListView
      (
        padding: EdgeInsets.only
        (
          bottom: 100 + MediaQuery.of(context).padding.bottom
        ),
        children: 
        [
          _section
          (
            'Seguridad',
            [
              SwitchListTile
              (
                secondary: const Icon(Icons.fingerprint), 
                title:  const Text('Biometría'),
                value: _biometricEnabled,
                onChanged: _onBiometricChanged,
              ),

              _option
              (
                icon: Icons.lock_outline, 
                title:  'Cambiar contraseña',
                onTap: () 
                {
                  Navigator.push
                  (
                    context, 
                    MaterialPageRoute(builder: (_) => const ChangePasswordPage())
                  );
                }
              ),

              _option
              (
                icon: Icons.person_remove_outlined, 
                title:  'Darse de baja',
                onTap: _deleteAccount,

              ),
            ]
          ),

          _section
          (
            'Accesibilidad',
            [
              _option
              (
                icon: Icons.accessibility_new, 
                title:  'VoiceOver o TalkBack',
                onTap: ()
                {
                  Navigator.push
                  (
                    context,
                    MaterialPageRoute(builder: (_) => const ScreenReaderPage())
                  );
                }
              ),

              _option
              (
                icon: Icons.text_fields, 
                title:  'Tamaño de letra',
                onTap: ()
                {
                  Navigator.push
                  (
                    context, 
                    MaterialPageRoute(builder: (_) => const FontSizePage()),
                  );
                },
              ),
            ]
          ),

          _section
          (
            'Preferencias',
            [
              SwitchListTile
              (
                secondary: const Icon(Icons.vibration), 
                title:  const Text('Vibración'),
                value: _vibrationEnabled,
                onChanged: _setVibration,
              ),
            ]
          ),

          _section
          (
            'Información',
            [
              _option
              (
                icon: Icons.info_outline, 
                title:  'Acerca de la app',
                onTap: ()
                {
                  Navigator.push
                  (
                    context, 
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  );
                },
              ),
            ]
          ),
        ],
      )
    );
  }
}
