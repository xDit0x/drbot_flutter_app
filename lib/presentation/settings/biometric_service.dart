import 'package:local_auth/local_auth.dart';

class BiometricService 
{
  final LocalAuthentication _authentication = LocalAuthentication();
  
  Future<bool> hasEnrolledBiometrics() async
  {
    try
    {
      final biometric = await _authentication.getAvailableBiometrics();
      return biometric.isNotEmpty;
    }
    catch(_)
    {
      return false;
    }
  }

  Future<bool> authenticated() async
  {
    try
    {
      return await _authentication.authenticate
      (
        localizedReason: 'Confirma tu identidad para activar la biometría', 
        biometricOnly: true,
      );
    }
    catch(_)
    {
      return false;
    }
  }
}