# SORTIA — Politique de sécurité

## Mesures implémentées

### Chiffrement
- **AES-256-CBC** avec IV aléatoire pour chaque opération
- Clé maître stockée dans le Keychain/Keystore/DPAPI du système
- Hash SHA-256 pour la vérification d'intégrité des fichiers

### Authentification
- Supabase Auth avec PKCE flow
- OAuth2 : Google, Microsoft
- Email/mot de passe avec vérification
- PIN à 6 chiffres (hashé SHA-256 + sel)
- Biométrie (Face ID, Touch ID, empreinte Android)

### Réseau
- Certificate Pinning en production
- HTTPS exclusif (pas de HTTP)
- Timeouts configurés (15s connexion, 30s réponse)
- Retry automatique avec backoff exponentiel

### Base de données
- Row Level Security (RLS) sur les 14 tables
- Chaque utilisateur ne voit que ses propres données
- Tokens OAuth chiffrés AES-256 avant stockage

### CI/CD
- Scan Trivy automatique (filesystem + secrets)
- Gitleaks sur l'historique Git complet
- dart pub audit sur chaque push
- Pipeline bloqué si vulnérabilité CRITICAL/HIGH

## Signaler une vulnérabilité
Contacter security@sortia.fr avec les détails de la faille.
Ne pas ouvrir de ticket public avant résolution.
