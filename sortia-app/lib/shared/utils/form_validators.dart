// ================================================================
// SORTIA — Validateurs de formulaires
// ================================================================

/// Validateurs de champs de formulaires réutilisables
abstract final class FormValidators {
  /// Valide une adresse email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'adresse email est requise.';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Veuillez saisir une adresse email valide.';
    }

    return null;
  }

  /// Valide un mot de passe
  ///
  /// Critères :
  /// - Minimum 8 caractères
  /// - Au moins une majuscule
  /// - Au moins un chiffre
  /// - Au moins un caractère spécial
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis.';
    }

    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins une majuscule.';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Le mot de passe doit contenir au moins un chiffre.';
    }

    if (!RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:,\.<>\?/\\|`~]')
        .hasMatch(value)) {
      return 'Le mot de passe doit contenir un caractère spécial.';
    }

    return null;
  }

  /// Valide la confirmation de mot de passe
  static String? validatePasswordConfirm(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe.';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas.';
    }

    return null;
  }

  /// Valide un nom complet
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est requis.';
    }

    if (value.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères.';
    }

    return null;
  }

  /// Valide un code PIN à 6 chiffres
  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le code PIN est requis.';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Le code PIN doit contenir exactement 6 chiffres.';
    }

    return null;
  }

  /// Calcule la force d'un mot de passe (0.0 à 1.0)
  static double passwordStrength(String password) {
    if (password.isEmpty) return 0;

    var score = 0.0;

    // Longueur
    if (password.length >= 8) score += 0.2;
    if (password.length >= 12) score += 0.1;
    if (password.length >= 16) score += 0.1;

    // Complexité
    if (RegExp(r'[a-z]').hasMatch(password)) score += 0.1;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.15;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.15;
    if (RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:,\.<>\?/\\|`~]')
        .hasMatch(password)) {
      score += 0.2;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Label de force du mot de passe en français
  static String passwordStrengthLabel(double strength) {
    if (strength < 0.3) return 'Très faible';
    if (strength < 0.5) return 'Faible';
    if (strength < 0.7) return 'Moyen';
    if (strength < 0.9) return 'Fort';
    return 'Très fort';
  }
}
