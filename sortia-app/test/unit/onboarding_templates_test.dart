// ================================================================
// SORTIA — Tests unitaires : OnboardingTemplates
// ================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/explorer/data/onboarding_templates.dart';

void main() {
  group('OnboardingTemplates', () {
    test('all contient 5 templates', () {
      expect(OnboardingTemplates.all.length, 5);
    });

    test('chaque template a un id, nom et description', () {
      for (final template in OnboardingTemplates.all) {
        expect(template.id, isNotEmpty);
        expect(template.name, isNotEmpty);
        expect(template.description, isNotEmpty);
      }
    });

    test('les ids sont uniques', () {
      final ids = OnboardingTemplates.all.map((t) => t.id).toSet();
      expect(ids.length, 5);
    });

    test('getTemplate retourne TPE avec dossiers', () {
      final tpe = OnboardingTemplates.getTemplate('tpe');
      expect(tpe, isNotEmpty);
      expect(tpe.first.name, 'Comptabilité');
    });

    test('getTemplate retourne auto avec dossiers', () {
      final auto = OnboardingTemplates.getTemplate('auto');
      expect(auto, isNotEmpty);
      expect(auto.first.name, 'Factures');
    });

    test('getTemplate retourne famille avec dossiers', () {
      final famille = OnboardingTemplates.getTemplate('famille');
      expect(famille, isNotEmpty);
      expect(famille.first.name, 'Identité');
    });

    test('getTemplate retourne immobilier avec dossiers', () {
      final immobilier = OnboardingTemplates.getTemplate('immobilier');
      expect(immobilier, isNotEmpty);
    });

    test('getTemplate retourne vierge = vide', () {
      final vierge = OnboardingTemplates.getTemplate('vierge');
      expect(vierge, isEmpty);
    });

    test('getTemplate retourne vide pour id inconnu', () {
      final unknown = OnboardingTemplates.getTemplate('inconnu');
      expect(unknown, isEmpty);
    });

    test('TPE a des sous-dossiers imbriqués', () {
      final tpe = OnboardingTemplates.getTemplate('tpe');
      final comptabilite = tpe.first;
      expect(comptabilite.children, isNotEmpty);
      expect(comptabilite.children.length, greaterThanOrEqualTo(3));
    });
  });
}
