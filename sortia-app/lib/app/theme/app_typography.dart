// ================================================================
// SORTIA — Typographie
// Hiérarchie de textes avec la police Inter
// ================================================================

import 'package:flutter/material.dart';

/// Styles typographiques de Sortia
///
/// Utilise la police Inter (Google Fonts, open source)
/// pour une lisibilité optimale sur tous les écrans.
abstract final class AppTypography {
  /// Nom de la police principale
  static const String fontFamily = 'Inter';

  /// Titre principal de page (H1)
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.5,
  );

  /// Titre de section (H2)
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  /// Sous-titre (H3)
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Texte de corps principal
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Texte de corps secondaire
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Petit texte (légendes, horodatage)
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Label de bouton
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// Label de champ de formulaire
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.3,
  );

  /// Texte monospace (pour les codes, hachages, etc.)
  static const TextStyle mono = TextStyle(
    fontFamily: 'Courier New',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}
