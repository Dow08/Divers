// ================================================================
// SORTIA — Modèle Paramètres / Profil utilisateur
// ================================================================

/// Préférences utilisateur
class UserPreferences {
  const UserPreferences({
    this.displayName,
    this.email,
    this.avatarUrl,
    this.plan = 'free',
    this.themeMode = AppThemeMode.system,
    this.language = 'fr',
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.autoClassify = true,
    this.defaultView = ViewMode.list,
    this.storageQuotaBytes = 1073741824, // 1 Go
    this.storageUsedBytes = 0,
  });

  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final String plan;
  final AppThemeMode themeMode;
  final String language;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool autoClassify;
  final ViewMode defaultView;
  final int storageQuotaBytes;
  final int storageUsedBytes;

  /// Label du plan
  String get planLabel => switch (plan) {
        'free' => 'Gratuit',
        'starter' => 'Starter',
        'pro' => 'Pro',
        'expert' => 'Expert',
        'business' => 'Business',
        _ => plan,
      };

  /// Emoji du plan
  String get planEmoji => switch (plan) {
        'free' => '🆓',
        'starter' => '⭐',
        'pro' => '💎',
        'expert' => '🏆',
        'business' => '🏢',
        _ => '📦',
      };

  /// Stockage formaté
  String get storageFormatted {
    final usedGo = storageUsedBytes / (1024 * 1024 * 1024);
    final quotaGo = storageQuotaBytes / (1024 * 1024 * 1024);
    return '${usedGo.toStringAsFixed(1)} / ${quotaGo.toStringAsFixed(0)} Go';
  }

  /// Taux d'utilisation
  double get storageRate =>
      storageQuotaBytes == 0 ? 0 : storageUsedBytes / storageQuotaBytes;

  UserPreferences copyWith({
    String? displayName,
    String? email,
    String? avatarUrl,
    String? plan,
    AppThemeMode? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? autoClassify,
    ViewMode? defaultView,
    int? storageQuotaBytes,
    int? storageUsedBytes,
  }) {
    return UserPreferences(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      plan: plan ?? this.plan,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      autoClassify: autoClassify ?? this.autoClassify,
      defaultView: defaultView ?? this.defaultView,
      storageQuotaBytes: storageQuotaBytes ?? this.storageQuotaBytes,
      storageUsedBytes: storageUsedBytes ?? this.storageUsedBytes,
    );
  }
}

/// Mode de thème
enum AppThemeMode {
  light('Clair', '☀️'),
  dark('Sombre', '🌙'),
  system('Système', '⚙️');

  const AppThemeMode(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// Mode d'affichage par défaut
enum ViewMode {
  list('Liste', '📋'),
  grid('Grille', '📊');

  const ViewMode(this.label, this.emoji);
  final String label;
  final String emoji;
}
