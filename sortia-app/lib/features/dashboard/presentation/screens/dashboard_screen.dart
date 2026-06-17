// ================================================================
// SORTIA — Écran Dashboard complet
// Actions rapides, 4 cartes, stockage, temps, sparkline, IA, récents
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sortia/features/dashboard/domain/models/dashboard_stats_model.dart';
import 'package:sortia/features/dashboard/presentation/dashboard_providers.dart';
import 'package:sortia/features/dashboard/presentation/widgets/stats_card.dart';
import 'package:sortia/features/dashboard/presentation/widgets/storage_gauge_widget.dart';
import 'package:sortia/features/dashboard/presentation/widgets/time_saved_widget.dart';
import 'package:sortia/features/dashboard/presentation/widgets/sparkline_widget.dart';
import 'package:sortia/features/dashboard/presentation/widgets/recent_files_widget.dart';
import 'package:sortia/features/dashboard/presentation/widgets/ai_breakdown_widget.dart';
import 'package:sortia/features/dashboard/presentation/widgets/quick_actions_widget.dart';

/// Écran principal du tableau de bord
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final recentAsync = ref.watch(recentFilesProvider);
    final refresh = ref.read(dashboardRefreshProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      body: RefreshIndicator(
        onRefresh: refresh,
        color: const Color(0xFF1B4F72),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App Bar ─────────────────────────────────────
            SliverAppBar(
              expandedHeight: 100,
              floating: true,
              snap: true,
              backgroundColor: const Color(0xFF1B4F72),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.only(left: 16, bottom: 12),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: const TextStyle(
                        color: Color(0xFFAED6F1),
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      'Tableau de bord',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                statsAsync.maybeWhen(
                  data: (s) => s.unreadAlerts > 0
                      ? Stack(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () => context.push('/alerts'),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE74C3C),
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${s.unreadAlerts}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () => context.push('/alerts'),
                        ),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(width: 4),
              ],
            ),

            // ── Contenu ─────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Actions rapides
                  const QuickActionsWidget(),
                  const SizedBox(height: 20),

                  // 4 cartes stats
                  statsAsync.when(
                    data: (s) => _StatsGrid(stats: s),
                    loading: () => const _SkeletonGrid(),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                  ),
                  const SizedBox(height: 20),

                  // Stockage + Temps économisé
                  statsAsync.when(
                    data: (s) => _buildStorageRow(context, s),
                    loading: () => const _SkeletonRow(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // Sparkline 6 mois
                  statsAsync.when(
                    data: (s) => s.monthlyActivity.isNotEmpty
                        ? SparklineWidget(data: s.monthlyActivity)
                        : const SizedBox.shrink(),
                    loading: () => const _SkeletonCard(height: 160),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // Répartition IA
                  statsAsync.when(
                    data: (s) => s.topCategories.isNotEmpty
                        ? AiBreakdownWidget(categories: s.topCategories)
                        : const SizedBox.shrink(),
                    loading: () => const _SkeletonCard(height: 180),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // Fichiers récents
                  recentAsync.when(
                    data: (files) => files.isNotEmpty
                        ? RecentFilesWidget(files: files)
                        : const SizedBox.shrink(),
                    loading: () => const _SkeletonCard(height: 300),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageRow(BuildContext context, DashboardStats s) {
    final isWide = MediaQuery.of(context).size.width > 600;
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: StorageGaugeWidget(stats: s)),
          const SizedBox(width: 12),
          Expanded(child: TimeSavedWidget(stats: s)),
        ],
      );
    }
    return Column(
      children: [
        StorageGaugeWidget(stats: s),
        const SizedBox(height: 12),
        TimeSavedWidget(stats: s),
      ],
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour 👋';
    if (h < 18) return 'Bon après-midi 👋';
    return 'Bonsoir 👋';
  }
}

// ── Grille 4 cartes ─────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        StatsCard(
          label: 'Documents',
          value: '${stats.totalFiles}',
          icon: Icons.description_outlined,
          iconColor: const Color(0xFF2E86C1),
          subtitle: '+${stats.filesImportedThisMonth} ce mois',
          onTap: () {},
        ),
        StatsCard(
          label: 'Dossiers',
          value: '${stats.totalFolders}',
          icon: Icons.folder_outlined,
          iconColor: const Color(0xFF17A589),
          subtitle: 'organisés',
          onTap: () {},
        ),
        StatsCard(
          label: 'IA',
          value: '${(stats.aiClassificationRate * 100).round()}%',
          icon: Icons.auto_awesome_outlined,
          iconColor: const Color(0xFF8E44AD),
          subtitle: '${stats.aiClassifiedFiles} classifiés',
          onTap: () {},
        ),
        StatsCard(
          label: 'Alertes',
          value: '${stats.unreadAlerts}',
          icon: Icons.notifications_outlined,
          iconColor: stats.unreadAlerts > 0
              ? const Color(0xFFE74C3C)
              : const Color(0xFF566573),
          subtitle: stats.unreadAlerts > 0 ? 'non lues' : 'à jour ✓',
          isHighlighted: stats.unreadAlerts > 0,
          onTap: () {},
        ),
      ],
    );
  }
}

// ── Skeletons ───────────────────────────────────────────────
class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();
  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
        children: List.generate(4, (_) => const _SkeletonBox()),
      );
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();
  @override
  Widget build(BuildContext context) => const Row(
        children: [
          Expanded(child: _SkeletonCard(height: 130)),
          SizedBox(width: 12),
          Expanded(child: _SkeletonCard(height: 130)),
        ],
      );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});
  final double height;
  @override
  Widget build(BuildContext context) => _SkeletonBox(height: height);
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({this.height});
  final double? height;
  @override
  Widget build(BuildContext context) => Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE8ECF0),
          borderRadius: BorderRadius.circular(12),
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDEDEC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE74C3C).withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFE74C3C)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Impossible de charger les statistiques',
                style: TextStyle(color: Color(0xFFE74C3C)),
              ),
            ),
          ],
        ),
      );
}
