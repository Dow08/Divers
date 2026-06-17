// ================================================================
// SORTIA — Providers IA (Riverpod)
// ================================================================

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sortia/features/ai/data/ai_service.dart';
import 'package:sortia/features/ai/domain/classification_types.dart';

/// Provider de disponibilité du service IA
final aiAvailableProvider = Provider<bool>((ref) {
  return AiService.isAvailable;
});

/// Provider de classification de texte
final classifyTextProvider =
    FutureProvider.family<AiClassificationResult, String>((ref, text) async {
  return AiService.classifyFromText(text);
});

/// Provider de classification d'image
final classifyImageProvider = FutureProvider.family<AiClassificationResult,
    ({Uint8List bytes, String mimeType})>((ref, params) async {
  return AiService.classifyFromImage(params.bytes, params.mimeType);
});

/// Provider de résumé de document
final summarizeProvider =
    FutureProvider.family<String, String>((ref, text) async {
  return AiService.summarize(text);
});
