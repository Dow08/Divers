// ================================================================
// SORTIA — Tests unitaires : FolderModel
// ================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/explorer/domain/models/folder_model.dart';

void main() {
  group('FolderModel', () {
    final sampleJson = {
      'id': 'folder-001',
      'user_id': 'user-001',
      'name': 'Comptabilité',
      'parent_id': null,
      'description': 'Documents comptables',
      'color': '#1B4F72',
      'icon': 'money',
      'is_locked': false,
      'sort_order': 0,
      'is_archived': false,
      'path': 'Comptabilité',
      'depth': 0,
      'child_count': 3,
      'file_count': 5,
      'created_at': '2026-01-15T10:30:00Z',
      'updated_at': '2026-02-20T14:00:00Z',
    };

    test('fromJson crée un modèle correct', () {
      final folder = FolderModel.fromJson(sampleJson);

      expect(folder.id, 'folder-001');
      expect(folder.userId, 'user-001');
      expect(folder.name, 'Comptabilité');
      expect(folder.parentId, isNull);
      expect(folder.description, 'Documents comptables');
      expect(folder.color, '#1B4F72');
      expect(folder.icon, 'money');
      expect(folder.isLocked, false);
      expect(folder.depth, 0);
      expect(folder.childCount, 3);
      expect(folder.fileCount, 5);
    });

    test('fromJson gère les valeurs nulles/manquantes', () {
      final minimalJson = {
        'id': 'folder-002',
        'user_id': 'user-001',
        'name': 'Test',
      };
      final folder = FolderModel.fromJson(minimalJson);

      expect(folder.id, 'folder-002');
      expect(folder.name, 'Test');
      expect(folder.parentId, isNull);
      expect(folder.color, '#1B4F72'); // défaut
      expect(folder.isLocked, false);
      expect(folder.depth, 0);
    });

    test('toJson sérialise correctement', () {
      final folder = FolderModel.fromJson(sampleJson);
      final json = folder.toJson();

      expect(json['id'], 'folder-001');
      expect(json['name'], 'Comptabilité');
      expect(json['user_id'], 'user-001');
      expect(json['color'], '#1B4F72');
      expect(json['icon'], 'money');
    });

    test('copyWith modifie un champ', () {
      final folder = FolderModel.fromJson(sampleJson);
      final renamed = folder.copyWith(name: 'Factures');

      expect(renamed.name, 'Factures');
      expect(renamed.id, folder.id); // inchangé
      expect(renamed.color, folder.color); // inchangé
    });

    test('colorValue retourne la couleur Flutter correcte', () {
      final folder = FolderModel.fromJson(sampleJson);
      expect(folder.colorValue.value, 0xFF1B4F72);
    });

    test('colorValue gère une couleur invalide', () {
      final folder = FolderModel.fromJson({...sampleJson, 'color': 'invalide'});
      expect(folder.colorValue.value, 0xFF1B4F72); // fallback
    });

    test('iconData retourne l\'icône correcte', () {
      final folder = FolderModel.fromJson(sampleJson);
      expect(folder.iconData, isNotNull);
    });

    test('equality basée sur id', () {
      final a = FolderModel.fromJson(sampleJson);
      final b = FolderModel.fromJson(sampleJson);
      expect(a, equals(b));
    });

    test('toString contient le nom et l\'id', () {
      final folder = FolderModel.fromJson(sampleJson);
      expect(folder.toString(), contains('Comptabilité'));
      expect(folder.toString(), contains('folder-001'));
    });
  });
}
