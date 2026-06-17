// ================================================================
// SORTIA — Écran Abonnements
// Plans, comparaison, gestion abonnement actif
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sortia/features/subscription/subscription_module.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(currentSubscriptionProvider);
    final currentPlan = ref.watch(currentPlanProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Abonnement'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Plan actuel
          subAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erreur : $e'),
            data: (sub) => _CurrentPlanCard(
              plan: sub?.plan ?? SortiaPlan.free,
              subscription: sub,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Comparer les plans',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),

          // Grille des plans
          ...SortiaPlan.values.map((plan) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PlanCard(
                  plan: plan,
                  isCurrent: plan == currentPlan,
                ),
              )),
        ],
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({required this.plan, this.subscription});
  final SortiaPlan plan;
  final Subscription? subscription;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4F72), Color(0xFF2E86C1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4F72).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(plan.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan ${plan.label}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    plan.priceFormatted,
                    style: const TextStyle(
                      color: Color(0xFFAED6F1),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (subscription != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${subscription!.status.emoji} ${subscription!.status.label}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          if (subscription != null) ...[
            const SizedBox(height: 12),
            Text(
              'Prochain renouvellement : ${subscription!.nextRenewalFormatted}',
              style: const TextStyle(
                color: Color(0xFFAED6F1),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            '${plan.storageGb} Go de stockage',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.isCurrent});
  final SortiaPlan plan;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrent
            ? const BorderSide(color: Color(0xFF1B4F72), width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(plan.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  plan.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                Text(
                  plan.priceFormatted,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B4F72),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...plan.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 14, color: Color(0xFF17A589)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(f,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF566573))),
                      ),
                    ],
                  ),
                )),
            if (!isCurrent && plan != SortiaPlan.free) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17A589),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Choisir ce plan',
                      style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
            if (isCurrent) ...[
              const SizedBox(height: 8),
              const Center(
                child: Text('✅ Plan actuel',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF17A589),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
