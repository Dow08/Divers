// ================================================================
// SORTIA — Configuration Supabase
// Initialisation du client Supabase avec les bonnes options
// ================================================================

import 'package:supabase_flutter/supabase_flutter.dart';

/// Service d'initialisation et d'accès au client Supabase
///
/// Gère la connexion à Supabase (PostgreSQL + Auth + Storage + Realtime)
/// Région: EU Frankfurt (conformité RGPD)
class SupabaseConfig {
  SupabaseConfig._();

  /// Initialise Supabase avec les clés provenant de env.dart
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  /// Accès au client Supabase
  static SupabaseClient get client => Supabase.instance.client;

  /// Accès au client Auth
  static GoTrueClient get auth => client.auth;

  /// Accès au Storage
  static SupabaseStorageClient get storage => client.storage;

  /// Utilisateur actuellement connecté (null si déconnecté)
  static User? get currentUser => auth.currentUser;

  /// Session active (null si pas de session)
  static Session? get currentSession => auth.currentSession;
}
