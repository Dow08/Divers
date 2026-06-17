// ================================================================
// SORTIA — Providers Dashboard (Riverpod)
// Auto-refresh 5 min + invalidation manuelle
// ================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sortia/features/dashboard/data/dashboard_repository.dart';
import 'package:sortia/features/dashboard/domain/models/dashboard_stats_model.dart';

/// Provider du repository
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(Supabase.instance.client);
});

/// Provider des stats du dashboard
final dashboardStatsProvider =
    AsyncNotifierProvider<DashboardStatsNotifier, DashboardStats>(
  DashboardStatsNotifier.new,
);

/// Notifier qui gère le chargement et le refresh des stats
class DashboardStatsNotifier extends AsyncNotifier<DashboardStats> {
  bool _disposed = false;

  @override
  Future<DashboardStats> build() async {
    ref.onDispose(() => _disposed = true);
    _scheduleAutoRefresh();
    return ref.read(dashboardRepositoryProvider).fetchStats();
  }

  /// Rafraîchit manuellement les stats
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(dashboardRepositoryProvider).fetchStats(),
    );
  }

  void _scheduleAutoRefresh() {
    Future.delayed(const Duration(minutes: 5), () {
      if (!_disposed) {
        refresh();
        _scheduleAutoRefresh();
      }
    });
  }
}

/// Provider des fichiers récents
final recentFilesProvider =
    AsyncNotifierProvider<RecentFilesNotifier, List<RecentFile>>(
  RecentFilesNotifier.new,
);

/// Notifier pour les fichiers récents
class RecentFilesNotifier extends AsyncNotifier<List<RecentFile>> {
  @override
  Future<List<RecentFile>> build() =>
      ref.read(dashboardRepositoryProvider).fetchRecentFiles(limit: 10);

  /// Rafraîchit la liste
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(dashboardRepositoryProvider).fetchRecentFiles(limit: 10),
    );
  }
}

/// Rafraîchit les 2 providers en parallèle (RefreshIndicator)
final dashboardRefreshProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await Future.wait([
      ref.read(dashboardStatsProvider.notifier).refresh(),
      ref.read(recentFilesProvider.notifier).refresh(),
    ]);
  };
});
