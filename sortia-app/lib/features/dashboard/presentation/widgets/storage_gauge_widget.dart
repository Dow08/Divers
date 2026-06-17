// ================================================================
// SORTIA — Widget Jauge de Stockage
// ================================================================

import 'package:flutter/material.dart';

import 'package:sortia/features/dashboard/domain/models/dashboard_stats_model.dart';

/// Jauge de stockage avec barre de progression colorée
class StorageGaugeWidget extends StatelessWidget {
  const StorageGaugeWidget({super.key, required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final rate = stats.storageUsageRate.clamp(0.0, 1.0);
    final Color gaugeColor = switch (stats.storageStatus) {
      StorageStatus.warning => const Color(0xFFE67E22),
      StorageStatus.critical => const Color(0xFFE74C3C),
      StorageStatus.safe => const Color(0xFF17A589),
    };

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
              const Text(
                'Stockage',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Icon(Icons.cloud_outlined, color: gaugeColor, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 8,
              backgroundColor: const Color(0xFFEBEEF0),
              valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stats.storageUsedFormatted,
                style: TextStyle(
                  fontSize: 12,
                  color: gaugeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                stats.storageQuotaFormatted,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF566573),
                ),
              ),
            ],
          ),
          if (stats.storageStatus == StorageStatus.critical)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '⚠️ Stockage presque plein — pensez à archiver',
                style: TextStyle(fontSize: 11, color: gaugeColor),
              ),
            ),
        ],
      ),
    );
  }
}
