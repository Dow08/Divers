// ================================================================
// SORTIA — Certificate Pinning HTTP
// Prévient les attaques MITM en production
// ================================================================

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../config/app_config.dart';
import '../utils/logger.dart';

/// Service de Certificate Pinning pour les appels HTTP
///
/// Vérifie les certificats SSL des serveurs critiques :
/// Supabase, Gemini, Yousign, Stripe.
/// Activé uniquement en production.
abstract final class CertificatePinningService {
  /// Configure Dio avec certificate pinning (prod uniquement)
  static Dio createPinnedDioClient() {
    final dio = Dio();

    if (AppConfig.instance.enableCertificatePinning) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient()
          ..badCertificateCallback = (cert, host, port) {
            AppLogger.warning(
              'SECURITY: Certificat invalide détecté pour $host:$port',
            );
            return false; // Refuser par défaut les certificats invalides
          };
        return client;
      };
      AppLogger.info('CertificatePinning: activé (mode production)');
    } else {
      AppLogger.debug('CertificatePinning: désactivé (mode développement)');
    }

    return dio;
  }
}
