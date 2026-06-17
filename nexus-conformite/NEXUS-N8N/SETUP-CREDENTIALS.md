# NEXUS CONFORMITÉ — Guide Configuration Credentials N8N
## Mis à jour le 28/03/2026

> **Prérequis :** N8N tourne sur http://localhost:5678
> Login : voir les identifiants dans votre fichier `.env`

---

## ÉTAPE 0 — Créer le fichier .env

Créer un fichier `.env` dans le dossier `NEXUS-N8N/` :

```bash
# Copier le template et remplir les valeurs :
cp .env.example .env
# Puis éditer .env avec vos secrets réels
```

Voir `.env.example` pour la liste complète des variables requises.

---

## CREDENTIAL 1 — Anthropic Claude API (IA contenu)

**Dans N8N :** Settings → Credentials → New → `Anthropic`

| Champ | Valeur |
|---|---|
| API Key | Obtenir sur https://console.anthropic.com/settings/keys |

**Nommer :** `Claude API NEXUS`

> 💡 Créer une clé avec nom "n8n-nexus" — modèle par défaut : claude-haiku-4-5

---

## CREDENTIAL 2 — Telegram Bot (alertes revenus)

### 2a — Créer le bot

1. Ouvrir Telegram → chercher **@BotFather**
2. Envoyer `/newbot`
3. Nom du bot : `NEXUS Conformité Alertes`
4. Username : `nexusconformite_bot` (ou similaire disponible)
5. Copier le **token** fourni (format : `123456:ABC-DEF...`)

### 2b — Obtenir ton Chat ID

1. Envoyer n'importe quel message à ton bot
2. Ouvrir dans le navigateur : `https://api.telegram.org/bot<TON_TOKEN>/getUpdates`
3. Copier la valeur de `"id"` dans `"chat"` (nombre entier)

### 2c — Dans N8N

**Settings → Credentials → New → `Telegram`**

| Champ | Valeur |
|---|---|
| Access Token | Ton token BotFather |

**Nommer :** `NEXUS Bot Telegram`

Puis mettre à jour `.env` :
```env
TELEGRAM_BOT_TOKEN=ton_token_ici
TELEGRAM_CHAT_ID=ton_chat_id_ici
```

---

## CREDENTIAL 3 — Google Sheets & Drive (dashboard + backup)

### 3a — Créer le Google Sheet NEXUS-REVENUS

1. Aller sur https://sheets.google.com
2. Créer une nouvelle feuille nommée **"NEXUS-REVENUS"**
3. Créer 6 onglets avec ces noms exacts :
   - `Revenus` → colonnes : date, montant, source, type, stripe_id
   - `Ventes` → colonnes : saleId, date, email, nom, produit, montant, statut_suivi
   - `Leads` → colonnes : leadId, date, entreprise, contact, email, secteur, besoin, prestataire, statut
   - `Prospects` → colonnes : email, prenom, nom, entreprise, secteur, statut, date_contact, sequence, optout
   - `Veille` → colonnes : date, source, titre, url, resume, publie
   - `Parrainages` → colonnes : email, code_parrain, nb_parrainages, recompense, date
4. Copier l'**ID du Sheet** depuis l'URL (entre `/d/` et `/edit`) → mettre dans `.env`

### 3b — Créer le dossier Google Drive

1. Aller sur https://drive.google.com
2. Créer dossier **"NEXUS-BACKUPS"**
3. Copier son ID depuis l'URL

### 3c — Dans N8N (OAuth2)

**Settings → Credentials → New → `Google Sheets OAuth2 API`**

1. Suivre le wizard d'autorisation Google
2. Autoriser l'accès à Google Sheets et Google Drive
3. **Nommer :** `Google Sheets NEXUS`

Puis créer une seconde credential :
**Settings → Credentials → New → `Google Drive OAuth2 API`**
**Nommer :** `Google Drive NEXUS`

---

## CREDENTIAL 4 — Beehiiv API (newsletter)

1. S'inscrire sur https://beehiiv.com
2. Créer la publication **"Conformité PME"**
3. Aller dans Settings → API → Generate API Key
4. Copier le Publication ID (format : `pub_xxxxxxxx`)

**Dans N8N :** Settings → Credentials → New → `Header Auth`

| Champ | Valeur |
|---|---|
| Name | `Authorization` |
| Value | `Bearer ton_api_key_beehiiv` |

**Nommer :** `Beehiiv API NEXUS`

Mettre à jour `.env` :
```env
BEEHIIV_API_KEY=ton_api_key
BEEHIIV_PUBLICATION_ID=pub_xxxxxxxx
```

---

## CREDENTIAL 5 — Brevo SMTP (cold email)

1. S'inscrire sur https://brevo.com (plan gratuit = 300 emails/jour)
2. Settings → API Keys → Generate SMTP key
3. Copier le mot de passe SMTP

**Dans N8N :** Settings → Credentials → New → `SMTP`

| Champ | Valeur |
|---|---|
| Host | `smtp-relay.brevo.com` |
| Port | `587` |
| User | `ton_email@domaine.fr` |
| Password | Clé SMTP Brevo |
| SSL | Non |

**Nommer :** `Brevo SMTP NEXUS`

---

## CREDENTIAL 6 — Stripe Webhooks (alertes paiement)

1. Créer un compte Stripe : https://stripe.com
2. Dashboard → Developers → Webhooks → Add endpoint
3. URL webhook : `http://localhost:5678/webhook/stripe-payment` (local) ou `https://nexusconformite.fr/webhook/stripe-payment` (VPS)
4. Événements à sélectionner :
   - `payment_intent.succeeded`
   - `customer.subscription.created`
   - `invoice.payment_succeeded`
   - `checkout.session.completed`
5. Copier le **Webhook Secret** (`whsec_...`)

Mettre dans `.env` :
```env
STRIPE_WEBHOOK_SECRET=whsec_...
```

> En **mode test** d'abord — activer le mode live uniquement au lancement réel.

---

## CREDENTIAL 7 — WordPress API (créer des articles)

> À configurer après installation de WordPress en local ou sur VPS.

1. WordPress Admin → Utilisateurs → Votre profil
2. Section **"Mots de passe d'application"** → Ajouter → Nommer "N8N API"
3. Copier le mot de passe généré (format : `xxxx xxxx xxxx xxxx`)

**Dans N8N :** Settings → Credentials → New → `Header Auth`

| Champ | Valeur |
|---|---|
| Name | `Authorization` |
| Value | `Basic ` + base64(`username:mot_de_passe_app`) |

Pour encoder en base64 :
```bash
echo -n "dow:xxxx xxxx xxxx xxxx" | base64
```

**Nommer :** `WordPress API NEXUS`

---

## ORDRE D'IMPORT DES WORKFLOWS

Une fois **tous les credentials créés**, importer les workflows dans cet ordre :

1. `WF-04-alertes-revenus.json` — tester avec un paiement Stripe sandbox
2. `WF-01-backup-auto.json` — déclencher manuellement pour vérifier Drive
3. `WF-02-veille-legislative.json` — déclencher manuellement
4. `WF-03-newsletter-hebdo.json` — vérifier le draft Beehiiv
5. `WF-05-onboarding-annuaire.json`
6. `WF-06-leads-annuaire.json`
7. `WF-07-livraison-gumroad.json`
8. `WF-08-dashboard-hebdo.json`
9. `WF-09-cold-email-b2b.json`

### Comment importer dans N8N :

1. Ouvrir N8N → http://localhost:5678
2. Menu gauche → Workflows → Import from File
3. Sélectionner le fichier JSON
4. Dans chaque workflow, **mettre à jour les nodes** qui référencent les credentials
5. Activer le workflow (toggle en haut à droite)

---

## VÉRIFICATION FINALE

Checklist avant de commencer à utiliser :

- [ ] N8N tourne sur http://localhost:5678
- [ ] Credential Anthropic créé + testé
- [ ] Bot Telegram créé + Chat ID récupéré
- [ ] Google Sheet NEXUS-REVENUS créé (6 onglets)
- [ ] Compte Beehiiv créé + publication configurée
- [ ] Compte Brevo créé + clé SMTP récupérée
- [ ] Compte Stripe en mode test
- [ ] Fichier `.env` complété
- [ ] WF-04 importé et testé (paiement Stripe test)

---

*Mettre à jour ce fichier au fur et à mesure de la configuration.*
