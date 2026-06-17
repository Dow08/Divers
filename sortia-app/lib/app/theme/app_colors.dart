// ================================================================
// SORTIA — Palette de couleurs
// Couleurs de la marque Sortia
// ================================================================

import 'package:flutter/material.dart';

/// Palette de couleurs de Sortia
///
/// Couleurs soigneusement choisies pour une interface professionnelle
/// mais chaleureuse, adaptée aux TPE/PME françaises.
abstract final class AppColors {
  // ── Couleurs principales ──
  /// Bleu professionnel principal
  static const Color primary = Color(0xFF1B4F72);

  /// Bleu clair pour les accents
  static const Color primaryLight = Color(0xFF2E86C1);

  /// Bleu très clair pour les fonds
  static const Color primarySurface = Color(0xFFEBF5FB);

  // ── Couleurs secondaires ──
  /// Vert succès / validation
  static const Color success = Color(0xFF27AE60);

  /// Orange avertissement
  static const Color warning = Color(0xFFF39C12);

  /// Rouge erreur / danger
  static const Color error = Color(0xFFE74C3C);

  /// Bleu info
  static const Color info = Color(0xFF3498DB);

  // ── Surfaces et fonds ──
  /// Fond principal (clair)
  static const Color backgroundLight = Color(0xFFF8F9FA);

  /// Fond principal (sombre)
  static const Color backgroundDark = Color(0xFF1A1A2E);

  /// Surface carte (clair)
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Surface carte (sombre)
  static const Color surfaceDark = Color(0xFF16213E);

  // ── Texte ──
  /// Texte principal (clair)
  static const Color textPrimaryLight = Color(0xFF2C3E50);

  /// Texte secondaire (clair)
  static const Color textSecondaryLight = Color(0xFF7F8C8D);

  /// Texte principal (sombre)
  static const Color textPrimaryDark = Color(0xFFECF0F1);

  /// Texte secondaire (sombre)
  static const Color textSecondaryDark = Color(0xFFBDC3C7);

  // ── Catégories de documents ──
  /// Facture
  static const Color categoryInvoice = Color(0xFF3498DB);

  /// Contrat
  static const Color categoryContract = Color(0xFF9B59B6);

  /// Administratif
  static const Color categoryAdmin = Color(0xFF1ABC9C);

  /// RH / Paie
  static const Color categoryHR = Color(0xFFE67E22);

  /// Fiscal
  static const Color categoryFiscal = Color(0xFFE74C3C);

  /// Bancaire
  static const Color categoryBank = Color(0xFF2ECC71);
}
