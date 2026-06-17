// ================================================================
// SORTIA — Widget Tuile Dossier
// ================================================================

import 'package:flutter/material.dart';
import 'package:sortia/app/theme/app_colors.dart';
import 'package:sortia/app/theme/app_dimensions.dart';
import 'package:sortia/app/theme/app_typography.dart';
import 'package:sortia/features/explorer/domain/models/folder_model.dart';

/// Tuile de dossier dans la vue liste
class FolderTile extends StatelessWidget {
  /// Crée une tuile de dossier
  const FolderTile({
    super.key,
    required this.folder,
    required this.onTap,
    this.onRename,
    this.onDelete,
  });

  final FolderModel folder;
  final VoidCallback onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

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
            color: folder.colorValue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Icon(
            folder.iconData,
            color: folder.colorValue,
            size: 24,
          ),
        ),
        title: Text(
          folder.name,
          style: AppTypography.bodyLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: folder.description != null
            ? Text(
                folder.description!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (folder.isLocked)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.lock_outlined,
                  size: 16,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            PopupMenuButton<String>(
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
                  case 'delete':
                    onDelete?.call();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Tuile de dossier en mode grille
class FolderGridTile extends StatelessWidget {
  /// Crée une tuile de dossier en mode grille
  const FolderGridTile({
    super.key,
    required this.folder,
    required this.onTap,
  });

  final FolderModel folder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                folder.iconData,
                color: folder.colorValue,
                size: 40,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                folder.name,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
