// ================================================================
// SORTIA — Application principale
// MaterialApp avec providers, thème et routeur
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Widget racine de l'application Sortia
///
/// Configure le MaterialApp avec :
/// - GoRouter pour la navigation
/// - Thème clair et sombre
/// - Localisation française
class SortiaApp extends StatelessWidget {
  /// Crée le widget racine de l'application
  const SortiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sortia',
      debugShowCheckedModeBanner: false,

      // Thème
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Navigation
      routerConfig: appRouter,

      // Localisation
      locale: const Locale('fr', 'FR'),
    );
  }
}
