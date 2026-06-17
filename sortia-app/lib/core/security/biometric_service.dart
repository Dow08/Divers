// ================================================================
// SORTIA — Service biométrique
// Face ID / empreinte digitale
// ================================================================

import 'package:local_auth/local_auth.dart';

import '../utils/logger.dart';

/// Service d'authentification biométrique  
///
/// Gère Face ID, Touch ID, et empreinte digitale Android.
/// Utilisé pour déverrouiller l'app et accéder au coffre-fort.
class BiometricService {
  /// Crée le service biométrique
  BiometricService() : _localAuth = LocalAuthentication();

  final LocalAuthentication _localAuth;

  /// Vérifie si la biométrie est disponible sur l'appareil
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      AppLogger.warning('Biométrie indisponible: $e');
      return false;
    }
  }

  /// Liste les types de biométrie disponibles
  Future<List<BiometricType>> getAvailableTypes() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authentifie l'utilisateur par biométrie
  ///
  /// [reason] : Message affiché à l'utilisateur pendant la vérification
  Future<bool> authenticate({
    String reason = 'Veuillez vous authentifier pour accéder à Sortia',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erreur authentification biométrique', e, stackTrace);
      return false;
    }
  }
}
