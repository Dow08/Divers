// ================================================================
// SORTIA — Widget Temps Économisé
// ================================================================

import 'package:flutter/material.dart';

import 'package:sortia/features/dashboard/domain/models/dashboard_stats_model.dart';

/// Carte "Temps économisé" avec gradient bleu et icône IA
class TimeSavedWidget extends StatelessWidget {
  const TimeSavedWidget({super.key, required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4F72), Color(0xFF2E86C1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4F72).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFFF8C471), size: 16),
              SizedBox(width: 6),
              Text(
                'Temps économisé',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFAED6F1),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            stats.timeSavedFormatted,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'grâce à la classification IA',
            style: TextStyle(fontSize: 11, color: Color(0xFFAED6F1)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '2 min économisées par document classifié',
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
