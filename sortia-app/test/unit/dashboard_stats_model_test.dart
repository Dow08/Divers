// ================================================================
// SORTIA — Tests unitaires : DashboardStats (10+ tests)
// ================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/dashboard/domain/models/dashboard_stats_model.dart';

void main() {
  DashboardStats makeStats({
    int totalFiles = 100,
    int totalFolders = 20,
    int unreadAlerts = 3,
    int storageUsedBytes = 2 * 1024 * 1024 * 1024,  // 2 Go
    int storageQuotaBytes = 10 * 1024 * 1024 * 1024, // 10 Go
    int aiClassifiedFiles = 80,
    int filesImportedThisMonth = 12,
    int timeSavedMinutes = 200,
  }) =>
      DashboardStats(
        totalFiles: totalFiles,
        totalFolders: totalFolders,
        unreadAlerts: unreadAlerts,
        storageUsedBytes: storageUsedBytes,
        storageQuotaBytes: storageQuotaBytes,
        aiClassifiedFiles: aiClassifiedFiles,
        filesImportedThisMonth: filesImportedThisMonth,
        timeSavedMinutes: timeSavedMinutes,
        topCategories: const [],
        monthlyActivity: const [],
      );

  group('DashboardStats — constructeur et modèle vide', () {
    test('TEST 1 — empty() retourne des valeurs zéro cohérentes', () {
      final s = DashboardStats.empty();
      expect(s.totalFiles, 0);
      expect(s.totalFolders, 0);
      expect(s.unreadAlerts, 0);
      expect(s.aiClassifiedFiles, 0);
      expect(s.timeSavedMinutes, 0);
      expect(s.topCategories, isEmpty);
      expect(s.monthlyActivity, isEmpty);
    });

    test('TEST 2 — empty() quota = 1 Go (plan free)', () {
      expect(DashboardStats.empty().storageQuotaBytes,
          StorageQuota.free.bytes);
    });
  });

  group('DashboardStats — aiClassificationRate', () {
    test('TEST 3 — 80/100 = 0.80', () {
      expect(makeStats().aiClassificationRate, closeTo(0.80, 0.001));
    });

    test('TEST 4 — 0 fichiers → 0.0 (pas de division par zéro)', () {
      expect(
        makeStats(totalFiles: 0, aiClassifiedFiles: 0)
            .aiClassificationRate,
        0.0,
      );
    });

    test('TEST 5 — 50/50 = 1.0', () {
      expect(
        makeStats(totalFiles: 50, aiClassifiedFiles: 50)
            .aiClassificationRate,
        1.0,
      );
    });
  });

  group('DashboardStats — stockage', () {
    test('TEST 6 — formatage en Go pour les grandes valeurs', () {
      final s = makeStats();
      expect(s.storageUsedFormatted, contains('Go'));
      expect(s.storageQuotaFormatted, contains('Go'));
    });

    test('TEST 7 — storageStatus : safe / warning / critical', () {
      expect(
        makeStats(
          storageUsedBytes: 5 * 1024 * 1024 * 1024,
          storageQuotaBytes: 10 * 1024 * 1024 * 1024,
        ).storageStatus,
        StorageStatus.safe,
      );
      expect(
        makeStats(
          storageUsedBytes: 8 * 1024 * 1024 * 1024,
          storageQuotaBytes: 10 * 1024 * 1024 * 1024,
        ).storageStatus,
        StorageStatus.warning,
      );
      expect(
        makeStats(
          storageUsedBytes: 95 * 1024 * 1024 * 1024,
          storageQuotaBytes: 100 * 1024 * 1024 * 1024,
        ).storageStatus,
        StorageStatus.critical,
      );
    });
  });

  group('DashboardStats — timeSavedFormatted', () {
    test('TEST 8 — 45 min → "45 min"', () {
      expect(makeStats(timeSavedMinutes: 45).timeSavedFormatted, '45 min');
    });

    test('TEST 9 — 60 min → "1h"', () {
      expect(makeStats(timeSavedMinutes: 60).timeSavedFormatted, '1h');
    });

    test('TEST 10 — 200 min → "3h 20min"', () {
      expect(
          makeStats(timeSavedMinutes: 200).timeSavedFormatted, '3h 20min');
    });
  });

  group('StorageQuota — fromPlan()', () {
    test('retourne les bons quotas pour chaque plan', () {
      expect(StorageQuota.fromPlan('free').bytes, 1 * 1024 * 1024 * 1024);
      expect(StorageQuota.fromPlan('starter').bytes,
          10 * 1024 * 1024 * 1024);
      expect(
          StorageQuota.fromPlan('pro').bytes, 50 * 1024 * 1024 * 1024);
      expect(StorageQuota.fromPlan('expert').bytes,
          200 * 1024 * 1024 * 1024);
      expect(StorageQuota.fromPlan('business').bytes,
          500 * 1024 * 1024 * 1024);
      expect(StorageQuota.fromPlan('unknown').bytes,
          StorageQuota.free.bytes);
    });
  });

  group('CategoryCount — helpers', () {
    test('labelFromKey retourne le bon libellé français', () {
      expect(CategoryCount.labelFromKey('invoice'), 'Factures');
      expect(CategoryCount.labelFromKey('contract'), 'Contrats');
      expect(CategoryCount.labelFromKey('delivery_note'),
          'Bons de livraison');
      expect(CategoryCount.labelFromKey('unknown'), 'unknown');
    });

    test('emojiFromKey retourne le bon emoji', () {
      expect(CategoryCount.emojiFromKey('invoice'), '🧾');
      expect(CategoryCount.emojiFromKey('contract'), '📝');
      expect(CategoryCount.emojiFromKey('other'), '📄');
    });
  });

  group('RecentFile', () {
    test('fromJson crée un fichier correct', () {
      final file = RecentFile.fromJson({
        'id': 'f1',
        'name': 'facture.pdf',
        'mime_type': 'application/pdf',
        'size_bytes': 2457600,
        'ai_classification': 'invoice',
        'created_at': '2026-01-15T10:30:00Z',
        'folder_id': 'folder1',
      });

      expect(file.name, 'facture.pdf');
      expect(file.sizeFormatted, '2.3 Mo');
      expect(file.aiLabel, 'Factures');
      expect(file.aiEmoji, '🧾');
    });

    test('sizeFormatted affiche Ko pour petits fichiers', () {
      final file = RecentFile.fromJson({
        'id': 'f2',
        'name': 'note.txt',
        'size_bytes': 5120,
        'created_at': '2026-01-15T10:30:00Z',
        'folder_id': 'folder1',
      });

      expect(file.sizeFormatted, '5 Ko');
    });
  });

  group('DashboardStats — copyWith', () {
    test('copyWith modifie un champ', () {
      final s = makeStats();
      final updated = s.copyWith(totalFiles: 999);

      expect(updated.totalFiles, 999);
      expect(updated.totalFolders, s.totalFolders);
    });
  });
}
