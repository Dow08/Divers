// ================================================================
// SORTIA — Tests unitaires : Modules avancés
// Partage, Coffre-fort, Abonnements, Signature
// ================================================================

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:sortia/features/sharing/sharing_module.dart';
import 'package:sortia/features/vault/vault_module.dart';
import 'package:sortia/features/subscription/subscription_module.dart';
import 'package:sortia/features/signature/signature_module.dart';

void main() {
  // ══════════════════════════════════════════════════════════════
  // PARTAGE
  // ══════════════════════════════════════════════════════════════
  group('ShareLink', () {
    test('fromJson crée un lien valide', () {
      final link = ShareLink.fromJson({
        'id': 's1',
        'user_id': 'u1',
        'file_id': 'f1',
        'token': 'abc123',
        'is_active': true,
        'download_count': 0,
        'created_at': '2026-03-01T10:00:00Z',
      });

      expect(link.token, 'abc123');
      expect(link.isActive, true);
      expect(link.isValid, true);
      expect(link.hasPin, false);
    });

    test('shareUrl contient le token', () {
      final link = ShareLink.fromJson({
        'id': 's1',
        'user_id': 'u1',
        'token': 'mytoken',
      });
      expect(link.shareUrl, contains('mytoken'));
    });

    test('isExpired détecte les liens expirés', () {
      final link = ShareLink.fromJson({
        'id': 's1',
        'user_id': 'u1',
        'token': 'tok',
        'expires_at':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      });
      expect(link.isExpired, true);
      expect(link.isValid, false);
    });

    test('isDownloadLimitReached détecte le quota', () {
      final link = ShareLink.fromJson({
        'id': 's1',
        'user_id': 'u1',
        'token': 'tok',
        'max_downloads': 5,
        'download_count': 5,
      });
      expect(link.isDownloadLimitReached, true);
      expect(link.isValid, false);
    });

    test('statusLabel retourne le bon état', () {
      final active = ShareLink.fromJson({
        'id': 's1',
        'user_id': 'u1',
        'token': 'tok',
        'is_active': true,
      });
      expect(active.statusLabel, contains('Actif'));

      final deactivated = ShareLink.fromJson({
        'id': 's2',
        'user_id': 'u1',
        'token': 'tok2',
        'is_active': false,
      });
      expect(deactivated.statusLabel, contains('Désactivé'));
    });

    test('hasPin détecte la protection', () {
      final withPin = ShareLink.fromJson({
        'id': 's1',
        'user_id': 'u1',
        'token': 'tok',
        'pin_hash': 'hashed123',
      });
      expect(withPin.hasPin, true);
    });

    test('toJson produit un JSON valide', () {
      final link = ShareLink.fromJson({
        'id': 's1',
        'user_id': 'u1',
        'token': 'tok',
        'is_active': true,
      });
      final json = link.toJson();
      expect(json['user_id'], 'u1');
      expect(json['token'], 'tok');
    });

    test('expiresFormatted gère l\'absence d\'expiration', () {
      final link = ShareLink.fromJson({
        'id': 's1',
        'user_id': 'u1',
        'token': 'tok',
      });
      expect(link.expiresFormatted, "Pas d'expiration");
    });
  });

  // ══════════════════════════════════════════════════════════════
  // COFFRE-FORT
  // ══════════════════════════════════════════════════════════════
  group('VaultItem', () {
    test('fromJson crée un item valide', () {
      final item = VaultItem.fromJson({
        'id': 'v1',
        'user_id': 'u1',
        'file_id': 'f1',
        'checksum_sha256': 'abcdef1234567890',
        'certificate_data': {'version': '1.0'},
        'is_valid': true,
      });
      expect(item.checksumSha256, 'abcdef1234567890');
      expect(item.shortHash, 'abcdef12');
      expect(item.isValid, true);
    });

    test('status retourne les bons états', () {
      final unverified = VaultItem.fromJson({
        'id': 'v1',
        'user_id': 'u1',
        'file_id': 'f1',
        'checksum_sha256': 'hash',
        'certificate_data': {},
        'is_valid': true,
      });
      expect(unverified.status, VaultStatus.unverified);

      final compromised = VaultItem.fromJson({
        'id': 'v2',
        'user_id': 'u1',
        'file_id': 'f2',
        'checksum_sha256': 'hash',
        'certificate_data': {},
        'is_valid': false,
      });
      expect(compromised.status, VaultStatus.compromised);
    });
  });

  group('HashService', () {
    test('computeSha256 génère un hash', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final hash = HashService.computeSha256(bytes);
      expect(hash, isNotEmpty);
      expect(hash.length, 64); // SHA-256 = 64 hex chars
    });

    test('verifyIntegrity valide un hash correct', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final hash = HashService.computeSha256(bytes);
      expect(HashService.verifyIntegrity(bytes, hash), true);
    });

    test('verifyIntegrity rejette un hash incorrect', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      expect(HashService.verifyIntegrity(bytes, 'wrong_hash'), false);
    });

    test('generateCertificate contient les bons champs', () {
      final cert = HashService.generateCertificate(
        fileId: 'f1',
        fileName: 'test.pdf',
        fileSize: 1024,
        checksum: 'abc',
      );
      expect(cert['algorithm'], 'SHA-256');
      expect(cert['file_name'], 'test.pdf');
      expect(cert['certified_by'], contains('SORTIA'));
    });
  });

  group('VaultStatus', () {
    test('chaque statut a un label et description', () {
      for (final s in VaultStatus.values) {
        expect(s.label, isNotEmpty);
        expect(s.description, isNotEmpty);
      }
    });
  });

  // ══════════════════════════════════════════════════════════════
  // ABONNEMENTS
  // ══════════════════════════════════════════════════════════════
  group('SortiaPlan', () {
    test('contient 5 plans', () {
      expect(SortiaPlan.values.length, 5);
    });

    test('priceFormatted est correct', () {
      expect(SortiaPlan.free.priceFormatted, 'Gratuit');
      expect(SortiaPlan.starter.priceFormatted, contains('9,90'));
      expect(SortiaPlan.pro.priceFormatted, contains('24,90'));
    });

    test('chaque plan a des features', () {
      for (final p in SortiaPlan.values) {
        expect(p.features, isNotEmpty);
        expect(p.emoji, isNotEmpty);
      }
    });

    test('fromString résout les plans', () {
      expect(SortiaPlan.fromString('pro'), SortiaPlan.pro);
      expect(SortiaPlan.fromString('unknown'), SortiaPlan.free);
    });
  });

  group('SubscriptionStatus', () {
    test('fromString résout les statuts', () {
      expect(
          SubscriptionStatus.fromString('active'), SubscriptionStatus.active);
      expect(SubscriptionStatus.fromString('past_due'),
          SubscriptionStatus.incomplete); // fallback
    });
  });

  group('Subscription', () {
    test('fromJson crée un abonnement valide', () {
      final sub = Subscription.fromJson({
        'id': 'sub1',
        'user_id': 'u1',
        'plan': 'pro',
        'status': 'active',
        'current_period_end': DateTime.now()
            .add(const Duration(days: 15))
            .toIso8601String(),
        'cancel_at_period_end': false,
      });

      expect(sub.plan, SortiaPlan.pro);
      expect(sub.status, SubscriptionStatus.active);
      expect(sub.isActive, true);
      expect(sub.daysRemaining, greaterThanOrEqualTo(14));
    });

    test('nextRenewalFormatted avec annulation', () {
      final sub = Subscription.fromJson({
        'id': 'sub1',
        'user_id': 'u1',
        'plan': 'starter',
        'status': 'active',
        'cancel_at_period_end': true,
      });
      expect(sub.nextRenewalFormatted, 'Pas de renouvellement');
    });
  });

  // ══════════════════════════════════════════════════════════════
  // SIGNATURE
  // ══════════════════════════════════════════════════════════════
  group('SignatureStatus', () {
    test('contient 6 statuts', () {
      expect(SignatureStatus.values.length, 6);
    });

    test('fromString résout les statuts', () {
      expect(SignatureStatus.fromString('signed'), SignatureStatus.signed);
      expect(SignatureStatus.fromString('???'), SignatureStatus.draft);
    });
  });

  group('Signer', () {
    test('fromJson crée un signataire', () {
      final signer = Signer.fromJson({
        'name': 'Jean Dupont',
        'email': 'jean@test.fr',
        'status': 'signed',
        'signed_at': '2026-03-01T10:00:00Z',
      });
      expect(signer.hasSigned, true);
      expect(signer.name, 'Jean Dupont');
    });
  });

  group('SignatureRequest', () {
    test('progress affiche correctement', () {
      const req = SignatureRequest(
        id: 'sr1',
        name: 'Contrat X',
        fileId: 'f1',
        status: SignatureStatus.pending,
        signers: [
          Signer(name: 'A', email: 'a@t.fr', status: SignatureStatus.signed),
          Signer(name: 'B', email: 'b@t.fr', status: SignatureStatus.pending),
          Signer(name: 'C', email: 'c@t.fr', status: SignatureStatus.pending),
        ],
      );
      expect(req.progress, '1/3 signé');
      expect(req.progressRate, closeTo(0.33, 0.01));
      expect(req.isFullySigned, false);
    });

    test('isFullySigned true quand tous signés', () {
      const req = SignatureRequest(
        id: 'sr1',
        name: 'Contrat',
        fileId: 'f1',
        status: SignatureStatus.signed,
        signers: [
          Signer(name: 'A', email: 'a@t.fr', status: SignatureStatus.signed),
          Signer(name: 'B', email: 'b@t.fr', status: SignatureStatus.signed),
        ],
      );
      expect(req.isFullySigned, true);
      expect(req.progress, '2/2 signés');
    });
  });
}
