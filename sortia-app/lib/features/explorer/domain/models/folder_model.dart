// ================================================================
// SORTIA — Modèle Dossier
// ================================================================

import 'package:flutter/material.dart';

/// Modèle représentant un dossier dans l'arborescence
class FolderModel {
  /// Crée un modèle dossier
  const FolderModel({
    required this.id,
    required this.userId,
    required this.name,
    this.parentId,
    this.description,
    this.color = '#1B4F72',
    this.icon,
    this.isLocked = false,
    this.sortOrder = 0,
    this.isArchived = false,
    this.path,
    this.depth = 0,
    this.childCount = 0,
    this.fileCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Crée un FolderModel depuis un Map JSON (Supabase)
  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      parentId: json['parent_id'] as String?,
      description: json['description'] as String?,
      color: (json['color'] as String?) ?? '#1B4F72',
      icon: json['icon'] as String?,
      isLocked: (json['is_locked'] as bool?) ?? false,
      sortOrder: (json['sort_order'] as int?) ?? 0,
      isArchived: (json['is_archived'] as bool?) ?? false,
      path: json['path'] as String?,
      depth: (json['depth'] as int?) ?? 0,
      childCount: (json['child_count'] as int?) ?? 0,
      fileCount: (json['file_count'] as int?) ?? 0,
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
  final String name;
  final String? parentId;
  final String? description;
  final String color;
  final String? icon;
  final bool isLocked;
  final int sortOrder;
  final bool isArchived;
  final String? path;
  final int depth;
  final int childCount;
  final int fileCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Couleur Flutter à partir du hex
  Color get colorValue {
    try {
      final hex = color.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF1B4F72);
    }
  }

  /// Icône Flutter à partir du nom
  IconData get iconData {
    const iconMap = {
      'folder': Icons.folder_rounded,
      'work': Icons.work_outline_rounded,
      'home': Icons.home_outlined,
      'health': Icons.health_and_safety_outlined,
      'car': Icons.directions_car_outlined,
      'money': Icons.attach_money_rounded,
      'tax': Icons.receipt_long_outlined,
      'insurance': Icons.shield_outlined,
      'contract': Icons.description_outlined,
      'bank': Icons.account_balance_outlined,
      'school': Icons.school_outlined,
      'legal': Icons.gavel_rounded,
    };
    return iconMap[icon] ?? Icons.folder_rounded;
  }

  /// Sérialise en Map JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'parent_id': parentId,
      'description': description,
      'color': color,
      'icon': icon,
      'is_locked': isLocked,
      'sort_order': sortOrder,
      'is_archived': isArchived,
      'path': path,
      'depth': depth,
    };
  }

  FolderModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? parentId,
    String? description,
    String? color,
    String? icon,
    bool? isLocked,
    int? sortOrder,
    bool? isArchived,
    String? path,
    int? depth,
    int? childCount,
    int? fileCount,
  }) {
    return FolderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isLocked: isLocked ?? this.isLocked,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      path: path ?? this.path,
      depth: depth ?? this.depth,
      childCount: childCount ?? this.childCount,
      fileCount: fileCount ?? this.fileCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'FolderModel(id: $id, name: $name, depth: $depth)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FolderModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
