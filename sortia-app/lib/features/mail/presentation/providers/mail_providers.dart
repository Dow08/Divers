// ================================================================
// SORTIA — Providers Email (Riverpod)
// ================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sortia/features/mail/data/mail_repository.dart';
import 'package:sortia/features/mail/domain/models/mail_account_model.dart';

/// Repository provider
final mailRepositoryProvider = Provider<MailRepository>((ref) {
  return MailRepository(Supabase.instance.client);
});

/// Provider de la liste des comptes email
final mailAccountsProvider =
    AsyncNotifierProvider<MailAccountsNotifier, MailState>(
  MailAccountsNotifier.new,
);

/// Notifier qui gère les comptes email
class MailAccountsNotifier extends AsyncNotifier<MailState> {
  @override
  Future<MailState> build() async {
    final accounts =
        await ref.read(mailRepositoryProvider).fetchAccounts();
    return MailState(accounts: accounts);
  }

  /// Rafraîchit la liste
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final accounts =
          await ref.read(mailRepositoryProvider).fetchAccounts();
      return MailState(accounts: accounts);
    });
  }

  /// Ajoute un compte
  Future<void> addAccount(MailAccount account) async {
    final repo = ref.read(mailRepositoryProvider);
    final added = await repo.addAccount(account);
    final current = state.valueOrNull ?? const MailState();
    state = AsyncValue.data(
      current.copyWith(accounts: [...current.accounts, added]),
    );
  }

  /// Supprime un compte (soft delete)
  Future<void> deleteAccount(String accountId) async {
    final repo = ref.read(mailRepositoryProvider);
    await repo.deleteAccount(accountId);
    final current = state.valueOrNull ?? const MailState();
    state = AsyncValue.data(
      current.copyWith(
        accounts:
            current.accounts.where((a) => a.id != accountId).toList(),
      ),
    );
  }

  /// Active/désactive la sync
  Future<void> toggleSync(String accountId, {required bool enabled}) async {
    final repo = ref.read(mailRepositoryProvider);
    await repo.toggleSync(accountId, enabled: enabled);
    final current = state.valueOrNull ?? const MailState();
    state = AsyncValue.data(
      current.copyWith(
        accounts: current.accounts.map((a) {
          if (a.id == accountId) {
            return a.copyWith(syncEnabled: enabled);
          }
          return a;
        }).toList(),
      ),
    );
  }
}
