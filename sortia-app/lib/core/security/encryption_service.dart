// ================================================================
// SORTIA — Service de chiffrement AES-256
// Utilisé pour : tokens OAuth, clés API PA, données vault
// ================================================================

import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/logger.dart';

/// Service de chiffrement AES-256 pour les données sensibles
///
/// Utilise AES-256-CBC avec IV aléatoire pour chaque opération.
/// La clé maître est générée une seule fois et stockée
/// dans le Keychain (iOS) / Keystore (Android) / DPAPI (Windows).
class EncryptionService {
  /// Crée le service de chiffrement
  EncryptionService(this._secureStorage);

  static const String _keyStorageKey = 'sortia_master_key';

  final FlutterSecureStorage _secureStorage;
  enc.Key? _masterKey;

  /// Initialise la clé maître (créée une seule fois, stockée de façon sécurisée)
  Future<void> initialize() async {
    final storedKey = await _secureStorage.read(key: _keyStorageKey);

    if (storedKey == null) {
      // Générer une nouvelle clé 256 bits
      final key = enc.Key.fromSecureRandom(32);
      await _secureStorage.write(key: _keyStorageKey, value: key.base64);
      _masterKey = key;
      AppLogger.info('EncryptionService: Nouvelle clé maître générée');
    } else {
      _masterKey = enc.Key.fromBase64(storedKey);
      AppLogger.info('EncryptionService: Clé maître chargée');
    }
  }

  /// Chiffre une chaîne de caractères avec AES-256-CBC
  ///
  /// Format de sortie : `base64(iv):base64(ciphertext)`
  /// L'IV est généré aléatoirement pour chaque opération.
  String encrypt(String plainText) {
    _ensureInitialized();

    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(
      enc.AES(_masterKey!, mode: enc.AESMode.cbc),
    );
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return '${iv.base64}:${encrypted.base64}';
  }

  /// Déchiffre une chaîne chiffrée avec [encrypt]
  String decrypt(String encryptedText) {
    _ensureInitialized();

    final parts = encryptedText.split(':');
    if (parts.length != 2) {
      throw const FormatException(
        'Format chiffré invalide. Attendu: base64(iv):base64(ciphertext)',
      );
    }

    final iv = enc.IV.fromBase64(parts[0]);
    final encrypted = enc.Encrypted.fromBase64(parts[1]);
    final encrypter = enc.Encrypter(
      enc.AES(_masterKey!, mode: enc.AESMode.cbc),
    );

    return encrypter.decrypt(encrypted, iv: iv);
  }

  /// Génère un hash SHA-256 (pour le coffre-fort / intégrité)
  String sha256Hash(Uint8List data) {
    final digest = sha256.convert(data);
    return digest.toString();
  }

  /// Vérifie l'intégrité d'un fichier via son hash SHA-256
  bool verifyIntegrity(Uint8List data, String expectedHash) {
    return sha256Hash(data) == expectedHash;
  }

  void _ensureInitialized() {
    if (_masterKey == null) {
      throw StateError(
        'EncryptionService non initialisé. Appeler initialize() avant.',
      );
    }
  }
}
