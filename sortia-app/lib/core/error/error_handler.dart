// ================================================================
// SORTIA — Gestion centralisée des erreurs
// ================================================================

import 'package:dio/dio.dart';

import 'app_exception.dart';
import '../utils/logger.dart';

/// Gestionnaire centralisé des erreurs
///
/// Convertit les exceptions techniques en exceptions métier lisibles.
/// Toutes les erreurs passent par ce handler pour un traitement uniforme.
abstract final class ErrorHandler {
  /// Gère une erreur et la convertit en [AppException]
  static AppException handle(Object error, [StackTrace? stackTrace]) {
    AppLogger.error('Erreur interceptée', error, stackTrace);

    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioError(error);
    }

    if (error is FormatException) {
      return ValidationException(
        'Format de données invalide: ${error.message}',
        code: 'FORMAT_ERROR',
      );
    }

    return NetworkException(
      'Une erreur inattendue est survenue: $error',
      code: 'UNKNOWN',
    );
  }

  static AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'Délai de connexion dépassé. Vérifiez votre connexion Internet.',
          code: 'TIMEOUT',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          'Impossible de se connecter au serveur. '
          'Vérifiez votre connexion Internet.',
          code: 'NO_CONNECTION',
        );
      case DioExceptionType.badResponse:
        return _handleHttpStatus(error.response?.statusCode);
      case DioExceptionType.cancel:
        return const NetworkException(
          'Requête annulée.',
          code: 'CANCELLED',
        );
      default:
        return NetworkException(
          'Erreur réseau: ${error.message}',
          code: 'NETWORK_ERROR',
        );
    }
  }

  static AppException _handleHttpStatus(int? statusCode) {
    switch (statusCode) {
      case 401:
        return const AuthException(
          'Session expirée. Veuillez vous reconnecter.',
          code: 'UNAUTHORIZED',
        );
      case 403:
        return const PermissionException(
          'Accès refusé. Vous n\'avez pas les droits nécessaires.',
          code: 'FORBIDDEN',
        );
      case 404:
        return const StorageException(
          'Ressource introuvable.',
          code: 'NOT_FOUND',
        );
      case 429:
        return const NetworkException(
          'Trop de requêtes. Veuillez patienter quelques instants.',
          code: 'RATE_LIMIT',
        );
      case 500:
      case 502:
      case 503:
        return const NetworkException(
          'Le serveur rencontre un problème. Réessayez dans quelques minutes.',
          code: 'SERVER_ERROR',
        );
      default:
        return NetworkException(
          'Erreur serveur (code: $statusCode)',
          code: 'HTTP_$statusCode',
        );
    }
  }
}
