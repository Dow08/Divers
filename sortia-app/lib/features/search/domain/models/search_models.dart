// ================================================================
// SORTIA — Modèles de Recherche
// SearchResult, SearchFilters, SearchState
// ================================================================

import 'package:sortia/features/ai/domain/classification_types.dart';

/// Un résultat de recherche individuels
class SearchResult {
  const SearchResult({
    required this.id,
    required this.type,
    required this.name,
    this.folderName,
    this.folderId,
    this.mimeType,
    this.sizeBytes,
    this.aiClassification,
    this.aiConfidence,
    this.contentSnippet,
    this.highlightedName,
    this.createdAt,
  });

  final String id;
  final SearchResultType type;
  final String name;
  final String? folderName;
  final String? folderId;
  final String? mimeType;
  final int? sizeBytes;
  final String? aiClassification;
  final double? aiConfidence;
  final String? contentSnippet;
  final String? highlightedName;
  final DateTime? createdAt;

  /// Icône emoji basée sur le type MIME
  String get fileEmoji {
    if (type == SearchResultType.folder) return '📁';
    final mime = mimeType ?? '';
    if (mime.contains('pdf')) return '📕';
    if (mime.contains('image')) return '🖼️';
    if (mime.contains('word') || mime.contains('doc')) return '📝';
    if (mime.contains('sheet') || mime.contains('excel')) return '📊';
    if (mime.contains('presentation') || mime.contains('ppt')) return '📎';
    if (mime.contains('text')) return '📄';
    return '📄';
  }

  /// Catégorie IA si disponible
  DocumentCategory? get category {
    if (aiClassification == null) return null;
    return DocumentCategory.fromLabel(aiClassification!);
  }

  /// Taille formatée
  String get sizeFormatted {
    if (sizeBytes == null) return '';
    if (sizeBytes! < 1024) return '$sizeBytes o';
    if (sizeBytes! < 1024 * 1024) return '${(sizeBytes! / 1024).round()} Ko';
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }

  factory SearchResult.fromFileJson(Map<String, dynamic> json) => SearchResult(
        id: json['id'] as String,
        type: SearchResultType.file,
        name: json['name'] as String,
        folderName: json['folder_name'] as String?,
        folderId: json['folder_id'] as String?,
        mimeType: json['mime_type'] as String?,
        sizeBytes: json['size_bytes'] as int?,
        aiClassification: json['ai_classification'] as String?,
        aiConfidence: (json['ai_confidence'] as num?)?.toDouble(),
        contentSnippet: json['content_text'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  factory SearchResult.fromFolderJson(Map<String, dynamic> json) =>
      SearchResult(
        id: json['id'] as String,
        type: SearchResultType.folder,
        name: json['name'] as String,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );
}

/// Type de résultat
enum SearchResultType {
  file('Fichier'),
  folder('Dossier');

  const SearchResultType(this.label);
  final String label;
}

/// Filtres de recherche
class SearchFilters {
  const SearchFilters({
    this.query = '',
    this.resultType,
    this.category,
    this.mimeTypes = const [],
    this.dateFrom,
    this.dateTo,
    this.minSize,
    this.maxSize,
    this.folderId,
    this.sortBy = SearchSortBy.relevance,
  });

  final String query;
  final SearchResultType? resultType;
  final DocumentCategory? category;
  final List<String> mimeTypes;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? minSize;
  final int? maxSize;
  final String? folderId;
  final SearchSortBy sortBy;

  bool get hasActiveFilters =>
      resultType != null ||
      category != null ||
      mimeTypes.isNotEmpty ||
      dateFrom != null ||
      dateTo != null ||
      folderId != null;

  int get activeFilterCount {
    int count = 0;
    if (resultType != null) count++;
    if (category != null) count++;
    if (mimeTypes.isNotEmpty) count++;
    if (dateFrom != null || dateTo != null) count++;
    if (folderId != null) count++;
    return count;
  }

  SearchFilters copyWith({
    String? query,
    SearchResultType? resultType,
    DocumentCategory? category,
    List<String>? mimeTypes,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? minSize,
    int? maxSize,
    String? folderId,
    SearchSortBy? sortBy,
    bool clearResultType = false,
    bool clearCategory = false,
    bool clearDates = false,
    bool clearFolder = false,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      resultType: clearResultType ? null : (resultType ?? this.resultType),
      category: clearCategory ? null : (category ?? this.category),
      mimeTypes: mimeTypes ?? this.mimeTypes,
      dateFrom: clearDates ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDates ? null : (dateTo ?? this.dateTo),
      minSize: minSize ?? this.minSize,
      maxSize: maxSize ?? this.maxSize,
      folderId: clearFolder ? null : (folderId ?? this.folderId),
      sortBy: sortBy ?? this.sortBy,
    );
  }

  static const SearchFilters empty = SearchFilters();
}

/// Critère de tri
enum SearchSortBy {
  relevance('Pertinence'),
  dateDesc('Plus récent'),
  dateAsc('Plus ancien'),
  nameAsc('Nom A-Z'),
  nameDesc('Nom Z-A'),
  sizeDesc('Plus gros'),
  sizeAsc('Plus petit');

  const SearchSortBy(this.label);
  final String label;
}

/// État de la recherche
class SearchState {
  const SearchState({
    this.results = const [],
    this.filters = SearchFilters.empty,
    this.isLoading = false,
    this.hasSearched = false,
    this.error,
    this.totalCount = 0,
  });

  final List<SearchResult> results;
  final SearchFilters filters;
  final bool isLoading;
  final bool hasSearched;
  final String? error;
  final int totalCount;

  bool get isEmpty => hasSearched && results.isEmpty;

  SearchState copyWith({
    List<SearchResult>? results,
    SearchFilters? filters,
    bool? isLoading,
    bool? hasSearched,
    String? error,
    int? totalCount,
  }) {
    return SearchState(
      results: results ?? this.results,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      hasSearched: hasSearched ?? this.hasSearched,
      error: error,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
