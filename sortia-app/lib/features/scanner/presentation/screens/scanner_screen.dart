// ================================================================
// SORTIA — Écran Scanner (Caméra / Galerie)
// Capture une image puis lance le pipeline OCR + IA
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sortia/features/scanner/presentation/providers/scanner_providers.dart';
import 'package:sortia/features/scanner/presentation/screens/scan_result_screen.dart';

/// Écran de scan — choix caméra ou galerie, puis traitement
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    ref.read(scanProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);

    // Si traitement en cours ou terminé → afficher le résultat
    if (scanState.isProcessing || scanState.currentStep == ScanStep.done) {
      return const ScanResultScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Scanner un document'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Illustration
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B4F72), Color(0xFF2E86C1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1B4F72).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Scanner un document',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Prenez une photo ou choisissez une image\npour extraire le texte et le classer automatiquement.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF566573)),
              ),
              const SizedBox(height: 32),

              // Bouton Caméra
              _ScanButton(
                label: 'Prendre une photo',
                icon: Icons.camera_alt_outlined,
                color: const Color(0xFF1B4F72),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(height: 12),

              // Bouton Galerie
              _ScanButton(
                label: 'Choisir depuis la galerie',
                icon: Icons.photo_library_outlined,
                color: const Color(0xFF8E44AD),
                onTap: () => _pickImage(ImageSource.gallery),
              ),

              // Erreur
              if (scanState.error != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEDEC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE74C3C).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFE74C3C), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          scanState.error!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE74C3C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 90,
      );

      if (picked == null) return;

      ref.read(scanProvider.notifier).processImage(picked.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
