// ================================================================
// SORTIA — Tests unitaires : SortiaAuthState
// ================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sortia/features/auth/domain/models/user_model.dart';
import 'package:sortia/features/auth/domain/states/auth_state.dart';

void main() {
  group('SortiaAuthState', () {
    test('initial a le statut correct', () {
      const state = SortiaAuthState.initial();

      expect(state.status, SortiaAuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, true);
      expect(state.isAuthenticated, false);
    });

    test('unauthenticated a le statut correct', () {
      const state = SortiaAuthState.unauthenticated();

      expect(state.status, SortiaAuthStatus.unauthenticated);
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
    });

    test('authenticated contient l\'utilisateur', () {
      final user = UserModel.fromJson({
        'id': 'user-001',
        'email': 'test@test.fr',
      });
      final state = SortiaAuthState.authenticated(user: user);

      expect(state.status, SortiaAuthStatus.authenticated);
      expect(state.isAuthenticated, true);
      expect(state.user, isNotNull);
      expect(state.user!.email, 'test@test.fr');
    });

    test('localMode a le statut correct', () {
      const state = SortiaAuthState.localMode();

      expect(state.status, SortiaAuthStatus.localMode);
      expect(state.isLocalMode, true);
      expect(state.isAuthenticated, false);
    });

    test('error contient le message', () {
      const state = SortiaAuthState.error(message: 'Identifiants incorrects.');

      expect(state.status, SortiaAuthStatus.error);
      expect(state.hasError, true);
      expect(state.errorMessage, 'Identifiants incorrects.');
    });
  });

  group('SortiaAuthStatus', () {
    test('contient 5 valeurs', () {
      expect(SortiaAuthStatus.values.length, 5);
      expect(SortiaAuthStatus.values, contains(SortiaAuthStatus.initial));
      expect(SortiaAuthStatus.values, contains(SortiaAuthStatus.authenticated));
      expect(SortiaAuthStatus.values, contains(SortiaAuthStatus.unauthenticated));
      expect(SortiaAuthStatus.values, contains(SortiaAuthStatus.localMode));
      expect(SortiaAuthStatus.values, contains(SortiaAuthStatus.error));
    });
  });
}
