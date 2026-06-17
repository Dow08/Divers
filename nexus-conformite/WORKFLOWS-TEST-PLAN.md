# 🧪 PLAN DE TEST DES WORKFLOWS N8N
**Date:** 1er avril 2026  
**Phase:** Étape 3 - Test des Workflows  
**Environnement:** Localhost (127.0.0.1:5678)

---

## WORKFLOWS TESTABLES LOCALEMENT (6)

### 1️⃣ WF-01 — Backup Auto Hebdomadaire ✅
**Trigger:** Schedule (Cron) - Hebdomadaire  
**Credentials requises:**
- Google Drive NEXUS (OAuth2) — À vérifier
- N8N API Key (NEXUS-BACKUP-WF01) — ✅ Renouvelé
- NEXUS Bot Telegram — ✅ Configuré

**Test Plan:**
1. [ ] Vérifier Google Drive credential existant
2. [ ] Déclencher manuellement (bouton "Test workflow")
3. [ ] Vérifier dans Google Drive que le backup a été créé
4. [ ] Vérifier alerte Telegram reçue
5. [ ] Valider que WF-01 exporte les workflows N8N correctement

**Dépendances:** Google Drive accessible, Telegram fonctionnel  
**Risques:** Google Drive token expiré, Telegram offline  
**Durée estimée:** 5-10 min

---

### 2️⃣ WF-02 — Veille Législative Quotidienne ✅
**Trigger:** Schedule (Cron) - Quotidienne  
**Credentials requises:**
- Google Gemini (IA générative) — ✅ Configuré
- WordPress API NEXUS — ⏳ À configurer
- NEXUS Bot Telegram — ✅ Configuré

**Test Plan:**
1. [ ] Déclencher manuellement WF-02
2. [ ] Vérifier que Gemini génère un article (test sans Wordpress d'abord)
3. [ ] Vérifier alerte Telegram envoyée
4. [ ] **Note:** WordPress test déferred (WP app password à générer)

**Dépendances:** Google Gemini API fonctionnelle  
**Risques:** Quota Gemini atteint (limite 1500/jour)  
**Durée estimée:** 3-5 min

---

### 3️⃣ WF-03 — Newsletter Hebdomadaire Auto ✅
**Trigger:** Schedule (Cron) - Hebdomadaire  
**Credentials requises:**
- Beehiiv API NEXUS — ✅ Configuré
- Google Gemini — ✅ Configuré
- Google Sheets NEXUS — ✅ Configuré
- NEXUS Bot Telegram — ✅ Configuré

**Test Plan:**
1. [ ] Déclencher manuellement WF-03
2. [ ] Vérifier que Gemini génère contenu newsletter
3. [ ] Vérifier que données sont loggées dans Google Sheets (onglet "Newsletter")
4. [ ] Vérifier alerte Telegram envoyée
5. [ ] **Optionnel:** Vérifier dans Beehiiv dashboard que contenu est prêt

**Dépendances:** Beehiiv, Google Sheets, Gemini, Telegram  
**Risques:** Quota Gemini, faux positif si contenu non généré  
**Durée estimée:** 5-8 min

---

### 4️⃣ WF-04 — Alertes Revenus Temps Réel ⚠️
**Trigger:** Webhook Stripe (externe) — Mais testable manuellement  
**Credentials requises:**
- Stripe NEXUS (API Key) — ✅ Configuré
- Google Sheets NEXUS — ✅ Configuré
- NEXUS Bot Telegram — ✅ Configuré

**Test Plan:**
1. [ ] Vérifier que Stripe credential est chargée
2. [ ] Créer test payment avec carte Stripe test (`4242 4242 4242 4242`)
3. [ ] Vérifier webhook reçu par N8N (logs)
4. [ ] Vérifier alerte Telegram avec montant reçu
5. [ ] Vérifier Google Sheets logger la transaction (onglet "Ventes")

**Dépendances:** Stripe credentials, Telegram, Google Sheets  
**Risques:** Webhook secret manquant (résolu sur VPS), test payment non déclenché  
**Durée estimée:** 10 min (nécessite création test sale)

**Note:** Webhook live testing déferred à VPS (requires public IP)

---

### 5️⃣ WF-08 — Dashboard Hebdomadaire Synthèse ✅
**Trigger:** Schedule (Cron) - Hebdomadaire  
**Credentials requises:**
- Google Sheets NEXUS — ✅ Configuré
- Beehiiv API NEXUS — ✅ Configuré
- NEXUS Bot Telegram — ✅ Configuré

**Test Plan:**
1. [ ] Déclencher manuellement WF-08
2. [ ] Vérifier que le dashboard lit les données Google Sheets (Ventes, Leads, Newsletter, Trafic)
3. [ ] Vérifier synthèse compilée correctement
4. [ ] Vérifier alerte Telegram avec résumé
5. [ ] Optionnel: Vérifier que onglet "Alertes" dans GSheets est mise à jour

**Dépendances:** Google Sheets populated, Beehiiv, Telegram  
**Risques:** GSheets vides (pas de données Ventes/Leads)  
**Durée estimée:** 5 min

---

### 6️⃣ WF-09 — Cold Email B2B RGPD-Conforme ✅
**Trigger:** Schedule (Cron) - Manual + Schedule  
**Credentials requises:**
- Brevo SMTP NEXUS — ✅ Configuré & testé
- Google Gemini — ✅ Configuré
- Google Sheets NEXUS — ✅ Configuré

**Test Plan:**
1. [ ] Déclencher manuellement WF-09
2. [ ] Vérifier que Gemini génère email personnalisé (test)
3. [ ] Vérifier que Brevo SMTP envoie correctement
4. [ ] Tester avec email de test (votre email personal)
5. [ ] Vérifier dans Google Sheets que la campagne est loggée
6. [ ] Vérifier conformité RGPD (footer + unsubscribe link)

**Dépendances:** Brevo SMTP, Gemini, Google Sheets, email de test valide  
**Risques:** SMTP rate-limit si relancé trop souvent  
**Durée estimée:** 8 min

---

## WORKFLOWS TESTABLES SUR VPS UNIQUEMENT (3)

### 5️⃣ WF-05 — Onboarding Prestataire Annuaire ⚠️ VPS
**Trigger:** Webhook (formulaire externe)  
**Credentials requises:**
- Brevo SMTP NEXUS — ✅ Configuré
- WordPress API NEXUS — ⏳ À configurer
- NEXUS Bot Telegram — ✅ Configuré

**Status:** Deferré à VPS (requires public webhook endpoint)  
**Action:** À tester une fois VPS déployé avec URL publique

---

### 6️⃣ WF-06 — Gestion Leads Annuaire (Mise en relation) ⚠️ VPS
**Trigger:** Webhook (formulaire contact)  
**Credentials requises:**
- Brevo SMTP NEXUS — ✅ Configuré
- Google Sheets NEXUS — ✅ Configuré
- NEXUS Bot Telegram — ✅ Configuré

**Status:** Deferré à VPS (requires public webhook endpoint)  
**Action:** À tester une fois VPS déployé

---

### 7️⃣ WF-07 — Livraison Gumroad + Suivi J+7 ⚠️ VPS
**Trigger:** Webhook (Gumroad sale events)  
**Credentials requises:**
- Brevo SMTP NEXUS — ✅ Configuré
- Google Sheets NEXUS — ✅ Configuré
- NEXUS Bot Telegram — ✅ Configuré
- Gumroad Webhook Secret — ⏳ À configurer

**Status:** Deferré à VPS (requires public webhook endpoint)  
**Action:** À tester une fois VPS déployé avec webhook Gumroad configuré

---

## ORDRE DE TEST RECOMMANDÉ

**Phase 1 - Tests Critiques (2-3 min each):**
1. ✅ WF-01 (Backup) — Valide Google Drive + API Key
2. ✅ WF-03 (Newsletter) — Valide Beehiiv + Gemini + GSheets
3. ✅ WF-09 (Cold Email) — Valide Brevo SMTP (test email)

**Phase 2 - Tests Complémentaires (5-8 min each):**
4. ✅ WF-02 (Veille Légale) — Valide Gemini + Telegram
5. ✅ WF-04 (Revenus) — Valide Stripe + GSheets
6. ✅ WF-08 (Dashboard) — Valide synthèse données

**Total temps estimé:** 30-45 minutes pour tous les tests

---

## CHECKLIST DE VALIDATION

### Avant tests:
- [ ] N8N running on localhost:5678
- [ ] Tous les credentials configurés
- [ ] Logs monitoring enabled
- [ ] Telegram chat ID accessible
- [ ] Google Drive accessible
- [ ] Google Sheets accessible (en lecture/écriture)

### Pendant tests:
- [ ] Chaque workflow déclenché manuellement
- [ ] Vérifier aucun erreur dans logs
- [ ] Vérifier chaque credential utilisé correctement
- [ ] Vérifier output des nodes critiques

### Après tests:
- [ ] Documenter résultats de chaque test
- [ ] Identifier any blockers avant VPS
- [ ] Qualifier si prêt pour Étape 4 (VPS checklist)

---

*Plan de test créé le 1er avril 2026 — Session #8*
