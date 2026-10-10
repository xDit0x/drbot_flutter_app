import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_learning/common/widgets/snackbar/snack_bar_root.dart';
import 'package:flutter_learning/domain/usecases/auth/delete_account.dart';
import 'package:flutter_learning/presentation/auth/pages/signin.dart';
import 'package:flutter_learning/presentation/auth/pages/signup_or_signin.dart';
import 'package:flutter_learning/service_locator.dart';
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
  late final ColorScheme scheme = Theme.of(context).colorScheme;

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

        SnackbarRoot.show(
          context,
          'Configura una huella o reconocimiento facial en el dispositivo',
          selection: SnackbarRootType.warning,
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

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          '¿Desea darse de baja?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: scheme.inversePrimary, fontSize: 16),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(color: scheme.primary),
              child: Text(
                'Continuar',
                style: TextStyle(color: scheme.inversePrimary, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (user == null || email == null) {
      return;
    }

    String password = '';

    final passw = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Verifique su identidad',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña actual',
                labelStyle: TextStyle(fontWeight: FontWeight.w500),
                floatingLabelStyle: TextStyle(
                  color: scheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              onChanged: (value) => password = value,
            ),
          ],
        ),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: scheme.inversePrimary, fontSize: 18),
                ),
              ),
              SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(dialogContext, password);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(color: Colors.red),
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_forever_rounded,
                        color: scheme.inversePrimary,
                        size: 30,
                      ),
                      Text(
                        'Eliminar cuenta',
                        style: TextStyle(
                          color: scheme.inversePrimary,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (passw == null) {
      return;
    }
    if (passw.isEmpty) {
      SnackbarRoot.show(
        context,
        "Introduzca la contraseña para continuar ",
        selection: SnackbarRootType.warning,
      );
      return;
    }

    final result = await sl<DeleteAccountUseCase>().call(params: passw);
    if (!mounted) return;

    result.fold(
      (l) => SnackbarRoot.show(
        context,
        l.toString(),
        selection: SnackbarRootType.warning,
      ),
      (r) {
        SnackbarRoot.show(
          context,
          'La cuenta se ha eliminado correctamente',
          selection: SnackbarRootType.ok,
          leading: Icon(Icons.person_remove_outlined),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const SignupOrSigninPage()),
          (route) => false,
        );
      },
    );
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

  Widget _option({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(
          bottom: 100 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          _section('Seguridad', [
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biometría'),
              value: _biometricEnabled,
              onChanged: _onBiometricChanged,
            ),

            _option(
              icon: Icons.lock_outline,
              title: 'Cambiar contraseña',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                );
              },
            ),

            _option(
              icon: Icons.person_remove_outlined,
              title: 'Darse de baja',
              onTap: _deleteAccount,
            ),
          ]),

          _section('Accesibilidad', [
            _option(
              icon: Icons.accessibility_new,
              title: 'VoiceOver o TalkBack',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScreenReaderPage()),
                );
              },
            ),

            _option(
              icon: Icons.text_fields,
              title: 'Tamaño de letra',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FontSizePage()),
                );
              },
            ),
          ]),

          _section('Preferencias', [
            SwitchListTile(
              secondary: const Icon(Icons.vibration),
              title: const Text('Vibración'),
              value: _vibrationEnabled,
              onChanged: _setVibration,
            ),
          ]),

          _section('Información', [
            _option(
              icon: Icons.info_outline,
              title: 'Acerca de la app',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }
}
