# NEXUS CONFORMITÉ — MASTER IMPLEMENTATION CHECKLIST
**Step-by-Step Project Execution Roadmap | Valid from 01/04/2026**

---

## 📌 HOW TO USE THIS DOCUMENT

This is your **directive line for the project's future**. Each checklist item is a concrete, actionable task. Complete them in order within each phase. Check them off as you complete them.

**Format**:
- ✅ = Done
- ⏳ = In Progress
- ❌ = Blocked / Pending decision
- 🟡 = Partially done / Needs verification

---

## 🔴 PHASE 0: CRITICAL BLOCKERS (Must resolve before ANY deployment)

These tasks block production deployment. Complete them first.

### 0.1 Fix Brevo SMTP Credentials (Affects: WF-05, WF-06, WF-07, WF-09)
- [ ] Open https://app.brevo.com → Settings → SMTP & API
- [ ] Generate NEW SMTP key (old key returns 535 Auth Failed)
- [ ] Copy SMTP credentials: `noreply@nexusconformite.fr` (login) + new password
- [ ] Update `.env` file: `BREVO_SMTP_PASSWORD=[new password]`
- [ ] In N8N: Settings → Credentials → Edit "Brevo SMTP NEXUS" with new password
- [ ] Test email delivery: Run WF-07 webhook test → check inbox for test email
- [ ] **Status**: ❌ BLOCKING

### 0.2 Obtain & Configure Stripe Webhook Secret (Affects: WF-04, WF-05)
- [ ] Login to https://dashboard.stripe.com/test/webhooks
- [ ] Create new endpoint: `https://nexusconformite.fr/webhook/stripe-subscription`
- [ ] Select events: `checkout.session.completed`, `customer.subscription.created`
- [ ] Copy webhook secret (starts with `whsec_`)
- [ ] Update `.env`: `STRIPE_WEBHOOK_SECRET=whsec_[key]`
- [ ] Deploy to production server (not needed for local testing)
- [ ] Test with Stripe CLI: `stripe listen --forward-to localhost:5678/webhook/stripe-subscription`
- [ ] **Status**: ❌ BLOCKING

### 0.3 Obtain & Configure Gumroad Webhook Secret (Affects: WF-07)
- [ ] Login to https://app.gumroad.com/settings/advanced
- [ ] Copy webhook URL secret (if available)
- [ ] Update `.env`: `GUMROAD_WEBHOOK_SECRET=[key]` (if provided by Gumroad)
- [ ] Configure Gumroad webhook: https://nexusconformite.fr/webhook/gumroad-webhook
- [ ] Test with test sale: $0 USD purchase → check email delivery in inbox
- [ ] **Status**: ❌ BLOCKING

### 0.4 Complete Legal Documents (Required before public launch)
- [ ] Open `NEXUS-Legal/NEXUS-Mentions-Legales.docx`
- [ ] Fill ALL placeholders: `[NOM COMPLET]`, `[ADRESSE]`, `[SIRET]`, `[HÉBERGEUR]`
- [ ] Verify SIRET on https://www.inpi.fr (or mark "EN CRÉATION")
- [ ] Save as: `NEXUS-Mentions-Legales-FINAL.docx`
- [ ] Repeat for `NEXUS-CGU.docx` and `NEXUS-Politique-Confidentialite.docx`
- [ ] Upload to WordPress: /mentions-legales, /cgv, /politique-confidentialite
- [ ] Add links in footer
- [ ] **Status**: ❌ PENDING

### 0.5 Renew N8N API Key (Expires 28/04/2026)
- [ ] Current expiry: 28/04/2026 (⏳ 27 days remaining as of 01/04)
- [ ] When within 7 days of expiry: N8N → Settings → API Keys → Create new
- [ ] Label: `NEXUS-BACKUP-WF01-[VERSION]`
- [ ] Copy key → Update WF-01 node "Récupérer workflows N8N" with new key
- [ ] Test WF-01: Execute workflow → check backup file generated
- [ ] **Status**: ⏳ SET REMINDER for 21/04/2026

---

## 🟡 PHASE 1: HOSTINGER INFRASTRUCTURE SETUP (Days 1-2)

Domain is purchased. Now set up the VPS and DNS.

### 1.1 Provision Hostinger VPS
- [ ] Login to Hostinger dashboard
- [ ] Create new VPS (Ubuntu 22.04 LTS recommended)
- [ ] Note VPS IP address: `___________` (save this)
- [ ] Create SSH user: `nexus-admin` with strong password
- [ ] Enable SSH key authentication (copy public key)
- [ ] Save connection details:
  - IP: `_____________`
  - Port: 22
  - User: nexus-admin
  - Password: saved in password manager
- [ ] **Status**: ⏳ PENDING

### 1.2 Configure DNS at OVH (For nexusconformite.fr)
- [ ] Login to OVH account
- [ ] Domain Management → nexusconformite.fr → DNS Zone
- [ ] Create/update A records:
  ```
  @          A     [HOSTINGER_IP]      # Main domain
  www        A     [HOSTINGER_IP]      # www subdomain
  ```
- [ ] Create CNAME for N8N:
  ```
  n8n        CNAME nexusconformite.fr.  # Redirect to main VPS
  ```
- [ ] Wait 1-24h for propagation (test with: `nslookup nexusconformite.fr`)
- [ ] Verify DNS works: `ping nexusconformite.fr`
- [ ] **Status**: ⏳ PENDING

### 1.3 Initial VPS Security Setup
- [ ] SSH into VPS: `ssh nexus-admin@[IP]`
- [ ] Update system: `sudo apt update && sudo apt upgrade -y`
- [ ] Install firewall: `sudo apt install ufw -y`
- [ ] Configure UFW:
  ```bash
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow 22/tcp      # SSH
  sudo ufw allow 80/tcp      # HTTP
  sudo ufw allow 443/tcp     # HTTPS
  sudo ufw allow 5678/tcp    # N8N (internal only, optional)
  sudo ufw enable
  ```
- [ ] Create `.ssh` directory and copy SSH key
- [ ] Disable password authentication in SSH (security best practice)
- [ ] **Status**: ⏳ PENDING

---

## 🟢 PHASE 2: N8N DEPLOYMENT TO PRODUCTION (Days 2-3)

Deploy N8N, WordPress, and SSL to Hostinger VPS.

### 2.1 Deploy N8N via Script
- [ ] Copy deployment script from local:
  ```bash
  scp NEXUS-N8N/deploy-n8n-vps.sh nexus-admin@[IP]:/home/nexus-admin/
  ```
- [ ] SSH into VPS and run:
  ```bash
  ssh nexus-admin@[IP]
  chmod +x deploy-n8n-vps.sh
  ./deploy-n8n-vps.sh
  ```
- [ ] Script installs:
  - Node.js + npm
  - N8N latest version
  - Nginx (reverse proxy)
  - Let's Encrypt SSL (auto-renew)
  - PM2 (process manager)
- [ ] Verify N8N started:
  ```bash
  pm2 logs
  pm2 status
  ```
- [ ] Check Nginx:
  ```bash
  sudo nginx -t
  sudo systemctl restart nginx
  ```
- [ ] **Status**: ⏳ PENDING

### 2.2 Configure N8N Production Environment
- [ ] SSH into VPS
- [ ] Create N8N production `.env`:
  ```bash
  sudo nano /etc/n8n/.env
  ```
- [ ] Copy from local `.env` and update:
  - `N8N_HOST=0.0.0.0` → production setup
  - `N8N_WEBHOOK_URL=https://n8n.nexusconformite.fr`
  - `N8N_BASIC_AUTH_ACTIVE=true`
  - All credential keys (Gemini, Brevo, Telegram, Beehiiv, Stripe, Gumroad)
  - All hardcoded values (GOOGLE_SHEETS_ID, TELEGRAM_CHAT_ID, etc.)
- [ ] Restart N8N:
  ```bash
  pm2 restart n8n
  pm2 save
  ```
- [ ] Test N8N accessible: https://n8n.nexusconformite.fr
- [ ] Login with production credentials
- [ ] **Status**: ⏳ PENDING

### 2.3 Import & Activate Workflows in Production
- [ ] Copy workflow JSON files to VPS:
  ```bash
  scp -r NEXUS-N8N/workflows/* nexus-admin@[IP]:/home/nexus-admin/workflows/
  ```
- [ ] Copy import script:
  ```bash
  scp NEXUS-N8N/import-workflows.js nexus-admin@[IP]:/home/nexus-admin/
  ```
- [ ] SSH into VPS and run:
  ```bash
  cd /home/nexus-admin
  node import-workflows.js
  ```
- [ ] Verify all 9 workflows imported:
  - WF-01 to WF-09 appear in N8N UI
  - No import errors in console
- [ ] Each workflow should show "versionId" in JSON (required for activation)
- [ ] **Status**: ⏳ PENDING

### 2.4 Install & Configure WordPress (via Hostinger or Manual)
**Option A: Hostinger Auto-Install**
- [ ] Hostinger Control Panel → Create WordPress install
- [ ] Select domain: nexusconformite.fr
- [ ] Create admin user: (strong password)
- [ ] Complete setup wizard

**Option B: Manual Install**
- [ ] SSH into VPS
- [ ] Install MySQL: `sudo apt install mysql-server -y`
- [ ] Install PHP: `sudo apt install php php-mysql php-fpm -y`
- [ ] Download WordPress: `cd /var/www/html && wget https://wordpress.org/latest.tar.gz`
- [ ] Extract and configure
- [ ] Update Nginx config to point to WordPress

**Either way:**
- [ ] Verify WordPress loads: https://nexusconformite.fr
- [ ] Create admin account with strong password
- [ ] Install required plugins:
  - Really Simple SSL (HTTPS)
  - Yoast SEO
  - Contact Form 7 (or Forminator)
  - UpdraftPlus (backups)
- [ ] **Status**: ⏳ PENDING

### 2.5 Configure Webhook Endpoints (N8N ↔ External Services)
- [ ] In N8N UI, update webhook URLs for each workflow:
  - WF-04 (Stripe): `https://nexusconformite.fr/webhook/stripe-subscription`
  - WF-05 (Stripe): `https://nexusconformite.fr/webhook/stripe-subscription`
  - WF-06 (Landing form): `https://nexusconformite.fr/webhook/lead-annuaire`
  - WF-07 (Gumroad): `https://nexusconformite.fr/webhook/gumroad-webhook`
- [ ] Configure Stripe webhook (if not done in Phase 0):
  - https://dashboard.stripe.com/test/webhooks → Add Endpoint
  - URL: `https://nexusconformite.fr/webhook/stripe-subscription`
  - Events: `checkout.session.completed`, `customer.subscription.created`
- [ ] Configure Gumroad webhook (if needed):
  - https://app.gumroad.com/settings/advanced → Webhooks
  - URL: `https://nexusconformite.fr/webhook/gumroad-webhook`
- [ ] Test each webhook with sample data
- [ ] **Status**: ⏳ PENDING

---

## 🔷 PHASE 3: WORKFLOW TESTING & ACTIVATION (Days 3-4)

Test each workflow end-to-end in production before enabling for real revenue.

### 3.1 Test WF-04 (Stripe Alerts)
- [ ] Create test charge in Stripe dashboard: $1.00
- [ ] Expected: Telegram message in admin chat + row in Google Sheets
- [ ] Verify: Check Telegram chat and Google Sheets → NEXUS-REVENUS sheet
- [ ] Mark workflow as: **PRODUCTION READY** or **NEEDS FIX**
- [ ] **Status**: ⏳ PENDING

### 3.2 Test WF-05 (Annuaire Onboarding)
- [ ] Create test Stripe subscription (annual 49€)
- [ ] Expected: Email sent (or skipped via continueOnFail), row in Google Sheets, Telegram alert
- [ ] Verify: Check email inbox, Telegram, Google Sheets
- [ ] Mark workflow as: **PRODUCTION READY** or **NEEDS FIX**
- [ ] **Status**: ⏳ PENDING

### 3.3 Test WF-06 (Lead Management)
- [ ] Manually trigger webhook:
  ```bash
  curl -X POST https://nexusconformite.fr/webhook/lead-annuaire \
    -H "Content-Type: application/json" \
    -d '{"company":"Test Inc","contactEmail":"test@example.com","name":"John Doe","sector":"Tech"}'
  ```
- [ ] Expected: Email sent, row in Sheets, Telegram alert
- [ ] Verify: Check email, Telegram, Sheets
- [ ] Mark workflow as: **PRODUCTION READY** or **NEEDS FIX**
- [ ] **Status**: ⏳ PENDING

### 3.4 Test WF-07 (Gumroad Delivery + J+7 Follow-up)
- [ ] Create test Gumroad sale (or use webhook simulator)
- [ ] Expected: Email delivered immediately, another email 7 days later
- [ ] For testing: Temporarily set wait to 5 minutes
- [ ] Verify email received in inbox
- [ ] Mark workflow as: **PRODUCTION READY** or **NEEDS FIX**
- [ ] Revert wait duration to 7 days before final deployment
- [ ] **Status**: ⏳ PENDING

### 3.5 Test WF-01 (Weekly Backup)
- [ ] Execute workflow manually: WF-01 → Execute
- [ ] Expected: Backup file generated, Telegram notification (or continueOnFail)
- [ ] Verify: Check Telegram, verify backup file exists on VPS
- [ ] Mark workflow as: **PRODUCTION READY** or **NEEDS FIX**
- [ ] **Status**: ⏳ PENDING

### 3.6 Test WF-02 (Daily Veille - Legislative Monitoring)
- [ ] Execute workflow manually: WF-02 → Execute
- [ ] Expected: Fetch RSS feeds, summarize with Gemini, send to Telegram
- [ ] Verify: Check Telegram chat for legislative summary
- [ ] If fails: Check Gemini API key, check RSS feed connectivity
- [ ] Mark workflow as: **PRODUCTION READY** or **NEEDS FIX**
- [ ] **Status**: ⏳ PENDING

### 3.7 Test WF-03 (Weekly Newsletter)
- [ ] Execute workflow manually: WF-03 → Execute
- [ ] Expected: Compile articles, generate digest with Gemini, send to Beehiiv
- [ ] Verify: Check Beehiiv dashboard for new draft/published email
- [ ] If fails: Check Beehiiv API key, check Google Sheets data
- [ ] Mark workflow as: **PRODUCTION READY** or **NEEDS FIX**
- [ ] **Status**: ⏳ PENDING

### 3.8 Test WF-08 (Dashboard Weekly Summary)
- [ ] Execute workflow manually: WF-08 → Execute
- [ ] Expected: Aggregate metrics from Google Sheets + Beehiiv, send summary to Telegram
- [ ] Verify: Check Telegram chat for dashboard summary
- [ ] If fails: Check Telegram bot initialized, check Google Sheets data
- [ ] Mark workflow as: **PRODUCTION READY** or **NEEDS FIX**
- [ ] **Status**: ⏳ PENDING

### 3.9 Test WF-09 (Cold Email B2B)
- [ ] Execute workflow manually: WF-09 → Execute
- [ ] Expected: Fetch target list (if configured), personalize with Gemini, send via Brevo
- [ ] For testing: Send 1-2 test emails only (avoid spam)
- [ ] Verify: Check email delivery, check spam folder
- [ ] Mark workflow as: **PRODUCTION READY** or **NEEDS FIX**
- [ ] **Status**: ⏳ PENDING

### 3.10 Enable Scheduled Workflows
Once all tests pass:
- [ ] WF-01: Enable cron "Monday 9am"
- [ ] WF-02: Enable cron "Daily 9am"
- [ ] WF-03: Enable cron "Friday 10am"
- [ ] WF-08: Enable cron "Sunday 8pm"
- [ ] WF-09: Enable cron "Tuesday & Thursday 9am"
- [ ] WF-04, WF-05, WF-06, WF-07: Keep webhook-triggered (always enabled)
- [ ] Verify: Each workflow shows "Active" in N8N UI
- [ ] **Status**: ⏳ PENDING

---

## 💰 PHASE 4: REVENUE ACTIVATION (Days 5-7)

Activate all revenue streams. Only after all workflows tested.

### 4.1 Gumroad Product Setup
- [ ] Product: "Kit RGPD NEXUS"
- [ ] Price: 97€
- [ ] Description: From landing page
- [ ] Webhook: Configure `https://nexusconformite.fr/webhook/gumroad-webhook`
- [ ] Test sale: $0 sale → verify email delivery
- [ ] Set to public/live
- [ ] Add purchase link to landing page
- [ ] **Status**: ❌ PENDING

### 4.2 Stripe Subscription Setup (Annuaire)
- [ ] Create Stripe subscription product: "Annuaire Prestataires"
- [ ] Price: 49€/month
- [ ] Webhook: Configure endpoint in Stripe dashboard
- [ ] Test subscription: Create via Stripe test card → verify onboarding email
- [ ] Set to public/live
- [ ] Add signup button to landing page: `/annuaire`
- [ ] **Status**: ❌ PENDING

### 4.3 Beehiiv Newsletter Referral
- [ ] Beehiiv dashboard → Refer & Earn
- [ ] Copy affiliate link
- [ ] Add to WordPress as bonus incentive page
- [ ] Monitor referral conversions (goal: 5-10 by M3)
- [ ] **Status**: ❌ PENDING

### 4.4 Axonaut CRM Affiliate
- [ ] Create Axonaut affiliate account (40% recurring commission)
- [ ] Unique affiliate link: [link to save]
- [ ] Create content: CRM comparison page (NEXUS vs competitors)
- [ ] Add CTA to dashboard page
- [ ] **Status**: ❌ PENDING

### 4.5 Cold Email B2B Service (Optional - Manual Service)
- [ ] Define target audience (SME 10-50 employees)
- [ ] Create email template for cold outreach
- [ ] Develop lead list (LinkedIn, Apollo, RocketReach)
- [ ] Use WF-09 to personalize + send
- [ ] Offer: Initial audit (free) → upsell to subscription
- [ ] **Status**: ❌ PENDING

---

## 📝 PHASE 5: CONTENT & SEO (Days 8-14)

Create content to drive organic traffic and establish authority.

### 5.1 Publish Legal Pages
- [ ] WordPress Pages:
  - [ ] /mentions-legales (from NEXUS-Mentions-Legales-FINAL.docx)
  - [ ] /cgv (from NEXUS-CGU-FINAL.docx)
  - [ ] /politique-confidentialite (from NEXUS-Politique-Confidentialite-FINAL.docx)
- [ ] Add footer links
- [ ] Test links on live site
- [ ] **Status**: ⏳ PENDING

### 5.2 Create SEO Articles (Content Calendar)
- [ ] Reference: `SEO-PLAN-10-ARTICLES.md` (10-article plan)
- [ ] Articles target long-tail keywords (e.g., "RGPD PME", "conformité données")
- [ ] Publish 1 article every 3-4 days (pace: 2-3 articles/week)
- [ ] Each article: 1500+ words, links to relevant services
- [ ] Enable Yoast SEO on each post
- [ ] Track: Analytics → goal is 100+ monthly visits by M3
- [ ] **Status**: ⏳ PENDING

### 5.3 Configure Analytics
- [ ] Google Analytics 4: Add tracking code to WordPress footer
- [ ] Goal 1: Newsletter signup
- [ ] Goal 2: Gumroad purchase
- [ ] Goal 3: Annuaire subscription
- [ ] Check dashboard daily
- [ ] **Status**: ⏳ PENDING

---

## 🎯 PHASE 6: FINAL QA & LAUNCH (Days 14-15)

Final checks before public announcement.

### 6.1 Full System Test
- [ ] Navigate https://nexusconformite.fr (landing page loads)
- [ ] All internal links work
- [ ] Footer links present + working
- [ ] Legal pages complete + readable
- [ ] Form submissions go to Google Sheets
- [ ] Purchase button → Gumroad
- [ ] Subscribe button → Stripe
- [ ] Mobile responsive (test on phone)
- [ ] **Status**: ⏳ PENDING

### 6.2 Security Final Check
- [ ] SSL certificate valid (should be auto from Let's Encrypt)
- [ ] No console errors in browser DevTools
- [ ] `.env` not in git (verify with `git log --all --full-history -- .env`)
- [ ] No secrets in public repositories
- [ ] Firewall configured (only 22, 80, 443 open)
- [ ] SSH key authentication enabled (password disabled)
- [ ] WordPress admin password strong + 2FA enabled (if available)
- [ ] **Status**: ⏳ PENDING

### 6.3 Workflow Verification
- [ ] All 9 workflows marked ACTIVE in N8N
- [ ] Cron schedules correct
- [ ] Webhook URLs correct
- [ ] Credentials all valid (no red "X" marks)
- [ ] No "Node is not executed" warnings
- [ ] **Status**: ⏳ PENDING

### 6.4 Backup Configuration
- [ ] WordPress: UpdraftPlus automatic backups enabled (daily)
- [ ] N8N: WF-01 running (weekly backup of workflows)
- [ ] Verify backup files exist on VPS
- [ ] Test restore procedure (not required now, but document for future)
- [ ] **Status**: ⏳ PENDING

---

## 🚀 PHASE 7: LAUNCH & MONITORING (Day 15+)

Go live and monitor for issues.

### 7.1 Public Announcement
- [ ] Send email to contacts: "NEXUS CONFORMITÉ is live"
- [ ] Post on LinkedIn: Company profile announcement
- [ ] Share landing page link
- [ ] Expected: 10-20 initial visits
- [ ] **Status**: ⏳ PENDING

### 7.2 First Week Monitoring
- [ ] Daily check: Analytics → traffic, conversions
- [ ] Daily check: Telegram alerts → are they coming through?
- [ ] Daily check: Google Sheets → new leads/sales?
- [ ] Weekly: Review email logs → any undelivered emails?
- [ ] Weekly: Review Google Gemini API usage → staying under 1500 req/day?
- [ ] **Status**: ⏳ PENDING

### 7.3 First Month KPIs
| Metric | Target | Actual |
|--------|--------|--------|
| Unique visitors | 50-100 | ___ |
| Newsletter signups | 5-10 | ___ |
| Gumroad sales | 1-2 | ___ |
| Annuaire leads | 2-3 | ___ |
| Return visitors | 5+ | ___ |

- [ ] Track weekly in Google Sheets: `NEXUS-KPI-DASHBOARD.xlsx`
- [ ] **Status**: ⏳ PENDING

### 7.4 Ongoing Maintenance (Monthly Checklist)
- [ ] First day of month: Review KPIs, update dashboard
- [ ] Mid-month: Publish 1-2 new SEO articles
- [ ] End of month: Backup verification, security audit
- [ ] Every 30 days: Rotate Brevo SMTP key (security best practice)
- [ ] Every 6 months: Renew Let's Encrypt SSL (should be auto)
- [ ] Before 28/04: Renew N8N API key
- [ ] **Status**: ⏳ PENDING

---

## 📊 SUCCESS CRITERIA

**By End of Week 1 (Day 7)**:
- ✅ All 9 workflows tested in production
- ✅ At least 1 real customer purchase (Gumroad or subscription)
- ✅ No critical errors in N8N logs
- ✅ SSL working, no browser warnings
- ✅ Legal pages published

**By End of Month 1 (Day 30)**:
- ✅ 50+ monthly visits
- ✅ 5+ newsletter signups
- ✅ 1-2 Gumroad sales
- ✅ 1-2 annuaire leads
- ✅ All workflows running on schedule

**By End of Month 3 (Day 90)**:
- ✅ 500+ monthly visits
- ✅ 50+ newsletter signups
- ✅ 10-15 Gumroad sales (~1,500€)
- ✅ 10-15 annuaire subscribers (~700€)
- ✅ Break-even or profitable
- ✅ Ready to scale (add more content, expand services)

---

## 🔗 SUPPORTING DOCUMENTS

Reference these while executing:
- `PROJECT.md` — Architecture & technical reference
- `SESSION-LOG.md` — What was done in each session + blockers
- `NEXUS-N8N/GUIDES/` — Specific operational guides
- `NEXUS-N8N/SETUP-CREDENTIALS.md` — How to configure credentials
- `.env.example` — Template for environment variables

---

## ✍️ EXECUTION LOG

Use this space to track progress and blockers:

```
[Date] [Phase] [Task] [Status] [Notes]
---
[01/04] Phase 0.1 Brevo SMTP ❌ BLOCKED - Need new key regeneration
[01/04] Phase 0.2 Stripe webhook ❌ BLOCKED - Need Stripe dashboard access
...
```

---

**Last Updated**: 01/04/2026
**Next Checkpoint**: Phase 0 completion (all blockers resolved)
**Review Frequency**: Daily during phases 0-3, then weekly

