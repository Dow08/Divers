// ================================================================
// SORTIA — Route Guards
// Protège les routes selon l'état d'authentification
// ================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/supabase_config.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import 'route_names.dart';

/// Guards de navigation pour l'application
///
/// Vérifie l'authentification et l'état de l'onboarding
/// avant d'autoriser l'accès aux routes protégées.
abstract final class RouteGuards {
  /// Redirige vers le login si l'utilisateur n'est pas connecté,
  /// ou vers l'onboarding si c'est sa première visite.
  static String? authGuard(
    BuildContext context,
    GoRouterState state,
  ) {
    final user = SupabaseConfig.currentUser;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/forgot-password';

    // Si pas connecté et pas sur une page d'auth → rediriger vers login
    if (user == null && !isAuthRoute) {
      return '/login';
    }

    // Si connecté et sur une page d'auth → rediriger vers l'explorateur
    if (user != null && isAuthRoute) {
      return '/explorer';
    }

    // Pas de redirection nécessaire
    return null;
  }
}
