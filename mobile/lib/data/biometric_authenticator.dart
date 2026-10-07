import 'package:local_auth/local_auth.dart';

/// Only the operating system handles biometric samples and the native prompt.
abstract class BiometricAuthenticator {
  Future<bool> isAvailable();
  Future<bool> authenticate();
}

class PlatformBiometricAuthenticator implements BiometricAuthenticator {
  final LocalAuthentication _auth;

  PlatformBiometricAuthenticator({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  @override
  Future<bool> isAvailable() async =>
      await _auth.canCheckBiometrics &&
      (await _auth.getAvailableBiometrics()).isNotEmpty;

  @override
  Future<bool> authenticate() => _auth.authenticate(
        localizedReason: 'Unlock your AmanFlow session',
        options: const AuthenticationOptions(biometricOnly: true),
      );
}
