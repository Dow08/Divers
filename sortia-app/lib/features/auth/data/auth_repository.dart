// ================================================================
// SORTIA — Repository d'authentification
// Couche data — accès Supabase Auth
// ================================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/error/app_exception.dart' as app;
import '../../../core/utils/logger.dart';
import '../domain/models/user_model.dart';

/// Repository d'authentification
///
/// Encapsule tous les appels à Supabase Auth :
/// - Connexion email/mot de passe
/// - Inscription
/// - OAuth (Google, Microsoft)
/// - Réinitialisation du mot de passe
/// - Déconnexion
/// - Récupération du profil utilisateur
class AuthRepository {
  // ── Email / Mot de passe ──

  /// Connexion par email et mot de passe
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const app.AuthException(
          'Identifiants incorrects.',
          code: 'INVALID_CREDENTIALS',
        );
      }

      AppLogger.info('Auth: connexion email réussie — ${response.user!.id}');
      return _fetchUserProfile(response.user!.id);
    } on AuthApiException catch (e) {
      throw app.AuthException(
        _translateAuthError(e.message),
        code: e.statusCode,
      );
    }
  }

  /// Inscription par email et mot de passe
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        throw const app.AuthException(
          'Erreur lors de la création du compte.',
          code: 'SIGNUP_FAILED',
        );
      }

      AppLogger.info('Auth: inscription réussie — ${response.user!.id}');
      return _fetchUserProfile(response.user!.id);
    } on AuthApiException catch (e) {
      throw app.AuthException(
        _translateAuthError(e.message),
        code: e.statusCode,
      );
    }
  }

  // ── OAuth ──

  /// Connexion via Google OAuth2
  Future<void> signInWithGoogle() async {
    try {
      await SupabaseConfig.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'fr.sortia.app://login-callback',
      );
      AppLogger.info('Auth: redirection Google OAuth lancée');
    } on AuthApiException catch (e) {
      throw app.AuthException(
        'Erreur Google OAuth: ${e.message}',
        code: 'GOOGLE_OAUTH_ERROR',
      );
    }
  }

  /// Connexion via Microsoft (Azure AD) OAuth2
  Future<void> signInWithMicrosoft() async {
    try {
      await SupabaseConfig.auth.signInWithOAuth(
        OAuthProvider.azure,
        redirectTo: 'fr.sortia.app://login-callback',
        queryParams: {
          'tenant': 'common',
        },
      );
      AppLogger.info('Auth: redirection Microsoft OAuth lancée');
    } on AuthApiException catch (e) {
      throw app.AuthException(
        'Erreur Microsoft OAuth: ${e.message}',
        code: 'MICROSOFT_OAUTH_ERROR',
      );
    }
  }

  // ── Mot de passe oublié ──

  /// Envoie un email de réinitialisation du mot de passe
  Future<void> resetPassword({required String email}) async {
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(
        email,
        redirectTo: 'fr.sortia.app://reset-password',
      );
      AppLogger.info('Auth: email de réinitialisation envoyé à $email');
    } on AuthApiException catch (e) {
      throw app.AuthException(
        _translateAuthError(e.message),
        code: 'RESET_PASSWORD_ERROR',
      );
    }
  }

  // ── Session ──

  /// Vérifie si une session active existe
  Future<UserModel?> getCurrentUser() async {
    final user = SupabaseConfig.currentUser;
    if (user == null) return null;

    try {
      return await _fetchUserProfile(user.id);
    } catch (e) {
      AppLogger.warning('Auth: impossible de charger le profil — $e');
      return null;
    }
  }

  /// Déconnecte l'utilisateur
  Future<void> signOut() async {
    try {
      await SupabaseConfig.auth.signOut();
      AppLogger.info('Auth: déconnexion réussie');
    } on AuthApiException catch (e) {
      throw app.AuthException(
        'Erreur déconnexion: ${e.message}',
        code: 'SIGNOUT_ERROR',
      );
    }
  }

  /// Écoute les changements d'état d'authentification
  Stream<AuthChangeEvent> onAuthStateChange() {
    return SupabaseConfig.auth.onAuthStateChange.map((data) {
      return data.event;
    });
  }

  // ── Profil utilisateur ──

  /// Met à jour le profil utilisateur
  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
    String? templateChosen,
    bool? onboardingDone,
  }) async {
    final updates = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (templateChosen != null) 'template_chosen': templateChosen,
      if (onboardingDone != null) 'onboarding_done': onboardingDone,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await SupabaseConfig.client
          .from('user_profiles')
          .update(updates)
          .eq('id', userId);

      return _fetchUserProfile(userId);
    } catch (e) {
      throw app.AuthException(
        'Erreur mise à jour du profil: $e',
        code: 'PROFILE_UPDATE_ERROR',
      );
    }
  }

  // ── Méthodes privées ──

  /// Récupère le profil utilisateur depuis la table user_profiles
  Future<UserModel> _fetchUserProfile(String userId) async {
    try {
      final data = await SupabaseConfig.client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel(
        id: data['id'] as String,
        email: data['email'] as String,
        fullName: (data['full_name'] as String?) ?? '',
        avatarUrl: data['avatar_url'] as String?,
        plan: (data['plan'] as String?) ?? 'free',
        onboardingDone: (data['onboarding_done'] as bool?) ?? false,
        templateChosen: data['template_chosen'] as String?,
        locale: (data['locale'] as String?) ?? 'fr',
        timezone: (data['timezone'] as String?) ?? 'Europe/Paris',
        createdAt: data['created_at'] != null
            ? DateTime.tryParse(data['created_at'] as String)
            : null,
      );
    } catch (e) {
      throw app.AuthException(
        'Impossible de charger le profil utilisateur.',
        code: 'PROFILE_FETCH_ERROR',
      );
    }
  }

  /// Traduit les messages d'erreur Supabase en français
  String _translateAuthError(String message) {
    final translations = {
      'Invalid login credentials':
          'Identifiants incorrects. Vérifiez votre email et mot de passe.',
      'Email not confirmed':
          'Veuillez confirmer votre adresse email avant de vous connecter.',
      'User already registered':
          'Un compte existe déjà avec cette adresse email.',
      'Password should be at least 6 characters':
          'Le mot de passe doit contenir au moins 6 caractères.',
      'Signup requires a valid password':
          'Veuillez saisir un mot de passe valide.',
      'Email rate limit exceeded':
          'Trop de tentatives. Veuillez patienter quelques minutes.',
      'For security purposes, you can only request this after':
          'Pour des raisons de sécurité, veuillez patienter avant de réessayer.',
    };

    for (final entry in translations.entries) {
      if (message.contains(entry.key)) return entry.value;
    }

    return 'Erreur d\'authentification: $message';
  }
}
