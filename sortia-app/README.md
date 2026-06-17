# SORTIA — Votre secrétaire administrative IA

[![CI](https://github.com/YOUR_USERNAME/sortia/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/sortia/actions/workflows/ci.yml)
[![Security](https://github.com/YOUR_USERNAME/sortia/actions/workflows/security-scan.yml/badge.svg)](https://github.com/YOUR_USERNAME/sortia/actions/workflows/security-scan.yml)

> Application Flutter multiplateforme de gestion documentaire intelligente pour les TPE/PME françaises.

## 🚀 Fonctionnalités

- 📂 **Explorateur de documents** — Navigation intuitive avec arborescence
- 🤖 **Classification IA** — Tri automatique via Google Gemini
- 📸 **Scan & OCR** — Photo → texte structuré via Gemini Vision
- 🔐 **Coffre-fort numérique** — Certifié avec hash SHA-256
- ✍️ **Signature électronique** — Conforme eIDAS via Yousign
- 📧 **Intégration mail** — Gmail & Outlook avec classement auto
- 🔔 **Alertes intelligentes** — Rappels RGPD, renouvellements
- 📊 **Tableau de bord** — Vue d'ensemble de votre activité
- 🔄 **Sync cloud** — Google Drive, OneDrive, Dropbox
- 🇫🇷 **Conformité 2026** — Facturation électronique Factur-X

## 📋 Prérequis

- Flutter SDK >= 3.19.0
- Dart SDK >= 3.3.0
- Visual Studio 2022 (pour le build Windows)
- Git

## ⚡ Démarrage rapide

```bash
# 1. Cloner le projet
git clone https://github.com/YOUR_USERNAME/sortia.git
cd sortia

# 2. Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos clés API

# 3. Générer la configuration
dart run scripts/generate_env.dart

# 4. Installer les dépendances
flutter pub get

# 5. Générer le code (Freezed, JSON, Riverpod)
dart run build_runner build --delete-conflicting-outputs

# 6. Lancer l'app
flutter run -d windows
```

## 🏗️ Architecture

```
lib/
├── app/          # MaterialApp, Router, Theme
├── core/         # Config, Security, Network, AI, Utils
├── features/     # Modules métier (auth, explorer, notes, etc.)
└── shared/       # Widgets et extensions réutilisables
```

Chaque feature suit l'architecture **Clean Architecture** :
- `data/` — Repositories, DataSources
- `domain/` — Models, UseCases
- `presentation/` — Controllers, Screens, Widgets

## 🔒 Sécurité

- Chiffrement AES-256-CBC pour les données sensibles
- Certificate Pinning en production
- Row Level Security (RLS) sur toutes les tables Supabase
- Détection jailbreak/root
- Authentification biométrique
- Aucune clé API dans le code source

## 📄 Licence

Propriétaire — © 2026 Sortia SAS. Tous droits réservés.
