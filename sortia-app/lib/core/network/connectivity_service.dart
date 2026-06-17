// ================================================================
// SORTIA — Service de connectivité réseau
// ================================================================

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../utils/logger.dart';

/// Service de surveillance de la connectivité réseau
///
/// Permet de vérifier l'état de la connexion et de réagir
/// aux changements (online/offline) en temps réel.
class ConnectivityService {
  /// Crée le service de connectivité
  ConnectivityService() : _connectivity = Connectivity();

  final Connectivity _connectivity;

  /// Vérifie si l'appareil est actuellement connecté
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  /// Stream des changements de connectivité
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      final connected = !results.contains(ConnectivityResult.none);
      AppLogger.debug(
        'Connectivité: ${connected ? "en ligne" : "hors ligne"}',
      );
      return connected;
    });
  }
}
