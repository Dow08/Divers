// ================================================================
// SORTIA — Providers Explorer (Riverpod)
// ================================================================

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sortia/core/utils/logger.dart';
import 'package:sortia/features/explorer/data/explorer_repository.dart';
import 'package:sortia/features/explorer/domain/models/folder_model.dart';
import 'package:sortia/features/explorer/domain/states/explorer_state.dart';

/// Provider du repository Explorer
final explorerRepositoryProvider = Provider<ExplorerRepository>((ref) {
  return ExplorerRepository();
});

/// Provider principal de l'explorateur
final explorerProvider =
    StateNotifierProvider<ExplorerNotifier, ExplorerState>((ref) {
  final repository = ref.watch(explorerRepositoryProvider);
  return ExplorerNotifier(repository);
});

/// Provider du dossier courant (dérivé)
final currentFolderIdProvider = Provider<String?>((ref) {
  return ref.watch(explorerProvider).currentFolderId;
});

/// Provider du fil d'Ariane (dérivé)
final breadcrumbsProvider = Provider<List<FolderModel>>((ref) {
  return ref.watch(explorerProvider).breadcrumbs;
});

/// Notifier principal de l'explorateur
class ExplorerNotifier extends StateNotifier<ExplorerState> {
  /// Crée le notifier
  ExplorerNotifier(this._repository) : super(const ExplorerState.initial());

  final ExplorerRepository _repository;

  /// Charge le contenu d'un dossier
  Future<void> navigateToFolder({String? folderId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final folders = await _repository.fetchFolders(parentId: folderId);
      final files = folderId != null
          ? await _repository.fetchFiles(folderId)
          : <dynamic>[];
      final breadcrumbs = await _repository.buildBreadcrumbs(folderId);

      state = state.copyWith(
        currentFolderId: folderId,
        folders: folders,
        files: List.from(files),
        breadcrumbs: breadcrumbs,
        isLoading: false,
        clearFolder: folderId == null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur de chargement : $e',
      );
    }
  }

  /// Charge la racine
  Future<void> loadRoot() => navigateToFolder();

  /// Remonte d'un niveau
  Future<void> navigateUp() async {
    if (state.breadcrumbs.length <= 1) {
      await navigateToFolder();
    } else {
      final parentFolder = state.breadcrumbs[state.breadcrumbs.length - 2];
      await navigateToFolder(folderId: parentFolder.id);
    }
  }

  /// Crée un nouveau dossier dans le dossier courant
  Future<void> createFolder({
    required String name,
    String color = '#1B4F72',
    String icon = 'folder',
  }) async {
    try {
      await _repository.createFolder(
        name: name,
        parentId: state.currentFolderId,
        color: color,
        icon: icon,
      );
      // Rafraîchir le dossier courant
      await navigateToFolder(folderId: state.currentFolderId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur création dossier : $e',
      );
    }
  }

  /// Renomme un dossier
  Future<void> renameFolder(String folderId, String newName) async {
    try {
      await _repository.renameFolder(folderId, newName);
      await navigateToFolder(folderId: state.currentFolderId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur renommage : $e',
      );
    }
  }

  /// Supprime un dossier
  Future<void> deleteFolder(String folderId) async {
    try {
      await _repository.deleteFolder(folderId);
      await navigateToFolder(folderId: state.currentFolderId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur suppression : $e',
      );
    }
  }

  /// Upload un fichier
  Future<void> uploadFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    if (state.currentFolderId == null) {
      state = state.copyWith(
        errorMessage: 'Sélectionnez un dossier avant d\'importer.',
      );
      return;
    }

    try {
      await _repository.uploadFile(
        folderId: state.currentFolderId!,
        fileName: fileName,
        bytes: bytes,
        mimeType: mimeType,
      );
      await navigateToFolder(folderId: state.currentFolderId);
      AppLogger.info('Explorer: fichier importé — $fileName');
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur import : $e',
      );
    }
  }

  /// Supprime un fichier
  Future<void> deleteFile(String fileId, String storagePath) async {
    try {
      await _repository.deleteFile(fileId, storagePath);
      await navigateToFolder(folderId: state.currentFolderId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur suppression fichier : $e',
      );
    }
  }

  /// Renomme un fichier
  Future<void> renameFile(String fileId, String newName) async {
    try {
      await _repository.renameFile(fileId, newName);
      await navigateToFolder(folderId: state.currentFolderId);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erreur renommage fichier : $e',
      );
    }
  }

  /// Recherche de fichiers
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(clearSearch: true, isSearching: false);
      return;
    }

    state = state.copyWith(searchQuery: query, isSearching: true);

    try {
      final results = await _repository.searchFiles(query);
      state = state.copyWith(
        searchResults: results,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(isSearching: false);
    }
  }

  /// Bascule le mode d'affichage
  void toggleViewMode() {
    state = state.copyWith(
      viewMode: state.viewMode == ExplorerViewMode.list
          ? ExplorerViewMode.grid
          : ExplorerViewMode.list,
    );
  }

  /// Change le tri
  void setSortBy(ExplorerSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  /// Crée l'arborescence d'un template d'onboarding
  Future<void> applyTemplate(String templateId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.createTemplateFolders(templateId);
      await loadRoot();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur création template : $e',
      );
    }
  }
}
