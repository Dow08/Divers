// ================================================================
// SORTIA — Écran Signature électronique
// Demandes de signature (Yousign)
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sortia/features/signature/signature_module.dart';

class SignatureScreen extends ConsumerWidget {
  const SignatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = ref.watch(signatureAvailableProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Signature électronique'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
      ),
      body: !isAvailable
          ? _UnavailableState()
          : _AvailableState(),
      floatingActionButton: isAvailable
          ? FloatingActionButton.extended(
              onPressed: () {},
              backgroundColor: const Color(0xFF1B4F72),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.draw_outlined),
              label: const Text('Nouvelle signature'),
            )
          : null,
    );
  }
}

class _UnavailableState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9E7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.draw_outlined,
                  size: 48, color: Color(0xFFE67E22)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Signature non configurée',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configurez votre clé API Yousign\ndans les paramètres pour activer\nla signature électronique.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF566573)),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Configurer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailableState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Pour l'instant, état vide — les demandes seront chargées dynamiquement
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E44AD), Color(0xFFBB8FCE)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child:
                const Icon(Icons.draw_outlined, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune demande de signature',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Envoyez un document à signer\nà un ou plusieurs destinataires',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF566573)),
          ),
        ],
      ),
    );
  }
}
