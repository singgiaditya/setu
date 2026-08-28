import 'package:local_auth/local_auth.dart';
import '../../shared/models/result.dart';

class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<Result<bool>> authenticate({String reason = 'Authenticate to access SETU'}) async {
    try {
      final available = await isBiometricAvailable();
      if (!available) {
        return Result.failure('Biometric authentication is not supported or setup on this device.');
      }

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        return Result.success(true);
      } else {
        return Result.failure('Authentication failed or was canceled.');
      }
    } catch (e) {
      return Result.failure('Biometric error: $e');
    }
  }
}
