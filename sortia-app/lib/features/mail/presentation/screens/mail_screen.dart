// ================================================================
// SORTIA — Écran Comptes Email
// Liste des comptes connectés + ajout Gmail/Outlook/IMAP
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sortia/features/mail/domain/models/mail_account_model.dart';
import 'package:sortia/features/mail/presentation/providers/mail_providers.dart';
import 'package:sortia/features/mail/presentation/widgets/add_mail_account_dialog.dart';

/// Écran de gestion des comptes email
class MailScreen extends ConsumerWidget {
  const MailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mailAsync = ref.watch(mailAccountsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Comptes Email'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(mailAccountsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: mailAsync.when(
        data: (mailState) => mailState.accounts.isEmpty
            ? _EmptyState(onAdd: () => _showAddDialog(context))
            : _AccountsList(
                accounts: mailState.accounts,
                syncingId: mailState.syncingAccountId,
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: e.toString(),
          onRetry: () =>
              ref.read(mailAccountsProvider.notifier).refresh(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un compte'),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddMailAccountDialog(),
    );
  }
}

// ── État vide ────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5FB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.email_outlined,
                size: 64,
                color: Color(0xFF2E86C1),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun compte email connecté',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connectez votre Gmail ou Outlook pour\nimporter et classer vos documents automatiquement.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF566573)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ProviderButton(
                  label: 'Gmail',
                  emoji: '📧',
                  color: const Color(0xFFD93025),
                  onTap: onAdd,
                ),
                const SizedBox(width: 12),
                _ProviderButton(
                  label: 'Outlook',
                  emoji: '📬',
                  color: const Color(0xFF0078D4),
                  onTap: onAdd,
                ),
                const SizedBox(width: 12),
                _ProviderButton(
                  label: 'IMAP',
                  emoji: '📩',
                  color: const Color(0xFF566573),
                  onTap: onAdd,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Liste des comptes ────────────────────────────────────────
class _AccountsList extends ConsumerWidget {
  const _AccountsList({required this.accounts, this.syncingId});
  final List<MailAccount> accounts;
  final String? syncingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return _MailAccountCard(
          account: account,
          isSyncing: syncingId == account.id,
        );
      },
    );
  }
}

class _MailAccountCard extends ConsumerWidget {
  const _MailAccountCard({
    required this.account,
    this.isSyncing = false,
  });

  final MailAccount account;
  final bool isSyncing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _providerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    account.provider.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.emailAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF5FB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              account.provider.label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF2E86C1),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            account.accountType,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF566573),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Toggle sync
                Switch(
                  value: account.syncEnabled,
                  activeColor: const Color(0xFF17A589),
                  onChanged: (value) {
                    ref.read(mailAccountsProvider.notifier).toggleSync(
                          account.id,
                          enabled: value,
                        );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Infos sync
            Row(
              children: [
                Icon(
                  isSyncing ? Icons.sync : Icons.schedule_outlined,
                  size: 14,
                  color: const Color(0xFF566573),
                ),
                const SizedBox(width: 6),
                Text(
                  isSyncing ? 'Synchronisation...' : account.lastSyncFormatted,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF566573),
                  ),
                ),
                const Spacer(),
                Text(
                  '${account.foldersWatched.length} dossier(s) surveillé(s)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF566573),
                  ),
                ),
              ],
            ),

            // Dossiers surveillés
            if (account.foldersWatched.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: account.foldersWatched.map((folder) {
                  return Chip(
                    label: Text(folder, style: const TextStyle(fontSize: 10)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: const Color(0xFFEBF5FB),
                  );
                }).toList(),
              ),
            ],

            // Actions
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_outlined, size: 16),
                  label: const Text('Configurer', style: TextStyle(fontSize: 12)),
                ),
                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(mailAccountsProvider.notifier)
                        .deleteAccount(account.id);
                  },
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: Color(0xFFE74C3C)),
                  label: const Text(
                    'Supprimer',
                    style: TextStyle(fontSize: 12, color: Color(0xFFE74C3C)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _providerColor => switch (account.provider) {
        MailProvider.gmail => const Color(0xFFD93025),
        MailProvider.outlook => const Color(0xFF0078D4),
        MailProvider.imap => const Color(0xFF566573),
      };
}

// ── État erreur ──────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFE74C3C)),
          const SizedBox(height: 12),
          const Text('Erreur de chargement',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
