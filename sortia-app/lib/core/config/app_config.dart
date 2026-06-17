// ================================================================
// SORTIA — Configuration par environnement
// Gère les différentes configs: dev, staging, production
// ================================================================

/// Environnements disponibles pour l'application
enum AppEnvironment {
  /// Environnement de développement local
  development,

  /// Environnement de pré-production
  staging,

  /// Environnement de production
  production,
}

/// Configuration centralisée de l'application
///
/// Utilise le pattern singleton pour garantir une seule instance.
/// Initialisée au démarrage de l'application avec l'environnement cible.
class AppConfig {
  /// Crée une instance de configuration pour l'environnement donné
  AppConfig._({required this.environment});

  /// Instance singleton
  static AppConfig? _instance;

  /// Accès à l'instance singleton
  static AppConfig get instance {
    if (_instance == null) {
      throw StateError(
        'AppConfig non initialisé. Appeler AppConfig.initialize() au démarrage.',
      );
    }
    return _instance!;
  }

  /// Initialise la configuration pour l'environnement donné
  static void initialize(AppEnvironment env) {
    _instance = AppConfig._(environment: env);
  }

  /// Environnement actuel
  final AppEnvironment environment;

  /// Retourne `true` si on est en mode développement
  bool get isDevelopment => environment == AppEnvironment.development;

  /// Retourne `true` si on est en mode production
  bool get isProduction => environment == AppEnvironment.production;

  /// Retourne `true` si on est en mode staging
  bool get isStaging => environment == AppEnvironment.staging;

  /// Active les logs détaillés (dev + staging uniquement)
  bool get enableVerboseLogging => !isProduction;

  /// Active le certificate pinning (production uniquement)
  bool get enableCertificatePinning => isProduction;

  /// Active les vérifications d'intégrité de l'appareil
  bool get enableDeviceIntegrity => isProduction;

  /// Plans d'abonnement avec Price IDs Stripe
  static const Map<String, String> stripePriceIds = {
    'starter': 'price_starter_monthly',
    'pro': 'price_pro_monthly',
    'expert': 'price_expert_monthly',
    'business': 'price_business_monthly',
  };

  /// Tarifs mensuels (en euros)
  static const Map<String, double> planPrices = {
    'free': 0,
    'starter': 7.90,
    'pro': 14.90,
    'expert': 24.90,
    'business': 44.90,
  };
}
