// ================================================================
// SORTIA — Module Signature Électronique (Yousign)
// Modèle + Repository + Providers
// ================================================================

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:sortia/core/config/env.dart';
import 'package:sortia/core/utils/logger.dart';

// ── Modèle ───────────────────────────────────────────────────

/// Statut de la demande de signature
enum SignatureStatus {
  draft('Brouillon', '📝'),
  pending('En attente', '⏳'),
  signed('Signé', '✅'),
  refused('Refusé', '❌'),
  expired('Expiré', '⏰'),
  canceled('Annulé', '🚫');

  const SignatureStatus(this.label, this.emoji);
  final String label;
  final String emoji;

  static SignatureStatus fromString(String value) {
    return SignatureStatus.values.firstWhere(
      (s) => s.name == value.toLowerCase(),
      orElse: () => SignatureStatus.draft,
    );
  }
}

/// Signataire
class Signer {
  const Signer({
    required this.name,
    required this.email,
    this.phone,
    this.signedAt,
    this.status = SignatureStatus.pending,
  });

  final String name;
  final String email;
  final String? phone;
  final DateTime? signedAt;
  final SignatureStatus status;

  bool get hasSigned => status == SignatureStatus.signed;

  factory Signer.fromJson(Map<String, dynamic> json) => Signer(
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        signedAt: json['signed_at'] != null
            ? DateTime.parse(json['signed_at'] as String)
            : null,
        status:
            SignatureStatus.fromString((json['status'] as String?) ?? 'pending'),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
      };
}

/// Demande de signature
class SignatureRequest {
  const SignatureRequest({
    required this.id,
    this.yousignId,
    required this.name,
    required this.fileId,
    required this.signers,
    required this.status,
    this.message,
    this.expiresAt,
    this.createdAt,
  });

  final String id;
  final String? yousignId;
  final String name;
  final String fileId;
  final List<Signer> signers;
  final SignatureStatus status;
  final String? message;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  /// Progression (ex: "1/3 signé")
  String get progress {
    final signed = signers.where((s) => s.hasSigned).length;
    return '$signed/${signers.length} signé${signed > 1 ? 's' : ''}';
  }

  /// Taux de progression (0.0 — 1.0)
  double get progressRate {
    if (signers.isEmpty) return 0;
    return signers.where((s) => s.hasSigned).length / signers.length;
  }

  /// Tous les signataires ont signé ?
  bool get isFullySigned => signers.every((s) => s.hasSigned);
}

// ── Service Yousign ──────────────────────────────────────────

class YousignService {
  YousignService._();
  static final YousignService instance = YousignService._();

  static const _baseUrl = 'https://api.yousign.app/v3';

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${Env.yousignApiKey}',
        'Content-Type': 'application/json',
      };

  /// Vérifie si le service est disponible
  bool get isAvailable => Env.yousignApiKey.isNotEmpty;

  /// Crée une procédure de signature
  Future<String?> createSignatureRequest({
    required String name,
    required List<Signer> signers,
    String? message,
    int expirationDays = 14,
  }) async {
    if (!isAvailable) return null;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/signature_requests'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'delivery_mode': 'email',
          'ordered_signers': false,
          'reminder_settings': {
            'interval_in_days': 3,
            'max_occurrences': 3,
          },
          'expiration_date': DateTime.now()
              .add(Duration(days: expirationDays))
              .toIso8601String()
              .split('T')
              .first,
          'external_id': 'sortia_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['id'] as String;
      }
      AppLogger.warning(
          'Yousign: erreur création — ${response.statusCode}');
      return null;
    } catch (e, st) {
      AppLogger.error('YousignService.createSignatureRequest', e, st);
      return null;
    }
  }

  /// Ajoute un document à une demande
  Future<String?> uploadDocument({
    required String signatureRequestId,
    required String fileName,
    required String base64Content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/signature_requests/$signatureRequestId/documents'),
        headers: _headers,
        body: jsonEncode({
          'nature': 'signable_document',
          'file_name': fileName,
          'file_content': base64Content,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['id'] as String;
      }
      return null;
    } catch (e, st) {
      AppLogger.error('YousignService.uploadDocument', e, st);
      return null;
    }
  }

  /// Ajoute un signataire
  Future<bool> addSigner({
    required String signatureRequestId,
    required String documentId,
    required Signer signer,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/signature_requests/$signatureRequestId/signers'),
        headers: _headers,
        body: jsonEncode({
          'info': signer.toJson(),
          'signature_level': 'electronic_signature',
          'fields': [
            {
              'type': 'signature',
              'document_id': documentId,
              'page': 1,
              'x': 100,
              'y': 700,
              'width': 200,
              'height': 50,
            },
          ],
        }),
      );
      return response.statusCode == 201;
    } catch (e, st) {
      AppLogger.error('YousignService.addSigner', e, st);
      return false;
    }
  }

  /// Active la demande de signature
  Future<bool> activate(String signatureRequestId) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/signature_requests/$signatureRequestId/activate'),
        headers: _headers,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e, st) {
      AppLogger.error('YousignService.activate', e, st);
      return false;
    }
  }
}

// ── Providers ────────────────────────────────────────────────

final yousignServiceProvider = Provider<YousignService>((ref) {
  return YousignService.instance;
});

final signatureAvailableProvider = Provider<bool>((ref) {
  return ref.read(yousignServiceProvider).isAvailable;
});
