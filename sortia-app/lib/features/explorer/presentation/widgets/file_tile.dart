// ================================================================
// SORTIA — Widget Tuile Fichier
// ================================================================

import 'package:flutter/material.dart';
import 'package:sortia/app/theme/app_colors.dart';
import 'package:sortia/app/theme/app_dimensions.dart';
import 'package:sortia/app/theme/app_typography.dart';
import 'package:sortia/features/explorer/domain/models/file_model.dart';

/// Tuile de fichier dans la vue liste
class FileTile extends StatelessWidget {
  /// Crée une tuile de fichier
  const FileTile({
    super.key,
    required this.file,
    this.onTap,
    this.onRename,
    this.onDelete,
    this.onShare,
  });

  final FileModel file;
  final VoidCallback? onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingXxs,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: file.fileColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(file.fileIcon, color: file.fileColor, size: 20),
              if (file.extension.isNotEmpty)
                Text(
                  file.extension,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: file.fileColor,
                  ),
                ),
            ],
          ),
        ),
        title: Text(
          file.name,
          style: AppTypography.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              file.formattedSize,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            if (file.aiClassification != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  file.aiClassification!,
                  style: AppTypography.label.copyWith(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
            if (file.isShared) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.share_outlined,
                size: 14,
                color: AppColors.textSecondaryLight,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rename',
              child: ListTile(
                leading: Icon(Icons.edit_outlined, size: 20),
                title: Text('Renommer'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share_outlined, size: 20),
                title: Text('Partager'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, size: 20, color: Colors.red),
                title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                dense: true,
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'rename':
                onRename?.call();
              case 'share':
                onShare?.call();
              case 'delete':
                onDelete?.call();
            }
          },
        ),
      ),
    );
  }
}
