// ================================================================
// SORTIA — SearchRepository
// Recherche plein texte + filtres Supabase
// ================================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sortia/core/utils/logger.dart';
import 'package:sortia/features/search/domain/models/search_models.dart';

class SearchRepository {
  SearchRepository(this._supabase);

  final SupabaseClient _supabase;

  String get _uid {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw const AuthException('Utilisateur non authentifié');
    return uid;
  }

  /// Recherche combinée fichiers + dossiers
  Future<List<SearchResult>> search(SearchFilters filters) async {
    if (filters.query.trim().isEmpty) return [];

    try {
      final results = <SearchResult>[];

      // Recherche fichiers sauf si filtre "dossier uniquement"
      if (filters.resultType != SearchResultType.folder) {
        final files = await _searchFiles(filters);
        results.addAll(files);
      }

      // Recherche dossiers sauf si filtre "fichier uniquement"
      if (filters.resultType != SearchResultType.file) {
        final folders = await _searchFolders(filters);
        results.addAll(folders);
      }

      // Tri
      _sortResults(results, filters.sortBy);

      return results;
    } catch (e, st) {
      AppLogger.error('SearchRepository.search', e, st);
      rethrow;
    }
  }

  /// Recherche dans les fichiers
  Future<List<SearchResult>> _searchFiles(SearchFilters filters) async {
    var query = _supabase
        .from('files')
        .select('id, name, folder_id, mime_type, size_bytes, '
            'ai_classification, ai_confidence, content_text, created_at')
        .eq('user_id', _uid)
        .or('name.ilike.%${filters.query}%,'
            'content_text.ilike.%${filters.query}%,'
            'ai_classification.ilike.%${filters.query}%');

    // Filtre catégorie IA
    if (filters.category != null) {
      query = query.eq('ai_classification', filters.category!.label);
    }

    // Filtre type MIME
    if (filters.mimeTypes.isNotEmpty) {
      query = query.inFilter('mime_type', filters.mimeTypes);
    }

    // Filtre dossier
    if (filters.folderId != null) {
      query = query.eq('folder_id', filters.folderId!);
    }

    // Filtre dates
    if (filters.dateFrom != null) {
      query = query.gte('created_at', filters.dateFrom!.toIso8601String());
    }
    if (filters.dateTo != null) {
      query = query.lte('created_at', filters.dateTo!.toIso8601String());
    }

    final data = await query.limit(50);

    return (data as List)
        .map((row) =>
            SearchResult.fromFileJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Recherche dans les dossiers
  Future<List<SearchResult>> _searchFolders(SearchFilters filters) async {
    final data = await _supabase
        .from('folders')
        .select('id, name, created_at')
        .eq('user_id', _uid)
        .ilike('name', '%${filters.query}%')
        .limit(20);

    return (data as List)
        .map((row) =>
            SearchResult.fromFolderJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Suggestions de recherche (dernières recherches + catégories fréquentes)
  Future<List<String>> getSuggestions(String partial) async {
    if (partial.length < 2) return [];

    try {
      final data = await _supabase
          .from('files')
          .select('name')
          .eq('user_id', _uid)
          .ilike('name', '%$partial%')
          .limit(5);

      return (data as List)
          .map((row) => (row as Map<String, dynamic>)['name'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Tri des résultats
  void _sortResults(List<SearchResult> results, SearchSortBy sortBy) {
    switch (sortBy) {
      case SearchSortBy.relevance:
        // Fichiers avant dossiers, puis par date
        results.sort((a, b) {
          if (a.type != b.type) {
            return a.type == SearchResultType.file ? -1 : 1;
          }
          return (b.createdAt ?? DateTime(0))
              .compareTo(a.createdAt ?? DateTime(0));
        });
      case SearchSortBy.dateDesc:
        results.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
      case SearchSortBy.dateAsc:
        results.sort((a, b) => (a.createdAt ?? DateTime(0))
            .compareTo(b.createdAt ?? DateTime(0)));
      case SearchSortBy.nameAsc:
        results.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case SearchSortBy.nameDesc:
        results.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case SearchSortBy.sizeDesc:
        results.sort((a, b) => (b.sizeBytes ?? 0).compareTo(a.sizeBytes ?? 0));
      case SearchSortBy.sizeAsc:
        results.sort((a, b) => (a.sizeBytes ?? 0).compareTo(b.sizeBytes ?? 0));
    }
  }
}
