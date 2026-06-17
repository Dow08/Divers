// ================================================================
// SORTIA — Tests unitaires : Scanner OCR
// ================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/scanner/data/ocr_service.dart';
import 'package:sortia/features/scanner/presentation/providers/scanner_providers.dart';

void main() {
  group('OcrResult', () {
    test('empty a des valeurs zéro', () {
      expect(OcrResult.empty.fullText, '');
      expect(OcrResult.empty.blocks, isEmpty);
      expect(OcrResult.empty.confidence, 0);
      expect(OcrResult.empty.wordCount, 0);
    });

    test('isUsable false pour texte trop court', () {
      const result = OcrResult(
        fullText: 'abc',
        blocks: [],
        confidence: 0.9,
        language: 'fr',
        processingTimeMs: 100,
      );
      expect(result.isUsable, false);
    });

    test('isUsable false pour confiance trop basse', () {
      const result = OcrResult(
        fullText: 'Un texte suffisamment long pour être valide',
        blocks: [],
        confidence: 0.1,
        language: 'fr',
        processingTimeMs: 100,
      );
      expect(result.isUsable, false);
    });

    test('isUsable true pour texte long et haute confiance', () {
      const result = OcrResult(
        fullText: 'Un texte suffisamment long pour être valide',
        blocks: [],
        confidence: 0.8,
        language: 'fr',
        processingTimeMs: 100,
      );
      expect(result.isUsable, true);
    });

    test('wordCount compte les mots correctement', () {
      const result = OcrResult(
        fullText: 'Bonjour le monde de SORTIA',
        blocks: [],
        confidence: 0.9,
        language: 'fr',
        processingTimeMs: 50,
      );
      expect(result.wordCount, 5);
    });

    test('wordCount gère les espaces multiples', () {
      const result = OcrResult(
        fullText: '  Bonjour   le   monde  ',
        blocks: [],
        confidence: 0.9,
        language: 'fr',
        processingTimeMs: 50,
      );
      expect(result.wordCount, 3);
    });

    test('preview retourne max 3 lignes', () {
      const result = OcrResult(
        fullText: 'Ligne 1\nLigne 2\nLigne 3\nLigne 4\nLigne 5',
        blocks: [],
        confidence: 0.9,
        language: 'fr',
        processingTimeMs: 50,
      );
      expect(result.preview, 'Ligne 1\nLigne 2\nLigne 3');
    });

    test('preview ignore les lignes vides', () {
      const result = OcrResult(
        fullText: '\n\nLigne 1\n\nLigne 2',
        blocks: [],
        confidence: 0.9,
        language: 'fr',
        processingTimeMs: 50,
      );
      expect(result.preview, 'Ligne 1\nLigne 2');
    });
  });

  group('OcrBlock', () {
    test('constructeur basique fonctionne', () {
      const block = OcrBlock(
        text: 'Test block',
        confidence: 0.95,
        lines: ['Test', 'block'],
      );
      expect(block.text, 'Test block');
      expect(block.confidence, 0.95);
      expect(block.lines.length, 2);
    });
  });

  group('ScanState', () {
    test('état initial est idle', () {
      const state = ScanState();
      expect(state.hasImage, false);
      expect(state.hasOcrResult, false);
      expect(state.hasClassification, false);
      expect(state.isProcessing, false);
      expect(state.currentStep, ScanStep.idle);
    });

    test('hasImage true quand imagePath est set', () {
      const state = ScanState(imagePath: '/path/to/image.jpg');
      expect(state.hasImage, true);
    });

    test('isComplete requiert OCR et classification', () {
      const usableOcr = OcrResult(
        fullText: 'Un texte suffisamment long pour être valide',
        blocks: [],
        confidence: 0.8,
        language: 'fr',
        processingTimeMs: 100,
      );

      const stateOcrOnly = ScanState(ocrResult: usableOcr);
      expect(stateOcrOnly.isComplete, false);
    });

    test('copyWith modifie un champ', () {
      const state = ScanState();
      final updated = state.copyWith(isProcessing: true);
      expect(updated.isProcessing, true);
      expect(updated.currentStep, ScanStep.idle);
    });
  });

  group('ScanStep', () {
    test('chaque step a un label', () {
      for (final step in ScanStep.values) {
        expect(step.label, isNotEmpty);
      }
    });

    test('contient 6 étapes', () {
      expect(ScanStep.values.length, 6);
    });
  });
}
