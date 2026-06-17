// ================================================================
// SORTIA — Détection d'intégrité de l'appareil
// Jailbreak/root detection
// ================================================================

import 'dart:io';

import '../utils/logger.dart';

/// Statut d'intégrité de l'appareil
enum DeviceIntegrityStatus {
  /// Appareil sain et vérifié
  clean,

  /// Appareil iOS jailbreaké
  jailbroken,

  /// Appareil Android rooté
  rooted,

  /// Appareil est un émulateur
  emulator,

  /// Statut inconnu
  unknown,
}

/// Service de vérification d'intégrité de l'appareil
///
/// Détecte les appareils rootés/jailbreakés.
/// En production, affiche un avertissement mais ne bloque pas
/// (certains utilisateurs légitimes ont des appareils modifiés).
class DeviceIntegrityService {
  /// Vérifie l'intégrité de l'appareil
  Future<DeviceIntegrityStatus> checkIntegrity() async {
    if (Platform.isAndroid) {
      return _checkAndroid();
    } else if (Platform.isIOS) {
      return _checkIOS();
    }
    // Windows/macOS : pas de vérification nécessaire
    return DeviceIntegrityStatus.clean;
  }

  Future<DeviceIntegrityStatus> _checkAndroid() async {
    try {
      final rootIndicators = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
      ];

      for (final path in rootIndicators) {
        if (await File(path).exists()) {
          AppLogger.warning('DeviceIntegrity: indicateur root détecté: $path');
          return DeviceIntegrityStatus.rooted;
        }
      }

      return DeviceIntegrityStatus.clean;
    } catch (e) {
      return DeviceIntegrityStatus.unknown;
    }
  }

  Future<DeviceIntegrityStatus> _checkIOS() async {
    try {
      final jailbreakPaths = [
        '/Applications/Cydia.app',
        '/Library/MobileSubstrate/MobileSubstrate.dylib',
        '/bin/bash',
        '/usr/sbin/sshd',
        '/etc/apt',
        '/private/var/lib/apt/',
      ];

      for (final path in jailbreakPaths) {
        if (await File(path).exists()) {
          AppLogger.warning(
            'DeviceIntegrity: indicateur jailbreak détecté: $path',
          );
          return DeviceIntegrityStatus.jailbroken;
        }
      }

      return DeviceIntegrityStatus.clean;
    } catch (e) {
      return DeviceIntegrityStatus.unknown;
    }
  }

  /// Détermine si l'accès doit être autorisé selon le statut
  Future<bool> shouldAllowAccess() async {
    final status = await checkIntegrity();

    switch (status) {
      case DeviceIntegrityStatus.clean:
      case DeviceIntegrityStatus.unknown:
        return true;
      case DeviceIntegrityStatus.jailbroken:
      case DeviceIntegrityStatus.rooted:
      case DeviceIntegrityStatus.emulator:
        // Avertissement mais pas de blocage
        AppLogger.warning(
          'DeviceIntegrity: appareil compromis ($status) — accès autorisé '
          'avec avertissement',
        );
        return true;
    }
  }
}
