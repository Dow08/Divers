# 🧪 GUIDE TEST LOCAL — 6 WORKFLOWS PRÉ-VPS
**Date:** 1er avril 2026  
**Objectif:** Valider tous les credentials avant achat VPS  
**Durée estimée:** 30-45 minutes (tous les tests)  
**Status:** Prêt à exécuter

---

## ✅ PRÉ-REQUIS AVANT DE COMMENCER

### 1. Vérifier N8N est actif
```bash
# Terminal: Vérifier que N8N tourne
curl -s http://localhost:5678/health
# Doit retourner: HTTP 200
```

### 2. Accéder à N8N UI
🔗 **http://localhost:5678**
- Login: `nexus`
- Password: `NexusConf2026!`

### 3. Ouvrir les Logs
🔗 **http://localhost:5678/settings/logs** (pour debug)

### 4. Préparer Google Sheets
🔗 **https://docs.google.com/spreadsheets/d/1MoQ9MR5hquCI3R7FyO5zRm5C1sDGWckTTtFw8t61zws/edit**
- Vérifier que tu as accès en lecture/écriture
- Onglets existants: Ventes, Leads, Newsletter, Trafic, Alertes, Config

### 5. Préparer Telegram
- Ouvrir Telegram app
- Chercher le bot @nexus_conformite_bot
- Envoyer `/start` une fois
- Chat ID: 7705787464 (tu devrais recevoir les messages de test)

---

## 🧪 ORDRE DE TEST RECOMMANDÉ

### TEST 1️⃣ : WF-09 — Cold Email B2B RGPD (Brevo SMTP) ⏱️ 8 min
**Pourquoi d'abord?** Valide le credential Brevo SMTP (port 587 STARTTLS) qui alimente 4 autres workflows

**Étapes:**
1. Accéder à WF-09 dans N8N
2. Cliquer sur le bouton **"Test workflow"** (ou Play)
3. **Vérifier résultats dans les logs:**
   - ✅ Gemini génère un email personnalisé (vérifier contenu)
   - ✅ Brevo SMTP accepte l'envoi (pas d'erreur 550/AUTH)
   - ✅ Email envoyé avec succès (status 200)
4. **Vérifier email reçu:**
   - Attendre 1-2 min
   - Vérifier ton email personnel reçoit l'email de test
   - Vérifier footer RGPD présent (mentions légales, lien désinscription)
5. **Vérifier Telegram:**
   - Vérifier que le bot envoie une alerte "Email envoyé"

**Credentials validés:**
- ✅ Brevo SMTP (Port 587 + STARTTLS)
- ✅ Google Gemini API
- ✅ Google Sheets (logging)
- ✅ Telegram Bot

**Si erreur?**
- Port 587 refusé → Vérifier `BREVO_SMTP_PORT=587` dans .env
- Auth failed → Vérifier `BREVO_SMTP_KEY` dans .env
- Email pas reçu → Vérifier spam folder + attendre 2-3 min

---

### TEST 2️⃣ : WF-03 — Newsletter Hebdomadaire Auto ⏱️ 5-8 min
**Dépendances:** Beehiiv, Gemini, Google Sheets, Telegram

**Étapes:**
1. Accéder à WF-03
2. Cliquer **"Test workflow"**
3. **Vérifier logs:**
   - ✅ Gemini génère contenu newsletter
   - ✅ Beehiiv API accepte contenu (status 200)
   - ✅ Google Sheets loggé (onglet "Newsletter")
   - ✅ Telegram alerte envoyée
4. **Vérifier Beehiiv:**
   - Aller sur https://beehiiv.com/dashboard
   - Vérifier que "Draft" article apparaît
5. **Vérifier Google Sheets:**
   - Onglet "Newsletter" doit avoir nouvelle ligne avec:
     - Date
     - Contenu généré
     - Status: "Sent to Beehiiv"

**Credentials validés:**
- ✅ Beehiiv API
- ✅ Google Gemini API
- ✅ Google Sheets OAuth2

**Si erreur?**
- Beehiiv 401 → Vérifier `BEEHIIV_API_KEY` dans .env
- GSheets 403 → Vérifier que credential "Google Sheets NEXUS" est connecté
- Gemini timeout → Vérifier limite 1500 req/jour pas atteinte

---

### TEST 3️⃣ : WF-01 — Backup Auto Hebdomadaire ⏱️ 5-10 min
**Dépendances:** Google Drive, N8N API Key, Telegram

**Étapes:**
1. Accéder à WF-01
2. Cliquer **"Test workflow"**
3. **Vérifier logs:**
   - ✅ N8N API Key acceptée (status 200)
   - ✅ Workflows exportés en JSON (vérifier "message: workflows exported")
   - ✅ Google Drive upload réussi (dossier created ou fichier created)
   - ✅ Telegram alerte envoyée
4. **Vérifier Google Drive:**
   - Accéder à https://drive.google.com
   - Chercher dossier "NEXUS-N8N-Backups" (ou similaire)
   - Vérifier fichier backup JSON créé aujourd'hui
   - Vérifier taille fichier > 50 KB
5. **Vérifier Telegram:**
   - Message: "✅ Backup hebdomadaire réussi: X workflows sauvegardés"

**Credentials validés:**
- ✅ N8N API Key (NEXUS-BACKUP-WF01)
- ✅ Google Drive OAuth2
- ✅ Telegram Bot

**Si erreur?**
- N8N API 401 → Vérifier `N8N_API_KEY` dans .env et expiration (01/05/2026)
- Google Drive 403 → Vérifier credential "Google Drive NEXUS" est connecté
- Aucun fichier créé → Vérifier permissions Google Drive

---

### TEST 4️⃣ : WF-02 — Veille Législative Quotidienne ⏱️ 3-5 min
**Dépendances:** Gemini, Telegram (WordPress optionnel pour test local)

**Étapes:**
1. Accéder à WF-02
2. Cliquer **"Test workflow"**
3. **Vérifier logs:**
   - ✅ Gemini génère article (vérifier contenu)
   - ✅ Telegram alerte envoyée
   - ⚠️ WordPress peut échouer (pas connecté) → C'est normal pour test local
4. **Vérifier contenu généré:**
   - Logs doivent montrer article sur sujet légal/conformité
   - Contenu doit être > 200 mots
5. **Note:** WordPress test est déferred à VPS (phase 3)

**Credentials validés:**
- ✅ Google Gemini API
- ✅ Telegram Bot
- ⏳ WordPress (VPS)

---

### TEST 5️⃣ : WF-08 — Dashboard Hebdomadaire Synthèse ⏱️ 5 min
**Dépendances:** Google Sheets, Beehiiv, Telegram

**Étapes:**
1. Accéder à WF-08
2. Cliquer **"Test workflow"**
3. **Vérifier logs:**
   - ✅ Synthèse compilée depuis Google Sheets (ventes, leads, newsletter, trafic)
   - ✅ Beehiiv stats récupérées
   - ✅ Telegram alerte envoyée avec résumé
4. **Vérifier Telegram:**
   - Message doit contenir:
     - Total revenus (si données existantes)
     - Nombre leads
     - Stats newsletter
     - Trafic site
5. **Vérifier Google Sheets:**
   - Onglet "Alertes" doit avoir nouvelle ligne avec synthèse

**Credentials validés:**
- ✅ Google Sheets OAuth2
- ✅ Beehiiv API
- ✅ Telegram Bot

---

### TEST 6️⃣ : WF-04 — Alertes Revenus Temps Réel ⏱️ 10 min
**Dépendances:** Stripe, Google Sheets, Telegram

**Étapes:**
1. Accéder à WF-04
2. **Créer test payment Stripe:**
   - Aller sur https://dashboard.stripe.com/test/payments
   - Cliquer "Create payment"
   - Utiliser carte TEST: **4242 4242 4242 4242**
   - Montant: €10.00
   - Cliquer "Pay"
3. **Vérifier logs N8N:**
   - ✅ Webhook reçu (event: payment_intent.succeeded)
   - ✅ Montant parsé correctement
   - ✅ Google Sheets logger montant
   - ✅ Telegram alerte envoyée
4. **Vérifier Telegram:**
   - Message: "💰 Revenu reçu: €10.00 via Stripe"
   - Timestamp
   - Client info
5. **Vérifier Google Sheets:**
   - Onglet "Ventes" doit avoir nouvelle ligne avec:
     - Date/heure
     - Montant: €10.00
     - Source: Stripe
     - Status: Captured

**Credentials validés:**
- ✅ Stripe API (clé secrète)
- ✅ Google Sheets OAuth2
- ✅ Telegram Bot

**Note:** Webhook secret manquant (récupéré en VPS phase 4) → Test payment ne déclenchera PAS automatiquement le webhook. On teste manuellement.

**Si erreur?**
- Stripe 401 → Vérifier `STRIPE_SECRET_KEY` dans .env
- GSheets 403 → Vérifier credential connecté
- Payment failed → Utiliser carte test, pas de vraie carte

---

## 📋 CHECKLIST DE VALIDATION

### Avant de commencer
- [ ] N8N running (`curl http://localhost:5678/health` = 200)
- [ ] N8N UI accessible (localhost:5678)
- [ ] Logs visible (Settings > Logs)
- [ ] Google Sheets accessible
- [ ] Telegram bot reçoit messages
- [ ] Tous les .env credentials présents

### Pendant les tests
- [ ] Chaque workflow testé individuellement
- [ ] Logs vérifiés pour erreurs
- [ ] Credentials utilisés avec succès
- [ ] Output vérifié (email, GSheets, Telegram, etc)

### Après les tests
- [ ] 6/6 workflows testés ✅
- [ ] Aucune erreur critique
- [ ] Tous les logs documentés
- [ ] Prêt pour `.env.production`

---

## 🚨 ERREURS COURANTES & SOLUTIONS

| Erreur | Cause | Solution |
|--------|-------|----------|
| **Auth failed (SMTP)** | Port 587 incorrect ou key invalide | Vérifier `BREVO_SMTP_PORT=587` et `BREVO_SMTP_KEY` |
| **Google 401** | Token expiré | Reconnecter credential OAuth (Settings > Credentials) |
| **Webhook timeout** | N8N ne reçoit pas | Normal pour localhost (VPS required) |
| **Stripe 401** | Clé secrète invalide | Vérifier `STRIPE_SECRET_KEY` commence par `STRIPE_TEST_KEY_REMOVED` |
| **Email pas reçu** | Spam folder ou délai | Attendre 2-3 min, vérifier spam |
| **GSheets 403** | Pas de permission | Vérifier spreadsheet partagée avec compte N8N |
| **Telegram pas de message** | Bot offline ou Chat ID incorrect | Vérifier `TELEGRAM_CHAT_ID` et bot actif |
| **Gemini quota** | Limite 1500 req/jour atteinte | Attendre lendemain ou utiliser autre API |

---

## ✨ RÉSUMÉ VALIDATION

| Workflow | Durée | Critère de succès | Credentials |
|----------|-------|-------------------|-------------|
| WF-09 | 8 min | Email reçu + Telegram alerte | Brevo, Gemini, GSheets, Telegram |
| WF-03 | 5-8 min | Newsletter dans Beehiiv + alerte | Beehiiv, Gemini, GSheets, Telegram |
| WF-01 | 5-10 min | Backup dans Google Drive | Google Drive, N8N API, Telegram |
| WF-02 | 3-5 min | Article généré + alerte | Gemini, Telegram (WordPress VPS) |
| WF-08 | 5 min | Synthèse dans GSheets + Telegram | GSheets, Beehiiv, Telegram |
| WF-04 | 10 min | Revenu loggé + alerte | Stripe, GSheets, Telegram |

**Total durée:** 30-45 minutes  
**Blockers avant VPS:** ❌ AUCUN  
**Prêt pour VPS?** ✅ OUI

---

**Prochaine étape:** Exécuter ces 6 tests et documenter les résultats

*Guide créé le 1er avril 2026 — Session #8*
