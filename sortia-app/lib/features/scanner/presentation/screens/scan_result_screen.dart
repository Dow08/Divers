// ================================================================
// SORTIA — Écran Résultat de Scan
// Affiche le texte OCR, la classification IA, et actions
// ================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sortia/features/scanner/presentation/providers/scanner_providers.dart';

/// Écran de résultat après scan OCR + classification IA
class ScanResultScreen extends ConsumerWidget {
  const ScanResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Résultat du scan'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(scanProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: scanState.isProcessing
          ? _ProcessingView(step: scanState.currentStep)
          : _ResultView(scanState: scanState),
    );
  }
}

// ── Vue de traitement (loading) ──────────────────────────────
class _ProcessingView extends StatelessWidget {
  const _ProcessingView({required this.step});
  final ScanStep step;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF1B4F72),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            step.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _stepDescription(step),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF566573)),
          ),
          const SizedBox(height: 32),
          // Barre de progression
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: _StepProgress(currentStep: step),
          ),
        ],
      ),
    );
  }

  String _stepDescription(ScanStep step) {
    return switch (step) {
      ScanStep.ocr => 'Extraction du texte avec Google ML Kit...',
      ScanStep.classifying => 'Classification du document par l\'IA Gemini...',
      _ => 'Traitement en cours...',
    };
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.currentStep});
  final ScanStep currentStep;

  @override
  Widget build(BuildContext context) {
    final steps = [ScanStep.ocr, ScanStep.classifying, ScanStep.done];
    final currentIndex = steps.indexOf(currentStep).clamp(0, steps.length - 1);

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connecteur
          final stepIndex = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: stepIndex < currentIndex
                  ? const Color(0xFF17A589)
                  : const Color(0xFFD5D8DC),
            ),
          );
        }
        // Cercle
        final stepIndex = i ~/ 2;
        final isActive = stepIndex <= currentIndex;
        final isCurrent = stepIndex == currentIndex;
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF17A589) : const Color(0xFFD5D8DC),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCurrent && currentStep != ScanStep.done
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isActive ? Icons.check : Icons.circle,
                    size: 14,
                    color: Colors.white,
                  ),
          ),
        );
      }),
    );
  }
}

// ── Vue résultat ─────────────────────────────────────────────
class _ResultView extends StatelessWidget {
  const _ResultView({required this.scanState});
  final ScanState scanState;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Image scannée
        if (scanState.imagePath != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(scanState.imagePath!),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Classification IA
        if (scanState.hasClassification) ...[
          _ClassificationCard(classification: scanState.classification!),
          const SizedBox(height: 16),
        ],

        // Texte OCR extrait
        if (scanState.hasOcrResult) ...[
          _OcrTextCard(ocrResult: scanState.ocrResult!),
          const SizedBox(height: 16),
        ],

        // Statistiques
        if (scanState.ocrResult != null) ...[
          _StatsRow(ocrResult: scanState.ocrResult!),
          const SizedBox(height: 16),
        ],

        // Actions
        _ActionsRow(scanState: scanState),
      ],
    );
  }
}

// ── Carte Classification IA ──────────────────────────────────
class _ClassificationCard extends StatelessWidget {
  const _ClassificationCard({required this.classification});
  final dynamic classification; // AiClassificationResult

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4F72), Color(0xFF2E86C1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4F72).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFFF8C471), size: 18),
              SizedBox(width: 8),
              Text(
                'Classification IA',
                style: TextStyle(
                  color: Color(0xFFAED6F1),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${classification.category.emoji} ${classification.category.label}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(classification.confidence * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (classification.summary != null &&
              classification.summary!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              classification.summary!,
              style: const TextStyle(
                color: Color(0xFFAED6F1),
                fontSize: 12,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (classification.vendorName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.business, color: Color(0xFFAED6F1), size: 14),
                const SizedBox(width: 6),
                Text(
                  classification.vendorName!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (classification.amount != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.euro, color: Color(0xFFAED6F1), size: 14),
                const SizedBox(width: 6),
                Text(
                  '${classification.amount!.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Carte Texte OCR ──────────────────────────────────────────
class _OcrTextCard extends StatelessWidget {
  const _OcrTextCard({required this.ocrResult});
  final dynamic ocrResult; // OcrResult

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.text_fields, color: Color(0xFF2E86C1), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Texte extrait (OCR)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copier le texte',
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: ocrResult.fullText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Texte copié dans le presse-papier'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEBEEF0)),
            ),
            child: SelectableText(
              ocrResult.fullText,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2C3E50),
                height: 1.5,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats du scan ────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.ocrResult});
  final dynamic ocrResult; // OcrResult

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.text_snippet_outlined,
          label: '${ocrResult.wordCount} mots',
          color: const Color(0xFF2E86C1),
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.speed_outlined,
          label: '${ocrResult.processingTimeMs} ms',
          color: const Color(0xFF17A589),
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.verified_outlined,
          label: '${(ocrResult.confidence * 100).round()}% confiance',
          color: const Color(0xFF8E44AD),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Actions ──────────────────────────────────────────────────
class _ActionsRow extends ConsumerWidget {
  const _ActionsRow({required this.scanState});
  final ScanState scanState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Sauvegarder
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: scanState.hasClassification ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF17A589),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.save_outlined),
            label: const Text(
              'Enregistrer et classer',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Nouveau scan
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(scanProvider.notifier).reset();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Nouveau scan', style: TextStyle(fontSize: 13)),
              ),
            ),
            const SizedBox(width: 10),
            // Partager
            Expanded(
              child: OutlinedButton.icon(
                onPressed: scanState.hasOcrResult ? () {} : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.share_outlined, size: 18),
                label:
                    const Text('Partager', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
