// ================================================================
// SORTIA — Modèle ShareLink + Repository + Providers
// Partage de fichiers/dossiers via lien sécurisé
// ================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sortia/core/utils/logger.dart';

// ── Modèle ───────────────────────────────────────────────────

class ShareLink {
  const ShareLink({
    required this.id,
    required this.userId,
    this.fileId,
    this.folderId,
    required this.token,
    this.pinHash,
    this.expiresAt,
    this.maxDownloads,
    this.downloadCount = 0,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String? fileId;
  final String? folderId;
  final String token;
  final String? pinHash;
  final DateTime? expiresAt;
  final int? maxDownloads;
  final int downloadCount;
  final bool isActive;
  final DateTime? createdAt;

  /// URL de partage
  String get shareUrl => 'https://app.sortia.fr/share/$token';

  /// Vérifie si le lien est expiré
  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  /// Vérifie si le quota de téléchargements est atteint
  bool get isDownloadLimitReached =>
      maxDownloads != null && downloadCount >= maxDownloads!;

  /// Vérifie si le lien est valide (actif + non expiré + sous quota)
  bool get isValid => isActive && !isExpired && !isDownloadLimitReached;

  /// Protégé par PIN ?
  bool get hasPin => pinHash != null && pinHash!.isNotEmpty;

  /// Statut formaté
  String get statusLabel {
    if (!isActive) return '⛔ Désactivé';
    if (isExpired) return '⏰ Expiré';
    if (isDownloadLimitReached) return '📥 Limite atteinte';
    return '✅ Actif';
  }

  /// Durée restante avant expiration
  String get expiresFormatted {
    if (expiresAt == null) return 'Pas d\'expiration';
    final diff = expiresAt!.difference(DateTime.now());
    if (diff.isNegative) return 'Expiré';
    if (diff.inDays > 0) return 'Expire dans ${diff.inDays}j';
    if (diff.inHours > 0) return 'Expire dans ${diff.inHours}h';
    return 'Expire dans ${diff.inMinutes}min';
  }

  factory ShareLink.fromJson(Map<String, dynamic> json) => ShareLink(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        fileId: json['file_id'] as String?,
        folderId: json['folder_id'] as String?,
        token: json['token'] as String,
        pinHash: json['pin_hash'] as String?,
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
        maxDownloads: json['max_downloads'] as int?,
        downloadCount: (json['download_count'] as int?) ?? 0,
        isActive: (json['is_active'] as bool?) ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'file_id': fileId,
        'folder_id': folderId,
        'token': token,
        'pin_hash': pinHash,
        'expires_at': expiresAt?.toIso8601String(),
        'max_downloads': maxDownloads,
        'is_active': isActive,
      };

  ShareLink copyWith({bool? isActive}) => ShareLink(
        id: id,
        userId: userId,
        fileId: fileId,
        folderId: folderId,
        token: token,
        pinHash: pinHash,
        expiresAt: expiresAt,
        maxDownloads: maxDownloads,
        downloadCount: downloadCount,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
      );
}

// ── Repository ───────────────────────────────────────────────

class ShareRepository {
  ShareRepository(this._supabase);
  final SupabaseClient _supabase;

  String get _uid => _supabase.auth.currentUser!.id;

  Future<List<ShareLink>> fetchLinks() async {
    try {
      final data = await _supabase
          .from('share_links')
          .select()
          .eq('user_id', _uid)
          .order('created_at', ascending: false);
      return (data as List)
          .map((r) => ShareLink.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('ShareRepository.fetchLinks', e, st);
      rethrow;
    }
  }

  Future<ShareLink> createLink(ShareLink link) async {
    try {
      final data = await _supabase
          .from('share_links')
          .insert(link.toJson())
          .select()
          .single();
      return ShareLink.fromJson(data);
    } catch (e, st) {
      AppLogger.error('ShareRepository.createLink', e, st);
      rethrow;
    }
  }

  Future<void> deactivateLink(String linkId) async {
    try {
      await _supabase
          .from('share_links')
          .update({'is_active': false})
          .eq('id', linkId)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('ShareRepository.deactivateLink', e, st);
      rethrow;
    }
  }

  Future<void> deleteLink(String linkId) async {
    try {
      await _supabase
          .from('share_links')
          .delete()
          .eq('id', linkId)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('ShareRepository.deleteLink', e, st);
      rethrow;
    }
  }
}

// ── Providers ────────────────────────────────────────────────

final shareRepositoryProvider = Provider<ShareRepository>((ref) {
  return ShareRepository(Supabase.instance.client);
});

final shareLinksProvider =
    AsyncNotifierProvider<ShareLinksNotifier, List<ShareLink>>(
  ShareLinksNotifier.new,
);

class ShareLinksNotifier extends AsyncNotifier<List<ShareLink>> {
  @override
  Future<List<ShareLink>> build() async {
    return ref.read(shareRepositoryProvider).fetchLinks();
  }

  Future<void> createLink(ShareLink link) async {
    final repo = ref.read(shareRepositoryProvider);
    final created = await repo.createLink(link);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([created, ...current]);
  }

  Future<void> deactivate(String linkId) async {
    final repo = ref.read(shareRepositoryProvider);
    await repo.deactivateLink(linkId);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.map((l) {
        if (l.id == linkId) return l.copyWith(isActive: false);
        return l;
      }).toList(),
    );
  }

  Future<void> deleteLink(String linkId) async {
    final repo = ref.read(shareRepositoryProvider);
    await repo.deleteLink(linkId);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.where((l) => l.id != linkId).toList(),
    );
  }
}
