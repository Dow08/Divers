// ================================================================
// SORTIA — Écran de prévisualisation de fichier
// Affiche un aperçu du fichier avec métadonnées et actions
// ================================================================

import 'package:flutter/material.dart';

class FilePreviewScreen extends StatelessWidget {
  const FilePreviewScreen({
    super.key,
    required this.fileId,
    required this.fileName,
    this.mimeType,
    this.fileSize,
    this.storagePath,
    this.aiCategory,
    this.aiConfidence,
  });

  final String fileId;
  final String fileName;
  final String? mimeType;
  final int? fileSize;
  final String? storagePath;
  final String? aiCategory;
  final double? aiConfidence;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(
        title: Text(
          fileName,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            onSelected: (v) {},
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                  value: 'rename', child: Text('✏️ Renommer')),
              const PopupMenuItem(
                  value: 'move', child: Text('📁 Déplacer')),
              const PopupMenuItem(
                  value: 'vault', child: Text('🔒 Coffre-fort')),
              const PopupMenuItem(
                  value: 'download', child: Text('📥 Télécharger')),
              const PopupMenuItem(
                  value: 'delete',
                  child:
                      Text('🗑️ Supprimer', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Aperçu ──────────────────────────────────
            _PreviewCard(
              fileName: fileName,
              mimeType: mimeType,
            ),
            const SizedBox(height: 16),

            // ── Infos fichier ───────────────────────────
            _InfoCard(
              fileName: fileName,
              mimeType: mimeType,
              fileSize: fileSize,
            ),
            const SizedBox(height: 16),

            // ── Classification IA ───────────────────────
            if (aiCategory != null)
              _AiCard(
                category: aiCategory!,
                confidence: aiConfidence,
              ),
            const SizedBox(height: 16),

            // ── Actions rapides ─────────────────────────
            _ActionsCard(),
          ],
        ),
      ),
    );
  }
}

// ── Aperçu du fichier ────────────────────────────────────────
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.fileName, this.mimeType});
  final String fileName;
  final String? mimeType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_emojiForMime, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              _typeLabel,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF566573),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _emojiForMime {
    final m = mimeType ?? '';
    if (m.contains('pdf')) return '📄';
    if (m.contains('image')) return '🖼️';
    if (m.contains('word') || m.contains('doc')) return '📝';
    if (m.contains('sheet') || m.contains('excel') || m.contains('csv')) {
      return '📊';
    }
    if (m.contains('presentation') || m.contains('ppt')) return '📽️';
    if (m.contains('video')) return '🎬';
    if (m.contains('audio')) return '🎵';
    if (m.contains('zip') || m.contains('rar')) return '📦';
    return '📎';
  }

  String get _typeLabel {
    final m = mimeType ?? '';
    if (m.contains('pdf')) return 'Document PDF';
    if (m.contains('image')) return 'Image';
    if (m.contains('word') || m.contains('doc')) return 'Document Word';
    if (m.contains('sheet') || m.contains('excel')) return 'Feuille de calcul';
    if (m.contains('csv')) return 'Fichier CSV';
    return 'Document';
  }
}

// ── Informations du fichier ──────────────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.fileName,
    this.mimeType,
    this.fileSize,
  });

  final String fileName;
  final String? mimeType;
  final int? fileSize;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const Divider(height: 20),
            _InfoRow('Nom', fileName),
            if (mimeType != null) _InfoRow('Type', mimeType!),
            if (fileSize != null)
              _InfoRow('Taille', _formatSize(fileSize!)),
          ],
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes o';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} Ko';
    return '${(bytes / 1048576).toStringAsFixed(1)} Mo';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF566573)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Classification IA ────────────────────────────────────────
class _AiCard extends StatelessWidget {
  const _AiCard({required this.category, this.confidence});
  final String category;
  final double? confidence;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Color(0xFF2E86C1), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Classification IA',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF566573),
                    ),
                  ),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                ],
              ),
            ),
            if (confidence != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF17A589).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(confidence! * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF17A589),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Actions rapides ──────────────────────────────────────────
class _ActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ActionButton(
              icon: Icons.share_outlined,
              label: 'Partager',
              color: const Color(0xFF2E86C1),
              onTap: () {},
            ),
            _ActionButton(
              icon: Icons.lock_outline,
              label: 'Coffre-fort',
              color: const Color(0xFF8E44AD),
              onTap: () {},
            ),
            _ActionButton(
              icon: Icons.draw_outlined,
              label: 'Signer',
              color: const Color(0xFFE67E22),
              onTap: () {},
            ),
            _ActionButton(
              icon: Icons.download_outlined,
              label: 'Export',
              color: const Color(0xFF17A589),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF566573)),
            ),
          ],
        ),
      ),
    );
  }
}
