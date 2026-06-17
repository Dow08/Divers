# SORTIA — Architecture

## Décisions architecturales

### Clean Architecture par feature
Chaque feature est organisée en 3 couches :
- **data/** — Accès aux données (Supabase, API, cache local)
- **domain/** — Modèles et cas d'usage (logique métier pure)
- **presentation/** — UI (écrans, widgets, contrôleurs Riverpod)

### State Management : Riverpod
Choisi pour sa testabilité et sa séparation des responsabilités.
Pas de Provider legacy. Pas de Bloc (trop verbeux pour ce projet).

### Navigation : GoRouter
Navigation déclarative avec guards d'authentification.
Deep linking prêt pour le web et les liens universels mobile.

### Sécurité
- AES-256-CBC pour le chiffrement des données sensibles
- SHA-256 pour les hachages d'intégrité (coffre-fort)
- Certificate Pinning en production
- RLS (Row Level Security) sur toutes les tables Supabase
- flutter_secure_storage (Keychain iOS, Keystore Android, DPAPI Windows)
- Détection jailbreak/root (non bloquant)

### Base de données
- PostgreSQL 15 via Supabase (région EU Frankfurt, conformité RGPD)
- Recherche full-text avec tsvector et pg_trgm
- Quotas de stockage appliqués au niveau DB (trigger)
- Profil utilisateur créé automatiquement à l'inscription (trigger)

### IA
- Gemini Flash 2.0 : classification rapide des documents
- Gemini Pro 2.0 : agent IA spécialisé (plans Expert/Business)
- Gemini Vision : OCR et analyse d'images
