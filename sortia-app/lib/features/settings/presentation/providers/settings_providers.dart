// ================================================================
// SORTIA — Providers Paramètres (Riverpod)
// ================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sortia/features/settings/domain/models/user_preferences.dart';

/// Provider des préférences utilisateur
final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier();
});

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier() : super(const UserPreferences()) {
    _loadFromAuth();
  }

  void _loadFromAuth() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      state = state.copyWith(
        email: user.email,
        displayName: user.userMetadata?['display_name'] as String?,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
      );
    }
  }

  void updateTheme(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void updateLanguage(String lang) {
    state = state.copyWith(language: lang);
  }

  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void toggleEmailNotifications(bool enabled) {
    state = state.copyWith(emailNotifications: enabled);
  }

  void toggleAutoClassify(bool enabled) {
    state = state.copyWith(autoClassify: enabled);
  }

  void updateDefaultView(ViewMode mode) {
    state = state.copyWith(defaultView: mode);
  }

  void updateDisplayName(String name) {
    state = state.copyWith(displayName: name);
  }

  /// Déconnexion
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = const UserPreferences();
  }
}
