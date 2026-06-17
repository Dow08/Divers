// ================================================================
// SORTIA — Écran Coffre-fort numérique
// Certification et vérification d'intégrité
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sortia/features/vault/vault_module.dart';

class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(vaultItemsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Coffre-fort'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(vaultItemsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (items) => items.isEmpty
            ? _EmptyState()
            : _VaultList(items: items),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B4F72), Color(0xFF2E86C1)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child:
                const Icon(Icons.lock_outline, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Coffre-fort vide',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Certifiez l\'intégrité de vos documents\nimportants avec un hash SHA-256',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF566573)),
          ),
        ],
      ),
    );
  }
}

class _VaultList extends StatelessWidget {
  const _VaultList({required this.items});
  final List<VaultItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => _VaultItemCard(item: items[i]),
    );
  }
}

class _VaultItemCard extends StatelessWidget {
  const _VaultItemCard({required this.item});
  final VaultItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.verified_outlined,
                      color: _statusColor, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.fileName ?? 'Document certifié',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SHA-256 : ${item.shortHash}…',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Color(0xFF566573),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(item.status.label,
                    style: const TextStyle(fontSize: 11)),
                const Spacer(),
                Text('Certifié le ${item.certifiedFormatted}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF566573))),
              ],
            ),
            const SizedBox(height: 4),
            Text('Dernière vérification : ${item.lastVerifiedFormatted}',
                style:
                    const TextStyle(fontSize: 11, color: Color(0xFF566573))),
          ],
        ),
      ),
    );
  }

  Color get _statusColor => switch (item.status) {
        VaultStatus.verified => const Color(0xFF17A589),
        VaultStatus.unverified => const Color(0xFFE67E22),
        VaultStatus.needsCheck => const Color(0xFF2E86C1),
        VaultStatus.compromised => const Color(0xFFE74C3C),
      };
}
