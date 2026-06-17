// ================================================================
// SORTIA — Tests unitaires : MailAccount
// ================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/mail/domain/models/mail_account_model.dart';

void main() {
  group('MailProvider', () {
    test('fromString reconnaît gmail', () {
      expect(MailProvider.fromString('gmail'), MailProvider.gmail);
    });

    test('fromString reconnaît outlook', () {
      expect(MailProvider.fromString('outlook'), MailProvider.outlook);
    });

    test('fromString reconnaît imap', () {
      expect(MailProvider.fromString('imap'), MailProvider.imap);
    });

    test('fromString retourne imap par défaut', () {
      expect(MailProvider.fromString('unknown'), MailProvider.imap);
    });

    test('chaque provider a un label et emoji', () {
      for (final p in MailProvider.values) {
        expect(p.label, isNotEmpty);
        expect(p.emoji, isNotEmpty);
      }
    });
  });

  group('MailAccount — fromJson', () {
    final json = {
      'id': 'mail-1',
      'user_id': 'user-1',
      'provider': 'gmail',
      'email_address': 'test@gmail.com',
      'display_name': 'Mon Gmail',
      'is_personal': true,
      'is_professional': false,
      'oauth_token': 'token123',
      'oauth_refresh': 'refresh123',
      'imap_host': null,
      'imap_port': null,
      'imap_use_ssl': true,
      'last_sync_at': '2026-01-15T10:30:00Z',
      'sync_enabled': true,
      'folders_watched': ['INBOX', 'SENT'],
      'is_active': true,
      'created_at': '2026-01-01T00:00:00Z',
    };

    test('crée un MailAccount correct depuis JSON', () {
      final account = MailAccount.fromJson(json);

      expect(account.id, 'mail-1');
      expect(account.provider, MailProvider.gmail);
      expect(account.emailAddress, 'test@gmail.com');
      expect(account.displayName, 'Mon Gmail');
      expect(account.isPersonal, true);
      expect(account.isProfessional, false);
      expect(account.hasOAuth, true);
      expect(account.foldersWatched, ['INBOX', 'SENT']);
    });

    test('label retourne displayName si disponible', () {
      final account = MailAccount.fromJson(json);
      expect(account.label, 'Mon Gmail');
    });

    test('label retourne email si pas de displayName', () {
      final account = MailAccount.fromJson({
        ...json,
        'display_name': null,
      });
      expect(account.label, 'test@gmail.com');
    });
  });

  group('MailAccount — accountType', () {
    MailAccount makeAccount({
      bool isPersonal = false,
      bool isProfessional = true,
    }) =>
        MailAccount(
          id: '1',
          userId: 'u1',
          provider: MailProvider.gmail,
          emailAddress: 'test@test.com',
          isPersonal: isPersonal,
          isProfessional: isProfessional,
        );

    test('Professionnel par défaut', () {
      expect(makeAccount().accountType, 'Professionnel');
    });

    test('Personnel seul', () {
      expect(
        makeAccount(isPersonal: true, isProfessional: false).accountType,
        'Personnel',
      );
    });

    test('Mixte si les deux', () {
      expect(
        makeAccount(isPersonal: true, isProfessional: true).accountType,
        'Mixte',
      );
    });
  });

  group('MailAccount — hasOAuth / hasImapConfig', () {
    test('hasOAuth true quand token présent', () {
      final account = MailAccount(
        id: '1',
        userId: 'u1',
        provider: MailProvider.gmail,
        emailAddress: 'test@gmail.com',
        oauthToken: 'token',
      );
      expect(account.hasOAuth, true);
    });

    test('hasOAuth false quand token vide', () {
      final account = MailAccount(
        id: '1',
        userId: 'u1',
        provider: MailProvider.gmail,
        emailAddress: 'test@gmail.com',
        oauthToken: '',
      );
      expect(account.hasOAuth, false);
    });

    test('hasImapConfig true pour IMAP complet', () {
      final account = MailAccount(
        id: '1',
        userId: 'u1',
        provider: MailProvider.imap,
        emailAddress: 'test@custom.com',
        imapHost: 'imap.custom.com',
        imapPort: 993,
      );
      expect(account.hasImapConfig, true);
    });

    test('hasImapConfig false pour Gmail', () {
      final account = MailAccount(
        id: '1',
        userId: 'u1',
        provider: MailProvider.gmail,
        emailAddress: 'test@gmail.com',
        imapHost: 'imap.gmail.com',
        imapPort: 993,
      );
      expect(account.hasImapConfig, false);
    });
  });

  group('MailAccount — toJson', () {
    test('sérialise correctement', () {
      final account = MailAccount(
        id: '1',
        userId: 'u1',
        provider: MailProvider.outlook,
        emailAddress: 'test@outlook.com',
        syncEnabled: false,
        foldersWatched: const ['INBOX', 'Drafts'],
      );

      final json = account.toJson();

      expect(json['provider'], 'outlook');
      expect(json['email_address'], 'test@outlook.com');
      expect(json['sync_enabled'], false);
      expect(json['folders_watched'], ['INBOX', 'Drafts']);
    });
  });

  group('MailAccount — copyWith', () {
    test('modifie un champ sans toucher les autres', () {
      final account = MailAccount(
        id: '1',
        userId: 'u1',
        provider: MailProvider.gmail,
        emailAddress: 'test@gmail.com',
        syncEnabled: true,
      );

      final updated = account.copyWith(syncEnabled: false);

      expect(updated.syncEnabled, false);
      expect(updated.emailAddress, 'test@gmail.com');
      expect(updated.provider, MailProvider.gmail);
    });
  });

  group('MailState', () {
    test('activeCount compte les comptes actifs', () {
      final state = MailState(
        accounts: [
          MailAccount(
            id: '1',
            userId: 'u1',
            provider: MailProvider.gmail,
            emailAddress: 'a@a.com',
            isActive: true,
          ),
          MailAccount(
            id: '2',
            userId: 'u1',
            provider: MailProvider.outlook,
            emailAddress: 'b@b.com',
            isActive: false,
          ),
        ],
      );

      expect(state.activeCount, 1);
    });

    test('gmailAccounts filtre correctement', () {
      final state = MailState(
        accounts: [
          MailAccount(
            id: '1',
            userId: 'u1',
            provider: MailProvider.gmail,
            emailAddress: 'a@gmail.com',
          ),
          MailAccount(
            id: '2',
            userId: 'u1',
            provider: MailProvider.outlook,
            emailAddress: 'b@outlook.com',
          ),
        ],
      );

      expect(state.gmailAccounts.length, 1);
      expect(state.outlookAccounts.length, 1);
    });
  });

  group('MailAccount — lastSyncFormatted', () {
    test('affiche "Jamais synchronisé" si null', () {
      final account = MailAccount(
        id: '1',
        userId: 'u1',
        provider: MailProvider.gmail,
        emailAddress: 'test@gmail.com',
      );
      expect(account.lastSyncFormatted, 'Jamais synchronisé');
    });
  });
}
