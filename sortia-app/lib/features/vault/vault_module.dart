// ================================================================
// SORTIA — Modèle VaultItem + Repository + Providers
// Coffre-fort numérique — certification & intégrité
// ================================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sortia/core/utils/logger.dart';

// ── Modèle ───────────────────────────────────────────────────

class VaultItem {
  const VaultItem({
    required this.id,
    required this.userId,
    required this.fileId,
    required this.checksumSha256,
    required this.certificateData,
    this.certifiedAt,
    this.integrityVerifiedAt,
    this.isValid = true,
    this.fileName,
    this.fileSize,
  });

  final String id;
  final String userId;
  final String fileId;
  final String checksumSha256;
  final Map<String, dynamic> certificateData;
  final DateTime? certifiedAt;
  final DateTime? integrityVerifiedAt;
  final bool isValid;
  final String? fileName;
  final int? fileSize;

  /// Hash court (8 premiers caractères)
  String get shortHash => checksumSha256.length >= 8
      ? checksumSha256.substring(0, 8)
      : checksumSha256;

  /// Statut d'intégrité
  VaultStatus get status {
    if (!isValid) return VaultStatus.compromised;
    if (integrityVerifiedAt == null) return VaultStatus.unverified;
    final diff = DateTime.now().difference(integrityVerifiedAt!);
    if (diff.inDays > 30) return VaultStatus.needsCheck;
    return VaultStatus.verified;
  }

  /// Date de certification formatée
  String get certifiedFormatted {
    if (certifiedAt == null) return 'Non certifié';
    return '${certifiedAt!.day}/${certifiedAt!.month}/${certifiedAt!.year}';
  }

  /// Dernière vérification formatée
  String get lastVerifiedFormatted {
    if (integrityVerifiedAt == null) return 'Jamais vérifié';
    final diff = DateTime.now().difference(integrityVerifiedAt!);
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return 'Hier';
    return 'il y a ${diff.inDays}j';
  }

  factory VaultItem.fromJson(Map<String, dynamic> json) => VaultItem(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        fileId: json['file_id'] as String,
        checksumSha256: json['checksum_sha256'] as String,
        certificateData: json['certificate_data'] != null
            ? Map<String, dynamic>.from(json['certificate_data'] as Map)
            : {},
        certifiedAt: json['certified_at'] != null
            ? DateTime.parse(json['certified_at'] as String)
            : null,
        integrityVerifiedAt: json['integrity_verified_at'] != null
            ? DateTime.parse(json['integrity_verified_at'] as String)
            : null,
        isValid: (json['is_valid'] as bool?) ?? true,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'file_id': fileId,
        'checksum_sha256': checksumSha256,
        'certificate_data': certificateData,
        'is_valid': isValid,
      };
}

/// Statut d'intégrité coffre-fort
enum VaultStatus {
  verified('✅ Vérifié', 'Intégrité confirmée'),
  unverified('⚠️ Non vérifié', 'Vérification recommandée'),
  needsCheck('🔄 À vérifier', 'Vérification > 30 jours'),
  compromised('🔴 Compromis', 'Intégrité compromise');

  const VaultStatus(this.label, this.description);
  final String label;
  final String description;
}

// ── Service de hash ──────────────────────────────────────────

class HashService {
  /// Calcule le hash SHA-256 d'un fichier
  static String computeSha256(Uint8List bytes) {
    return sha256.convert(bytes).toString();
  }

  /// Vérifie l'intégrité d'un fichier
  static bool verifyIntegrity(Uint8List bytes, String expectedHash) {
    return computeSha256(bytes) == expectedHash;
  }

  /// Génère un certificat d'intégrité
  static Map<String, dynamic> generateCertificate({
    required String fileId,
    required String fileName,
    required int fileSize,
    required String checksum,
  }) {
    return {
      'version': '1.0',
      'algorithm': 'SHA-256',
      'file_id': fileId,
      'file_name': fileName,
      'file_size': fileSize,
      'checksum': checksum,
      'certified_at': DateTime.now().toIso8601String(),
      'certified_by': 'SORTIA Coffre-fort v1.0',
    };
  }
}

// ── Repository ───────────────────────────────────────────────

class VaultRepository {
  VaultRepository(this._supabase);
  final SupabaseClient _supabase;

  String get _uid => _supabase.auth.currentUser!.id;

  Future<List<VaultItem>> fetchItems() async {
    try {
      final data = await _supabase
          .from('vault_items')
          .select()
          .eq('user_id', _uid)
          .order('certified_at', ascending: false);
      return (data as List)
          .map((r) => VaultItem.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error('VaultRepository.fetchItems', e, st);
      rethrow;
    }
  }

  Future<VaultItem> certifyFile({
    required String fileId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final checksum = HashService.computeSha256(fileBytes);
    final certificate = HashService.generateCertificate(
      fileId: fileId,
      fileName: fileName,
      fileSize: fileBytes.length,
      checksum: checksum,
    );

    try {
      final data = await _supabase
          .from('vault_items')
          .insert({
            'user_id': _uid,
            'file_id': fileId,
            'checksum_sha256': checksum,
            'certificate_data': certificate,
          })
          .select()
          .single();
      return VaultItem.fromJson(data);
    } catch (e, st) {
      AppLogger.error('VaultRepository.certifyFile', e, st);
      rethrow;
    }
  }

  Future<void> updateVerification(String vaultId, bool isValid) async {
    try {
      await _supabase
          .from('vault_items')
          .update({
            'integrity_verified_at': DateTime.now().toIso8601String(),
            'is_valid': isValid,
          })
          .eq('id', vaultId)
          .eq('user_id', _uid);
    } catch (e, st) {
      AppLogger.error('VaultRepository.updateVerification', e, st);
      rethrow;
    }
  }
}

// ── Providers ────────────────────────────────────────────────

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  return VaultRepository(Supabase.instance.client);
});

final vaultItemsProvider =
    AsyncNotifierProvider<VaultNotifier, List<VaultItem>>(
  VaultNotifier.new,
);

class VaultNotifier extends AsyncNotifier<List<VaultItem>> {
  @override
  Future<List<VaultItem>> build() async {
    return ref.read(vaultRepositoryProvider).fetchItems();
  }

  Future<void> certifyFile({
    required String fileId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final repo = ref.read(vaultRepositoryProvider);
    final item = await repo.certifyFile(
      fileId: fileId,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([item, ...current]);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(vaultRepositoryProvider).fetchItems(),
    );
  }
}
