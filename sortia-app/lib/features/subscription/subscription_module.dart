// ================================================================
// SORTIA — Modèle Subscription + Repository + Providers
// Gestion des abonnements Stripe
// ================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sortia/core/utils/logger.dart';

// ── Modèle ───────────────────────────────────────────────────

/// Plan d'abonnement SORTIA
enum SortiaPlan {
  free('Gratuit', 0, 1, '🆓'),
  starter('Starter', 990, 10, '⭐'),
  pro('Pro', 2490, 50, '💎'),
  expert('Expert', 4990, 200, '🏆'),
  business('Business', 9990, 500, '🏢');

  const SortiaPlan(this.label, this.priceMonthly, this.storageGb, this.emoji);
  final String label;

  /// Prix en centimes
  final int priceMonthly;

  /// Stockage en Go
  final int storageGb;
  final String emoji;

  /// Prix formaté (ex: "9,90 €/mois")
  String get priceFormatted {
    if (priceMonthly == 0) return 'Gratuit';
    return '${(priceMonthly / 100).toStringAsFixed(2).replaceAll('.', ',')} €/mois';
  }

  /// Fonctionnalités du plan
  List<String> get features => switch (this) {
        SortiaPlan.free => [
            '1 Go de stockage',
            'Classification IA basique',
            '50 documents/mois',
          ],
        SortiaPlan.starter => [
            '10 Go de stockage',
            'Classification IA avancée',
            'Illimité documents',
            'Scanner OCR',
          ],
        SortiaPlan.pro => [
            '50 Go de stockage',
            'Classification IA premium',
            'Partage sécurisé',
            'Coffre-fort numérique',
            'Comptes email illimités',
          ],
        SortiaPlan.expert => [
            '200 Go de stockage',
            'Toutes fonctionnalités Pro',
            'Signature électronique',
            'API accès',
            'Support prioritaire',
          ],
        SortiaPlan.business => [
            '500 Go de stockage',
            'Toutes fonctionnalités Expert',
            'Multi-utilisateurs',
            'SSO entreprise',
            'SLA garanti',
          ],
      };

  static SortiaPlan fromString(String name) {
    return SortiaPlan.values.firstWhere(
      (p) => p.name == name.toLowerCase(),
      orElse: () => SortiaPlan.free,
    );
  }
}

/// Statut d'abonnement Stripe
enum SubscriptionStatus {
  active('Actif', '✅'),
  pastDue('Paiement en retard', '⚠️'),
  canceled('Annulé', '❌'),
  trialing('Essai', '🎁'),
  incomplete('Incomplet', '⏳'),
  unpaid('Impayé', '🔴');

  const SubscriptionStatus(this.label, this.emoji);
  final String label;
  final String emoji;

  static SubscriptionStatus fromString(String value) {
    return SubscriptionStatus.values.firstWhere(
      (s) => s.name == value.toLowerCase(),
      orElse: () => SubscriptionStatus.incomplete,
    );
  }
}

/// Modèle d'abonnement
class Subscription {
  const Subscription({
    required this.id,
    required this.userId,
    this.stripeSubscriptionId,
    this.stripePriceId,
    required this.plan,
    required this.status,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String? stripeSubscriptionId;
  final String? stripePriceId;
  final SortiaPlan plan;
  final SubscriptionStatus status;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime? createdAt;

  /// Jours restants dans la période
  int get daysRemaining {
    if (currentPeriodEnd == null) return 0;
    return currentPeriodEnd!.difference(DateTime.now()).inDays;
  }

  /// Prochain renouvellement formaté
  String get nextRenewalFormatted {
    if (cancelAtPeriodEnd) return 'Pas de renouvellement';
    if (currentPeriodEnd == null) return '-';
    return '${currentPeriodEnd!.day}/${currentPeriodEnd!.month}/${currentPeriodEnd!.year}';
  }

  /// L'abonnement est-il actif ?
  bool get isActive =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.trialing;

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        stripeSubscriptionId: json['stripe_subscription_id'] as String?,
        stripePriceId: json['stripe_price_id'] as String?,
        plan: SortiaPlan.fromString(json['plan'] as String),
        status:
            SubscriptionStatus.fromString(json['status'] as String),
        currentPeriodStart: json['current_period_start'] != null
            ? DateTime.parse(json['current_period_start'] as String)
            : null,
        currentPeriodEnd: json['current_period_end'] != null
            ? DateTime.parse(json['current_period_end'] as String)
            : null,
        cancelAtPeriodEnd:
            (json['cancel_at_period_end'] as bool?) ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );
}

// ── Repository ───────────────────────────────────────────────

class SubscriptionRepository {
  SubscriptionRepository(this._supabase);
  final SupabaseClient _supabase;

  String get _uid => _supabase.auth.currentUser!.id;

  Future<Subscription?> fetchCurrent() async {
    try {
      final data = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', _uid)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;
      return Subscription.fromJson(data);
    } catch (e, st) {
      AppLogger.error('SubscriptionRepository.fetchCurrent', e, st);
      rethrow;
    }
  }
}

// ── Providers ────────────────────────────────────────────────

final subscriptionRepositoryProvider =
    Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(Supabase.instance.client);
});

final currentSubscriptionProvider =
    FutureProvider<Subscription?>((ref) async {
  return ref.read(subscriptionRepositoryProvider).fetchCurrent();
});

final currentPlanProvider = Provider<SortiaPlan>((ref) {
  final sub = ref.watch(currentSubscriptionProvider);
  return sub.valueOrNull?.plan ?? SortiaPlan.free;
});
