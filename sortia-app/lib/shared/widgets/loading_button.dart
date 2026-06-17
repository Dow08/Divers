// ================================================================
// SORTIA — Widget bouton de chargement
// ================================================================

import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';

/// Bouton avec indicateur de chargement intégré
class LoadingButton extends StatelessWidget {
  /// Crée un bouton de chargement
  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
  });

  /// Action du bouton
  final VoidCallback? onPressed;

  /// Texte du bouton
  final String label;

  /// Afficher l'indicateur de chargement
  final bool isLoading;

  /// Icône optionnelle
  final IconData? icon;

  /// Style outlined au lieu de filled
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AppDimensions.spacingXs),
              ],
              Text(label),
            ],
          );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: child,
    );
  }
}
