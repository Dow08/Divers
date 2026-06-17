// ================================================================
// SORTIA — Tests unitaires : UserModel
// ================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/auth/domain/models/user_model.dart';

void main() {
  group('UserModel', () {
    final sampleJson = {
      'id': 'user-001',
      'email': 'jean@sortia.fr',
      'full_name': 'Jean Dupont',
      'avatar_url': 'https://example.com/avatar.jpg',
      'plan': 'starter',
      'onboarding_done': true,
      'template_chosen': 'tpe',
      'locale': 'fr',
      'timezone': 'Europe/Paris',
      'created_at': '2026-01-01T00:00:00Z',
    };

    test('fromJson crée un modèle correct', () {
      final user = UserModel.fromJson(sampleJson);

      expect(user.id, 'user-001');
      expect(user.email, 'jean@sortia.fr');
      expect(user.fullName, 'Jean Dupont');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.plan, 'starter');
      expect(user.onboardingDone, true);
      expect(user.templateChosen, 'tpe');
    });

    test('fromJson gère les valeurs minimales', () {
      final minimalJson = {
        'id': 'user-002',
        'email': 'test@test.fr',
      };
      final user = UserModel.fromJson(minimalJson);

      expect(user.id, 'user-002');
      expect(user.email, 'test@test.fr');
      expect(user.fullName, '');
      expect(user.plan, 'free'); // défaut
      expect(user.onboardingDone, false);
    });

    test('toJson sérialise correctement', () {
      final user = UserModel.fromJson(sampleJson);
      final json = user.toJson();

      expect(json['id'], 'user-001');
      expect(json['email'], 'jean@sortia.fr');
      expect(json['full_name'], 'Jean Dupont');
      expect(json['plan'], 'starter');
    });

    test('copyWith modifie un champ', () {
      final user = UserModel.fromJson(sampleJson);
      final upgraded = user.copyWith(plan: 'pro');

      expect(upgraded.plan, 'pro');
      expect(upgraded.id, user.id); // inchangé
      expect(upgraded.email, user.email);
    });

    test('copyWith modifie fullName', () {
      final user = UserModel.fromJson(sampleJson);
      final renamed = user.copyWith(fullName: 'Marie Martin');

      expect(renamed.fullName, 'Marie Martin');
      expect(renamed.email, user.email);
    });

    test('equality basée sur id', () {
      final a = UserModel.fromJson(sampleJson);
      final b = UserModel.fromJson(sampleJson);
      expect(a, equals(b));
    });

    test('toString contient l\'email', () {
      final user = UserModel.fromJson(sampleJson);
      expect(user.toString(), contains('jean@sortia.fr'));
    });
  });
}
