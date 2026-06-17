// ================================================================
// SORTIA — Écran Partage de fichiers
// Liens de partage actifs et création
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sortia/features/sharing/sharing_module.dart';

class SharingScreen extends ConsumerWidget {
  const SharingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(shareLinksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: const Text('Partage'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
      ),
      body: linksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (links) => links.isEmpty
            ? _EmptyState()
            : _LinksList(links: links),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_link),
        label: const Text('Nouveau lien'),
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
              color: const Color(0xFFEBF5FB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.share_outlined,
                size: 48, color: Color(0xFF2E86C1)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun lien de partage',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Partagez vos fichiers en toute sécurité\nvia un lien protégé par PIN',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF566573)),
          ),
        ],
      ),
    );
  }
}

class _LinksList extends StatelessWidget {
  const _LinksList({required this.links});
  final List<ShareLink> links;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: links.length,
      itemBuilder: (_, i) => _ShareLinkCard(link: links[i]),
    );
  }
}

class _ShareLinkCard extends ConsumerWidget {
  const _ShareLinkCard({required this.link});
  final ShareLink link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Icon(
                  link.isValid ? Icons.link : Icons.link_off,
                  color: link.isValid
                      ? const Color(0xFF17A589)
                      : const Color(0xFFE74C3C),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    link.token,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: link.shareUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lien copié !')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(link.statusLabel,
                    style: const TextStyle(fontSize: 11)),
                const Spacer(),
                if (link.hasPin)
                  const Chip(
                    label: Text('🔒 PIN',
                        style: TextStyle(fontSize: 10)),
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.symmetric(horizontal: 6),
                  ),
                const SizedBox(width: 6),
                Text(
                  '${link.downloadCount}${link.maxDownloads != null ? '/${link.maxDownloads}' : ''} 📥',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF566573)),
                ),
              ],
            ),
            Text(link.expiresFormatted,
                style:
                    const TextStyle(fontSize: 11, color: Color(0xFF566573))),
          ],
        ),
      ),
    );
  }
}
