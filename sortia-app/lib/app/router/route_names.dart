// ================================================================
// SORTIA — Constantes de nommage des routes
// ================================================================

/// Noms des routes de l'application
///
/// Utilisés comme référence unique pour chaque écran.
/// Ne jamais utiliser de chaînes en dur pour la navigation.
abstract final class RouteNames {
  // ── Auth ──
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String cgu = 'cgu';

  // ── Onboarding ──
  static const String welcome = 'welcome';
  static const String templateSelection = 'template-selection';
  static const String folderDescription = 'folder-description';
  static const String onboardingComplete = 'onboarding-complete';

  // ── Explorateur (coeur de l'app) ──
  static const String explorer = 'explorer';
  static const String filePreview = 'file-preview';

  // ── Fonctionnalités ──
  static const String search = 'search';
  static const String scanner = 'scanner';
  static const String notes = 'notes';
  static const String noteEditor = 'note-editor';
  static const String mail = 'mail';
  static const String mailList = 'mail-list';
  static const String alerts = 'alerts';
  static const String versionHistory = 'version-history';
  static const String sharing = 'sharing';
  static const String dashboard = 'dashboard';
  static const String workflow = 'workflow';
  static const String signature = 'signature';
  static const String vault = 'vault';
  static const String importScreen = 'import';
  static const String conformite = 'conformite';
  static const String diagnostic = 'diagnostic';
  static const String archive = 'archive';

  // ── Paramètres ──
  static const String settings = 'settings';
  static const String securitySettings = 'security-settings';
  static const String subscription = 'subscription';
  static const String about = 'about';
}
