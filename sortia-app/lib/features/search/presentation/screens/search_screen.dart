// ================================================================
// SORTIA — Écran Recherche Avancée
// Barre de recherche, filtres, résultats
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sortia/features/ai/domain/classification_types.dart';
import 'package:sortia/features/search/domain/models/search_models.dart';
import 'package:sortia/features/search/presentation/providers/search_providers.dart';

/// Écran de recherche avancée
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Recherche'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
        actions: [
          if (searchState.filters.hasActiveFilters)
            Badge(
              label: Text('${searchState.filters.activeFilterCount}'),
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => setState(() => _showFilters = !_showFilters),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          _SearchBar(
            controller: _searchController,
            onSearch: (q) => ref.read(searchProvider.notifier).search(q),
            onClear: () {
              _searchController.clear();
              ref.read(searchProvider.notifier).reset();
            },
          ),

          // Filtres
          if (_showFilters) _FiltersPanel(
            filters: searchState.filters,
            onFiltersChanged: (f) =>
                ref.read(searchProvider.notifier).updateFilters(f),
          ),

          // Résultats
          Expanded(
            child: searchState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchState.isEmpty
                    ? _EmptyResults(query: searchState.filters.query)
                    : searchState.hasSearched
                        ? _ResultsList(
                            results: searchState.results,
                            totalCount: searchState.totalCount,
                          )
                        : _InitialState(),
          ),
        ],
      ),
    );
  }
}

// ── Barre de recherche ───────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onSearch,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1B4F72),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: onSearch,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Rechercher un document, dossier...',
          hintStyle: const TextStyle(color: Color(0xFFAED6F1)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFAED6F1)),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFAED6F1)),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

// ── Panneau de filtres ───────────────────────────────────────
class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({
    required this.filters,
    required this.onFiltersChanged,
  });

  final SearchFilters filters;
  final ValueChanged<SearchFilters> onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type de résultat
          const Text('Type',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [
              _FilterChip(
                label: 'Tous',
                isSelected: filters.resultType == null,
                onTap: () => onFiltersChanged(
                    filters.copyWith(clearResultType: true)),
              ),
              _FilterChip(
                label: '📄 Fichiers',
                isSelected: filters.resultType == SearchResultType.file,
                onTap: () => onFiltersChanged(
                    filters.copyWith(resultType: SearchResultType.file)),
              ),
              _FilterChip(
                label: '📁 Dossiers',
                isSelected: filters.resultType == SearchResultType.folder,
                onTap: () => onFiltersChanged(
                    filters.copyWith(resultType: SearchResultType.folder)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Catégorie IA
          const Text('Catégorie IA',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'Toutes',
                  isSelected: filters.category == null,
                  onTap: () => onFiltersChanged(
                      filters.copyWith(clearCategory: true)),
                ),
                const SizedBox(width: 6),
                ...DocumentCategory.values.take(8).map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _FilterChip(
                        label: cat.label,
                        isSelected: filters.category == cat,
                        onTap: () => onFiltersChanged(
                            filters.copyWith(category: cat)),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tri
          Row(
            children: [
              const Text('Tri : ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              DropdownButton<SearchSortBy>(
                value: filters.sortBy,
                underline: const SizedBox.shrink(),
                style: const TextStyle(fontSize: 12, color: Color(0xFF1B4F72)),
                items: SearchSortBy.values.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.label));
                }).toList(),
                onChanged: (sort) {
                  if (sort != null) {
                    onFiltersChanged(filters.copyWith(sortBy: sort));
                  }
                },
              ),
              const Spacer(),
              if (filters.hasActiveFilters)
                TextButton(
                  onPressed: () => onFiltersChanged(SearchFilters(
                    query: filters.query,
                  )),
                  child: const Text('Réinitialiser',
                      style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1B4F72)
              : const Color(0xFFF4F6F7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1B4F72)
                : const Color(0xFFD5D8DC),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF566573),
          ),
        ),
      ),
    );
  }
}

// ── État initial ─────────────────────────────────────────────
class _InitialState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Recherchez un document ou un dossier',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _SuggestionChip(label: '🧾 Factures'),
              _SuggestionChip(label: '📝 Contrats'),
              _SuggestionChip(label: '💰 Bulletins de paie'),
              _SuggestionChip(label: '🏦 Relevés bancaires'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF2E86C1)),
      ),
    );
  }
}

// ── Résultats vides ──────────────────────────────────────────
class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48, color: Color(0xFFD5D8DC)),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat pour "$query"',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF566573),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Essayez avec d\'autres termes ou filtres',
            style: TextStyle(fontSize: 13, color: Color(0xFF566573)),
          ),
        ],
      ),
    );
  }
}

// ── Liste des résultats ──────────────────────────────────────
class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results, required this.totalCount});
  final List<SearchResult> results;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // En-tête
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                '$totalCount résultat${totalCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF566573),
                ),
              ),
            ],
          ),
        ),
        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: results.length,
            itemBuilder: (context, index) =>
                _SearchResultCard(result: results[index]),
          ),
        ),
      ],
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.result});
  final SearchResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Emoji
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: result.type == SearchResultType.folder
                      ? const Color(0xFFF0F9FF)
                      : const Color(0xFFFEF9E7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    result.fileEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF5FB),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            result.type.label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF2E86C1),
                            ),
                          ),
                        ),
                        if (result.sizeFormatted.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            result.sizeFormatted,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF566573),
                            ),
                          ),
                        ],
                        if (result.category != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            result.category!.label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF8E44AD),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (result.contentSnippet != null &&
                        result.contentSnippet!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.contentSnippet!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF566573),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Flèche
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFD5D8DC),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
