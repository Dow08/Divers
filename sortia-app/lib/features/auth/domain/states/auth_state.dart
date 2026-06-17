// ================================================================
// SORTIA — État d'authentification
// ================================================================

import 'package:sortia/features/auth/domain/models/user_model.dart';

/// Types d'état d'authentification
enum SortiaAuthStatus {
  /// Vérification en cours (splash)
  initial,

  /// Utilisateur connecté
  authenticated,

  /// Utilisateur non connecté
  unauthenticated,

  /// Mode local sans compte cloud
  localMode,

  /// Erreur d'authentification
  error,
}

/// État de l'authentification dans l'application
class SortiaAuthState {
  /// Crée un état d'authentification
  const SortiaAuthState({
    this.status = SortiaAuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// État initial (vérification en cours)
  const SortiaAuthState.initial() : this(status: SortiaAuthStatus.initial);

  /// Utilisateur connecté
  SortiaAuthState.authenticated({required UserModel user})
      : this(status: SortiaAuthStatus.authenticated, user: user);

  /// Utilisateur non connecté
  const SortiaAuthState.unauthenticated()
      : this(status: SortiaAuthStatus.unauthenticated);

  /// Mode local (sans compte)
  const SortiaAuthState.localMode()
      : this(status: SortiaAuthStatus.localMode);

  /// Erreur d'authentification
  const SortiaAuthState.error({required String message})
      : this(status: SortiaAuthStatus.error, errorMessage: message);

  /// Statut actuel
  final SortiaAuthStatus status;

  /// Utilisateur connecté (null si non connecté)
  final UserModel? user;

  /// Message d'erreur (null si pas d'erreur)
  final String? errorMessage;

  /// Vérifie si l'utilisateur est connecté
  bool get isAuthenticated => status == SortiaAuthStatus.authenticated;

  /// Vérifie si on est en mode local
  bool get isLocalMode => status == SortiaAuthStatus.localMode;

  /// Vérifie s'il y a une erreur
  bool get hasError => status == SortiaAuthStatus.error;

  /// Vérifie si on est en chargement (initial)
  bool get isLoading => status == SortiaAuthStatus.initial;

  @override
  String toString() => 'SortiaAuthState(status: $status, user: $user)';
}
