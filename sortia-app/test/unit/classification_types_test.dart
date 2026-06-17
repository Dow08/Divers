// ================================================================
// SORTIA — Tests unitaires : Classification IA
// ================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/ai/domain/classification_types.dart';

void main() {
  group('DocumentCategory', () {
    test('contient 17 catégories', () {
      expect(DocumentCategory.values.length, 17);
    });

    test('fromLabel trouve Facture', () {
      expect(DocumentCategory.fromLabel('Facture'), DocumentCategory.facture);
    });

    test('fromLabel est insensible à la casse', () {
      expect(DocumentCategory.fromLabel('facture'), DocumentCategory.facture);
      expect(DocumentCategory.fromLabel('FACTURE'), DocumentCategory.facture);
    });

    test('fromLabel gère les espaces', () {
      expect(
        DocumentCategory.fromLabel('  Facture  '),
        DocumentCategory.facture,
      );
    });

    test('fromLabel retourne autre pour inconnu', () {
      expect(DocumentCategory.fromLabel('xyz123'), DocumentCategory.autre);
    });

    test('chaque catégorie a un label et un icon', () {
      for (final cat in DocumentCategory.values) {
        expect(cat.label, isNotEmpty);
        expect(cat.icon, isNotEmpty);
      }
    });

    test('fromLabel trouve toutes les catégories par label', () {
      for (final cat in DocumentCategory.values) {
        expect(DocumentCategory.fromLabel(cat.label), cat);
      }
    });
  });

  group('AiClassificationResult', () {
    test('crée un résultat correct', () {
      const result = AiClassificationResult(
        category: DocumentCategory.facture,
        confidence: 0.95,
        vendorName: 'ACME Corp',
        documentAmount: 1250.50,
        documentNumber: 'FA-2026-001',
      );

      expect(result.category, DocumentCategory.facture);
      expect(result.confidence, 0.95);
      expect(result.vendorName, 'ACME Corp');
      expect(result.documentAmount, 1250.50);
    });

    test('toString affiche le pourcentage', () {
      const result = AiClassificationResult(
        category: DocumentCategory.contrat,
        confidence: 0.87,
      );

      expect(result.toString(), contains('Contrat'));
      expect(result.toString(), contains('87%'));
    });

    test('tags par défaut est vide', () {
      const result = AiClassificationResult(
        category: DocumentCategory.autre,
        confidence: 0.0,
      );

      expect(result.tags, isEmpty);
    });

    test('champs optionnels sont null par défaut', () {
      const result = AiClassificationResult(
        category: DocumentCategory.autre,
        confidence: 0.5,
      );

      expect(result.vendorName, isNull);
      expect(result.documentDate, isNull);
      expect(result.documentAmount, isNull);
      expect(result.suggestedFolder, isNull);
      expect(result.summary, isNull);
    });
  });
}
