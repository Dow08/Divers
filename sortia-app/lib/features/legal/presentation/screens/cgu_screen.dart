// ================================================================
// SORTIA — Écran des Conditions Générales d'Utilisation (CGU)
// Affichage des CGU et de la Politique de Confidentialité RGPD
// ================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sortia/app/theme/app_colors.dart';
import 'package:sortia/app/theme/app_dimensions.dart';
import 'package:sortia/app/theme/app_typography.dart';
import 'package:sortia/shared/widgets/loading_button.dart';

class CguScreen extends StatelessWidget {
  const CguScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conditions Générales d\'Utilisation & Politique de Confidentialité (RGPD)',
                      style: AppTypography.heading2,
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    const Text(
                      'Dernière mise à jour : Mars 2026',
                      style: TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXl),

                    _buildSection(
                      '1. Objet de l\'application',
                      'SORTIA est une application de gestion documentaire intelligente conçue pour organiser, stocker et classifier vos documents. L\'utilisation de ce service implique l\'acceptation pleine et entière des présentes conditions.',
                    ),
                    _buildSection(
                      '2. Données personnelles collectées (RGPD)',
                      'Conformément au Règlement Général sur la Protection des Données (RGPD), SORTIA collecte vos données pour le seul fonctionnement du service :\n'
                      '• Adresse email et identité : Pour la création et l\'authentification de votre compte.\n'
                      '• Documents stockés : Hébergés de manière sécurisée (Supabase).\n'
                      '• Données de facturation : Gérées de manière chiffrée par Stripe (si abonnement applicable).\n\n'
                      'Vos données ne sont jamais revendues ou exploitées à des fins publicitaires.',
                    ),
                    _buildSection(
                      '3. Intelligence Artificielle et Classification',
                      'Certains de vos documents (via le module Scanner) peuvent être traités par l\'IA de Google Gemini pour en extraire les textes et catégories. Ces données sont traitées de manière éphémère pour la classification et le nommage automatique et ne servent pas à entrainer les modèles de langage.',
                    ),
                    _buildSection(
                      '4. Droit d\'accès, de rectification et d\'oubli',
                      'Vous disposez d\'un droit total sur vos données. À tout moment, vous pouvez supprimer définitivement votre compte, ce qui entrainera la suppression irrévocable de vos documents et informations personnelles de nos serveurs.',
                    ),
                    _buildSection(
                      '5. Sécurité et Responsabilités',
                      'Les mots de passe sont hachés, et SORTIA s\'engage à appliquer les meilleures normes de sécurité. Cependant, en cas de fuite de vos identifiants par votre faute (ou attaque sur vos appareils), SORTIA ne saurait être tenu responsable du vol de vos documents.',
                    ),
                    const SizedBox(height: AppDimensions.spacingXl),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  onPressed: () => context.pop(),
                  label: 'J\'ai lu et compris',
                  icon: Icons.check_circle_outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.heading3.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            content,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
