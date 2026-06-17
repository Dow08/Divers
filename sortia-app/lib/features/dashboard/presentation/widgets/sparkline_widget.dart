// ================================================================
// SORTIA — Widget Sparkline (Activité 6 mois)
// ================================================================

import 'package:flutter/material.dart';

import 'package:sortia/features/dashboard/domain/models/dashboard_stats_model.dart';

/// Graphique en barres de l'activité sur les 6 derniers mois
class SparklineWidget extends StatelessWidget {
  const SparklineWidget({super.key, required this.data});
  final List<MonthlyActivity> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxVal =
        data.map((d) => d.filesAdded).fold(0, (a, b) => a > b ? a : b);

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
              Icon(Icons.bar_chart, color: Color(0xFF2E86C1), size: 18),
              SizedBox(width: 8),
              Text(
                'Activité — 6 derniers mois',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.map((d) {
                final ratio =
                    maxVal == 0 ? 0.0 : d.filesAdded / maxVal;
                final isLast = data.last == d;
                return _SparkBar(
                  label: d.monthLabel,
                  value: d.filesAdded,
                  ratio: ratio,
                  isHighlighted: isLast,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkBar extends StatelessWidget {
  const _SparkBar({
    required this.label,
    required this.value,
    required this.ratio,
    required this.isHighlighted,
  });

  final String label;
  final int value;
  final double ratio;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isHighlighted)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4F72),
              ),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          width: 28,
          height: (ratio * 60).clamp(4.0, 60.0),
          decoration: BoxDecoration(
            color: isHighlighted
                ? const Color(0xFF1B4F72)
                : const Color(0xFFAED6F1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isHighlighted
                ? const Color(0xFF1B4F72)
                : Colors.grey[500],
            fontWeight:
                isHighlighted ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
