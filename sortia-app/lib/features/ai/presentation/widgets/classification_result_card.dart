// ================================================================
// SORTIA — Widget résultat de classification IA
// ================================================================

import 'package:flutter/material.dart';
import 'package:sortia/app/theme/app_colors.dart';
import 'package:sortia/app/theme/app_dimensions.dart';
import 'package:sortia/app/theme/app_typography.dart';
import 'package:sortia/features/ai/domain/classification_types.dart';

/// Affiche le résultat de la classification IA d'un document
class ClassificationResultCard extends StatelessWidget {
  const ClassificationResultCard({
    super.key,
    required this.result,
    this.onAccept,
    this.onReject,
  });

  final AiClassificationResult result;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  Color get _confidenceColor {
    if (result.confidence >= 0.8) return AppColors.success;
    if (result.confidence >= 0.5) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête IA
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Classification IA',
                        style: AppTypography.label.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        result.category.label,
                        style: AppTypography.heading3,
                      ),
                    ],
                  ),
                ),
                // Badge confiance
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _confidenceColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    '${(result.confidence * 100).toStringAsFixed(0)}%',
                    style: AppTypography.label.copyWith(
                      color: _confidenceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingMd),

            // Métadonnées extraites
            if (result.vendorName != null)
              _buildMetadataRow(Icons.business, 'Émetteur', result.vendorName!),
            if (result.documentDate != null)
              _buildMetadataRow(
                  Icons.calendar_today, 'Date', result.documentDate!),
            if (result.documentAmount != null)
              _buildMetadataRow(Icons.euro, 'Montant',
                  '${result.documentAmount!.toStringAsFixed(2)} €'),
            if (result.documentNumber != null)
              _buildMetadataRow(
                  Icons.tag, 'Numéro', result.documentNumber!),
            if (result.suggestedFolder != null)
              _buildMetadataRow(
                  Icons.folder_outlined, 'Dossier suggéré', result.suggestedFolder!),

            // Résumé
            if (result.summary != null) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                result.summary!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // Tags
            if (result.tags.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: result.tags.map((tag) {
                  return Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 11)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppColors.primarySurface,
                  );
                }).toList(),
              ),
            ],

            // Actions
            if (onAccept != null || onReject != null) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onReject != null)
                    TextButton(
                      onPressed: onReject,
                      child: const Text('Ignorer'),
                    ),
                  if (onAccept != null) ...[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Appliquer'),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondaryLight),
          const SizedBox(width: 8),
          Text(
            '$label : ',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
