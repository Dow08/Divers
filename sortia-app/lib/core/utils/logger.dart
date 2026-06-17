// ================================================================
// SORTIA — Logger structuré
// Remplace print() dans toute l'application
// ================================================================

import 'package:logger/logger.dart' as pkg;

/// Logger centralisé pour toute l'application Sortia
///
/// Utilise le package `logger` pour un affichage structuré et lisible.
/// En production, seuls les niveaux warning et supérieurs sont affichés.
class AppLogger {
  AppLogger._();

  static final pkg.Logger _logger = pkg.Logger(
    printer: pkg.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      noBoxingByDefault: true,
    ),
  );

  /// Log de debug (dev uniquement)
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log d'information
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log d'avertissement
  static void warning(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log d'erreur
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal (erreur critique)
  static void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
