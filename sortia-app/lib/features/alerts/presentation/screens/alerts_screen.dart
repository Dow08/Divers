// ================================================================
// SORTIA — Écran Notifications / Alertes
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sortia/features/alerts/domain/models/alert_model.dart';
import 'package:sortia/features/alerts/presentation/providers/alert_providers.dart';

/// Écran des notifications et alertes
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
        actions: [
          alertsAsync.maybeWhen(
            data: (alerts) => alerts.any((a) => !a.isRead)
                ? TextButton(
                    onPressed: () =>
                        ref.read(alertsProvider.notifier).markAllAsRead(),
                    child: const Text(
                      'Tout lire',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(alertsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: alertsAsync.when(
        data: (alerts) => alerts.isEmpty
            ? _EmptyState()
            : _AlertsList(alerts: alerts),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Color(0xFFE74C3C)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(alertsProvider.notifier).refresh(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── État vide ────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 64,
              color: Color(0xFF17A589),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous êtes à jour ! 🎉\nLes alertes d\'échéances et RGPD\napparaîtront ici.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF566573)),
          ),
        ],
      ),
    );
  }
}

// ── Liste des alertes avec sections ──────────────────────────
class _AlertsList extends StatelessWidget {
  const _AlertsList({required this.alerts});
  final List<AlertModel> alerts;

  @override
  Widget build(BuildContext context) {
    // Séparer en groupes
    final overdue = alerts.where((a) => a.isOverdue && !a.isToday).toList();
    final today = alerts.where((a) => a.isToday).toList();
    final upcoming = alerts
        .where((a) => !a.isOverdue && !a.isToday)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (overdue.isNotEmpty)
          _AlertSection(
            title: '🔴 En retard',
            color: const Color(0xFFE74C3C),
            alerts: overdue,
          ),
        if (today.isNotEmpty)
          _AlertSection(
            title: "🟡 Aujourd'hui",
            color: const Color(0xFFF39C12),
            alerts: today,
          ),
        if (upcoming.isNotEmpty)
          _AlertSection(
            title: '🟢 À venir',
            color: const Color(0xFF17A589),
            alerts: upcoming,
          ),
      ],
    );
  }
}

class _AlertSection extends StatelessWidget {
  const _AlertSection({
    required this.title,
    required this.color,
    required this.alerts,
  });

  final String title;
  final Color color;
  final List<AlertModel> alerts;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${alerts.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...alerts.map((a) => _AlertCard(alert: a)),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Carte d'alerte ───────────────────────────────────────────
class _AlertCard extends ConsumerWidget {
  const _AlertCard({required this.alert});
  final AlertModel alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(alertsProvider.notifier).dismiss(alert.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!alert.isRead) {
              ref.read(alertsProvider.notifier).markAsRead(alert.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Indicateur non lu
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: alert.isRead
                        ? Colors.transparent
                        : const Color(0xFF2E86C1),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),

                // Icône priorité
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alert.priority.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),

                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: alert.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                                color: const Color(0xFF1A1A2E),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF5FB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${alert.type.emoji} ${alert.type.label}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF2E86C1),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (alert.message != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          alert.message!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF566573),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: alert.isOverdue
                                ? const Color(0xFFE74C3C)
                                : const Color(0xFF566573),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${alert.dateFormatted} — ${alert.timeRemainingFormatted}',
                            style: TextStyle(
                              fontSize: 11,
                              color: alert.isOverdue
                                  ? const Color(0xFFE74C3C)
                                  : const Color(0xFF566573),
                              fontWeight: alert.isOverdue
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _priorityColor => switch (alert.priority) {
        AlertPriority.low => const Color(0xFF2E86C1),
        AlertPriority.normal => const Color(0xFFF39C12),
        AlertPriority.high => const Color(0xFFE67E22),
        AlertPriority.urgent => const Color(0xFFE74C3C),
      };
}
