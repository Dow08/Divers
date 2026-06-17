// ================================================================
// SORTIA — Tests unitaires : FileModel
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/explorer/domain/models/file_model.dart';

void main() {
  group('FileModel', () {
    final sampleJson = {
      'id': 'file-001',
      'user_id': 'user-001',
      'folder_id': 'folder-001',
      'name': 'facture_janvier.pdf',
      'original_name': 'facture_janvier.pdf',
      'mime_type': 'application/pdf',
      'size_bytes': 2457600,
      'storage_path': 'user-001/folder-001/facture_janvier.pdf',
      'storage_bucket': 'documents',
      'ai_classification': 'Facture',
      'ai_confidence': 0.95,
      'document_date': '2026-01-15',
      'document_amount': 1250.50,
      'vendor_name': 'ACME Corp',
      'document_number': 'FA-2026-001',
      'is_archived': false,
      'is_shared': false,
      'version': 1,
      'created_at': '2026-01-15T10:30:00Z',
    };

    test('fromJson crée un modèle correct', () {
      final file = FileModel.fromJson(sampleJson);

      expect(file.id, 'file-001');
      expect(file.name, 'facture_janvier.pdf');
      expect(file.mimeType, 'application/pdf');
      expect(file.sizeBytes, 2457600);
      expect(file.aiClassification, 'Facture');
      expect(file.aiConfidence, 0.95);
      expect(file.vendorName, 'ACME Corp');
      expect(file.documentNumber, 'FA-2026-001');
    });

    test('fromJson gère les valeurs minimales', () {
      final minimalJson = {
        'id': 'file-002',
        'user_id': 'user-001',
        'folder_id': 'folder-001',
        'name': 'doc.txt',
      };
      final file = FileModel.fromJson(minimalJson);

      expect(file.id, 'file-002');
      expect(file.name, 'doc.txt');
      expect(file.mimeType, 'application/octet-stream'); // défaut
      expect(file.sizeBytes, 0);
    });

    test('formattedSize affiche les octets', () {
      final file = FileModel.fromJson({...sampleJson, 'size_bytes': 500});
      expect(file.formattedSize, '500 o');
    });

    test('formattedSize affiche les Ko', () {
      final file = FileModel.fromJson({...sampleJson, 'size_bytes': 5120});
      expect(file.formattedSize, '5.0 Ko');
    });

    test('formattedSize affiche les Mo', () {
      final file = FileModel.fromJson(sampleJson); // 2457600
      expect(file.formattedSize, '2.3 Mo');
    });

    test('formattedSize affiche les Go', () {
      final file = FileModel.fromJson({...sampleJson, 'size_bytes': 1610612736});
      expect(file.formattedSize, '1.5 Go');
    });

    test('extension retourne PDF', () {
      final file = FileModel.fromJson(sampleJson);
      expect(file.extension, 'PDF');
    });

    test('extension retourne vide pour fichier sans extension', () {
      final file = FileModel.fromJson({...sampleJson, 'name': 'readme'});
      expect(file.extension, '');
    });

    test('fileIcon retourne PDF icon pour PDF', () {
      final file = FileModel.fromJson(sampleJson);
      expect(file.fileIcon, Icons.picture_as_pdf_outlined);
    });

    test('fileIcon retourne image icon pour JPEG', () {
      final file = FileModel.fromJson({...sampleJson, 'mime_type': 'image/jpeg'});
      expect(file.fileIcon, Icons.image_outlined);
    });

    test('fileColor retourne rouge pour PDF', () {
      final file = FileModel.fromJson(sampleJson);
      expect(file.fileColor, const Color(0xFFE53935));
    });

    test('toJson sérialise correctement', () {
      final file = FileModel.fromJson(sampleJson);
      final json = file.toJson();

      expect(json['id'], 'file-001');
      expect(json['name'], 'facture_janvier.pdf');
      expect(json['mime_type'], 'application/pdf');
    });

    test('copyWith modifie un champ', () {
      final file = FileModel.fromJson(sampleJson);
      final renamed = file.copyWith(name: 'facture_février.pdf');

      expect(renamed.name, 'facture_février.pdf');
      expect(renamed.id, file.id);
      expect(renamed.mimeType, file.mimeType);
    });

    test('equality basée sur id', () {
      final a = FileModel.fromJson(sampleJson);
      final b = FileModel.fromJson(sampleJson);
      expect(a, equals(b));
    });
  });
}
