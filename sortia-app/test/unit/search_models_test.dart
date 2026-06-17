// ================================================================
// SORTIA — Tests unitaires : Recherche
// ================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/ai/domain/classification_types.dart';
import 'package:sortia/features/search/domain/models/search_models.dart';

void main() {
  group('SearchResult', () {
    test('fromFileJson crée un résultat fichier', () {
      final result = SearchResult.fromFileJson({
        'id': 'f1',
        'name': 'facture.pdf',
        'folder_id': 'fold1',
        'mime_type': 'application/pdf',
        'size_bytes': 2457600,
        'ai_classification': 'Facture',
        'ai_confidence': 0.95,
        'content_text': 'Facture n°123 du 15/01/2026',
        'created_at': '2026-01-15T10:30:00Z',
      });

      expect(result.type, SearchResultType.file);
      expect(result.name, 'facture.pdf');
      expect(result.sizeFormatted, '2.3 Mo');
      expect(result.fileEmoji, '📕');
      expect(result.category, DocumentCategory.facture);
    });

    test('fromFolderJson crée un résultat dossier', () {
      final result = SearchResult.fromFolderJson({
        'id': 'd1',
        'name': 'Comptabilité',
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(result.type, SearchResultType.folder);
      expect(result.name, 'Comptabilité');
      expect(result.fileEmoji, '📁');
    });

    test('fileEmoji retourne le bon emoji par MIME', () {
      expect(
        SearchResult.fromFileJson({
          'id': '1',
          'name': 'img.jpg',
          'mime_type': 'image/jpeg',
          'created_at': '2026-01-01T00:00:00Z',
        }).fileEmoji,
        '🖼️',
      );

      expect(
        SearchResult.fromFileJson({
          'id': '2',
          'name': 'doc.docx',
          'mime_type': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          'created_at': '2026-01-01T00:00:00Z',
        }).fileEmoji,
        '📝',
      );
    });

    test('sizeFormatted gère o, Ko, Mo', () {
      expect(
        SearchResult.fromFileJson({
          'id': '1',
          'name': 'f',
          'size_bytes': 512,
          'created_at': '2026-01-01T00:00:00Z',
        }).sizeFormatted,
        '512 o',
      );

      expect(
        SearchResult.fromFileJson({
          'id': '2',
          'name': 'f',
          'size_bytes': 5120,
          'created_at': '2026-01-01T00:00:00Z',
        }).sizeFormatted,
        '5 Ko',
      );
    });
  });

  group('SearchResultType', () {
    test('a un label', () {
      expect(SearchResultType.file.label, 'Fichier');
      expect(SearchResultType.folder.label, 'Dossier');
    });
  });

  group('SearchFilters', () {
    test('empty a des valeurs par défaut', () {
      expect(SearchFilters.empty.query, '');
      expect(SearchFilters.empty.resultType, isNull);
      expect(SearchFilters.empty.category, isNull);
      expect(SearchFilters.empty.hasActiveFilters, false);
      expect(SearchFilters.empty.activeFilterCount, 0);
    });

    test('hasActiveFilters détecte les filtres', () {
      final f = SearchFilters.empty.copyWith(
        resultType: SearchResultType.file,
      );
      expect(f.hasActiveFilters, true);
      expect(f.activeFilterCount, 1);
    });

    test('activeFilterCount compte correctement', () {
      final f = SearchFilters(
        query: 'test',
        resultType: SearchResultType.file,
        category: DocumentCategory.facture,
        dateFrom: DateTime(2026),
        folderId: 'fold1',
      );
      expect(f.activeFilterCount, 4);
    });

    test('copyWith avec clear flags', () {
      final f = SearchFilters(
        query: 'test',
        resultType: SearchResultType.file,
        category: DocumentCategory.contrat,
      );

      final cleared = f.copyWith(clearResultType: true, clearCategory: true);
      expect(cleared.resultType, isNull);
      expect(cleared.category, isNull);
      expect(cleared.query, 'test');
    });

    test('copyWith modifie un champ', () {
      const f = SearchFilters(query: 'doc');
      final updated = f.copyWith(sortBy: SearchSortBy.nameAsc);
      expect(updated.sortBy, SearchSortBy.nameAsc);
      expect(updated.query, 'doc');
    });
  });

  group('SearchSortBy', () {
    test('contient 7 options', () {
      expect(SearchSortBy.values.length, 7);
    });

    test('chaque option a un label', () {
      for (final s in SearchSortBy.values) {
        expect(s.label, isNotEmpty);
      }
    });
  });

  group('SearchState', () {
    test('état initial', () {
      const state = SearchState();
      expect(state.results, isEmpty);
      expect(state.isLoading, false);
      expect(state.hasSearched, false);
      expect(state.isEmpty, false); // hasSearched est false
    });

    test('isEmpty true après recherche sans résultats', () {
      const state = SearchState(hasSearched: true, results: []);
      expect(state.isEmpty, true);
    });

    test('copyWith modifie un champ', () {
      const state = SearchState();
      final updated = state.copyWith(isLoading: true, hasSearched: true);
      expect(updated.isLoading, true);
      expect(updated.hasSearched, true);
    });
  });
}
