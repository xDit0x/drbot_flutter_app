import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning/common/widgets/snackbar/snack_bar_root.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (user == null || email == null) {
      SnackbarRoot.show(
        context,
        "No hay un sesión iniciada",
        selection: SnackbarRootType.bad,
      );

      return;
    }

    setState(() => _loading = true);

    try {
      final userCredential = EmailAuthProvider.credential(
        email: email,
        password: _currentPassword.text,
      );

      await user.reauthenticateWithCredential(userCredential);
      await user.updatePassword(_newPassword.text);

      if (!mounted) {
        return;
      }

      SnackbarRoot.show(
        context,
        'La contraseña ha sido actualizada correctamente',
        selection: SnackbarRootType.ok,
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      final message = switch (e.code) {
        'wrong-password' ||
        'invalid-credential' => 'La contraseña no es correcta',
        'weak-password' => 'La contraseña es demasiado débil',
        'requires-recent-login' =>
          'Vuelve a iniciar sesión e intentalo de nuevo',
        _ => e.message ?? 'No se pudo cambiar la contraseña',
      };

      SnackbarRoot.show(context, message, selection: SnackbarRootType.warning);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar contraseña')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _currentPassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Introduzca su contraseña actual'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.length < 6
                    ? 'Debe tener al menos 6 carácteres'
                    : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _changePassword,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
