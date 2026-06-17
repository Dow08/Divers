// ================================================================
// SORTIA — Providers Recherche (Riverpod)
// ================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sortia/features/search/data/search_repository.dart';
import 'package:sortia/features/search/domain/models/search_models.dart';

/// Repository provider
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(Supabase.instance.client);
});

/// Provider principal de recherche
final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});

/// Notifier de recherche
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._ref) : super(const SearchState());

  final Ref _ref;

  /// Lance une recherche
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    final filters = state.filters.copyWith(query: query);
    state = state.copyWith(
      filters: filters,
      isLoading: true,
      hasSearched: true,
    );

    try {
      final results =
          await _ref.read(searchRepositoryProvider).search(filters);
      state = state.copyWith(
        results: results,
        isLoading: false,
        totalCount: results.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Met à jour les filtres et relance la recherche
  Future<void> updateFilters(SearchFilters filters) async {
    state = state.copyWith(filters: filters);
    if (filters.query.isNotEmpty) {
      await search(filters.query);
    }
  }

  /// Réinitialise la recherche
  void reset() => state = const SearchState();
}

/// Suggestions de recherche
final searchSuggestionsProvider =
    FutureProvider.family<List<String>, String>((ref, partial) async {
  if (partial.length < 2) return [];
  return ref.read(searchRepositoryProvider).getSuggestions(partial);
});
