// ================================================================
// SORTIA — Écran d'inscription (avec Riverpod)
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sortia/app/theme/app_colors.dart';
import 'package:sortia/app/theme/app_dimensions.dart';
import 'package:sortia/app/theme/app_typography.dart';
import 'package:sortia/features/auth/domain/states/auth_state.dart';
import 'package:sortia/features/auth/presentation/providers/auth_providers.dart';
import 'package:sortia/shared/utils/form_validators.dart';
import 'package:sortia/shared/widgets/loading_button.dart';
import 'package:sortia/shared/widgets/password_strength_bar.dart';
import 'package:sortia/shared/widgets/sortia_text_field.dart';

/// Écran de création de compte
class RegisterScreen extends ConsumerStatefulWidget {
  /// Crée l'écran d'inscription
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptedTerms = false;
  String _password = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    await ref.read(authProvider.notifier).signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
        );

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SortiaAuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/explorer');
      } else if (next.hasError && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    children: [
                      const Text(
                        'Créer votre compte Sortia',
                        style: AppTypography.heading2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        'Commencez à organiser vos documents intelligemment',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.spacingXl),

                      SortiaTextField(
                        controller: _nameController,
                        label: 'Nom complet',
                        prefixIcon: Icons.person_outline,
                        validator: FormValidators.validateFullName,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        enabled: !_isLoading,
                      ),
                      SortiaTextField(
                        controller: _emailController,
                        label: 'Adresse email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: FormValidators.validateEmail,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        enabled: !_isLoading,
                      ),
                      SortiaTextField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        prefixIcon: Icons.lock_outline,
                        obscureText: !_isPasswordVisible,
                        validator: FormValidators.validatePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        enabled: !_isLoading,
                        onChanged: (value) =>
                            setState(() => _password = value),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      if (_password.isNotEmpty)
                        PasswordStrengthBar(password: _password),
                      const SizedBox(height: AppDimensions.spacingSm),

                      SortiaTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmer le mot de passe',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        enabled: !_isLoading,
                        validator: (value) =>
                            FormValidators.validatePasswordConfirm(
                          value,
                          _passwordController.text,
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _acceptedTerms = value ?? false;
                                    });
                                  },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.push('/cgu'),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'J\'accepte les ',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'conditions générales d\'utilisation',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' et la ',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'politique de confidentialité',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '.',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),

                      LoadingButton(
                        onPressed: _handleSignUp,
                        label: 'Créer mon compte',
                        isLoading: _isLoading,
                        icon: Icons.person_add_outlined,
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      TextButton(
                        onPressed: _isLoading ? null : () => context.pop(),
                        child: const Text('Déjà un compte ? Se connecter'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
