// ================================================================
// SORTIA — Tests modules finaux
// Notes, Workflow, RGPD, Import batch, Archive
// ================================================================

import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/notes/notes_module.dart';
import 'package:sortia/features/workflow/workflow_module.dart';
import 'package:sortia/features/rgpd/rgpd_module.dart';
import 'package:sortia/features/import_batch/import_module.dart';
import 'package:sortia/features/archive/archive_module.dart';

void main() {
  // ════════════════ NOTES ════════════════════════════════════
  group('NoteType', () {
    test('5 types de notes', () {
      expect(NoteType.values.length, 5);
    });

    test('fromString parse correctement', () {
      expect(NoteType.fromString('text'), NoteType.text);
      expect(NoteType.fromString('checklist'), NoteType.checklist);
      expect(NoteType.fromString('voice'), NoteType.voice);
      expect(NoteType.fromString('inconnu'), NoteType.text);
    });

    test('chaque type a label, icon, emoji', () {
      for (final t in NoteType.values) {
        expect(t.label, isNotEmpty);
        expect(t.emoji, isNotEmpty);
      }
    });
  });

  group('NoteModel', () {
    final json = {
      'id': 'n1',
      'user_id': 'u1',
      'folder_id': 'f1',
      'type': 'text',
      'title': 'Ma note',
      'content': {'text': 'Contenu de la note'},
      'is_pinned': true,
      'tags': ['urgent', 'perso'],
      'created_at': '2025-01-15T10:00:00Z',
      'updated_at': '2025-01-16T10:00:00Z',
    };

    test('fromJson parse correctement', () {
      final note = NoteModel.fromJson(json);
      expect(note.id, 'n1');
      expect(note.type, NoteType.text);
      expect(note.title, 'Ma note');
      expect(note.isPinned, true);
      expect(note.tags, ['urgent', 'perso']);
    });

    test('textContent extrait le texte', () {
      final note = NoteModel.fromJson(json);
      expect(note.textContent, 'Contenu de la note');
    });

    test('preview retourne le titre si présent', () {
      final note = NoteModel.fromJson(json);
      expect(note.preview, 'Ma note');
    });

    test('toJson produit un map valide', () {
      final note = NoteModel.fromJson(json);
      final map = note.toJson();
      expect(map['type'], 'text');
      expect(map['is_pinned'], true);
      expect(map['tags'], ['urgent', 'perso']);
    });

    test('copyWith modifie les champs', () {
      final note = NoteModel.fromJson(json);
      final updated = note.copyWith(title: 'Nouveau titre', isPinned: false);
      expect(updated.title, 'Nouveau titre');
      expect(updated.isPinned, false);
      expect(updated.type, NoteType.text);
    });
  });

  // ════════════════ WORKFLOW ═════════════════════════════════
  group('WorkflowStatus', () {
    test('4 statuts', () {
      expect(WorkflowStatus.values.length, 4);
    });

    test('fromString parse correctement', () {
      expect(WorkflowStatus.fromString('pending'), WorkflowStatus.pending);
      expect(WorkflowStatus.fromString('in_review'), WorkflowStatus.inReview);
      expect(WorkflowStatus.fromString('approved'), WorkflowStatus.approved);
      expect(WorkflowStatus.fromString('rejected'), WorkflowStatus.rejected);
    });

    test('dbValue retourne le format BDD', () {
      expect(WorkflowStatus.inReview.dbValue, 'in_review');
      expect(WorkflowStatus.pending.dbValue, 'pending');
    });
  });

  group('WorkflowModel', () {
    final json = {
      'id': 'wf1',
      'user_id': 'u1',
      'file_id': 'f1',
      'title': 'Approbation contrat',
      'status': 'pending',
      'assigned_to': 'user2',
      'due_date': '2025-01-20T00:00:00Z',
      'created_at': '2025-01-15T10:00:00Z',
    };

    test('fromJson parse correctement', () {
      final wf = WorkflowModel.fromJson(json);
      expect(wf.id, 'wf1');
      expect(wf.title, 'Approbation contrat');
      expect(wf.status, WorkflowStatus.pending);
      expect(wf.assignedTo, 'user2');
    });

    test('isOverdue détecte les retards', () {
      final wf = WorkflowModel.fromJson(json);
      expect(wf.isOverdue, true); // due_date est dans le passé
    });

    test('canAdvance selon le statut', () {
      expect(WorkflowModel.fromJson(json).canAdvance, true);
      expect(
        WorkflowModel.fromJson({...json, 'status': 'approved'}).canAdvance,
        false,
      );
    });
  });

  // ════════════════ RGPD ════════════════════════════════════
  group('RgpdCategory', () {
    test('8 catégories', () {
      expect(RgpdCategory.values.length, 8);
    });
  });

  group('RgpdItemStatus', () {
    test('4 statuts', () {
      expect(RgpdItemStatus.values.length, 4);
    });

    test('chaque statut a label, emoji, color', () {
      for (final s in RgpdItemStatus.values) {
        expect(s.label, isNotEmpty);
        expect(s.emoji, isNotEmpty);
      }
    });
  });

  group('RgpdDiagnostic', () {
    test('score calculé correctement', () {
      final diag = RgpdDiagnostic(
        items: RgpdTemplateItems.defaultItems,
        lastRunAt: DateTime.now(),
      );
      expect(diag.score, greaterThanOrEqualTo(0));
      expect(diag.score, lessThanOrEqualTo(100));
    });

    test('actionCount compte les items non conformes', () {
      final diag = RgpdDiagnostic(
        items: RgpdTemplateItems.defaultItems,
        lastRunAt: DateTime.now(),
      );
      expect(diag.actionCount, greaterThan(0));
    });

    test('scoreColor change selon le score', () {
      final full = RgpdDiagnostic(items: [
        const RgpdCheckItem(
          id: 'x', category: RgpdCategory.security,
          title: 'Test', description: 'Test',
          status: RgpdItemStatus.compliant,
        ),
      ], lastRunAt: DateTime.now());
      expect(full.score, 100);
      expect(full.scoreColor, const Color(0xFF17A589));
    });

    test('items par défaut contiennent 10 éléments', () {
      expect(RgpdTemplateItems.defaultItems.length, 10);
    });
  });

  // ════════════════ IMPORT BATCH ═════════════════════════════
  group('ImportSource', () {
    test('4 sources', () {
      expect(ImportSource.values.length, 4);
    });
  });

  group('ImportJobStatus', () {
    test('4 statuts', () {
      expect(ImportJobStatus.values.length, 4);
    });

    test('fromString parse correctement', () {
      expect(ImportJobStatus.fromString('running'), ImportJobStatus.running);
      expect(ImportJobStatus.fromString('completed'), ImportJobStatus.completed);
      expect(ImportJobStatus.fromString('xxx'), ImportJobStatus.pending);
    });
  });

  group('ImportJob', () {
    final json = {
      'id': 'ij1',
      'user_id': 'u1',
      'source': 'drive',
      'status': 'running',
      'total_files': 20,
      'processed_files': 15,
      'classified_files': 12,
      'failed_files': 1,
      'started_at': '2025-01-15T10:00:00Z',
    };

    test('fromJson parse correctement', () {
      final job = ImportJob.fromJson(json);
      expect(job.id, 'ij1');
      expect(job.status, ImportJobStatus.running);
      expect(job.totalFiles, 20);
      expect(job.processedFiles, 15);
    });

    test('progress calculé correctement', () {
      final job = ImportJob.fromJson(json);
      expect(job.progress, 0.75);
    });

    test('sourceType résolu correctement', () {
      final job = ImportJob.fromJson(json);
      expect(job.sourceType, ImportSource.drive);
    });

    test('progressFormatted affiche correctement', () {
      final job = ImportJob.fromJson(json);
      expect(job.progressFormatted, '15 / 20 fichiers');
    });
  });

  // ════════════════ ARCHIVE ═════════════════════════════════
  group('ArchiveItem', () {
    final json = {
      'id': 'a1',
      'user_id': 'u1',
      'file_id': 'f1',
      'file_name': 'Contrat 2024.pdf',
      'reason': 'Fin de contrat',
      'retention_years': 5,
      'archived_at': '2025-01-15T10:00:00Z',
      'expires_at': '2030-01-15T10:00:00Z',
      'is_locked': true,
    };

    test('fromJson parse correctement', () {
      final item = ArchiveItem.fromJson(json);
      expect(item.id, 'a1');
      expect(item.fileName, 'Contrat 2024.pdf');
      expect(item.retentionYears, 5);
      expect(item.isLocked, true);
    });

    test('isExpired détecte les archives expirées', () {
      final item = ArchiveItem.fromJson(json);
      expect(item.isExpired, false); // 2030 pas encore passé

      final expired = ArchiveItem.fromJson({
        ...json,
        'expires_at': '2020-01-01T00:00:00Z',
      });
      expect(expired.isExpired, true);
    });

    test('retentionFormatted affiche correctement', () {
      final item = ArchiveItem.fromJson(json);
      expect(item.retentionFormatted, contains('ans'));
    });

    test('archivedFormatted affiche la date', () {
      final item = ArchiveItem.fromJson(json);
      expect(item.archivedFormatted, '15/1/2025');
    });

    test('toJson produit un map valide', () {
      final item = ArchiveItem.fromJson(json);
      final map = item.toJson();
      expect(map['file_name'], 'Contrat 2024.pdf');
      expect(map['retention_years'], 5);
      expect(map['is_locked'], true);
    });
  });
}
