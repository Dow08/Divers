// ================================================================
// SORTIA — Point d'entrée principal
// Initialise tous les services et lance l'application
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/config/env.dart';
import 'core/config/supabase_config.dart';
import 'core/utils/logger.dart';
import 'features/ai/data/ai_service.dart';

/// Point d'entrée principal de l'application Sortia
///
/// Initialise dans l'ordre :
/// 1. Widgets Flutter
/// 2. Variables d'environnement (.env)
/// 3. Configuration environnement
/// 4. Client Supabase
/// 5. Service IA (Gemini)
/// 6. Application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Charger les variables d'environnement
  await Env.load();

  // 2. Initialiser la configuration
  AppConfig.initialize(AppEnvironment.production);

  // 3. Initialiser Supabase (si les clés sont configurées)
  if (Env.isConfigured) {
    await SupabaseConfig.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    AppLogger.info('Supabase initialisé — ${Env.supabaseUrl}');
  } else {
    AppLogger.warning(
      'Supabase non configuré — les clés API sont manquantes dans .env',
    );
  }

  // 4. Initialiser le service IA
  AiService.initialize();

  AppLogger.info('SORTIA v${Env.appVersion} — Démarrage en mode ${Env.appEnv}');

  // 4. Lancer l'application avec Riverpod
  runApp(
    const ProviderScope(
      child: SortiaApp(),
    ),
  );
}
