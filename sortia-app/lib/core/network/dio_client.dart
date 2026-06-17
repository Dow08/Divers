// ================================================================
// SORTIA — Client HTTP Dio configuré
// Avec interceptors, timeouts, et certificate pinning
// ================================================================

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../security/certificate_pinning.dart';
import '../utils/logger.dart';

/// Client HTTP Dio configuré pour Sortia
///
/// Inclut :
/// - Timeouts configurés
/// - Interceptors (auth, retry, logging)
/// - Certificate pinning en production
class DioClient {
  /// Crée un client Dio configuré
  DioClient() {
    _dio = CertificatePinningService.createPinnedDioClient();

    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Interceptor de logging (dev/staging uniquement)
    if (AppConfig.instance.enableVerboseLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (message) => AppLogger.debug('[HTTP] $message'),
        ),
      );
    }
  }

  late final Dio _dio;

  /// Accès au client Dio configuré
  Dio get client => _dio;

  /// Requête GET
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Requête POST
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.post<T>(path, data: data, options: options);
  }

  /// Requête PUT
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.put<T>(path, data: data, options: options);
  }

  /// Requête DELETE
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.delete<T>(path, data: data, options: options);
  }
}
