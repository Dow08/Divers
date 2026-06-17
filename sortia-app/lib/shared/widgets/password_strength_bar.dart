// ================================================================
// SORTIA — Widget barre de force du mot de passe
// ================================================================

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_typography.dart';
import '../utils/form_validators.dart';

/// Barre visuelle de force du mot de passe
///
/// Affiche une barre de progression colorée avec un label
/// indiquant la force du mot de passe (Très faible → Très fort).
class PasswordStrengthBar extends StatelessWidget {
  /// Crée la barre de force
  const PasswordStrengthBar({super.key, required this.password});

  /// Mot de passe à évaluer
  final String password;

  @override
  Widget build(BuildContext context) {
    final strength = FormValidators.passwordStrength(password);
    final label = FormValidators.passwordStrengthLabel(strength);

    Color barColor;
    if (strength < 0.3) {
      barColor = AppColors.error;
    } else if (strength < 0.5) {
      barColor = AppColors.warning;
    } else if (strength < 0.7) {
      barColor = const Color(0xFFF1C40F);
    } else {
      barColor = AppColors.success;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimensions.spacingXs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
          child: LinearProgressIndicator(
            value: strength,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXxs),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(color: barColor),
        ),
      ],
    );
  }
}
