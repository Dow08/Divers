// ================================================================
// SORTIA — AlertRepository
// CRUD alertes + marquage lu/dismissé
// ================================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sortia/core/utils/logger.dart';
import 'package:sortia/features/alerts/domain/models/alert_model.dart';

class AlertRepository {
  AlertRepository(this._supabase);

  final SupabaseClient _supabase;

  String get _uid {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw const AuthException('Utilisateur non authentifié');
    return uid;
  }

  /// Récupère toutes les alertes non-dismissées
  Future<List<AlertModel>> fetchAlerts() async {
    try {
      final data = await _supabase
          .from('alerts')
          .select()
          .eq('user_id', _uid)
          .eq('is_dismissed', false)
          .order('trigger_at', ascending: true);

      return (data as List)
          .map((row) => AlertModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('AlertRepository.fetchAlerts', e, st);
      rethrow;
    }
  }

  /// Récupère uniquement les alertes non lues
  Future<List<AlertModel>> fetchUnreadAlerts() async {
    try {
      final data = await _supabase
          .from('alerts')
          .select()
          .eq('user_id', _uid)
          .eq('is_read', false)
          .eq('is_dismissed', false)
          .order('priority', ascending: false)
          .order('trigger_at', ascending: true);

      return (data as List)
          .map((row) => AlertModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('AlertRepository.fetchUnreadAlerts', e, st);
      rethrow;
    }
  }

  /// Crée une nouvelle alerte
  Future<AlertModel> createAlert(AlertModel alert) async {
    try {
      final data = await _supabase
          .from('alerts')
          .insert(alert.toJson())
          .select()
          .single();

      return AlertModel.fromJson(data);
    } catch (e, st) {
      AppLogger.error('AlertRepository.createAlert', e, st);
      rethrow;
    }
  }

  /// Marque une alerte comme lue
  Future<void> markAsRead(String alertId) async {
    try {
      await _supabase
          .from('alerts')
          .update({'is_read': true})
          .eq('id', alertId)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('AlertRepository.markAsRead', e, st);
      rethrow;
    }
  }

  /// Marque toutes les alertes comme lues
  Future<void> markAllAsRead() async {
    try {
      await _supabase
          .from('alerts')
          .update({'is_read': true})
          .eq('user_id', _uid)
          .eq('is_read', false);
    } catch (e, st) {
      AppLogger.error('AlertRepository.markAllAsRead', e, st);
      rethrow;
    }
  }

  /// Dismiss une alerte (masquer)
  Future<void> dismissAlert(String alertId) async {
    try {
      await _supabase
          .from('alerts')
          .update({'is_dismissed': true})
          .eq('id', alertId)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('AlertRepository.dismissAlert', e, st);
      rethrow;
    }
  }

  /// Supprime une alerte définitivement
  Future<void> deleteAlert(String alertId) async {
    try {
      await _supabase
          .from('alerts')
          .delete()
          .eq('id', alertId)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('AlertRepository.deleteAlert', e, st);
      rethrow;
    }
  }

  /// Compte les alertes non lues
  Future<int> countUnread() async {
    try {
      final res = await _supabase
          .from('alerts')
          .select('id')
          .eq('user_id', _uid)
          .eq('is_read', false)
          .eq('is_dismissed', false)
          .count(CountOption.exact);
      return res.count;
    } catch (e, st) {
      AppLogger.error('AlertRepository.countUnread', e, st);
      rethrow;
    }
  }
}
