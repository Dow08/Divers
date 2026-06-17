// ================================================================
// SORTIA — MailRepository
// CRUD comptes email + sync Supabase
// ================================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sortia/core/utils/logger.dart';
import 'package:sortia/features/mail/domain/models/mail_account_model.dart';

class MailRepository {
  MailRepository(this._supabase);

  final SupabaseClient _supabase;

  String get _uid {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw const AuthException('Utilisateur non authentifié');
    return uid;
  }

  /// Récupère tous les comptes email de l'utilisateur
  Future<List<MailAccount>> fetchAccounts() async {
    try {
      final data = await _supabase
          .from('mail_accounts')
          .select()
          .eq('user_id', _uid)
          .order('created_at', ascending: true);

      return (data as List)
          .map((row) => MailAccount.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('MailRepository.fetchAccounts', e, st);
      rethrow;
    }
  }

  /// Ajoute un nouveau compte email
  Future<MailAccount> addAccount(MailAccount account) async {
    try {
      final data = await _supabase
          .from('mail_accounts')
          .insert(account.toJson())
          .select()
          .single();

      return MailAccount.fromJson(data);
    } catch (e, st) {
      AppLogger.error('MailRepository.addAccount', e, st);
      rethrow;
    }
  }

  /// Met à jour un compte email
  Future<MailAccount> updateAccount(MailAccount account) async {
    try {
      final data = await _supabase
          .from('mail_accounts')
          .update(account.toJson())
          .eq('id', account.id)
          .eq('user_id', _uid)
          .select()
          .single();

      return MailAccount.fromJson(data);
    } catch (e, st) {
      AppLogger.error('MailRepository.updateAccount', e, st);
      rethrow;
    }
  }

  /// Supprime un compte email (soft delete — désactive)
  Future<void> deleteAccount(String accountId) async {
    try {
      await _supabase
          .from('mail_accounts')
          .update({'is_active': false})
          .eq('id', accountId)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('MailRepository.deleteAccount', e, st);
      rethrow;
    }
  }

  /// Active/désactive la synchronisation
  Future<void> toggleSync(String accountId, {required bool enabled}) async {
    try {
      await _supabase
          .from('mail_accounts')
          .update({'sync_enabled': enabled})
          .eq('id', accountId)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('MailRepository.toggleSync', e, st);
      rethrow;
    }
  }

  /// Met à jour le timestamp de dernière sync
  Future<void> updateLastSync(String accountId) async {
    try {
      await _supabase
          .from('mail_accounts')
          .update({'last_sync_at': DateTime.now().toIso8601String()})
          .eq('id', accountId)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('MailRepository.updateLastSync', e, st);
      rethrow;
    }
  }

  /// Enregistre les tokens OAuth après authentification
  Future<void> saveOAuthTokens({
    required String accountId,
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _supabase
          .from('mail_accounts')
          .update({
            'oauth_token': accessToken,
            'oauth_refresh': refreshToken,
          })
          .eq('id', accountId)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('MailRepository.saveOAuthTokens', e, st);
      rethrow;
    }
  }

  /// Met à jour les dossiers surveillés
  Future<void> updateWatchedFolders(
    String accountId,
    List<String> folders,
  ) async {
    try {
      await _supabase
          .from('mail_accounts')
          .update({'folders_watched': folders})
          .eq('id', accountId)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('MailRepository.updateWatchedFolders', e, st);
      rethrow;
    }
  }
}
