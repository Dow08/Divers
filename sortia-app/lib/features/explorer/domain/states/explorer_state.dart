// ================================================================
// SORTIA — État de l'explorateur
// ================================================================

import 'package:sortia/features/explorer/domain/models/file_model.dart';
import 'package:sortia/features/explorer/domain/models/folder_model.dart';

/// Mode d'affichage de l'explorateur
enum ExplorerViewMode {
  /// Vue en liste
  list,

  /// Vue en grille
  grid,
}

/// Tri des éléments
enum ExplorerSortBy {
  /// Par nom (A-Z)
  name,

  /// Par date de création (récent d'abord)
  date,

  /// Par taille (plus gros d'abord)
  size,

  /// Par type de fichier
  type,
}

/// État de l'explorateur de documents
class ExplorerState {
  /// Crée l'état de l'explorateur
  const ExplorerState({
    this.currentFolderId,
    this.folders = const [],
    this.files = const [],
    this.breadcrumbs = const [],
    this.isLoading = false,
    this.errorMessage,
    this.viewMode = ExplorerViewMode.list,
    this.sortBy = ExplorerSortBy.name,
    this.searchQuery,
    this.searchResults = const [],
    this.isSearching = false,
  });

  /// État initial (racine)
  const ExplorerState.initial() : this();

  /// ID du dossier courant (null = racine)
  final String? currentFolderId;

  /// Sous-dossiers du dossier courant
  final List<FolderModel> folders;

  /// Fichiers du dossier courant
  final List<FileModel> files;

  /// Fil d'Ariane (de la racine au dossier courant)
  final List<FolderModel> breadcrumbs;

  /// Chargement en cours
  final bool isLoading;

  /// Message d'erreur
  final String? errorMessage;

  /// Mode d'affichage (liste / grille)
  final ExplorerViewMode viewMode;

  /// Tri courant
  final ExplorerSortBy sortBy;

  /// Requête de recherche
  final String? searchQuery;

  /// Résultats de recherche
  final List<FileModel> searchResults;

  /// Recherche en cours
  final bool isSearching;

  /// Vérifie si on est à la racine
  bool get isRoot => currentFolderId == null;

  /// Vérifie s'il y a du contenu
  bool get isEmpty => folders.isEmpty && files.isEmpty;

  /// Nombre total d'éléments
  int get itemCount => folders.length + files.length;

  /// Crée une copie avec des valeurs modifiées
  ExplorerState copyWith({
    String? currentFolderId,
    List<FolderModel>? folders,
    List<FileModel>? files,
    List<FolderModel>? breadcrumbs,
    bool? isLoading,
    String? errorMessage,
    ExplorerViewMode? viewMode,
    ExplorerSortBy? sortBy,
    String? searchQuery,
    List<FileModel>? searchResults,
    bool? isSearching,
    bool clearFolder = false,
    bool clearError = false,
    bool clearSearch = false,
  }) {
    return ExplorerState(
      currentFolderId:
          clearFolder ? null : (currentFolderId ?? this.currentFolderId),
      folders: folders ?? this.folders,
      files: files ?? this.files,
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      viewMode: viewMode ?? this.viewMode,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      searchResults: clearSearch ? const [] : (searchResults ?? this.searchResults),
      isSearching: isSearching ?? this.isSearching,
    );
  }
}
