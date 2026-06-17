// ================================================================
// SORTIA — Providers Scanner (Riverpod)
// ================================================================

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sortia/features/scanner/data/ocr_service.dart';
import 'package:sortia/features/ai/data/ai_service.dart';
import 'package:sortia/features/ai/domain/classification_types.dart';

/// Provider du service OCR
final ocrServiceProvider = Provider<OcrService>((ref) {
  return OcrService.instance..initialize();
});

/// État du scan en cours
class ScanState {
  const ScanState({
    this.imagePath,
    this.ocrResult,
    this.classification,
    this.isProcessing = false,
    this.currentStep = ScanStep.idle,
    this.error,
  });

  final String? imagePath;
  final OcrResult? ocrResult;
  final AiClassificationResult? classification;
  final bool isProcessing;
  final ScanStep currentStep;
  final String? error;

  bool get hasImage => imagePath != null;
  bool get hasOcrResult => ocrResult != null && ocrResult!.isUsable;
  bool get hasClassification => classification != null;
  bool get isComplete => hasOcrResult && hasClassification;

  ScanState copyWith({
    String? imagePath,
    OcrResult? ocrResult,
    AiClassificationResult? classification,
    bool? isProcessing,
    ScanStep? currentStep,
    String? error,
  }) {
    return ScanState(
      imagePath: imagePath ?? this.imagePath,
      ocrResult: ocrResult ?? this.ocrResult,
      classification: classification ?? this.classification,
      isProcessing: isProcessing ?? this.isProcessing,
      currentStep: currentStep ?? this.currentStep,
      error: error,
    );
  }
}

/// Étapes du pipeline de scan
enum ScanStep {
  idle('En attente'),
  capturing('Capture...'),
  ocr('Extraction OCR...'),
  classifying('Classification IA...'),
  done('Terminé'),
  error('Erreur');

  const ScanStep(this.label);
  final String label;
}

/// Notifier principal du scanner
final scanProvider =
    StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(ref);
});

class ScanNotifier extends StateNotifier<ScanState> {
  ScanNotifier(this._ref) : super(const ScanState());

  final Ref _ref;

  /// Reset le state
  void reset() => state = const ScanState();

  /// Pipeline complet : Image → OCR → Classification IA
  Future<void> processImage(String imagePath) async {
    state = ScanState(
      imagePath: imagePath,
      isProcessing: true,
      currentStep: ScanStep.ocr,
    );

    try {
      // ── Étape 1 : OCR ────────────────────────────
      final ocr = _ref.read(ocrServiceProvider);
      final ocrResult = await ocr.extractTextFromPath(imagePath);

      state = state.copyWith(
        ocrResult: ocrResult,
        currentStep: ScanStep.classifying,
      );

      if (!ocrResult.isUsable) {
        // Pas assez de texte → tenter classification par image
        final imageBytes = await File(imagePath).readAsBytes();
        final classification = await AiService.classifyFromImage(
          imageBytes,
          'image/${imagePath.split('.').last}',
        );

        state = state.copyWith(
          classification: classification,
          isProcessing: false,
          currentStep: ScanStep.done,
        );
        return;
      }

      // ── Étape 2 : Classification IA du texte ─────
      final classification =
          await AiService.classifyFromText(ocrResult.fullText);

      state = state.copyWith(
        classification: classification,
        isProcessing: false,
        currentStep: ScanStep.done,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        currentStep: ScanStep.error,
        error: e.toString(),
      );
    }
  }
}
