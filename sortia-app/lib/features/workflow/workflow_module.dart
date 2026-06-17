// ================================================================
// SORTIA — Module Workflow
// Approbation de documents : pending → in_review → approved/rejected
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sortia/core/utils/logger.dart';

// ── Modèle ───────────────────────────────────────────────────

enum WorkflowStatus {
  pending('En attente', Icons.hourglass_empty, Color(0xFFE67E22), '⏳'),
  inReview('En révision', Icons.rate_review_outlined, Color(0xFF2E86C1), '🔍'),
  approved('Approuvé', Icons.check_circle_outline, Color(0xFF17A589), '✅'),
  rejected('Rejeté', Icons.cancel_outlined, Color(0xFFE74C3C), '❌');

  const WorkflowStatus(this.label, this.icon, this.color, this.emoji);
  final String label;
  final IconData icon;
  final Color color;
  final String emoji;

  static WorkflowStatus fromString(String value) {
    return WorkflowStatus.values.firstWhere(
      (e) => e.name == value || _snakeMap[value] == e,
      orElse: () => WorkflowStatus.pending,
    );
  }

  static const _snakeMap = {
    'pending': WorkflowStatus.pending,
    'in_review': WorkflowStatus.inReview,
    'approved': WorkflowStatus.approved,
    'rejected': WorkflowStatus.rejected,
  };

  String get dbValue => switch (this) {
        WorkflowStatus.pending => 'pending',
        WorkflowStatus.inReview => 'in_review',
        WorkflowStatus.approved => 'approved',
        WorkflowStatus.rejected => 'rejected',
      };
}

class WorkflowModel {
  const WorkflowModel({
    required this.id,
    required this.userId,
    required this.fileId,
    required this.title,
    required this.status,
    this.assignedTo,
    this.dueDate,
    this.comments = const [],
    this.history = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String fileId;
  final String title;
  final WorkflowStatus status;
  final String? assignedTo;
  final DateTime? dueDate;
  final List<dynamic> comments;
  final List<dynamic> history;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// En retard ?
  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      status != WorkflowStatus.approved;

  /// Date d'échéance formatée
  String get dueDateFormatted {
    if (dueDate == null) return 'Pas de date limite';
    return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
  }

  /// Le workflow peut être avancé ?
  bool get canAdvance =>
      status == WorkflowStatus.pending ||
      status == WorkflowStatus.inReview;

  factory WorkflowModel.fromJson(Map<String, dynamic> json) => WorkflowModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        fileId: json['file_id'] as String,
        title: json['title'] as String,
        status: WorkflowStatus.fromString(json['status'] as String),
        assignedTo: json['assigned_to'] as String?,
        dueDate: json['due_date'] != null
            ? DateTime.parse(json['due_date'] as String)
            : null,
        comments: (json['comments'] as List?) ?? [],
        history: (json['history'] as List?) ?? [],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'file_id': fileId,
        'title': title,
        'status': status.dbValue,
        'assigned_to': assignedTo,
        'due_date': dueDate?.toIso8601String(),
      };
}

// ── Repository ───────────────────────────────────────────────

class WorkflowRepository {
  WorkflowRepository(this._supabase);
  final SupabaseClient _supabase;

  String get _uid => _supabase.auth.currentUser!.id;

  Future<List<WorkflowModel>> fetchWorkflows() async {
    try {
      final data = await _supabase
          .from('workflows')
          .select()
          .eq('user_id', _uid)
          .order('created_at', ascending: false);
      return (data as List)
          .map((r) => WorkflowModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('WorkflowRepository.fetchWorkflows', e, st);
      rethrow;
    }
  }

  Future<WorkflowModel> create(WorkflowModel wf) async {
    try {
      final data = await _supabase
          .from('workflows')
          .insert(wf.toJson())
          .select()
          .single();
      return WorkflowModel.fromJson(data);
    } catch (e, st) {
      AppLogger.error('WorkflowRepository.create', e, st);
      rethrow;
    }
  }

  Future<void> updateStatus(String wfId, WorkflowStatus status) async {
    try {
      await _supabase
          .from('workflows')
          .update({
            'status': status.dbValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', wfId)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('WorkflowRepository.updateStatus', e, st);
      rethrow;
    }
  }
}

// ── Providers ────────────────────────────────────────────────

final workflowRepositoryProvider = Provider<WorkflowRepository>((ref) {
  return WorkflowRepository(Supabase.instance.client);
});

final workflowsProvider =
    AsyncNotifierProvider<WorkflowsNotifier, List<WorkflowModel>>(
  WorkflowsNotifier.new,
);

class WorkflowsNotifier extends AsyncNotifier<List<WorkflowModel>> {
  @override
  Future<List<WorkflowModel>> build() async {
    return ref.read(workflowRepositoryProvider).fetchWorkflows();
  }

  Future<void> create(WorkflowModel wf) async {
    final created = await ref.read(workflowRepositoryProvider).create(wf);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([created, ...current]);
  }

  Future<void> approve(String wfId) async {
    await ref
        .read(workflowRepositoryProvider)
        .updateStatus(wfId, WorkflowStatus.approved);
    _updateLocal(wfId, WorkflowStatus.approved);
  }

  Future<void> reject(String wfId) async {
    await ref
        .read(workflowRepositoryProvider)
        .updateStatus(wfId, WorkflowStatus.rejected);
    _updateLocal(wfId, WorkflowStatus.rejected);
  }

  void _updateLocal(String wfId, WorkflowStatus newStatus) {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.map((w) {
      if (w.id == wfId) {
        return WorkflowModel(
          id: w.id,
          userId: w.userId,
          fileId: w.fileId,
          title: w.title,
          status: newStatus,
          assignedTo: w.assignedTo,
          dueDate: w.dueDate,
          comments: w.comments,
          history: w.history,
          createdAt: w.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      return w;
    }).toList());
  }
}

// ── Écran Workflows ──────────────────────────────────────────

class WorkflowScreen extends ConsumerWidget {
  const WorkflowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wfAsync = ref.watch(workflowsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Workflows'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
      ),
      body: wfAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (wfs) => wfs.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF5FB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.task_alt,
                          size: 48, color: Color(0xFF2E86C1)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Aucun workflow',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text(
                        'Soumettez un document pour\napprobation',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF566573))),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: wfs.length,
                itemBuilder: (_, i) => _WorkflowCard(wf: wfs[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task),
        label: const Text('Nouveau'),
      ),
    );
  }
}

class _WorkflowCard extends ConsumerWidget {
  const _WorkflowCard({required this.wf});
  final WorkflowModel wf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(wf.status.icon, color: wf.status.color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(wf.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: wf.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${wf.status.emoji} ${wf.status.label}',
                    style: TextStyle(
                      fontSize: 11,
                      color: wf.status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('📅 ${wf.dueDateFormatted}',
                    style: TextStyle(
                      fontSize: 11,
                      color: wf.isOverdue
                          ? const Color(0xFFE74C3C)
                          : const Color(0xFF566573),
                    )),
                if (wf.isOverdue)
                  const Text(' ⚠️ En retard',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFFE74C3C))),
                const Spacer(),
                if (wf.canAdvance) ...[
                  TextButton(
                    onPressed: () =>
                        ref.read(workflowsProvider.notifier).approve(wf.id),
                    child: const Text('✅ Approuver',
                        style: TextStyle(fontSize: 11)),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(workflowsProvider.notifier).reject(wf.id),
                    child: const Text('❌ Rejeter',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFFE74C3C))),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
