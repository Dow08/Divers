// ================================================================
// SORTIA — Exceptions personnalisées
// Types d'erreurs métier de l'application
// ================================================================

/// Exception de base de l'application Sortia
abstract class AppException implements Exception {
  /// Crée une exception avec un message et un code optionnel
  const AppException(this.message, {this.code});

  /// Message d'erreur lisible
  final String message;

  /// Code d'erreur pour le debug
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

/// Erreur d'authentification
class AuthException extends AppException {
  /// Crée une erreur d'authentification
  const AuthException(super.message, {super.code});
}

/// Erreur réseau (pas de connexion, timeout, etc.)
class NetworkException extends AppException {
  /// Crée une erreur réseau
  const NetworkException(super.message, {super.code});
}

/// Erreur de stockage (fichier introuvable, quota dépassé)
class StorageException extends AppException {
  /// Crée une erreur de stockage
  const StorageException(super.message, {super.code});
}

/// Erreur de l'IA (classification échouée, quota API)
class AiException extends AppException {
  /// Crée une erreur IA
  const AiException(super.message, {super.code});
}

/// Erreur de permission (accès refusé, plan insuffisant)
class PermissionException extends AppException {
  /// Crée une erreur de permission
  const PermissionException(super.message, {super.code});
}

/// Erreur de validation (données invalides)
class ValidationException extends AppException {
  /// Crée une erreur de validation
  const ValidationException(super.message, {super.code});
}

/// Erreur de chiffrement (clé invalide, données corrompues)
class EncryptionException extends AppException {
  /// Crée une erreur de chiffrement  
  const EncryptionException(super.message, {super.code});
}
