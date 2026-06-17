# SORTIA — Guide de déploiement

## Supabase

### Appliquer les migrations
```bash
# Via le SQL Editor dans le dashboard Supabase
# Ou via la CLI Supabase :
supabase db push
```

### Ordre des migrations
1. `001_initial_schema.sql` — Tables de base
2. `002_rls_policies.sql` — Row Level Security
3. `003_functions.sql` — Triggers et fonctions
4. `004_indexes.sql` — Index de performance

### Réinitialiser la base (dev uniquement)
```bash
supabase db reset
```

## Build Windows
```bash
flutter build windows --release
```

## Installateur Windows
```bash
# Après le build Windows
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer/windows/sortia_installer.iss
```

## GitHub Actions
Les workflows CI/CD se déclenchent automatiquement :
- **ci.yml** : sur chaque push/PR → tests, lint, build
- **security-scan.yml** : hebdomadaire + push sur main
- **build-windows.yml** : push sur main + tags v*

## Variables d'environnement requises
Voir `.env.example` pour la liste complète.
Configurer dans GitHub Secrets pour la CI.
