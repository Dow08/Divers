// ================================================================
// SORTIA — Écran de connexion (avec Riverpod)
// Options: Google, Microsoft, Email/Password, Mode local
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
import 'package:sortia/shared/widgets/sortia_text_field.dart';

/// Écran de connexion principal
class LoginScreen extends ConsumerStatefulWidget {
  /// Crée l'écran de connexion
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await ref.read(authProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SortiaAuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated || next.isLocalMode) {
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                          boxShadow: AppDimensions.shadowMd,
                        ),
                        child: const Icon(
                          Icons.folder_special_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),
                      const Text(
                        'Bienvenue sur Sortia',
                        style: AppTypography.heading1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        'Votre secrétaire administrative intelligente',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.spacingXxl),

                      _OAuthButton(
                        label: 'Continuer avec Google',
                        icon: Icons.g_mobiledata_rounded,
                        color: const Color(0xFF4285F4),
                        onPressed: _isLoading
                            ? null
                            : () => ref
                                .read(authProvider.notifier)
                                .signInWithGoogle(),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      _OAuthButton(
                        label: 'Continuer avec Microsoft',
                        icon: Icons.window_rounded,
                        color: const Color(0xFF00A4EF),
                        onPressed: _isLoading
                            ? null
                            : () => ref
                                .read(authProvider.notifier)
                                .signInWithMicrosoft(),
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),

                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingMd,
                            ),
                            child: Text(
                              'ou',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),

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
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        enabled: !_isLoading,
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => context.push('/forgot-password'),
                          child: const Text('Mot de passe oublié ?'),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),

                      LoadingButton(
                        onPressed: _handleEmailSignIn,
                        label: 'Se connecter',
                        isLoading: _isLoading,
                        icon: Icons.login_rounded,
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      LoadingButton(
                        onPressed:
                            _isLoading ? null : () => context.push('/register'),
                        label: 'Créer un compte',
                        isOutlined: true,
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

class _OAuthButton extends StatelessWidget {
  const _OAuthButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 24),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
    );
  }
}
