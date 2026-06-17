// ================================================================
// SORTIA — Écran mot de passe oublié (avec Riverpod)
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sortia/app/theme/app_colors.dart';
import 'package:sortia/app/theme/app_dimensions.dart';
import 'package:sortia/app/theme/app_typography.dart';
import 'package:sortia/features/auth/presentation/providers/auth_providers.dart';
import 'package:sortia/shared/utils/form_validators.dart';
import 'package:sortia/shared/widgets/loading_button.dart';
import 'package:sortia/shared/widgets/sortia_text_field.dart';

/// Écran de réinitialisation du mot de passe
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// Crée l'écran de mot de passe oublié
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).resetPassword(
          email: _emailController.text.trim(),
        );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _emailSent = success;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email de réinitialisation envoyé ! Vérifiez votre boîte.',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
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
              child: _emailSent ? _buildSuccessView() : _buildFormView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Icon(
            Icons.lock_reset_rounded,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          const Text(
            'Réinitialiser votre mot de passe',
            style: AppTypography.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Entrez votre adresse email. Nous vous enverrons '
            'un lien de réinitialisation.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXl),
          SortiaTextField(
            controller: _emailController,
            label: 'Adresse email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: FormValidators.validateEmail,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          LoadingButton(
            onPressed: _handleResetPassword,
            label: 'Envoyer le lien',
            isLoading: _isLoading,
            icon: Icons.send_rounded,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          TextButton(
            onPressed: _isLoading ? null : () => context.pop(),
            child: const Text('Retour à la connexion'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        const Text(
          'Email envoyé !',
          style: AppTypography.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          'Vérifiez votre boîte de réception à\n'
          '${_emailController.text.trim()}\n\n'
          'Cliquez sur le lien dans l\'email pour '
          'réinitialiser votre mot de passe.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        LoadingButton(
          onPressed: () => context.go('/login'),
          label: 'Retour à la connexion',
          icon: Icons.arrow_back,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: const Text('Renvoyer l\'email'),
        ),
      ],
    );
  }
}
