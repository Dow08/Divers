// ================================================================
// SORTIA — Widget Répartition IA
// ================================================================

import 'package:flutter/material.dart';

import 'package:sortia/features/dashboard/domain/models/dashboard_stats_model.dart';

/// Répartition des documents par catégorie IA (barres horizontales)
class AiBreakdownWidget extends StatelessWidget {
  const AiBreakdownWidget({super.key, required this.categories});
  final List<CategoryCount> categories;

  @override
  Widget build(BuildContext context) {
    final total = categories.fold<int>(0, (s, c) => s + c.count);

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
          const Row(
            children: [
              Icon(Icons.auto_awesome_outlined,
                  color: Color(0xFF8E44AD), size: 18),
              SizedBox(width: 8),
              Text(
                "Répartition par l'IA",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...categories.map((cat) {
            final ratio = total == 0 ? 0.0 : cat.count / total;
            return _CategoryRow(
              emoji: cat.emoji,
              label: cat.label,
              count: cat.count,
              ratio: ratio,
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.emoji,
    required this.label,
    required this.count,
    required this.ratio,
  });

  final String emoji;
  final String label;
  final int count;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1A1A2E),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: const Color(0xFFEBEEF0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF8E44AD),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF566573),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
