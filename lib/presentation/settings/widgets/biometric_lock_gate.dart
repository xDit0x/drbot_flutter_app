import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricLockGate extends StatefulWidget 
{
  const BiometricLockGate
  ({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<BiometricLockGate> createState() => _BiometricLockGateState();
}

class _BiometricLockGateState extends State<BiometricLockGate> with WidgetsBindingObserver 
{
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _enabled = false;
  bool _locked = true;
  bool _loading = true;
  bool _authenticating = false;

  @override
  void initState() 
  {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPreference();
  }

  Future<void> _loadPreference() async 
  {
    final preferences = await SharedPreferences.getInstance();
    final enabled = preferences.getBool('biometricEnabled') ?? false;

    if (!mounted) return;

    setState(() 
    {
      _enabled = enabled;
      _locked = enabled;
      _loading = false;
    });

    if (enabled) 
    {
      await _unlock();
    }
  }

  Future<void> _unlock() async 
  {
    if (!_enabled || _authenticating || !mounted) { return; }

    setState(() => _authenticating = true);

    var authenticated = false;

    try 
    {
      authenticated = await _localAuth.authenticate
      (
        localizedReason: 'Desbloquea Dr. Bot',
        biometricOnly: true,
      );
    } catch (_) {
      authenticated = false;
    }

    if (!mounted) { return; }

    setState(() 
    {
      _authenticating = false;
      if (authenticated) 
      {
        _locked = false;
      }
    });
  }

  Future<void> _unlockWithPassword() async 
  {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (user == null || email == null) return;

    final controller = TextEditingController();

    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Desbloquear con contraseña'),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text);
              },
              child: const Text('Desbloquear'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (password == null || password.isEmpty) return;

    setState(() => _authenticating = true);

    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: email,
          password: password,
        ),
      );

      if (!mounted) return;
      setState(() => _locked = false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message =
          e.code == 'wrong-password' || e.code == 'invalid-credential'
              ? 'La contraseña no es correcta.'
              : 'No se pudo verificar la contraseña.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _authenticating = false);
      }
    }
  }

  Future<void> _signOut() async 
  {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('biometricEnabled');
    await FirebaseAuth.instance.signOut();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) 
  {
    if (!_enabled) { return; }

    if (state == AppLifecycleState.paused) 
    {
      setState(() => _locked = true);
    } 
    else if (state == AppLifecycleState.resumed && _locked) 
    {
      _unlock();
    }
  }

  @override
  void dispose() 
  {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    if (_loading) 
    {
      return const Scaffold
      (
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_enabled || !_locked) 
    {
      return widget.child;
    }

    return Scaffold
    (
      body: Center
      (
        child: Column
        (
          mainAxisSize: MainAxisSize.min,
          children: 
          [
            const Icon(Icons.fingerprint, size: 64),
            const SizedBox(height: 16),
            const Text('Dr. Bot está bloqueado'),
            const SizedBox(height: 16),
            ElevatedButton
            (
              onPressed: _authenticating ? null : () => _unlock(),
              child: Text(_authenticating ? 'Comprobando…' : 'Desbloquear con huella'),
            ),
            
            TextButton
            (
              onPressed: _authenticating ? null : () => _unlockWithPassword(),
              child: const Text('Usar contraseña'),
            ),
            
            TextButton
            (
              onPressed: _signOut,
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}