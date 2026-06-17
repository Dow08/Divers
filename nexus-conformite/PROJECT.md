# NEXUS CONFORMITÉ — MASTER PROJECT REFERENCE
**Single Source of Truth | Last Updated: 01/04/2026**

---

## 📋 EXECUTIVE SUMMARY

**NEXUS CONFORMITÉ** is a compliance automation SaaS platform combining regulatory monitoring, legal template library, and B2B directory.

**Status**: 9 workflows complete & tested locally | Ready for Hostinger deployment | Legal docs pending signature placeholders | Revenue streams ready to activate

**Critical Blockers**: Brevo SMTP credentials (535 error) | Hostinger infrastructure configuration | DNS setup | Legal document completion

---

## ⚡ STATUS ACTUEL (01/04/2026)

**Infrastructure confirmée**:
- ✅ **Domaine**: nexusconformite.fr — Acheté via OVH (~5€/an)
- ✅ **Hébergement**: Hostinger VPS (remplace OVH Starter)
- ✅ **Workflows**: 9/9 vérifiés, aucun doublon JSON
- ✅ **Consolidation**: Single source of truth établi (PROJECT.md)
- 🔴 **Blocages Phase 0**: 5 éléments critiques à résoudre (voir MASTER-CHECKLIST.md Phase 0)

---

## 🎯 BUSINESS MODEL

### Revenue Streams (6 Primary)
1. **Gumroad Digital Product** — Kit RGPD 97€ (automated delivery WF-07) | Target: 15 sales/month = 1,455€
2. **Annuaire Prestataires** — Subscription 49€/month (1-3 leads/month per subscriber) | Target: 50 subs = 2,450€
3. **Veille Premium** — Newsletter + alerts (Beehiiv affiliate) | Target: 30 paying subs = 450€
4. **PDP/Webinars** — Live training (cold email WF-09) | Target: 2 events/month = 3,000€
5. **Axonaut Affiliate** — CRM platform (40% recurring) | Target: 5 clients = 5,000€/year
6. **Cold Email B2B** — GDPR-compliant outreach automation | Lead gen service = custom pricing

**Projected M1**: 1,200-1,800€ | **M12**: 12,300-23,500€

### Target Audience
- SME compliance officers (10-50 employees)
- Legal tech startups
- DPOs & privacy consultants
- ISO/RGPD compliance teams

---

## 🏗️ TECHNOLOGY STACK

### Core Infrastructure
- **N8N Community** — Self-hosted workflow automation (9 primary workflows)
- **WordPress** — Content CMS + landing pages
- **Hosting**: **Hostinger VPS** (remplace OVH Starter)
  - Plan: VPS équivalent Ubuntu 22.04
  - Coût: ~6-8€/mois
  - Specs: Processeur partagé, 4GB RAM, 60GB SSD
- **Database**: SQLite (local N8N) / MySQL (WordPress via Hostinger)
- **DNS**: OVH zones configurées pour nexusconformite.fr
- **SSL**: Let's Encrypt (auto-renewal via deploy script)

### External Services (Free/Freemium)
| Service | Function | Cost | Limits |
|---------|----------|------|--------|
| **Google Sheets** | CRM + revenue dashboard | Free | 5M cells |
| **Google Gemini 2.0 Flash** | IA content generation | Free | 1,500 req/day |
| **Brevo SMTP** | Transactional email | Free | 300 emails/day |
| **Beehiiv** | Newsletter hosting + referral | Free | 10K subscribers |
| **Telegram** | Admin alerts | Free | Unlimited |
| **Stripe** | Payment processing | 2.9% + 0.30$ | Sandbox for testing |
| **Gumroad** | Digital product delivery | 10% | Automatic webhooks |

### Monthly Cost Estimate
**Startup** (M1-M3): 12-15€ (domain + hosting)
**Growth** (M4-M12): 25-35€ (add video CDN + analytics)
**Mature** (M13+): 40-45€ (add compliance audit tools)

---

## 🔄 WORKFLOW ARCHITECTURE (9 Primary + 2 Bonus)

### Core Workflows (Local N8N)

| # | Name | Trigger | Function | Status | Last Tested |
|---|------|---------|----------|--------|------------|
| **WF-01** | Backup Auto Hebdomadaire | Cron (Monday 9am) | Export all N8N workflows to backup file | ✅ Active | 30/03 |
| **WF-02** | Veille Législative Quotidienne | Cron (9am daily) | Fetch 5 RSS feeds (Legifrance, Europe) + Gemini summary | ✅ Active | 30/03 |
| **WF-03** | Newsletter Hebdomadaire Auto | Cron (Friday 10am) | Curate week's articles + Gemini digest → Beehiiv | 🟡 Patched, untested | 28/03 |
| **WF-04** | Alertes Revenus Temps Réel | Webhook (Stripe) | New charge → Telegram + Google Sheets | ✅ Active | 28/03 |
| **WF-05** | Onboarding Prestataire Annuaire | Webhook (Stripe) | New annuaire subscriber → Email (continueOnFail) → Sheets | ✅ Active | 30/03 |
| **WF-06** | Gestion Leads Annuaire | Webhook (custom form) | Directory inquiry → Email (continueOnFail) → Sheets → Telegram | ✅ Active | 30/03 |
| **WF-07** | Livraison Gumroad + Suivi J+7 | Webhook (Gumroad) | Purchase → Email delivery (continueOnFail) → Wait 7d → Follow-up email | ✅ Active | 30/03 |
| **WF-08** | Dashboard Hebdomadaire Synthèse | Cron (Sunday 8pm) | Aggregate metrics from Google Sheets + Beehiiv → Telegram summary | ⏳ Active | Untested |
| **WF-09** | Cold Email B2B RGPD-Conforme | Cron (2x/week Tue/Thu 9am) | Fetch target list → Gemini personalization → Brevo SMTP (continueOnFail) | 🟡 Patched, untested | 28/03 |

### Bonus Workflows (Not yet imported)
| # | Name | Status | Notes |
|---|------|--------|-------|
| **WF-10** | AI Support Bot | Pending | Telegram + LLM for customer queries |
| **WF-11** | Price Monitor | Pending | Track competitor pricing, alert on changes |

### Credential Mapping (N8N IDs)

| Credential | ID | Service | Status |
|------------|---|---------|--------|
| Anthropic NEXUS | `FlKJz08s7j2Lr4N1` | Claude API (replaced by Gemini) | Configured (deprecated) |
| Brevo SMTP NEXUS | `ITliUTfuwkRQE3DM` | Email relay | ❌ Invalid (535 Auth Failed) |
| Telegram NEXUS | `AUFGPlY8MBGH3aAb` | Bot messaging | ✅ Configured |
| Google Sheets NEXUS | `TKonzkmoB6RvROBy` | OAuth connected | ✅ Configured |
| Beehiiv NEXUS | `E1oeuvWZ3Mlgu0Uq` | Newsletter API | ✅ Configured |
| Stripe (test) | — | Webhook endpoint | ⏳ Pending secret |
| WordPress | — | REST API | ⏳ Pending install |

### Webhook Endpoints (Production)
```
POST /webhook/lead-annuaire          → WF-06 (form submissions)
POST /webhook/gumroad-webhook        → WF-07 (product delivery)
POST /webhook/stripe-subscription    → WF-04, WF-05 (payments)
POST /webhook/newsletter-subscribe   → WF-03 (custom signup)
```

---

## 📁 PROJECT STRUCTURE

```
Projet V2 WEB/
├── PROJECT.md                              ← THIS FILE (master reference)
├── SESSION-LOG.md                          ← Audit trail (all sessions S1-S9)
├── MASTER-CHECKLIST.md                     ← Step-by-step implementation roadmap
│
├── NEXUS-N8N/                              ← N8N configuration & workflows
│   ├── .env.example                        ← Environment template
│   ├── .env                                ← Active config (DO NOT COMMIT)
│   ├── workflows/                          ← All 9 workflow JSON files
│   │   ├── WF-01-backup-auto.json
│   │   ├── WF-02-veille-legislative.json
│   │   ├── WF-03-newsletter-hebdo.json
│   │   ├── WF-04-alertes-revenus.json
│   │   ├── WF-05-onboarding-annuaire.json
│   │   ├── WF-06-leads-annuaire.json
│   │   ├── WF-07-livraison-gumroad.json
│   │   ├── WF-08-dashboard-hebdo.json
│   │   └── WF-09-cold-email-b2b.json
│   ├── config/
│   │   └── credentials-template.json       ← Credential structure reference
│   ├── scripts/
│   │   ├── import-workflows.js             ← Auto-import workflows to N8N
│   │   ├── setup-n8n-credentials.js        ← Auto-configure credentials
│   │   └── deploy-n8n-vps.sh               ← VPS deployment script
│   ├── email-templates/
│   │   ├── EMAIL-Confirmation-Abonnement.html
│   │   ├── EMAIL-Livraison-Gumroad.html
│   │   └── EMAIL-Suivi-J7.html
│   ├── GUIDES/                             ← Operational guides
│   │   ├── GUIDE-Stripe-Webhook-Secret.md
│   │   ├── GUIDE-Gumroad-Webhook.md
│   │   ├── GUIDE-OVH-WordPress-DNS.md
│   │   └── OVH-SETUP-GUIDE.md
│   ├── SETUP-CREDENTIALS.md                ← Credential config guide
│   └── IMPORT-WORKFLOWS.md                 ← Workflow import guide
│
├── NEXUS-Legal/                            ← Legal documentation
│   ├── NEXUS-Mentions-Legales.docx         ← [PLACEHOLDERS PENDING]
│   ├── NEXUS-CGU.docx                      ← [PLACEHOLDERS PENDING]
│   └── NEXUS-Politique-Confidentialite.docx ← [PLACEHOLDERS PENDING]
│
├── Content/
│   ├── nexusconformite-landing.html        ← Main landing page
│   ├── SEO-PLAN-10-ARTICLES.md             ← Content calendar
│   └── NEXUS-KPI-DASHBOARD.xlsx            ← Metrics tracking
│
└── Historical/                             ← Archive (old sessions S1-S7)
    └── [Archived documents from previous sessions]
```

---

## 🔧 CONFIGURATION REFERENCE

### Environment Variables (.env)

```bash
# N8N Configuration
N8N_HOST=0.0.0.0
N8N_PORT=5678
N8N_WEBHOOK_URL=http://localhost:5678    # Local; production: https://n8n.nexusconformite.fr
N8N_API_KEY=n8n_api_[key]                # Expires 28/04/2026
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=[REDACTED]

# Google / Gemini
GOOGLE_SHEETS_ID=1bxK_[ID]_[workspace sheets]
GEMINI_API_KEY=AIzaSy[KEY]

# Brevo SMTP (⚠️ Currently returns 535 Auth Failed)
BREVO_SMTP_HOST=smtp-relay.brevo.com
BREVO_SMTP_PORT=587
BREVO_SMTP_USER=noreply@nexusconformite.fr
BREVO_SMTP_PASSWORD=[REDACTED — invalid, needs regeneration]
BREVO_API_KEY=xkeysib-[KEY]

# Stripe (Test Mode)
STRIPE_PUBLISHABLE_KEY=pk_test_[KEY]
STRIPE_SECRET_KEY=STRIPE_TEST_KEY_REMOVED[KEY]
STRIPE_WEBHOOK_SECRET=whsec_[MISSING]

# Gumroad
GUMROAD_WEBHOOK_SECRET=[MISSING]

# Telegram
TELEGRAM_BOT_TOKEN=7[TOKEN]
TELEGRAM_CHAT_ID=123456789

# Beehiiv
BEEHIIV_PUBLICATION_ID=[ID]
BEEHIIV_API_KEY=[KEY]

# Domain
DOMAIN_NAME=nexusconformite.fr
HOSTING_PROVIDER=hostinger
```

---

## 🚀 DEPLOYMENT CHECKLIST

### Pre-Deployment (Blocking Issues)

**CRITICAL — Must resolve before production:**
- [ ] **Brevo SMTP credentials regenerated** (currently 535 Auth Failed) — affects WF-05, WF-06, WF-07, WF-09
- [ ] **Hostinger VPS provisioned** (replacing OVH)
- [ ] **DNS configured** (A records, CNAME for n8n subdomain)
- [ ] **SSL certificate** (Let's Encrypt auto via deploy script)
- [ ] **Stripe webhook secret** obtained and configured
- [ ] **Gumroad webhook secret** obtained and configured
- [ ] **Legal documents completed** (placeholders: [NOM], [ADRESSE], [SIRET])

### Workflows Requiring Retesting Post-Migration
- WF-03 (Newsletter) — Gemini patched, not fully retested
- WF-08 (Dashboard) — Not retested since session 5
- WF-09 (Cold Email) — Gemini patched, not fully retested

---

## 📊 KEY METRICS & DATES

| Metric | Value | Note |
|--------|-------|------|
| **Domain** | nexusconformite.fr | ~5€/year (OVH) |
| **VPS Cost** | ~6-8€/month | Hostinger |
| **N8N Version** | v2.13.4 | Community (no env vars support) |
| **N8N API Key Expiry** | 28/04/2026 | Requires renewal |
| **Google Gemini Quota** | 1,500 req/day | Free tier |
| **Brevo Email Limit** | 300 emails/day | Free tier |
| **Stripe Webhook Test** | Via Stripe CLI or test flow | Not yet configured |

---

## ⚠️ KNOWN ISSUES & WORKAROUNDS

| Issue | Impact | Workaround | Status |
|-------|--------|-----------|--------|
| Brevo SMTP 535 error | Email delivery fails | Applied `continueOnFail` on all nodes; need credential regen | 🔴 BLOCKING |
| `$env` not supported (N8N community) | Dynamic config impossible | All values hardcoded | ✅ Applied |
| LangChain nodes don't execute | WF-02, WF-03, WF-09 fail | Replaced with HTTP Request + Gemini | ✅ Applied |
| Expressions with newlines break | Evals to empty string | All expressions single-line | ✅ Applied |
| Stripe webhook secret missing | WF-04 production fails | Need to create in Stripe dashboard | 🔴 PENDING |
| Gumroad webhook secret missing | WF-07 production fails | Need to create in Gumroad settings | 🔴 PENDING |
| RSS Legifrance returns 403 | WF-02 fails occasionally | Applied `continueOnFail` on RSS nodes | ✅ Applied |
| Telegram bot never initialized | Dashboard summary can't send | User must send `/start` to @nexus_conformite_bot | ⏳ PENDING |

---

## 📖 TECHNICAL NOTES FOR FUTURE DEVELOPMENT

### N8N Best Practices (for this project)
1. **Credentials**: Always use N8N UI or `setup-n8n-credentials.js` script
2. **Workflows**: Import via `import-workflows.js` script (handles versionId)
3. **Email failures**: Use `continueOnFail: true` on Brevo nodes (unreliable SMTP)
4. **IA Integration**: Use Gemini 2.0 Flash (1500 req/day free) not Claude
5. **Gemini API call**: Raw body `contentType`, single-line JSON expression, reference `$json.candidates[0].content.parts[0].text`
6. **Activation**: `POST /rest/workflows/{id}/activate` requires `versionId` in body
7. **Google Sheets**: Use "Get Row(s)" operation only; don't specify `operation` explicitly

### Database/CRM
- Google Sheets: 6 worksheets (Ventes, Leads, Newsletter, Trafic, Alertes, Config)
- Telegram: Admin alerts only (not customer-facing)
- WordPress: Post content + legal pages only

### Revenue Tracking
- Gumroad: Auto-notifies via webhook → WF-07 → Google Sheets + Telegram
- Stripe: Custom webhook endpoint → WF-04, WF-05
- Annuaire: Manual entry in Google Sheets (pending CRM integration)

---

## 🔐 Security Checklist

- [ ] `.env` file in `.gitignore` (no secrets in git)
- [ ] `.gitignore` includes `node_modules/`, `*.log`, `.env`
- [ ] N8N basic auth enabled (username/password)
- [ ] SMTP credentials rotate monthly (Brevo regenerate)
- [ ] API keys stored in environment only (not hardcoded except N8N community workaround)
- [ ] Webhook secrets from Stripe/Gumroad never committed
- [ ] HTTPS only for production (Let's Encrypt via deploy script)
- [ ] WordPress admin account with strong password
- [ ] Database backups automated (WF-01)

---

## 📞 CONTACT & DOCUMENTATION

**Project Owner**: Dow (seallia81@gmail.com)
**Domain**: nexusconformite.fr (registrant: to be filled)
**Hosting**: Hostinger (TBD)

**Key Documents**:
- SESSION-LOG.md — Complete audit trail of all 9 sessions
- MASTER-CHECKLIST.md — Step-by-step implementation roadmap
- SETUP-CREDENTIALS.md — How to configure N8N credentials
- IMPORT-WORKFLOWS.md — How to import workflows to N8N

---

**Last Updated**: 01/04/2026
**Next Review**: After Hostinger deployment
**Maintained By**: Claude (AI Assistant)
