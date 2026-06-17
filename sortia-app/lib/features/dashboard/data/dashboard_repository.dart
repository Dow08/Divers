// ================================================================
// SORTIA — DashboardRepository
// 6 requêtes COUNT en Future.wait() + 3 appels RPC
// ================================================================

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import 'package:sortia/core/error/app_exception.dart';
import 'package:sortia/core/utils/logger.dart';
import 'package:sortia/features/dashboard/domain/models/dashboard_stats_model.dart';

class DashboardRepository {
  DashboardRepository(this._supabase);

  final SupabaseClient _supabase;

  String get _uid {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      throw const AuthException('Utilisateur non authentifié');
    }
    return uid;
  }

  /// Récupère toutes les statistiques du dashboard
  Future<DashboardStats> fetchStats() async {
    try {
      final uid = _uid;

      // 6 requêtes en parallèle
      final results = await Future.wait([
        _countFiles(uid),
        _countFolders(uid),
        _countUnreadAlerts(uid),
        _fetchStorageUsed(uid),
        _countAiClassified(uid),
        _countImportedThisMonth(uid),
      ]);

      final totalFiles = results[0];
      final totalFolders = results[1];
      final unreadAlerts = results[2];
      final storageUsed = results[3];
      final aiClassified = results[4];
      final thisMonth = results[5];

      final storageQuota = await _fetchStorageQuota(uid);

      final rawResults = await Future.wait([
        _fetchTopCategories(uid),
        _fetchMonthlyActivity(uid),
      ]);

      // 2 min/fichier classifié + 5 min × 30% des fichiers (recherche)
      final timeSaved =
          (aiClassified * 2) + ((totalFiles * 0.3) * 5).round();

      return DashboardStats(
        totalFiles: totalFiles,
        totalFolders: totalFolders,
        unreadAlerts: unreadAlerts,
        storageUsedBytes: storageUsed,
        storageQuotaBytes: storageQuota,
        aiClassifiedFiles: aiClassified,
        filesImportedThisMonth: thisMonth,
        timeSavedMinutes: timeSaved,
        topCategories: rawResults[0] as List<CategoryCount>,
        monthlyActivity: rawResults[1] as List<MonthlyActivity>,
      );
    } on AuthException {
      rethrow;
    } catch (e, st) {
      AppLogger.error('DashboardRepository.fetchStats', e, st);
      rethrow;
    }
  }

  /// Derniers fichiers importés
  Future<List<RecentFile>> fetchRecentFiles({int limit = 10}) async {
    try {
      final data = await _supabase
          .from('files')
          .select(
              'id, name, mime_type, size_bytes, ai_classification, created_at, folder_id')
          .eq('user_id', _uid)
          .eq('is_latest_version', true)
          .eq('is_archived', false)
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List)
          .map((row) => RecentFile.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('DashboardRepository.fetchRecentFiles', e, st);
      rethrow;
    }
  }

  // ── Requêtes privées ─────────────────────────────────────────

  Future<int> _countFiles(String uid) async {
    final res = await _supabase
        .from('files')
        .select('id')
        .eq('user_id', uid)
        .eq('is_latest_version', true)
        .eq('is_archived', false)
        .count(CountOption.exact);
    return res.count;
  }

  Future<int> _countFolders(String uid) async {
    final res = await _supabase
        .from('folders')
        .select('id')
        .eq('user_id', uid)
        .eq('is_archived', false)
        .count(CountOption.exact);
    return res.count;
  }

  Future<int> _countUnreadAlerts(String uid) async {
    final res = await _supabase
        .from('alerts')
        .select('id')
        .eq('user_id', uid)
        .eq('is_read', false)
        .eq('is_dismissed', false)
        .count(CountOption.exact);
    return res.count;
  }

  Future<int> _fetchStorageUsed(String uid) async {
    final res = await _supabase.rpc(
      'get_user_storage_used',
      params: {'p_user_id': uid},
    );
    return (res as int?) ?? 0;
  }

  Future<int> _countAiClassified(String uid) async {
    final res = await _supabase
        .from('files')
        .select('id')
        .eq('user_id', uid)
        .eq('is_latest_version', true)
        .not('ai_classification', 'is', null)
        .count(CountOption.exact);
    return res.count;
  }

  Future<int> _countImportedThisMonth(String uid) async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month).toIso8601String();
    final res = await _supabase
        .from('files')
        .select('id')
        .eq('user_id', uid)
        .eq('is_latest_version', true)
        .gte('created_at', firstDay)
        .count(CountOption.exact);
    return res.count;
  }

  Future<int> _fetchStorageQuota(String uid) async {
    final data = await _supabase
        .from('user_profiles')
        .select('plan')
        .eq('id', uid)
        .single();
    final plan = (data['plan'] as String?) ?? 'free';
    return StorageQuota.fromPlan(plan).bytes;
  }

  Future<List<CategoryCount>> _fetchTopCategories(String uid) async {
    final data = await _supabase.rpc(
      'get_top_categories',
      params: {'p_user_id': uid, 'p_limit': 5},
    );
    return (data as List).map((row) {
      final key = (row['ai_classification'] as String?) ?? 'other';
      return CategoryCount(
        aiKey: key,
        label: CategoryCount.labelFromKey(key),
        emoji: CategoryCount.emojiFromKey(key),
        count: (row['count'] as int?) ?? 0,
      );
    }).toList();
  }

  Future<List<MonthlyActivity>> _fetchMonthlyActivity(String uid) async {
    final data = await _supabase.rpc(
      'get_monthly_activity',
      params: {'p_user_id': uid, 'p_months': 6},
    );
    return (data as List).map((row) {
      final month = row['month'] as int;
      final year = row['year'] as int;
      final filesAdded = (row['files_added'] as int?) ?? 0;
      return MonthlyActivity(
        monthLabel: _monthLabel(month),
        year: year,
        month: month,
        filesAdded: filesAdded,
        timeSavedMinutes: filesAdded * 2,
      );
    }).toList();
  }

  static String _monthLabel(int month) => const [
        '',
        'Jan',
        'Fév',
        'Mar',
        'Avr',
        'Mai',
        'Jun',
        'Jul',
        'Aoû',
        'Sep',
        'Oct',
        'Nov',
        'Déc',
      ][month];
}
