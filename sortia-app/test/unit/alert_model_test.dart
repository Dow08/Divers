// ================================================================
// SORTIA — Tests unitaires : AlertModel
// ================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/alerts/domain/models/alert_model.dart';

void main() {
  group('AlertPriority', () {
    test('fromString reconnaît toutes les priorités', () {
      expect(AlertPriority.fromString('low'), AlertPriority.low);
      expect(AlertPriority.fromString('normal'), AlertPriority.normal);
      expect(AlertPriority.fromString('high'), AlertPriority.high);
      expect(AlertPriority.fromString('urgent'), AlertPriority.urgent);
    });

    test('fromString retourne normal par défaut', () {
      expect(AlertPriority.fromString('unknown'), AlertPriority.normal);
    });

    test('chaque priorité a un label et emoji', () {
      for (final p in AlertPriority.values) {
        expect(p.label, isNotEmpty);
        expect(p.emoji, isNotEmpty);
      }
    });
  });

  group('AlertType', () {
    test('fromString reconnaît les types', () {
      expect(AlertType.fromString('deadline'), AlertType.deadline);
      expect(AlertType.fromString('rgpd'), AlertType.rgpd);
      expect(AlertType.fromString('storage'), AlertType.storage);
    });

    test('fromString retourne custom par défaut', () {
      expect(AlertType.fromString('xyz'), AlertType.custom);
    });

    test('contient 8 types', () {
      expect(AlertType.values.length, 8);
    });
  });

  group('AlertModel — fromJson', () {
    final json = {
      'id': 'alert-1',
      'user_id': 'user-1',
      'type': 'deadline',
      'title': 'Déclaration TVA',
      'message': 'Échéance le 15 janvier',
      'related_file_id': 'file-1',
      'related_folder_id': null,
      'trigger_at': '2026-01-15T00:00:00Z',
      'is_read': false,
      'is_dismissed': false,
      'priority': 'high',
      'created_at': '2026-01-01T00:00:00Z',
    };

    test('crée un AlertModel correct', () {
      final alert = AlertModel.fromJson(json);

      expect(alert.id, 'alert-1');
      expect(alert.type, AlertType.deadline);
      expect(alert.title, 'Déclaration TVA');
      expect(alert.priority, AlertPriority.high);
      expect(alert.isRead, false);
    });

    test('message est optionnel', () {
      final alert = AlertModel.fromJson({...json, 'message': null});
      expect(alert.message, isNull);
    });
  });

  group('AlertModel — toJson', () {
    test('sérialise correctement', () {
      final alert = AlertModel(
        id: '1',
        userId: 'u1',
        type: AlertType.rgpd,
        title: 'Alerte RGPD',
        triggerAt: DateTime(2026, 6, 15),
        priority: AlertPriority.urgent,
      );

      final json = alert.toJson();

      expect(json['type'], 'rgpd');
      expect(json['title'], 'Alerte RGPD');
      expect(json['priority'], 'urgent');
    });
  });

  group('AlertModel — computed getters', () {
    test('isOverdue pour date passée', () {
      final alert = AlertModel(
        id: '1',
        userId: 'u1',
        type: AlertType.deadline,
        title: 'Test',
        triggerAt: DateTime.now().subtract(const Duration(days: 5)),
      );
      expect(alert.isOverdue, true);
    });

    test('isOverdue false pour date future', () {
      final alert = AlertModel(
        id: '1',
        userId: 'u1',
        type: AlertType.deadline,
        title: 'Test',
        triggerAt: DateTime.now().add(const Duration(days: 5)),
      );
      expect(alert.isOverdue, false);
    });

    test('isThisWeek pour date dans 3 jours', () {
      final alert = AlertModel(
        id: '1',
        userId: 'u1',
        type: AlertType.deadline,
        title: 'Test',
        triggerAt: DateTime.now().add(const Duration(days: 3)),
      );
      expect(alert.isThisWeek, true);
    });

    test('isThisWeek false pour date dans 10 jours', () {
      final alert = AlertModel(
        id: '1',
        userId: 'u1',
        type: AlertType.deadline,
        title: 'Test',
        triggerAt: DateTime.now().add(const Duration(days: 10)),
      );
      expect(alert.isThisWeek, false);
    });

    test('timeRemainingFormatted pour demain', () {
      final alert = AlertModel(
        id: '1',
        userId: 'u1',
        type: AlertType.deadline,
        title: 'Test',
        triggerAt: DateTime.now().add(const Duration(days: 1, hours: 12)),
      );
      expect(alert.timeRemainingFormatted, 'Demain');
    });

    test('dateFormatted formate correctement', () {
      final alert = AlertModel(
        id: '1',
        userId: 'u1',
        type: AlertType.deadline,
        title: 'Test',
        triggerAt: DateTime(2026, 3, 15),
      );
      expect(alert.dateFormatted, '15 mar 2026');
    });
  });

  group('AlertModel — copyWith', () {
    test('modifie isRead sans toucher les autres', () {
      final alert = AlertModel(
        id: '1',
        userId: 'u1',
        type: AlertType.deadline,
        title: 'Test',
        triggerAt: DateTime(2026, 6, 15),
        isRead: false,
      );

      final updated = alert.copyWith(isRead: true);

      expect(updated.isRead, true);
      expect(updated.title, 'Test');
      expect(updated.type, AlertType.deadline);
    });

    test('modifie isDismissed', () {
      final alert = AlertModel(
        id: '1',
        userId: 'u1',
        type: AlertType.rgpd,
        title: 'RGPD',
        triggerAt: DateTime(2026, 6, 15),
      );

      expect(alert.copyWith(isDismissed: true).isDismissed, true);
    });
  });
}
