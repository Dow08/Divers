// ================================================================
// SORTIA — Générateur de configuration env.dart
// Usage: dart run scripts/generate_env.dart
// Lit le fichier .env et génère lib/core/config/env.dart
// ================================================================

// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final envFile = File('.env');

  if (!envFile.existsSync()) {
    print('❌ Fichier .env introuvable.');
    print('   Copiez .env.example vers .env et remplissez les valeurs.');
    exit(1);
  }

  final lines = envFile.readAsLinesSync();
  final entries = <String, String>{};

  for (final line in lines) {
    final trimmed = line.trim();
    // Ignorer les commentaires et les lignes vides
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

    final separatorIndex = trimmed.indexOf('=');
    if (separatorIndex == -1) continue;

    final key = trimmed.substring(0, separatorIndex).trim();
    final value = trimmed.substring(separatorIndex + 1).trim();
    entries[key] = value;
  }

  if (entries.isEmpty) {
    print('⚠️  Aucune variable trouvée dans .env');
    exit(1);
  }

  // Générer le fichier Dart
  final buffer = StringBuffer()
    ..writeln('// ================================================================')
    ..writeln('// FICHIER GÉNÉRÉ AUTOMATIQUEMENT — NE PAS MODIFIER MANUELLEMENT')
    ..writeln('// Généré par: dart run scripts/generate_env.dart')
    ..writeln('// ================================================================')
    ..writeln()
    ..writeln("// ignore_for_file: constant_identifier_names")
    ..writeln()
    ..writeln('/// Variables d\'environnement chargées depuis .env')
    ..writeln('abstract final class Env {');

  for (final entry in entries.entries) {
    buffer.writeln(
      "  static const String ${entry.key} = '${entry.value}';",
    );
  }

  buffer
    ..writeln('}')
    ..writeln();

  // Écrire le fichier
  final outputDir = Directory('lib/core/config');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final outputFile = File('lib/core/config/env.dart');
  outputFile.writeAsStringSync(buffer.toString());

  print('✅ Généré: lib/core/config/env.dart');
  print('   ${entries.length} variable(s) chargée(s)');
}
