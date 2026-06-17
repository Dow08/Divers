// ================================================================
// SORTIA — Modèle DashboardStats (plain Dart, sans Freezed)
// Compteurs, stockage, IA, temps économisé, sparkline 6 mois
// ================================================================

/// Statistiques complètes du tableau de bord
class DashboardStats {
  const DashboardStats({
    required this.totalFiles,
    required this.totalFolders,
    required this.unreadAlerts,
    required this.storageUsedBytes,
    required this.storageQuotaBytes,
    required this.aiClassifiedFiles,
    required this.filesImportedThisMonth,
    required this.timeSavedMinutes,
    required this.topCategories,
    required this.monthlyActivity,
  });

  final int totalFiles;
  final int totalFolders;
  final int unreadAlerts;
  final int storageUsedBytes;
  final int storageQuotaBytes;
  final int aiClassifiedFiles;
  final int filesImportedThisMonth;
  final int timeSavedMinutes;
  final List<CategoryCount> topCategories;
  final List<MonthlyActivity> monthlyActivity;

  // ── Getters calculés ─────────────────────────────────────────

  /// Pourcentage de fichiers classifiés par l'IA (0.0 à 1.0)
  double get aiClassificationRate =>
      totalFiles == 0 ? 0.0 : aiClassifiedFiles / totalFiles;

  /// Pourcentage de stockage utilisé (0.0 à 1.0)
  double get storageUsageRate =>
      storageQuotaBytes == 0 ? 0.0 : storageUsedBytes / storageQuotaBytes;

  /// Stockage utilisé formaté (ex: "2.34 Go")
  String get storageUsedFormatted => _formatBytes(storageUsedBytes);

  /// Quota formaté (ex: "10.00 Go")
  String get storageQuotaFormatted => _formatBytes(storageQuotaBytes);

  /// Temps économisé formaté (ex: "4h 20min" ou "45 min")
  String get timeSavedFormatted {
    if (timeSavedMinutes < 60) return '$timeSavedMinutes min';
    final hours = timeSavedMinutes ~/ 60;
    final minutes = timeSavedMinutes % 60;
    return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}min';
  }

  /// Couleur de la barre de stockage selon le taux d'utilisation
  StorageStatus get storageStatus {
    if (storageUsageRate < 0.70) return StorageStatus.safe;
    if (storageUsageRate < 0.90) return StorageStatus.warning;
    return StorageStatus.critical;
  }

  /// Modèle vide pour les états de chargement
  factory DashboardStats.empty() => DashboardStats(
        totalFiles: 0,
        totalFolders: 0,
        unreadAlerts: 0,
        storageUsedBytes: 0,
        storageQuotaBytes: StorageQuota.free.bytes,
        aiClassifiedFiles: 0,
        filesImportedThisMonth: 0,
        timeSavedMinutes: 0,
        topCategories: const [],
        monthlyActivity: const [],
      );

  DashboardStats copyWith({
    int? totalFiles,
    int? totalFolders,
    int? unreadAlerts,
    int? storageUsedBytes,
    int? storageQuotaBytes,
    int? aiClassifiedFiles,
    int? filesImportedThisMonth,
    int? timeSavedMinutes,
    List<CategoryCount>? topCategories,
    List<MonthlyActivity>? monthlyActivity,
  }) {
    return DashboardStats(
      totalFiles: totalFiles ?? this.totalFiles,
      totalFolders: totalFolders ?? this.totalFolders,
      unreadAlerts: unreadAlerts ?? this.unreadAlerts,
      storageUsedBytes: storageUsedBytes ?? this.storageUsedBytes,
      storageQuotaBytes: storageQuotaBytes ?? this.storageQuotaBytes,
      aiClassifiedFiles: aiClassifiedFiles ?? this.aiClassifiedFiles,
      filesImportedThisMonth:
          filesImportedThisMonth ?? this.filesImportedThisMonth,
      timeSavedMinutes: timeSavedMinutes ?? this.timeSavedMinutes,
      topCategories: topCategories ?? this.topCategories,
      monthlyActivity: monthlyActivity ?? this.monthlyActivity,
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} Ko';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} Go';
  }

  @override
  String toString() =>
      'DashboardStats(files: $totalFiles, folders: $totalFolders, '
      'storage: $storageUsedFormatted/$storageQuotaFormatted)';
}

/// Compteur par catégorie IA
class CategoryCount {
  const CategoryCount({
    required this.label,
    required this.aiKey,
    required this.count,
    required this.emoji,
  });

  final String label;
  final String aiKey;
  final int count;
  final String emoji;

  static String labelFromKey(String key) => const {
        'invoice': 'Factures',
        'contract': 'Contrats',
        'delivery_note': 'Bons de livraison',
        'payslip': 'Bulletins de paie',
        'bank_statement': 'Relevés bancaires',
        'quote': 'Devis',
        'receipt': 'Tickets de caisse',
        'identity': "Documents d'identité",
        'insurance': 'Assurances',
        'other': 'Autres',
      }[key] ??
      key;

  static String emojiFromKey(String key) => const {
        'invoice': '🧾',
        'contract': '📝',
        'delivery_note': '📦',
        'payslip': '💼',
        'bank_statement': '🏦',
        'quote': '💬',
        'receipt': '🛒',
        'identity': '🪪',
        'insurance': '🛡️',
        'other': '📄',
      }[key] ??
      '📄';

  @override
  String toString() => 'CategoryCount($emoji $label: $count)';
}

/// Activité mensuelle (sparkline)
class MonthlyActivity {
  const MonthlyActivity({
    required this.monthLabel,
    required this.year,
    required this.month,
    required this.filesAdded,
    required this.timeSavedMinutes,
  });

  final String monthLabel;
  final int year;
  final int month;
  final int filesAdded;
  final int timeSavedMinutes;

  @override
  String toString() => 'MonthlyActivity($monthLabel $year: $filesAdded files)';
}

/// Fichier récent pour l'historique
class RecentFile {
  const RecentFile({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
    required this.aiClassification,
    required this.createdAt,
    required this.folderId,
  });

  final String id;
  final String name;
  final String mimeType;
  final int sizeBytes;
  final String? aiClassification;
  final DateTime createdAt;
  final String folderId;

  factory RecentFile.fromJson(Map<String, dynamic> json) => RecentFile(
        id: json['id'] as String,
        name: json['name'] as String,
        mimeType: (json['mime_type'] as String?) ?? 'application/octet-stream',
        sizeBytes: (json['size_bytes'] as int?) ?? 0,
        aiClassification: json['ai_classification'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        folderId: json['folder_id'] as String,
      );

  String get sizeFormatted {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(0)} Ko';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }

  String get aiLabel =>
      CategoryCount.labelFromKey(aiClassification ?? 'other');
  String get aiEmoji =>
      CategoryCount.emojiFromKey(aiClassification ?? 'other');

  @override
  String toString() => 'RecentFile($name)';
}

/// Statut de stockage
enum StorageStatus { safe, warning, critical }

/// Quotas de stockage par plan
enum StorageQuota {
  free(1 * 1024 * 1024 * 1024),         // 1 Go
  starter(10 * 1024 * 1024 * 1024),      // 10 Go
  pro(50 * 1024 * 1024 * 1024),          // 50 Go
  expert(200 * 1024 * 1024 * 1024),      // 200 Go
  business(500 * 1024 * 1024 * 1024);    // 500 Go

  const StorageQuota(this.bytes);
  final int bytes;

  static StorageQuota fromPlan(String plan) {
    return switch (plan) {
      'starter' => StorageQuota.starter,
      'pro' => StorageQuota.pro,
      'expert' => StorageQuota.expert,
      'business' => StorageQuota.business,
      _ => StorageQuota.free,
    };
  }
}
