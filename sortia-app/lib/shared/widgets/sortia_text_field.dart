// ================================================================
// SORTIA — Widget champ de texte Sortia
// ================================================================

import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';

/// Champ de texte personnalisé avec validation intégrée
class SortiaTextField extends StatelessWidget {
  /// Crée un champ de texte Sortia
  const SortiaTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.textInputAction,
    this.autofillHints,
    this.enabled = true,
  });

  /// Contrôleur du champ
  final TextEditingController controller;

  /// Label du champ
  final String label;

  /// Icône préfixe
  final IconData? prefixIcon;

  /// Masquer le texte (mot de passe)
  final bool obscureText;

  /// Type de clavier
  final TextInputType? keyboardType;

  /// Fonction de validation
  final String? Function(String?)? validator;

  /// Callback lors de changement
  final ValueChanged<String>? onChanged;

  /// Widget suffixe (ex: toggle visibilité)
  final Widget? suffixIcon;

  /// Action du clavier
  final TextInputAction? textInputAction;

  /// Indices de remplissage automatique
  final Iterable<String>? autofillHints;

  /// Champ activé ou désactivé
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon,
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        enabled: enabled,
      ),
    );
  }
}
