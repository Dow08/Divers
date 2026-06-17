// ================================================================
// SORTIA — Module Archive
// Archivage long terme de documents
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sortia/core/utils/logger.dart';

// ── Modèle ───────────────────────────────────────────────────

class ArchiveItem {
  const ArchiveItem({
    required this.id, required this.userId, required this.fileId,
    required this.fileName, this.reason, this.retentionYears = 10,
    this.archivedAt, this.expiresAt, this.isLocked = true,
  });

  final String id, userId, fileId, fileName;
  final String? reason;
  final int retentionYears;
  final DateTime? archivedAt, expiresAt;
  final bool isLocked;

  /// Durée restante
  String get retentionFormatted {
    if (expiresAt == null) return '$retentionYears ans';
    final days = expiresAt!.difference(DateTime.now()).inDays;
    if (days < 0) return 'Expiré';
    if (days > 365) return '${(days / 365).floor()} ans';
    return '$days jours';
  }

  /// Date d'archivage formatée
  String get archivedFormatted {
    if (archivedAt == null) return '-';
    return '${archivedAt!.day}/${archivedAt!.month}/${archivedAt!.year}';
  }

  /// L'archive est-elle expirée ?
  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  factory ArchiveItem.fromJson(Map<String, dynamic> j) => ArchiveItem(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        fileId: j['file_id'] as String,
        fileName: j['file_name'] as String? ?? 'Document',
        reason: j['reason'] as String?,
        retentionYears: (j['retention_years'] as int?) ?? 10,
        archivedAt: j['archived_at'] != null
            ? DateTime.parse(j['archived_at'] as String) : null,
        expiresAt: j['expires_at'] != null
            ? DateTime.parse(j['expires_at'] as String) : null,
        isLocked: (j['is_locked'] as bool?) ?? true,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId, 'file_id': fileId, 'file_name': fileName,
        'reason': reason, 'retention_years': retentionYears,
        'is_locked': isLocked,
      };
}

// ── Repository ───────────────────────────────────────────────

class ArchiveRepository {
  ArchiveRepository(this._sb);
  final SupabaseClient _sb;
  String get _uid => _sb.auth.currentUser!.id;

  Future<List<ArchiveItem>> fetchArchives() async {
    try {
      // Archives stockées en tant que metadata dans la table files avec flag
      // Pour simplifier, on utilise une vue ou une requête custom
      final data = await _sb.from('files').select()
          .eq('user_id', _uid).eq('is_archived', true)
          .order('created_at', ascending: false);
      return (data as List).map((r) {
        final m = r as Map<String, dynamic>;
        return ArchiveItem(
          id: m['id'] as String,
          userId: m['user_id'] as String,
          fileId: m['id'] as String,
          fileName: m['name'] as String? ?? 'Document',
          archivedAt: m['created_at'] != null
              ? DateTime.parse(m['created_at'] as String) : null,
        );
      }).toList();
    } catch (e, st) {
      AppLogger.error('ArchiveRepository.fetchArchives', e, st);
      rethrow;
    }
  }

  Future<void> archiveFile(String fileId) async {
    try {
      await _sb.from('files').update({
        'is_archived': true,
      }).eq('id', fileId).eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('ArchiveRepository.archiveFile', e, st);
      rethrow;
    }
  }

  Future<void> restoreFile(String fileId) async {
    try {
      await _sb.from('files').update({
        'is_archived': false,
      }).eq('id', fileId).eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('ArchiveRepository.restoreFile', e, st);
      rethrow;
    }
  }
}

// ── Providers ────────────────────────────────────────────────

final archiveRepositoryProvider = Provider<ArchiveRepository>((ref) =>
    ArchiveRepository(Supabase.instance.client));

final archivesProvider = AsyncNotifierProvider<ArchivesNotifier, List<ArchiveItem>>(
    ArchivesNotifier.new);

class ArchivesNotifier extends AsyncNotifier<List<ArchiveItem>> {
  @override
  Future<List<ArchiveItem>> build() =>
      ref.read(archiveRepositoryProvider).fetchArchives();

  Future<void> archive(String fileId) async {
    await ref.read(archiveRepositoryProvider).archiveFile(fileId);
    ref.invalidateSelf();
  }

  Future<void> restore(String fileId) async {
    await ref.read(archiveRepositoryProvider).restoreFile(fileId);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.where((a) => a.fileId != fileId).toList());
  }
}

// ── Écran Archive ────────────────────────────────────────────

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archAsync = ref.watch(archivesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Archives'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
      ),
      body: archAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (items) => items.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBEEF0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.archive_outlined, size: 48, color: Color(0xFF566573)),
                ),
                const SizedBox(height: 16),
                const Text('Aucune archive', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Archivez vos documents pour\nune conservation long terme', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF566573))),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (_, i) => _ArchiveCard(item: items[i]),
              ),
      ),
    );
  }
}

class _ArchiveCard extends ConsumerWidget {
  const _ArchiveCard({required this.item});
  final ArchiveItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.archive, color: Color(0xFF566573)),
        title: Text(item.fileName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
        subtitle: Text('Archivé le ${item.archivedFormatted} • ${item.retentionFormatted}', style: const TextStyle(fontSize: 11, color: Color(0xFF566573))),
        trailing: TextButton(
          onPressed: () => ref.read(archivesProvider.notifier).restore(item.fileId),
          child: const Text('Restaurer', style: TextStyle(fontSize: 11)),
        ),
      ),
    );
  }
}
