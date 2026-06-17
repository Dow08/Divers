// ================================================================
// SORTIA — Modèle utilisateur (sans Freezed)
// ================================================================

/// Modèle utilisateur de Sortia
///
/// Représente un utilisateur avec ses données de profil,
/// son plan d'abonnement, et ses préférences.
class UserModel {
  /// Crée un modèle utilisateur
  const UserModel({
    required this.id,
    required this.email,
    this.fullName = '',
    this.avatarUrl,
    this.plan = 'free',
    this.onboardingDone = false,
    this.templateChosen,
    this.locale = 'fr',
    this.timezone = 'Europe/Paris',
    this.createdAt,
  });

  /// Crée un UserModel depuis un Map JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: (json['full_name'] as String?) ?? '',
      avatarUrl: json['avatar_url'] as String?,
      plan: (json['plan'] as String?) ?? 'free',
      onboardingDone: (json['onboarding_done'] as bool?) ?? false,
      templateChosen: json['template_chosen'] as String?,
      locale: (json['locale'] as String?) ?? 'fr',
      timezone: (json['timezone'] as String?) ?? 'Europe/Paris',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Identifiant unique (UUID Supabase)
  final String id;

  /// Adresse email
  final String email;

  /// Nom complet
  final String fullName;

  /// URL de l'avatar
  final String? avatarUrl;

  /// Plan d'abonnement actif
  final String plan;

  /// Onboarding terminé
  final bool onboardingDone;

  /// Template choisi lors de l'onboarding
  final String? templateChosen;

  /// Locale (langue)
  final String locale;

  /// Fuseau horaire
  final String timezone;

  /// Date de création
  final DateTime? createdAt;

  /// Crée une copie avec des valeurs modifiées
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? plan,
    bool? onboardingDone,
    String? templateChosen,
    String? locale,
    String? timezone,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      plan: plan ?? this.plan,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      templateChosen: templateChosen ?? this.templateChosen,
      locale: locale ?? this.locale,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Sérialise en Map JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'plan': plan,
      'onboarding_done': onboardingDone,
      'template_chosen': templateChosen,
      'locale': locale,
      'timezone': timezone,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'UserModel(id: $id, email: $email, plan: $plan)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && other.id == id && other.email == email;

  @override
  int get hashCode => Object.hash(id, email);
}
