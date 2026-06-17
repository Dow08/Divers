// ================================================================
// SORTIA — Module Import Batch
// Import depuis cloud (Drive, Dropbox) ou local
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sortia/core/utils/logger.dart';

// ── Modèle ───────────────────────────────────────────────────

enum ImportSource {
  local('Appareil', Icons.phone_android, '📱'),
  drive('Google Drive', Icons.cloud_outlined, '☁️'),
  dropbox('Dropbox', Icons.cloud_circle_outlined, '📦'),
  onedrive('OneDrive', Icons.cloud_queue_outlined, '🔷');

  const ImportSource(this.label, this.icon, this.emoji);
  final String label;
  final IconData icon;
  final String emoji;
}

enum ImportJobStatus {
  pending('En attente', Color(0xFF566573)),
  running('En cours', Color(0xFF2E86C1)),
  completed('Terminé', Color(0xFF17A589)),
  failed('Échoué', Color(0xFFE74C3C));

  const ImportJobStatus(this.label, this.color);
  final String label;
  final Color color;

  static ImportJobStatus fromString(String v) =>
      ImportJobStatus.values.firstWhere((e) => e.name == v,
          orElse: () => ImportJobStatus.pending);
}

class ImportJob {
  const ImportJob({
    required this.id, required this.userId, required this.source,
    required this.status, this.totalFiles = 0, this.processedFiles = 0,
    this.classifiedFiles = 0, this.failedFiles = 0,
    this.errorLog = const [], this.startedAt, this.completedAt, this.createdAt,
  });

  final String id, userId, source;
  final ImportJobStatus status;
  final int totalFiles, processedFiles, classifiedFiles, failedFiles;
  final List<dynamic> errorLog;
  final DateTime? startedAt, completedAt, createdAt;

  double get progress => totalFiles == 0 ? 0 : processedFiles / totalFiles;
  String get progressFormatted => '$processedFiles / $totalFiles fichiers';

  ImportSource get sourceType =>
      ImportSource.values.where((s) => s.name == source).firstOrNull ??
      ImportSource.local;

  factory ImportJob.fromJson(Map<String, dynamic> j) => ImportJob(
        id: j['id'] as String, userId: j['user_id'] as String,
        source: j['source'] as String,
        status: ImportJobStatus.fromString(j['status'] as String),
        totalFiles: (j['total_files'] as int?) ?? 0,
        processedFiles: (j['processed_files'] as int?) ?? 0,
        classifiedFiles: (j['classified_files'] as int?) ?? 0,
        failedFiles: (j['failed_files'] as int?) ?? 0,
        errorLog: (j['error_log'] as List?) ?? [],
        startedAt: j['started_at'] != null ? DateTime.parse(j['started_at'] as String) : null,
        completedAt: j['completed_at'] != null ? DateTime.parse(j['completed_at'] as String) : null,
        createdAt: j['created_at'] != null ? DateTime.parse(j['created_at'] as String) : null,
      );
}

// ── Repository ───────────────────────────────────────────────

class ImportRepository {
  ImportRepository(this._sb);
  final SupabaseClient _sb;
  String get _uid => _sb.auth.currentUser!.id;

  Future<List<ImportJob>> fetchJobs() async {
    try {
      final data = await _sb.from('import_jobs').select()
          .eq('user_id', _uid).order('created_at', ascending: false);
      return (data as List).map((r) => ImportJob.fromJson(r as Map<String, dynamic>)).toList();
    } catch (e, st) { AppLogger.error('ImportRepository.fetchJobs', e, st); rethrow; }
  }

  Future<ImportJob> createJob(String source) async {
    try {
      final data = await _sb.from('import_jobs')
          .insert({'user_id': _uid, 'source': source, 'status': 'pending'})
          .select().single();
      return ImportJob.fromJson(data);
    } catch (e, st) { AppLogger.error('ImportRepository.createJob', e, st); rethrow; }
  }
}

// ── Providers ────────────────────────────────────────────────

final importRepositoryProvider = Provider<ImportRepository>((ref) =>
    ImportRepository(Supabase.instance.client));

final importJobsProvider = AsyncNotifierProvider<ImportJobsNotifier, List<ImportJob>>(
    ImportJobsNotifier.new);

class ImportJobsNotifier extends AsyncNotifier<List<ImportJob>> {
  @override
  Future<List<ImportJob>> build() => ref.read(importRepositoryProvider).fetchJobs();

  Future<void> startImport(ImportSource source) async {
    final job = await ref.read(importRepositoryProvider).createJob(source.name);
    state = AsyncValue.data([job, ...(state.valueOrNull ?? [])]);
  }
}

// ── Écran Import ─────────────────────────────────────────────

class ImportScreen extends ConsumerWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(importJobsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(title: const Text('Import'), backgroundColor: const Color(0xFF1B4F72), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Importer depuis', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 10),
          ...ImportSource.values.map((src) => Card(
            margin: const EdgeInsets.only(bottom: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(src.icon, color: const Color(0xFF1B4F72)),
              title: Text(src.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              trailing: ElevatedButton(
                onPressed: () => ref.read(importJobsProvider.notifier).startImport(src),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF17A589), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Importer', style: TextStyle(fontSize: 12)),
              ),
            ),
          )),
          const SizedBox(height: 20),
          const Text('Historique', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 10),
          jobsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erreur : $e'),
            data: (jobs) => jobs.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Aucun import', style: TextStyle(fontSize: 13, color: Color(0xFF566573)))))
                : Column(children: jobs.map((j) => _JobCard(job: j)).toList()),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job});
  final ImportJob job;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(job.sourceType.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(job.sourceType.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: job.status.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(job.status.label, style: TextStyle(fontSize: 10, color: job.status.color, fontWeight: FontWeight.w600)),
            ),
          ]),
          if (job.totalFiles > 0) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(value: job.progress, minHeight: 4, backgroundColor: const Color(0xFFEBEEF0), valueColor: AlwaysStoppedAnimation(job.status.color)),
            const SizedBox(height: 4),
            Text(job.progressFormatted, style: const TextStyle(fontSize: 10, color: Color(0xFF566573))),
          ],
        ]),
      ),
    );
  }
}
