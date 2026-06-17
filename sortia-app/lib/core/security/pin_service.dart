// ================================================================
// SORTIA — Gestion du code PIN 6 chiffres
// ================================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'secure_storage_service.dart';
import '../utils/logger.dart';

/// Service de gestion du code PIN à 6 chiffres
///
/// Le PIN est hashé avec SHA-256 + sel avant stockage.
/// Utilisé pour verrouiller l'app et les dossiers sensibles.
class PinService {
  /// Crée le service PIN
  PinService(this._secureStorage);

  static const String _pinHashKey = 'sortia_pin_hash';
  static const String _pinSaltKey = 'sortia_pin_salt';

  final SecureStorageService _secureStorage;

  /// Vérifie si un PIN est configuré
  Future<bool> isPinConfigured() async {
    return _secureStorage.containsKey(key: _pinHashKey);
  }

  /// Configure un nouveau PIN
  ///
  /// Le PIN doit contenir exactement 6 chiffres.
  Future<void> setPin(String pin) async {
    if (!_isValidPin(pin)) {
      throw ArgumentError('Le PIN doit contenir exactement 6 chiffres');
    }

    // Générer un sel aléatoire
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = _hashPin(pin, salt);

    await _secureStorage.write(key: _pinHashKey, value: hash);
    await _secureStorage.write(key: _pinSaltKey, value: salt);

    AppLogger.info('PinService: PIN configuré');
  }

  /// Vérifie un PIN saisi
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secureStorage.read(key: _pinHashKey);
    final storedSalt = await _secureStorage.read(key: _pinSaltKey);

    if (storedHash == null || storedSalt == null) {
      return false;
    }

    final inputHash = _hashPin(pin, storedSalt);
    return inputHash == storedHash;
  }

  /// Supprime le PIN
  Future<void> removePin() async {
    await _secureStorage.delete(key: _pinHashKey);
    await _secureStorage.delete(key: _pinSaltKey);
    AppLogger.info('PinService: PIN supprimé');
  }

  bool _isValidPin(String pin) {
    return pin.length == 6 && RegExp(r'^\d{6}$').hasMatch(pin);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }
}
