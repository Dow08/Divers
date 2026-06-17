# NEXUS CONFORMITÉ — Guide de Configuration N8N
## Ordre d'exécution pour activer les 11 workflows

---

## ÉTAPE 1 — Prérequis comptes & API keys (30 min)

### 1.1 Anthropic API (Claude Haiku)
1. Aller sur https://console.anthropic.com
2. Settings > API Keys > Create Key
3. Nom : `nexus-conformite-n8n`
4. Copier la clé dans `.env` : `ANTHROPIC_API_KEY=sk-ant-...`
5. **Dans N8N** : Settings > Credentials > New > HTTP Request (Bearer Token)
   - Nom : `Anthropic Claude Haiku`
   - Token : votre ANTHROPIC_API_KEY

### 1.2 Telegram Bot
1. Ouvrir https://t.me/BotFather sur Telegram
2. Envoyer `/newbot` → nom : `NexusConformiteBot`
3. Copier le token dans `.env` : `TELEGRAM_BOT_TOKEN=...`
4. Démarrer le bot et appeler :
   `https://api.telegram.org/bot{TOKEN}/getUpdates`
5. Copier le `chat.id` dans `.env` : `TELEGRAM_CHAT_ID=...`

### 1.3 Slack Webhooks
1. Aller sur https://api.slack.com/apps > Create App
2. Incoming Webhooks > Activate > Add New Webhook
3. Choisir canal `#support` → copier URL → `SLACK_WEBHOOK=T.../B.../X...`
4. Répéter pour canal `#alertes` → `SLACK_WEBHOOK_ALERTS=T.../B.../Y...`

### 1.4 Resend (emails transactionnels)
1. Créer compte sur https://resend.com
2. Domains > Add Domain : `nexusconformite.fr`
3. Ajouter les enregistrements DNS chez OVH (SPF + DKIM + DMARC)
4. API Keys > Create Key > Copier dans `.env` : `RESEND_API_KEY=re_...`

### 1.5 Beehiiv
1. Aller sur https://app.beehiiv.com > Settings > Integrations
2. API > Generate Key → copier `BEEHIIV_API_KEY=bh-...`
3. Copier le Publication ID visible dans l'URL → `BEEHIIV_PUB_ID=pub_...`

### 1.6 Google Sheets & Drive
1. Google Cloud Console > Nouveau projet "nexus-conformite"
2. Activer APIs : Google Sheets API + Google Drive API
3. IAM > Comptes de service > Créer (nom : `n8n-nexus`)
4. Télécharger JSON de la clé privée
5. **Dans N8N** : Credentials > New > Google Sheets OAuth2 > importer le JSON
6. Créer le Google Sheet avec ces onglets :
   - `Tickets` | `Pricing` | `Revenus` | `Leads` | `Ventes` | `ColdEmail` | `Veille` | `Blacklist`
7. Copier l'ID du Sheet (dans l'URL) → `GOOGLE_SHEETS_ID=1BxiMV...`
8. Créer dossier Drive "NEXUS-BACKUPS" → copier ID → `GOOGLE_DRIVE_BACKUP_FOLDER=1A2B3C...`

### 1.7 WordPress Application Password
1. WordPress > Utilisateurs > Votre profil
2. Descendre jusqu'à "Mots de passe d'application"
3. Nom : `N8N Integration` > Ajouter
4. Copier le mot de passe généré → `WP_AUTH_TOKEN=xxxx xxxx xxxx xxxx xxxx xxxx`

### 1.8 Stripe Webhooks
1. Dashboard Stripe > Développeurs > Webhooks > Ajouter endpoint
2. URL : `https://n8n.nexusconformite.fr/webhook/stripe`
3. Événements : `payment_intent.succeeded`, `customer.subscription.created`
4. Copier le secret de signature → `STRIPE_WEBHOOK_SECRET=whsec_...`

---

## ÉTAPE 2 — Import des variables dans N8N (10 min)

Une fois le VPS déployé avec N8N :

```bash
# 1. Copier le fichier .env dans le dossier N8N
cp NEXUS.env.template /opt/n8n/.env
# Éditer et remplir toutes les valeurs
nano /opt/n8n/.env

# 2. Redémarrer N8N pour charger les variables
sudo systemctl restart n8n

# 3. Vérifier dans N8N > Settings > Variables que tout est visible
```

---

## ÉTAPE 3 — Import des workflows dans N8N (15 min)

```bash
# Ordre d'import recommandé
# 1. Workflows de monitoring (pas de dépendance)
wf-04-revenue-alerts.json
wf-11-price-monitor.json

# 2. Workflows de livraison
wf-07-gumroad.json
wf-10-ai-support.json

# 3. Workflows d'engagement
wf-05-onboarding.json
wf-06-leads.json

# 4. Workflows de contenu
wf-02-veille.json
wf-03-newsletter.json
wf-09-cold-email.json

# 5. Workflows de reporting
wf-08-dashboard.json

# 6. Workflow de backup (en dernier — nécessite N8N_API_KEY)
wf-01-backup.json
```

**Dans N8N** : Menu > Workflows > Import from File > choisir chaque JSON

---

## ÉTAPE 4 — Configuration des Credentials N8N (20 min)

Pour chaque workflow importé, configurer les credentials :

| Credential N8N | Type | Utiliser pour |
|---|---|---|
| `Anthropic Claude Haiku` | HTTP Bearer Token | WF-02, 03, 09, 10, 11 |
| `Google Sheets` | Google OAuth2 | WF-03, 04, 06, 07, 08, 09 |
| `Google Drive` | Google OAuth2 | WF-01 |
| `Gmail` | Gmail OAuth2 | WF-10 (réception emails) |
| `WordPress` | HTTP Basic Auth | WF-01, 02, 05 |

**Pour configurer une credential** : ouvrir le workflow > cliquer sur un node rouge > cliquer sur la credential manquante > créer/sélectionner.

---

## ÉTAPE 5 — Tests par workflow (30 min)

### WF-04 (Revenue Alerts) — Tester en premier
1. Ouvrir WF-04 > Activer
2. Faire un paiement test sur Stripe (mode test)
3. Vérifier réception Telegram ✓ et log Sheets ✓

### WF-10 (Support IA) — Tester critique
1. Envoyer un email test à support@nexusconformite.fr avec sujet "Question RGPD"
2. Vérifier classification Claude + auto-réponse Resend ✓
3. Envoyer un email ambigu → vérifier escalade Slack ✓

### WF-02 (Veille) — Tester RSS
1. Déclencher manuellement (bouton "Test Workflow")
2. Vérifier alerte Telegram + brouillon WP créé ✓

### WF-11 (Price Monitor) — Tester scraping
1. Déclencher manuellement
2. Vérifier extraction Claude + log Sheets ✓
3. (Prix identiques à la baseline → pas d'alerte Slack attendue)

### WF-01 (Backup) — Tester en dernier
1. Vérifier que `N8N_API_KEY` est configurée
2. Déclencher manuellement
3. Vérifier fichier dans Google Drive/NEXUS-BACKUPS ✓

---

## ÉTAPE 6 — Activation définitive

```
Activer dans cet ordre :
✅ WF-04 Revenue Alerts     (webhook Stripe actif)
✅ WF-07 Livraison Gumroad  (webhook Gumroad actif)
✅ WF-05 Onboarding         (webhook Stripe subscription actif)
✅ WF-06 Leads              (webhook contact form actif)
✅ WF-10 Support IA         (Gmail trigger actif)
✅ WF-02 Veille             (cron daily 7h)
✅ WF-03 Newsletter         (cron Monday 6h)
✅ WF-11 Price Monitor      (cron daily 9h)
✅ WF-08 Dashboard          (cron Friday 18h)
✅ WF-01 Backup             (cron Sunday 3h)
⏸  WF-09 Cold Email         (manuel — activer seulement quand liste prête)
```

---

## Variables par workflow — Tableau de référence rapide

| Workflow | Variables requises |
|---|---|
| WF-01 Backup | N8N_API_URL, WP_API_URL, GOOGLE_DRIVE_BACKUP_FOLDER, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID |
| WF-02 Veille | WP_API_URL, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID + Credential Anthropic |
| WF-03 Newsletter | GOOGLE_SHEETS_ID, BEEHIIV_PUB_ID, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID + Credential Anthropic |
| WF-04 Revenue Alerts | GOOGLE_SHEETS_ID, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID |
| WF-05 Onboarding | RESEND_FROM_EMAIL, WP_API_URL, WP_DIRECTORY_CATEGORY, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID |
| WF-06 Leads | GOOGLE_SHEETS_ID, RESEND_FROM_EMAIL, PROVIDER_EMAIL_FOR_SERVICE_TYPE |
| WF-07 Gumroad | GOOGLE_SHEETS_ID, RESEND_FROM_EMAIL, FEEDBACK_FORM_URL |
| WF-08 Dashboard | GOOGLE_SHEETS_ID, BEEHIIV_PUB_ID, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID |
| WF-09 Cold Email | GOOGLE_SHEETS_ID, BREVO_FROM_EMAIL, BREVO_FROM_NAME + Credential Anthropic |
| WF-10 Support IA | RESEND_API_KEY, SHEETS_ID_SUPPORT, SLACK_WEBHOOK + Credential Anthropic + Gmail |
| WF-11 Price Monitor | SHEETS_ID_PRICING, SLACK_WEBHOOK_ALERTS + Credential Anthropic |

---

## Temps total estimé : **~2h** pour une configuration complète from scratch
