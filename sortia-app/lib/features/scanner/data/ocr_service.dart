// ================================================================
// SORTIA — Service OCR (Google ML Kit Text Recognition)
// Extraction de texte depuis images (caméra/galerie)
// ================================================================

import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:sortia/core/utils/logger.dart';

/// Résultat d'une extraction OCR
class OcrResult {
  const OcrResult({
    required this.fullText,
    required this.blocks,
    required this.confidence,
    required this.language,
    required this.processingTimeMs,
  });

  /// Texte complet extrait
  final String fullText;

  /// Blocs de texte structurés
  final List<OcrBlock> blocks;

  /// Confiance moyenne (0.0 — 1.0)
  final double confidence;

  /// Langue détectée
  final String language;

  /// Temps de traitement en ms
  final int processingTimeMs;

  /// Nombre de mots extraits
  int get wordCount =>
      fullText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  /// Vérifie si le résultat est exploitable
  bool get isUsable => fullText.trim().length > 10 && confidence > 0.3;

  /// Résumé rapide (premières lignes)
  String get preview {
    final lines = fullText.split('\n').where((l) => l.trim().isNotEmpty);
    return lines.take(3).join('\n');
  }

  static const OcrResult empty = OcrResult(
    fullText: '',
    blocks: [],
    confidence: 0,
    language: '',
    processingTimeMs: 0,
  );
}

/// Bloc de texte reconnu
class OcrBlock {
  const OcrBlock({
    required this.text,
    required this.confidence,
    required this.lines,
  });

  final String text;
  final double confidence;
  final List<String> lines;
}

/// Service OCR principal
class OcrService {
  OcrService._();
  static final OcrService instance = OcrService._();

  TextRecognizer? _recognizer;

  /// Initialise le recognizer (latin par défaut)
  void initialize({TextRecognitionScript script = TextRecognitionScript.latin}) {
    _recognizer?.close();
    _recognizer = TextRecognizer(script: script);
  }

  /// Extrait le texte d'un fichier image
  Future<OcrResult> extractText(File imageFile) async {
    if (_recognizer == null) {
      initialize();
    }

    final sw = Stopwatch()..start();

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognized = await _recognizer!.processImage(inputImage);

      sw.stop();

      if (recognized.text.isEmpty) {
        return OcrResult(
          fullText: '',
          blocks: const [],
          confidence: 0,
          language: 'fr',
          processingTimeMs: sw.elapsedMilliseconds,
        );
      }

      // Construire les blocs structurés
      final blocks = recognized.blocks.map((block) {
        return OcrBlock(
          text: block.text,
          confidence: _blockConfidence(block),
          lines: block.lines.map((l) => l.text).toList(),
        );
      }).toList();

      // Confiance moyenne pondérée
      final totalConf = blocks.fold<double>(0, (s, b) => s + b.confidence);
      final avgConf = blocks.isEmpty ? 0.0 : totalConf / blocks.length;

      return OcrResult(
        fullText: recognized.text,
        blocks: blocks,
        confidence: avgConf.clamp(0.0, 1.0),
        language: 'fr',
        processingTimeMs: sw.elapsedMilliseconds,
      );
    } catch (e, st) {
      sw.stop();
      AppLogger.error('OcrService.extractText', e, st);
      return OcrResult(
        fullText: '',
        blocks: const [],
        confidence: 0,
        language: '',
        processingTimeMs: sw.elapsedMilliseconds,
      );
    }
  }

  /// Extrait le texte depuis un chemin de fichier
  Future<OcrResult> extractTextFromPath(String path) async {
    return extractText(File(path));
  }

  /// Confiance d'un bloc (moyenne des éléments)
  double _blockConfidence(TextBlock block) {
    final elements = block.lines.expand((l) => l.elements);
    if (elements.isEmpty) return 0.5;
    final total =
        elements.fold<double>(0, (s, e) => s + (e.confidence ?? 0.5));
    return total / elements.length;
  }

  /// Libère les ressources
  void dispose() {
    _recognizer?.close();
    _recognizer = null;
  }
}
