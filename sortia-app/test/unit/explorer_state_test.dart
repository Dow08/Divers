// ================================================================
// SORTIA — Tests unitaires : ExplorerState
// ================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/explorer/domain/models/folder_model.dart';
import 'package:sortia/features/explorer/domain/states/explorer_state.dart';

void main() {
  group('ExplorerState', () {
    test('initial crée un état vide à la racine', () {
      const state = ExplorerState.initial();

      expect(state.currentFolderId, isNull);
      expect(state.folders, isEmpty);
      expect(state.files, isEmpty);
      expect(state.breadcrumbs, isEmpty);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.viewMode, ExplorerViewMode.list);
      expect(state.sortBy, ExplorerSortBy.name);
      expect(state.isRoot, true);
      expect(state.isEmpty, true);
      expect(state.itemCount, 0);
    });

    test('isRoot retourne true quand currentFolderId est null', () {
      const state = ExplorerState();
      expect(state.isRoot, true);
    });

    test('isRoot retourne false quand dans un sous-dossier', () {
      const state = ExplorerState(currentFolderId: 'folder-001');
      expect(state.isRoot, false);
    });

    test('isEmpty retourne true sans contenu', () {
      const state = ExplorerState();
      expect(state.isEmpty, true);
    });

    test('isEmpty retourne false avec des dossiers', () {
      final folder = FolderModel.fromJson({
        'id': 'f1',
        'user_id': 'u1',
        'name': 'Test',
      });
      final state = ExplorerState(folders: [folder]);
      expect(state.isEmpty, false);
      expect(state.itemCount, 1);
    });

    test('copyWith modifie un champ', () {
      const state = ExplorerState.initial();
      final updated = state.copyWith(isLoading: true);

      expect(updated.isLoading, true);
      expect(updated.currentFolderId, isNull); // inchangé
    });

    test('copyWith clearFolder remet à la racine', () {
      const state = ExplorerState(currentFolderId: 'folder-001');
      final cleared = state.copyWith(clearFolder: true);

      expect(cleared.currentFolderId, isNull);
    });

    test('copyWith clearError supprime l\'erreur', () {
      const state = ExplorerState(errorMessage: 'Erreur test');
      final cleared = state.copyWith(clearError: true);

      expect(cleared.errorMessage, isNull);
    });

    test('copyWith clearSearch vide la recherche', () {
      const state = ExplorerState(searchQuery: 'facture', isSearching: true);
      final cleared = state.copyWith(clearSearch: true);

      expect(cleared.searchQuery, isNull);
      expect(cleared.searchResults, isEmpty);
    });

    test('viewMode toggle fonctionne', () {
      const state = ExplorerState(viewMode: ExplorerViewMode.list);
      final toggled = state.copyWith(viewMode: ExplorerViewMode.grid);

      expect(toggled.viewMode, ExplorerViewMode.grid);
    });
  });

  group('ExplorerViewMode', () {
    test('contient list et grid', () {
      expect(ExplorerViewMode.values, contains(ExplorerViewMode.list));
      expect(ExplorerViewMode.values, contains(ExplorerViewMode.grid));
    });
  });

  group('ExplorerSortBy', () {
    test('contient 4 options de tri', () {
      expect(ExplorerSortBy.values.length, 4);
      expect(ExplorerSortBy.values, contains(ExplorerSortBy.name));
      expect(ExplorerSortBy.values, contains(ExplorerSortBy.date));
      expect(ExplorerSortBy.values, contains(ExplorerSortBy.size));
      expect(ExplorerSortBy.values, contains(ExplorerSortBy.type));
    });
  });
}
