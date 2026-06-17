// ================================================================
// SORTIA — Providers d'authentification (Riverpod)
// ================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sortia/core/utils/logger.dart';
import 'package:sortia/features/auth/data/auth_repository.dart';
import 'package:sortia/features/auth/domain/models/user_model.dart';
import 'package:sortia/features/auth/domain/states/auth_state.dart';

/// Provider du repository d'authentification
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider de l'état d'authentification (Notifier)
final authProvider =
    StateNotifierProvider<AuthNotifier, SortiaAuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Provider du profil utilisateur courant (dérivé)
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

/// Provider vérifiant si l'utilisateur est connecté
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// Provider du plan actuel
final currentPlanProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.plan ?? 'free';
});

/// Notifier d'authentification
class AuthNotifier extends StateNotifier<SortiaAuthState> {
  /// Crée le notifier avec l'état initial
  AuthNotifier(this._repository)
      : super(const SortiaAuthState.initial());

  final AuthRepository _repository;

  /// Vérifie si une session existe au démarrage
  Future<void> checkSession() async {
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = SortiaAuthState.authenticated(user: user);
        AppLogger.info('Auth: session existante restaurée');
      } else {
        state = const SortiaAuthState.unauthenticated();
      }
    } catch (e) {
      state = const SortiaAuthState.unauthenticated();
    }
  }

  /// Connexion par email/mot de passe
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const SortiaAuthState.initial();
    try {
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      state = SortiaAuthState.authenticated(user: user);
    } catch (e) {
      state = SortiaAuthState.error(message: e.toString());
    }
  }

  /// Inscription par email/mot de passe
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const SortiaAuthState.initial();
    try {
      final user = await _repository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      state = SortiaAuthState.authenticated(user: user);
    } catch (e) {
      state = SortiaAuthState.error(message: e.toString());
    }
  }

  /// Connexion Google
  Future<void> signInWithGoogle() async {
    state = const SortiaAuthState.initial();
    try {
      await _repository.signInWithGoogle();
    } catch (e) {
      state = SortiaAuthState.error(message: e.toString());
    }
  }

  /// Connexion Microsoft
  Future<void> signInWithMicrosoft() async {
    state = const SortiaAuthState.initial();
    try {
      await _repository.signInWithMicrosoft();
    } catch (e) {
      state = SortiaAuthState.error(message: e.toString());
    }
  }

  /// Réinitialisation du mot de passe
  Future<bool> resetPassword({required String email}) async {
    try {
      await _repository.resetPassword(email: email);
      return true;
    } catch (e) {
      state = SortiaAuthState.error(message: e.toString());
      return false;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      await _repository.signOut();
      state = const SortiaAuthState.unauthenticated();
    } catch (e) {
      state = SortiaAuthState.error(message: e.toString());
    }
  }

  /// Met à jour le profil utilisateur
  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? templateChosen,
    bool? onboardingDone,
  }) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    try {
      final updated = await _repository.updateProfile(
        userId: currentUser.id,
        fullName: fullName,
        avatarUrl: avatarUrl,
        templateChosen: templateChosen,
        onboardingDone: onboardingDone,
      );
      state = SortiaAuthState.authenticated(user: updated);
    } catch (e) {
      AppLogger.error('Auth: erreur mise à jour profil', e);
    }
  }
}
