// ================================================================
// SORTIA — Dimensions et espacements
// Spacing, radius, shadows standardisés
// ================================================================

import 'package:flutter/material.dart';

/// Dimensions et espacements standardisés de Sortia
///
/// Garantit une cohérence visuelle parfaite dans toute l'application.
abstract final class AppDimensions {
  // ── Spacing ──
  /// 4px
  static const double spacingXxs = 4;

  /// 8px
  static const double spacingXs = 8;

  /// 12px
  static const double spacingSm = 12;

  /// 16px
  static const double spacingMd = 16;

  /// 24px
  static const double spacingLg = 24;

  /// 32px
  static const double spacingXl = 32;

  /// 48px
  static const double spacingXxl = 48;

  /// 64px
  static const double spacingXxxl = 64;

  // ── Border Radius ──
  /// 4px
  static const double radiusXs = 4;

  /// 8px
  static const double radiusSm = 8;

  /// 12px
  static const double radiusMd = 12;

  /// 16px
  static const double radiusLg = 16;

  /// 24px
  static const double radiusXl = 24;

  /// Complètement arrondi
  static const double radiusFull = 999;

  // ── Shadows ──
  /// Ombre légère (cards)
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Ombre moyenne (cards surélevées)
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Ombre forte (modals, popovers)
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // ── Tailles d'icônes ──
  /// 16px
  static const double iconSm = 16;

  /// 20px
  static const double iconMd = 20;

  /// 24px (taille par défaut Material)
  static const double iconLg = 24;

  /// 32px
  static const double iconXl = 32;

  /// 48px
  static const double iconXxl = 48;

  // ── Hauteurs de composants ──
  /// Hauteur d'un bouton standard
  static const double buttonHeight = 48;

  /// Hauteur d'un champ de texte
  static const double inputHeight = 48;

  /// Hauteur de la barre de navigation
  static const double navBarHeight = 64;

  /// Largeur maximale du contenu (desktop)
  static const double maxContentWidth = 1200;

  /// Largeur de la sidebar (desktop)
  static const double sidebarWidth = 280;
}
