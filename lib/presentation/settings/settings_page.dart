import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_learning/presentation/settings/font_size_page.dart';
import 'package:flutter_learning/presentation/settings/about_page.dart';
import 'package:flutter_learning/presentation/settings/screen_reader_page.dart';
import 'package:flutter_learning/presentation/settings/biometric_service.dart';

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

  // Changes: Añadir ajustes de borrado de cuenta
  /*
  Future<void> _deleteAccount() async
  {
    final confirm = await showDialog<bool>
    (
      context,
      builder: (dialogContext) => AlertDialog
      (
        title: const Text
      )
    );
  }
  */

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
      appBar: AppBar(title: const Text('Ajustes')),

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

            _option(icon: Icons.lock_outline, title: 'Cambiar contraseña'),

            _option(icon: Icons.person_remove_outlined, title: 'Darse de baja'),
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
