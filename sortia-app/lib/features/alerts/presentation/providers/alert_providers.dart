// ================================================================
// SORTIA — Providers Alertes (Riverpod)
// ================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sortia/features/alerts/data/alert_repository.dart';
import 'package:sortia/features/alerts/domain/models/alert_model.dart';

/// Repository provider
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepository(Supabase.instance.client);
});

/// Provider de la liste des alertes
final alertsProvider =
    AsyncNotifierProvider<AlertsNotifier, List<AlertModel>>(
  AlertsNotifier.new,
);

/// Notifier des alertes
class AlertsNotifier extends AsyncNotifier<List<AlertModel>> {
  @override
  Future<List<AlertModel>> build() async {
    return ref.read(alertRepositoryProvider).fetchAlerts();
  }

  /// Rafraîchit la liste
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(alertRepositoryProvider).fetchAlerts(),
    );
  }

  /// Marque une alerte comme lue
  Future<void> markAsRead(String alertId) async {
    final repo = ref.read(alertRepositoryProvider);
    await repo.markAsRead(alertId);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.map((a) {
        if (a.id == alertId) return a.copyWith(isRead: true);
        return a;
      }).toList(),
    );
  }

  /// Marque toutes comme lues
  Future<void> markAllAsRead() async {
    final repo = ref.read(alertRepositoryProvider);
    await repo.markAllAsRead();
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.map((a) => a.copyWith(isRead: true)).toList(),
    );
  }

  /// Dismiss (masquer) une alerte
  Future<void> dismiss(String alertId) async {
    final repo = ref.read(alertRepositoryProvider);
    await repo.dismissAlert(alertId);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.where((a) => a.id != alertId).toList(),
    );
  }
}

/// Compteur d'alertes non lues
final unreadAlertsCountProvider = FutureProvider<int>((ref) async {
  return ref.read(alertRepositoryProvider).countUnread();
});
