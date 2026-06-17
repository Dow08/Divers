// ================================================================
// SORTIA — Wrapper Flutter Secure Storage
// Stockage sécurisé des données sensibles
// ================================================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/logger.dart';

/// Service de stockage sécurisé
///
/// Wrapper autour de `flutter_secure_storage` qui utilise :
/// - iOS : Keychain
/// - Android : Keystore
/// - Windows : DPAPI (Data Protection API)
/// - macOS : Keychain
class SecureStorageService {
  /// Crée le service de stockage sécurisé
  SecureStorageService() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  /// Écrit une valeur chiffrée dans le stockage sécurisé
  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erreur écriture stockage sécurisé: $key',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Lit une valeur depuis le stockage sécurisé
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erreur lecture stockage sécurisé: $key',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Supprime une valeur du stockage sécurisé
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erreur suppression stockage sécurisé: $key',
        e,
        stackTrace,
      );
    }
  }

  /// Vérifie si une clé existe dans le stockage
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      return false;
    }
  }

  /// Supprime toutes les données du stockage sécurisé
  ///
  /// ⚠️ Opération irréversible — utilisée uniquement à la déconnexion
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.info('Stockage sécurisé: toutes les données supprimées');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Erreur purge stockage sécurisé',
        e,
        stackTrace,
      );
    }
  }
}
