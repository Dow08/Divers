// ================================================================
// SORTIA — Tests unitaires : FormValidators
// ================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:sortia/shared/utils/form_validators.dart';

void main() {
  group('FormValidators.validateEmail', () {
    test('retourne une erreur si vide', () {
      expect(FormValidators.validateEmail(''), isNotNull);
      expect(FormValidators.validateEmail(null), isNotNull);
    });

    test('retourne une erreur si email invalide', () {
      expect(FormValidators.validateEmail('test'), isNotNull);
      expect(FormValidators.validateEmail('test@'), isNotNull);
      expect(FormValidators.validateEmail('@test.com'), isNotNull);
      expect(FormValidators.validateEmail('test@.com'), isNotNull);
    });

    test('retourne null si email valide', () {
      expect(FormValidators.validateEmail('test@example.com'), isNull);
      expect(FormValidators.validateEmail('user.name@domain.fr'), isNull);
      expect(FormValidators.validateEmail('a+b@c.io'), isNull);
    });
  });

  group('FormValidators.validatePassword', () {
    test('retourne une erreur si vide', () {
      expect(FormValidators.validatePassword(''), isNotNull);
      expect(FormValidators.validatePassword(null), isNotNull);
    });

    test('retourne une erreur si trop court', () {
      expect(FormValidators.validatePassword('Ab1!'), isNotNull);
    });

    test('retourne une erreur si pas de majuscule', () {
      expect(FormValidators.validatePassword('abcdefg1!'), isNotNull);
    });

    test('retourne une erreur si pas de chiffre', () {
      expect(FormValidators.validatePassword('Abcdefgh!'), isNotNull);
    });

    test('retourne une erreur si pas de caractère spécial', () {
      expect(FormValidators.validatePassword('Abcdefg1'), isNotNull);
    });

    test('retourne null si mot de passe valide', () {
      expect(FormValidators.validatePassword('Abcdefg1!'), isNull);
      expect(FormValidators.validatePassword('MonP@ssw0rd'), isNull);
      expect(FormValidators.validatePassword('S3cr3t!Pwd'), isNull);
    });
  });

  group('FormValidators.validatePasswordConfirm', () {
    test('retourne une erreur si les mots de passe diffèrent', () {
      expect(
        FormValidators.validatePasswordConfirm('abc', 'xyz'),
        isNotNull,
      );
    });

    test('retourne null si les mots de passe correspondent', () {
      expect(
        FormValidators.validatePasswordConfirm('Abc123!x', 'Abc123!x'),
        isNull,
      );
    });
  });

  group('FormValidators.validateFullName', () {
    test('retourne une erreur si vide', () {
      expect(FormValidators.validateFullName(''), isNotNull);
      expect(FormValidators.validateFullName(null), isNotNull);
    });

    test('retourne une erreur si trop court', () {
      expect(FormValidators.validateFullName('A'), isNotNull);
    });

    test('retourne null si nom valide', () {
      expect(FormValidators.validateFullName('Jean Dupont'), isNull);
      expect(FormValidators.validateFullName('Marie'), isNull);
    });
  });

  group('FormValidators.validatePin', () {
    test('retourne une erreur si non-numérique', () {
      expect(FormValidators.validatePin('abcdef'), isNotNull);
    });

    test('retourne une erreur si mauvaise longueur', () {
      expect(FormValidators.validatePin('12345'), isNotNull);
      expect(FormValidators.validatePin('1234567'), isNotNull);
    });

    test('retourne null si PIN valide', () {
      expect(FormValidators.validatePin('123456'), isNull);
      expect(FormValidators.validatePin('000000'), isNull);
    });
  });

  group('FormValidators.passwordStrength', () {
    test('retourne 0.0 pour un mot de passe vide', () {
      expect(FormValidators.passwordStrength(''), equals(0.0));
    });

    test('retourne une valeur faible pour un mot de passe simple', () {
      expect(FormValidators.passwordStrength('abc'), lessThan(0.3));
    });

    test('retourne une valeur élevée pour un mot de passe complexe', () {
      expect(
        FormValidators.passwordStrength('MyP@ssw0rd2024!'),
        greaterThan(0.7),
      );
    });
  });

  group('FormValidators.passwordStrengthLabel', () {
    test('retourne les bons labels', () {
      expect(FormValidators.passwordStrengthLabel(0.1), equals('Très faible'));
      expect(FormValidators.passwordStrengthLabel(0.4), equals('Faible'));
      expect(FormValidators.passwordStrengthLabel(0.6), equals('Moyen'));
      expect(FormValidators.passwordStrengthLabel(0.8), equals('Fort'));
      expect(FormValidators.passwordStrengthLabel(1.0), equals('Très fort'));
    });
  });
}
