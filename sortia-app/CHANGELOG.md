# SORTIA — Changelog

## [0.1.0] — 2026-03-01

### Ajouté
- Structure complète du projet Flutter multiplateforme
- Système de thème clair/sombre avec palette Sortia
- Navigation GoRouter avec guards d'authentification
- Écrans : Login, Register, ForgotPassword, Explorer, Dashboard, Settings
- Service de chiffrement AES-256-CBC
- Service de stockage sécurisé (Keychain/Keystore/DPAPI)
- Service biométrique (Face ID / empreinte)
- Service PIN à 6 chiffres (hashé SHA-256)
- Certificate Pinning (production)
- Détection jailbreak/root
- Client HTTP Dio configuré
- Gestion centralisée des erreurs
- Service de connectivité réseau
- Base de données Supabase (14 tables, RLS, triggers, indexes)
- CI/CD GitHub Actions (lint, tests, security scan, build Windows)
- Installateur Windows via Inno Setup
- Documentation complète (Architecture, Sécurité, Déploiement, API Keys)
