// ================================================================
// SORTIA — Tests unitaires : UserPreferences
// ================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/settings/domain/models/user_preferences.dart';

void main() {
  group('UserPreferences', () {
    test('valeurs par défaut', () {
      const prefs = UserPreferences();
      expect(prefs.plan, 'free');
      expect(prefs.planLabel, 'Gratuit');
      expect(prefs.planEmoji, '🆓');
      expect(prefs.themeMode, AppThemeMode.system);
      expect(prefs.language, 'fr');
      expect(prefs.notificationsEnabled, true);
      expect(prefs.autoClassify, true);
      expect(prefs.defaultView, ViewMode.list);
    });

    test('planLabel retourne le bon label pour chaque plan', () {
      expect(
          const UserPreferences(plan: 'free').planLabel, 'Gratuit');
      expect(
          const UserPreferences(plan: 'starter').planLabel, 'Starter');
      expect(const UserPreferences(plan: 'pro').planLabel, 'Pro');
      expect(
          const UserPreferences(plan: 'expert').planLabel, 'Expert');
      expect(const UserPreferences(plan: 'business').planLabel,
          'Business');
    });

    test('planEmoji retourne le bon emoji', () {
      expect(const UserPreferences(plan: 'pro').planEmoji, '💎');
      expect(const UserPreferences(plan: 'business').planEmoji, '🏢');
    });

    test('storageFormatted affiche correctement', () {
      const prefs = UserPreferences(
        storageUsedBytes: 536870912, // 0.5 Go
        storageQuotaBytes: 1073741824, // 1 Go
      );
      expect(prefs.storageFormatted, '0.5 / 1 Go');
    });

    test('storageRate calcule correctement', () {
      const prefs = UserPreferences(
        storageUsedBytes: 536870912,
        storageQuotaBytes: 1073741824,
      );
      expect(prefs.storageRate, closeTo(0.5, 0.01));
    });

    test('storageRate 0 si quota 0', () {
      const prefs = UserPreferences(storageQuotaBytes: 0);
      expect(prefs.storageRate, 0);
    });

    test('copyWith modifie un champ', () {
      const prefs = UserPreferences();
      final updated = prefs.copyWith(
        themeMode: AppThemeMode.dark,
        plan: 'pro',
      );
      expect(updated.themeMode, AppThemeMode.dark);
      expect(updated.plan, 'pro');
      expect(updated.language, 'fr'); // non modifié
    });
  });

  group('AppThemeMode', () {
    test('chaque mode a un label et emoji', () {
      for (final m in AppThemeMode.values) {
        expect(m.label, isNotEmpty);
        expect(m.emoji, isNotEmpty);
      }
    });

    test('contient 3 modes', () {
      expect(AppThemeMode.values.length, 3);
    });
  });

  group('ViewMode', () {
    test('chaque mode a un label et emoji', () {
      for (final m in ViewMode.values) {
        expect(m.label, isNotEmpty);
        expect(m.emoji, isNotEmpty);
      }
    });

    test('contient 2 modes', () {
      expect(ViewMode.values.length, 2);
    });
  });
}
