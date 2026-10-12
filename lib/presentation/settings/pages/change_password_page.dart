import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool _showActualPassword = false;
  bool _showNewPassword = false;
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
      HapticFeedback.mediumImpact();
      SnackbarRoot.show(
        context,
        'La contraseña ha sido actualizada correctamente',
        selection: SnackbarRootType.ok,
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        HapticFeedback.lightImpact();
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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cambiar contraseña',
          style: TextStyle(
            color: scheme.inverseSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),

                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.inverseSurface.withAlpha(50),
                          offset: Offset(1, 1.2),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _currentPassword,
                            obscureText: !_showActualPassword,
                            decoration: InputDecoration(
                              floatingLabelStyle: TextStyle(
                                fontSize: 24,
                                color: scheme.inversePrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              labelText: 'Contraseña actual',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.length < 6
                                ? 'Debe tener al menos 6 carácteres'
                                : null,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(
                            () => _showActualPassword = !_showActualPassword,
                          ),
                          icon: _showActualPassword
                              ? Icon(
                                  Icons.visibility_off,
                                  color: scheme.inverseSurface,
                                )
                              : Icon(
                                  Icons.visibility,
                                  color: scheme.inverseSurface,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),

                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.inverseSurface.withAlpha(50),
                          offset: Offset(1, 1.2),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _newPassword,
                            obscureText: !_showNewPassword,
                            decoration: InputDecoration(
                              floatingLabelStyle: TextStyle(
                                color: scheme.inversePrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 24,
                              ),
                              labelText: 'Contraseña nueva',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.length < 6
                                ? 'Debe tener al menos 6 carácteres'
                                : null,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(
                            () => _showNewPassword = !_showNewPassword,
                          ),
                          icon: _showNewPassword
                              ? Icon(
                                  Icons.visibility_off,
                                  color: scheme.inverseSurface,
                                )
                              : Icon(
                                  Icons.visibility,
                                  color: scheme.inverseSurface,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  FilledButton(
                    onPressed: _loading ? null : _changePassword,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 45,
                              vertical: 22,
                            ),
                            child: const Text(
                              'Guardar contraseña',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
