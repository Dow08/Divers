// ================================================================
// SORTIA — Module Conformité RGPD
// Diagnostic + plan d'action + score de conformité
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Modèle ───────────────────────────────────────────────────

enum RgpdCategory {
  dataMapping('Cartographie des données', Icons.map_outlined),
  consent('Consentements', Icons.verified_user_outlined),
  rights('Droits des personnes', Icons.people_outlined),
  security('Sécurité', Icons.security_outlined),
  breach('Violations de données', Icons.warning_outlined),
  dpo('DPO / Gouvernance', Icons.admin_panel_settings_outlined),
  transfers('Transferts hors UE', Icons.public_outlined),
  retention('Conservation des données', Icons.timer_outlined);

  const RgpdCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum RgpdItemStatus {
  compliant('Conforme', '✅', Color(0xFF17A589)),
  partial('Partiellement', '⚠️', Color(0xFFE67E22)),
  nonCompliant('Non conforme', '❌', Color(0xFFE74C3C)),
  notApplicable('N/A', '➖', Color(0xFF566573));

  const RgpdItemStatus(this.label, this.emoji, this.color);
  final String label;
  final String emoji;
  final Color color;
}

class RgpdCheckItem {
  const RgpdCheckItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.status,
    this.action,
    this.priority = 0,
  });

  final String id;
  final RgpdCategory category;
  final String title;
  final String description;
  final RgpdItemStatus status;
  final String? action;
  final int priority; // 0=normal, 1=important, 2=critique

  bool get needsAction =>
      status == RgpdItemStatus.partial ||
      status == RgpdItemStatus.nonCompliant;

  String get priorityLabel => switch (priority) {
        2 => '🔴 Critique',
        1 => '🟡 Important',
        _ => '🟢 Normal',
      };
}

class RgpdDiagnostic {
  const RgpdDiagnostic({
    required this.items,
    this.lastRunAt,
  });

  final List<RgpdCheckItem> items;
  final DateTime? lastRunAt;

  /// Score global (0–100)
  int get score {
    if (items.isEmpty) return 0;
    final applicable =
        items.where((i) => i.status != RgpdItemStatus.notApplicable);
    if (applicable.isEmpty) return 100;
    final compliant =
        applicable.where((i) => i.status == RgpdItemStatus.compliant).length;
    final partial =
        applicable.where((i) => i.status == RgpdItemStatus.partial).length;
    return ((compliant + partial * 0.5) / applicable.length * 100).round();
  }

  /// Nombre d'actions à mener
  int get actionCount => items.where((i) => i.needsAction).length;

  /// Catégories avec problèmes
  Set<RgpdCategory> get problemCategories =>
      items.where((i) => i.needsAction).map((i) => i.category).toSet();

  /// Score formaté avec couleur
  Color get scoreColor {
    if (score >= 80) return const Color(0xFF17A589);
    if (score >= 50) return const Color(0xFFE67E22);
    return const Color(0xFFE74C3C);
  }
}

/// Diagnostic par défaut (checklist RGPD standard)
class RgpdTemplateItems {
  static List<RgpdCheckItem> get defaultItems => [
        const RgpdCheckItem(
          id: 'dm1',
          category: RgpdCategory.dataMapping,
          title: 'Registre des traitements',
          description: 'Un registre des activités de traitement est tenu à jour',
          status: RgpdItemStatus.nonCompliant,
          action: 'Créer le registre des traitements dans SORTIA',
          priority: 2,
        ),
        const RgpdCheckItem(
          id: 'dm2',
          category: RgpdCategory.dataMapping,
          title: 'Finalités documentées',
          description: 'Les finalités de chaque traitement sont clairement définies',
          status: RgpdItemStatus.partial,
          action: 'Documenter les finalités pour chaque catégorie de données',
        ),
        const RgpdCheckItem(
          id: 'co1',
          category: RgpdCategory.consent,
          title: 'Recueil du consentement',
          description: 'Les consentements sont recueillis de manière explicite',
          status: RgpdItemStatus.nonCompliant,
          action: 'Mettre en place des formulaires de consentement',
          priority: 1,
        ),
        const RgpdCheckItem(
          id: 'ri1',
          category: RgpdCategory.rights,
          title: 'Droit d\'accès',
          description: 'Procédure pour répondre aux demandes d\'accès',
          status: RgpdItemStatus.partial,
          action: 'Formaliser la procédure de droit d\'accès',
        ),
        const RgpdCheckItem(
          id: 'ri2',
          category: RgpdCategory.rights,
          title: 'Droit à l\'effacement',
          description: 'Procédure pour supprimer les données sur demande',
          status: RgpdItemStatus.nonCompliant,
          action: 'Créer une procédure d\'effacement documentée',
          priority: 1,
        ),
        const RgpdCheckItem(
          id: 'se1',
          category: RgpdCategory.security,
          title: 'Chiffrement des données',
          description: 'Les données sensibles sont chiffrées au repos et en transit',
          status: RgpdItemStatus.compliant,
        ),
        const RgpdCheckItem(
          id: 'se2',
          category: RgpdCategory.security,
          title: 'Sauvegardes',
          description: 'Des sauvegardes régulières sont effectuées',
          status: RgpdItemStatus.compliant,
        ),
        const RgpdCheckItem(
          id: 'br1',
          category: RgpdCategory.breach,
          title: 'Procédure de notification',
          description: 'Procédure de notification de violation en 72h',
          status: RgpdItemStatus.nonCompliant,
          action: 'Rédiger la procédure de notification CNIL',
          priority: 2,
        ),
        const RgpdCheckItem(
          id: 'dp1',
          category: RgpdCategory.dpo,
          title: 'DPO désigné',
          description: 'Un délégué à la protection des données est désigné',
          status: RgpdItemStatus.notApplicable,
        ),
        const RgpdCheckItem(
          id: 're1',
          category: RgpdCategory.retention,
          title: 'Politique de conservation',
          description: 'Les durées de conservation sont définies et appliquées',
          status: RgpdItemStatus.partial,
          action: 'Définir les durées de conservation par type de document',
        ),
      ];
}

// ── Providers ────────────────────────────────────────────────

final rgpdDiagnosticProvider =
    StateNotifierProvider<RgpdNotifier, RgpdDiagnostic>((ref) {
  return RgpdNotifier();
});

class RgpdNotifier extends StateNotifier<RgpdDiagnostic> {
  RgpdNotifier()
      : super(RgpdDiagnostic(
          items: RgpdTemplateItems.defaultItems,
          lastRunAt: DateTime.now(),
        ));

  void updateItemStatus(String itemId, RgpdItemStatus status) {
    state = RgpdDiagnostic(
      items: state.items.map((i) {
        if (i.id == itemId) {
          return RgpdCheckItem(
            id: i.id,
            category: i.category,
            title: i.title,
            description: i.description,
            status: status,
            action: i.action,
            priority: i.priority,
          );
        }
        return i;
      }).toList(),
      lastRunAt: state.lastRunAt,
    );
  }

  void runDiagnostic() {
    state = RgpdDiagnostic(
      items: state.items,
      lastRunAt: DateTime.now(),
    );
  }
}

// ── Écran RGPD ───────────────────────────────────────────────

class RgpdScreen extends ConsumerWidget {
  const RgpdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diag = ref.watch(rgpdDiagnosticProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Conformité RGPD'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(rgpdDiagnosticProvider.notifier).runDiagnostic(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Score global
          _ScoreCard(diag: diag),
          const SizedBox(height: 16),

          // Actions à mener
          if (diag.actionCount > 0) ...[
            Text(
              '⚡ ${diag.actionCount} actions à mener',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE74C3C),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Liste des items par catégorie
          ...RgpdCategory.values.expand((cat) {
            final catItems =
                diag.items.where((i) => i.category == cat).toList();
            if (catItems.isEmpty) return <Widget>[];
            return [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(cat.icon, size: 18, color: const Color(0xFF1B4F72)),
                    const SizedBox(width: 6),
                    Text(cat.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4F72),
                        )),
                  ],
                ),
              ),
              ...catItems.map((item) => _RgpdItemTile(item: item)),
            ];
          }),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.diag});
  final RgpdDiagnostic diag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: diag.score / 100,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFFEBEEF0),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(diag.scoreColor),
                ),
                Center(
                  child: Text(
                    '${diag.score}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: diag.scoreColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Score de conformité',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    )),
                const SizedBox(height: 4),
                Text(
                  '${diag.actionCount} action${diag.actionCount > 1 ? 's' : ''} à mener',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF566573)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RgpdItemTile extends StatelessWidget {
  const _RgpdItemTile({required this.item});
  final RgpdCheckItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        leading: Text(item.status.emoji, style: const TextStyle(fontSize: 18)),
        title: Text(item.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        subtitle: Text(item.status.label,
            style: TextStyle(fontSize: 11, color: item.status.color)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF566573))),
                if (item.action != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF9E7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            size: 14, color: Color(0xFFD4AC0D)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(item.action!,
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF7D6608))),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(item.priorityLabel,
                    style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
