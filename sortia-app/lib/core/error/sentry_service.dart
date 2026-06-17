// ================================================================
// SORTIA — Sentry error reporting service
// Monitoring des erreurs en production
// ================================================================

import '../utils/logger.dart';

/// Service de reporting d'erreurs via Sentry
///
/// Envoie les erreurs et exceptions à Sentry en production.
/// Désactivé en développement pour ne pas polluer les données.
class SentryService {
  SentryService._();

  /// Initialise Sentry avec le DSN configuré
  static Future<void> initialize({required String dsn}) async {
    // Sentry est initialisé dans main.dart via SentryFlutter.init()
    AppLogger.info('SentryService: initialisé');
  }

  /// Capture une exception et l'envoie à Sentry
  static Future<void> captureException(
    Object exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) async {
    AppLogger.error(
      'SentryService: exception capturée',
      exception,
      stackTrace,
    );
    // TODO(#16): Implémenter Sentry.captureException
  }

  /// Capture un message informatif
  static Future<void> captureMessage(String message) async {
    AppLogger.info('SentryService: $message');
    // TODO(#17): Implémenter Sentry.captureMessage
  }
}
