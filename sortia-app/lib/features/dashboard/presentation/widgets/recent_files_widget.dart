// ================================================================
// SORTIA — Widget Fichiers Récents
// ================================================================

import 'package:flutter/material.dart';

import 'package:sortia/features/dashboard/domain/models/dashboard_stats_model.dart';

/// Liste des derniers fichiers importés avec temps relatif
class RecentFilesWidget extends StatelessWidget {
  const RecentFilesWidget({super.key, required this.files});
  final List<RecentFile> files;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history, color: Color(0xFF2E86C1), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Activité récente',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Voir tout',
                  style: TextStyle(fontSize: 12, color: Color(0xFF2E86C1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...files.take(10).map((f) => _RecentFileRow(file: f)),
        ],
      ),
    );
  }
}

class _RecentFileRow extends StatelessWidget {
  const _RecentFileRow({required this.file});
  final RecentFile file;

  @override
  Widget build(BuildContext context) {
    final diff = DateTime.now().difference(file.createdAt);
    final String timeAgo;
    if (diff.inMinutes < 60) {
      timeAgo = 'il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      timeAgo = 'il y a ${diff.inHours}h';
    } else {
      timeAgo = 'il y a ${diff.inDays}j';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF5FB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                file.aiEmoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${file.aiLabel}  •  ${file.sizeFormatted}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF566573),
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: const TextStyle(fontSize: 11, color: Color(0xFF566573)),
          ),
        ],
      ),
    );
  }
}
