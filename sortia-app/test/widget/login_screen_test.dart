// ================================================================
// SORTIA — Tests Widget : LoginScreen
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/auth/presentation/screens/login_screen.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('affiche le titre de bienvenue', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Bienvenue sur Sortia'), findsOneWidget);
      expect(
        find.text('Votre secrétaire administrative intelligente'),
        findsOneWidget,
      );
    });

    testWidgets('affiche les boutons OAuth', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Continuer avec Google'), findsOneWidget);
      expect(find.text('Continuer avec Microsoft'), findsOneWidget);
    });

    testWidgets('affiche les champs email et mot de passe', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Adresse email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
    });

    testWidgets('affiche les boutons d\'action', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('Créer un compte'), findsOneWidget);
    });

    testWidgets('affiche le lien mot de passe oublié', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    });

    testWidgets('valide le formulaire visuellement', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Vérifier que le formulaire existe avec les bons labels
      expect(find.text('Adresse email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('Créer un compte'), findsOneWidget);

      // Vérifier le séparateur 'ou' entre OAuth et email
      expect(find.text('ou'), findsOneWidget);

      // Vérifier la présence du logo Sortia (Container avec Icon)
      expect(find.byIcon(Icons.folder_special_rounded), findsOneWidget);
    });
  });
}
