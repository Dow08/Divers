# 🔐 AUDIT COMPLET DES CREDENTIALS N8N
**Date:** 1er avril 2026  
**Phase:** Étape 2 - Vérification des Credentials N8N

---

## MATRICE : Workflows × Credentials Requis

| Credential | Type | WF-01 | WF-02 | WF-03 | WF-04 | WF-05 | WF-06 | WF-07 | WF-08 | WF-09 | Statut |
|-----------|------|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|--------|
| **Brevo SMTP NEXUS** | SMTP | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ CONFIGURÉ |
| **Google Sheets NEXUS** | OAuth2 | ❌ | ❌ | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ CONFIGURÉ |
| **NEXUS Bot Telegram** | API | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ CONFIGURÉ |
| **Stripe NEXUS** | API | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ⚠️ SECRET MANQUANT |
| **Google Drive NEXUS** | OAuth2 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❓ À VÉRIFIER |
| **N8N API Key** | Header | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ⚠️ RENOUVELÉ |
| **WordPress API NEXUS** | Header | ❌ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ⏳ À CONFIGURER |
| **Beehiiv API NEXUS** | Header | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ CONFIGURÉ |
| **Claude API NEXUS** | API | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ REMPLACÉ (→Gemini) |
| **Google Gemini** | API | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ CONFIGURÉ |
| **Gumroad Webhook** | Webhook | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ⏳ À CONFIGURER (VPS) |

---

## ✅ CREDENTIALS OPÉRATIONNELS

### 1. **Brevo SMTP NEXUS** ✅
- **Type:** SMTP
- **Hôte:** smtp-relay.brevo.com
- **Port:** 587 (STARTTLS) — ✅ CORRIGÉ (Port 465 SMTPS → Port 587 STARTTLS)
- **Authentification:** a6541e001@smtp-brevo.com
- **Clé API:** xsmtpsib-[REDACTED]
- **Statut test:** ✅ "Connection tested successfully" (Session #7, 29/03/2026)
- **Workflows dépendants:** WF-05, WF-06, WF-07, WF-09 (emails de livraison)

### 2. **NEXUS Bot Telegram** ✅
- **Type:** Telegram Bot API
- **Token:** [REDACTED]
- **Chat ID:** 7705787464 (Telegram user ID personnel)
- **Statut:** ✅ CONFIGURÉ (Session #3, 28/03/2026)
- **Workflows dépendants:** Tous (WF-01 à WF-09) — alertes temps réel

### 3. **Google Sheets NEXUS** ✅
- **Type:** OAuth2 API
- **Spreadsheet ID:** 1MoQ9MR5hquCI3R7FyO5zRm5C1sDGWckTTtFw8t61zws
- **URL:** https://docs.google.com/spreadsheets/d/1MoQ9MR5hquCI3R7FyO5zRm5C1sDGWckTTtFw8t61zws
- **Onglets:** Ventes | Leads | Newsletter | Trafic | Alertes | Config
- **Statut:** ✅ Account connected (Session #4, 28/03/2026)
- **Workflows dépendants:** WF-03, WF-04, WF-06, WF-07, WF-08, WF-09

### 4. **Beehiiv API NEXUS** ✅
- **Type:** HTTP Header Auth
- **Publication ID:** pub_ab9381e0-2d4f-4dd3-8768-572ed1d1936b
- **Clé API:** SBH1GSSWaHpAWNksZFqmbbAHHkvZD22zSHbpBwEuItJf4SgEf3aD6aDWZXkUJkbt
- **Statut:** ✅ CONFIGURÉ
- **Workflows dépendants:** WF-03 (Newsletter Hebdo), WF-08 (Dashboard)
- **Note:** Newsletter renommage "Dow Nexus Newsletter" → "Conformité PME"

### 5. **Google Gemini API** ✅
- **Type:** Generative AI API
- **Clé API:** [REDACTED]
- **Modèle:** gemini-2.0-flash
- **Limite:** 1 500 req/jour (gratuit)
- **Statut:** ✅ CONFIGURÉ (Session #7, 29/03/2026)
- **Workflows dépendants:** WF-02, WF-03, WF-09 (remplace Anthropic)
- **Réponse parse:** $json.candidates[0].content.parts[0].text

### 6. **Stripe NEXUS** ⚠️ PARTIELLEMENT CONFIGURÉ
- **Type:** Stripe API (Payment Processing)
- **Mode:** TEST (development)
- **Clé Publique:** pk_test_51T6FKqJgMxnUBKFbfHQXI0TBoF7ZGpYPqugFlStGOzRZ5OgtdkvqwnEzx32asV6JN43ifI77KzIDi1YeqvX4pM1l00W9sgaJ8Q
- **Clé Secrète:** STRIPE_TEST_KEY_REMOVED[REDACTED]
- **Webhook Secret:** ❌ **MANQUANT** — `REMPLIR_WEBHOOK_SECRET_STRIPE`
- **Statut:** ✅ API Key configurée | ⏳ Webhook endpoint déferred à VPS
- **Workflows dépendants:** WF-04 (Alertes Revenus Temps Réel)
- **Dashboard Stripe:** https://dashboard.stripe.com/test/apikeys

### 7. **N8N API Key** ⚠️ RENOUVELÉ
- **Label:** NEXUS-BACKUP-WF01 (nouvelle création)
- **Ancienne clé:** Expirée le 28/04/2026 — ❌ SUPPRIMÉE (Session #7)
- **Nouvelle clé:** Créée 01/04/2026 — Expire le 01/05/2026 (30 jours)
- **Autres clés permanentes:**
  - NEXUS-SESSION3: Never expires
  - nexusv2: Never expires
  - NEXUS-AUTOMATION: Never expires
- **Statut:** ✅ RENOUVELÉ avant expiration
- **Workflows dépendants:** WF-01 (Récupérer workflows N8N via header)

---

## ⏳ CREDENTIALS EN ATTENTE DE CONFIGURATION

### 1. **WordPress API NEXUS** ⏳ À CONFIGURER
- **Type:** HTTP Header Auth (Basic Auth)
- **URL:** https://nexusconformite.fr (production)
- **Username:** dow
- **App Password:** ❌ **À GÉNÉRER** — Admin > Utilisateurs > Profil > Mots de passe d'application
- **Statut:** ⏳ En attente de configuration WordPress
- **Workflows dépendants:** WF-02 (Veille Législative), WF-05 (Onboarding)
- **Action requise:** Générer mot de passe application dans WordPress admin

### 2. **Gumroad Webhook Secret** ⏳ À Configurer (VPS)
- **Type:** Webhook Signature Secret
- **Service:** Gumroad Digital Product Delivery
- **URL Webhook:** `http://[IP_PUBLIQUE]:5678/webhook/gumroad-webhook`
- **Secret:** ❌ **À REMPLIR** — Après création du webhook sur Gumroad
- **Statut:** ⏳ Déferred à phase VPS (requires public IP)
- **Workflows dépendants:** WF-07 (Livraison Gumroad + Suivi J+7)
- **Action requise:** 
  1. Configurer URL webhook sur https://app.gumroad.com/settings/advanced
  2. Copier le secret généré par Gumroad
  3. Ajouter à `.env`: `GUMROAD_WEBHOOK_SECRET=gumroad_secret_xxx`

### 3. **Google Drive NEXUS** ❓ À Vérifier
- **Type:** OAuth2 API
- **Statut:** Configuration présumée existante mais non vérifiée
- **Workflows dépendants:** WF-01 (Backup Auto Hebdomadaire)
- **Action requise:** Vérifier via N8N Credentials UI (http://localhost:5678/home/credentials)

---

## ❌ CREDENTIALS ARCHIVÉS / REMPLACÉS

### Claude API NEXUS ❌ Archivé (remplacé par Gemini)
- **Raison:** Compte Anthropic sans crédits suffisants
- **Clé conservée:** sk-ant-api03-[REDACTED]
- **Remplacement:** Google Gemini (gratuit, 1 500 req/jour)
- **Workflows affectés:** WF-02, WF-03, WF-09
- **Statut:** ✅ Remplacé par Gemini (Session #7, 29/03/2026)

---

## RÉSUMÉ STATUT

| Catégorie | Nombre | Status |
|-----------|--------|--------|
| ✅ Configurés & testés | 6 | Brevo, Google Sheets, Telegram, Beehiiv, Gemini, Stripe(API) |
| ⚠️ Partiellement configurés | 1 | Stripe (API OK, Webhook manquant) |
| ⏳ En attente configuration | 2 | WordPress, Gumroad |
| ❓ À vérifier | 1 | Google Drive |
| ❌ Archivés | 1 | Claude API (remplacé) |

---

## PROCHAINES ACTIONS

### Immédiat (Localhost testing)
- [ ] Vérifier Google Drive NEXUS credential dans N8N UI
- [ ] Procéder à l'Étape 3 : Tester les workflows
- [ ] Procéder à l'Étape 4 : Créer VPS deployment checklist
- [ ] Procéder à l'Étape 5 : Vérifier structure projet

### Avant VPS
- [ ] Documenter Stripe webhook secret (nécessite VPS + IP publique)
- [ ] Documenter Gumroad webhook secret (nécessite VPS + IP publique)

### Production (OVH VPS)
- [ ] Générer WordPress app password et configurer
- [ ] Créer endpoint Stripe webhook avec signature secret
- [ ] Créer Gumroad webhook avec secret
- [ ] Remplir credentials N8N production

---

*Audit effectué le 1er avril 2026 — Session #8 (continuation)*
