// ================================================================
// SORTIA — Modèle Fichier
// ================================================================

import 'package:flutter/material.dart';

/// Modèle représentant un fichier dans l'arborescence
class FileModel {
  /// Crée un modèle fichier
  const FileModel({
    required this.id,
    required this.userId,
    required this.folderId,
    required this.name,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
    required this.storagePath,
    this.storageBucket = 'documents',
    this.aiClassification,
    this.aiConfidence,
    this.documentDate,
    this.documentAmount,
    this.vendorName,
    this.documentNumber,
    this.contentText,
    this.isArchived = false,
    this.isShared = false,
    this.version = 1,
    this.createdAt,
    this.updatedAt,
  });

  /// Crée un FileModel depuis un Map JSON (Supabase)
  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      folderId: json['folder_id'] as String,
      name: json['name'] as String,
      originalName: (json['original_name'] as String?) ?? json['name'] as String,
      mimeType: (json['mime_type'] as String?) ?? 'application/octet-stream',
      sizeBytes: (json['size_bytes'] as int?) ?? 0,
      storagePath: (json['storage_path'] as String?) ?? '',
      storageBucket: (json['storage_bucket'] as String?) ?? 'documents',
      aiClassification: json['ai_classification'] as String?,
      aiConfidence: (json['ai_confidence'] as num?)?.toDouble(),
      documentDate: json['document_date'] != null
          ? DateTime.tryParse(json['document_date'] as String)
          : null,
      documentAmount: json['document_amount'] != null
          ? double.tryParse(json['document_amount'].toString())
          : null,
      vendorName: json['vendor_name'] as String?,
      documentNumber: json['document_number'] as String?,
      contentText: json['content_text'] as String?,
      isArchived: (json['is_archived'] as bool?) ?? false,
      isShared: (json['is_shared'] as bool?) ?? false,
      version: (json['version'] as int?) ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String userId;
  final String folderId;
  final String name;
  final String originalName;
  final String mimeType;
  final int sizeBytes;
  final String storagePath;
  final String storageBucket;
  final String? aiClassification;
  final double? aiConfidence;
  final DateTime? documentDate;
  final double? documentAmount;
  final String? vendorName;
  final String? documentNumber;
  final String? contentText;
  final bool isArchived;
  final bool isShared;
  final int version;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Taille formatée (Ko, Mo, Go)
  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes o';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} Ko';
    }
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} Go';
  }

  /// Icône selon le type MIME
  IconData get fileIcon {
    if (mimeType.startsWith('image/')) return Icons.image_outlined;
    if (mimeType.startsWith('video/')) return Icons.videocam_outlined;
    if (mimeType.startsWith('audio/')) return Icons.audiotrack_outlined;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (mimeType.contains('spreadsheet') || mimeType.contains('excel')) {
      return Icons.table_chart_outlined;
    }
    if (mimeType.contains('presentation') || mimeType.contains('powerpoint')) {
      return Icons.slideshow_outlined;
    }
    if (mimeType.contains('word') || mimeType.contains('document')) {
      return Icons.article_outlined;
    }
    if (mimeType.contains('text')) return Icons.text_snippet_outlined;
    if (mimeType.contains('zip') || mimeType.contains('archive')) {
      return Icons.archive_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  /// Couleur selon le type MIME
  Color get fileColor {
    if (mimeType.contains('pdf')) return const Color(0xFFE53935);
    if (mimeType.startsWith('image/')) return const Color(0xFF43A047);
    if (mimeType.contains('spreadsheet') || mimeType.contains('excel')) {
      return const Color(0xFF1B5E20);
    }
    if (mimeType.contains('word') || mimeType.contains('document')) {
      return const Color(0xFF1565C0);
    }
    if (mimeType.contains('presentation')) return const Color(0xFFE65100);
    return const Color(0xFF616161);
  }

  /// Extension du fichier
  String get extension {
    final dot = name.lastIndexOf('.');
    if (dot == -1) return '';
    return name.substring(dot + 1).toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'folder_id': folderId,
      'name': name,
      'original_name': originalName,
      'mime_type': mimeType,
      'size_bytes': sizeBytes,
      'storage_path': storagePath,
      'storage_bucket': storageBucket,
      'ai_classification': aiClassification,
      'ai_confidence': aiConfidence,
      'document_date': documentDate?.toIso8601String(),
      'document_amount': documentAmount,
      'vendor_name': vendorName,
      'document_number': documentNumber,
      'is_archived': isArchived,
      'is_shared': isShared,
      'version': version,
    };
  }

  FileModel copyWith({
    String? name,
    String? folderId,
    String? aiClassification,
    double? aiConfidence,
    String? vendorName,
    bool? isArchived,
    bool? isShared,
  }) {
    return FileModel(
      id: id,
      userId: userId,
      folderId: folderId ?? this.folderId,
      name: name ?? this.name,
      originalName: originalName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      storagePath: storagePath,
      storageBucket: storageBucket,
      aiClassification: aiClassification ?? this.aiClassification,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      documentDate: documentDate,
      documentAmount: documentAmount,
      vendorName: vendorName ?? this.vendorName,
      documentNumber: documentNumber,
      contentText: contentText,
      isArchived: isArchived ?? this.isArchived,
      isShared: isShared ?? this.isShared,
      version: version,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'FileModel(id: $id, name: $name, size: $formattedSize)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FileModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
