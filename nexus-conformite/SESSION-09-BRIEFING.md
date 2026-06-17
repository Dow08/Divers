# SESSION 9 — NEXUS CONFORMITÉ
## Briefing de reprise — Prêt à démarrer

> **Prochaine priorité #1 :** Acheter `nexusconformite.fr` sur OVH → puis déploiement production

---

## 🔴 ÉTAT AU 30/03/2026 — CE QUI EST FAIT

| # | Élément | Statut |
|---|---------|--------|
| WF-06 emails | **✅ CORRIGÉ + TESTÉ** (exec #45, #46 — success) |
| WF-07 JSON | **✅ CORRIGÉ sur disque** — import-workflows.js à lancer |
| WF-04 JSON | **✅ RÉPARÉ** (JSON tronqué → complet, 4 nodes) |
| WF-05/08/09 | **✅ JSON valides** — non testés en live |
| Landing HTML | **✅ REFAITE** 2026 UX/UI (64K, 1506 lignes, 8 sections) |
| GitHub repo | **✅ SÉCURISÉ** — .gitignore, zéro secrets, push initial OK |
| git-commit-session8.bat | **✅ PRÊT** à double-cliquer |

---

## 🟡 À FAIRE CE SOIR AVANT DE FERMER

1. **Double-clic** → `git-commit-session8.bat` (commit + push GitHub)
2. **Terminal** → `cd NEXUS-N8N && node import-workflows.js` (apply WF-07 fix in N8N)
3. **Test WF-07** (PowerShell) :
   ```powershell
   curl.exe -X POST http://127.0.0.1:5678/webhook/gumroad-webhook `
     -H "Content-Type: application/json" `
     -d "{\"email\":\"seallia81@gmail.com\",\"product_name\":\"Kit RGPD NEXUS\",\"price\":9700,\"sale_id\":\"TEST-S8\"}"
   ```

---

## 🟢 SESSION 9 — PLAN D'ATTAQUE (dans l'ordre)

### ÉTAPE 1 — OVH : Domaine + Hébergement (30 min)

**1.1 Acheter le domaine**
- URL : https://www.ovhcloud.com/fr/domains/
- Rechercher : `nexusconformite.fr`
- Prix : ~4,99 €/an
- **Options à cocher :**
  - ☑ Protection WHOIS (gratuit)
  - ☑ DNS OVH (par défaut)
  - ✗ Ne PAS prendre l'hébergement mail OVH (on utilise Brevo)

**1.2 Choisir l'hébergement**

Option A — **OVH Pro 1** (~4,49 €/mois) : WordPress + SSL auto
- Inclut : 100 Go SSD, PHP 8.2, MySQL, SSL Let's Encrypt, 1 domaine
- Commande : https://www.ovhcloud.com/fr/web-hosting/

Option B — **OVH VPS Starter** (~5,99 €/mois) : plus de contrôle
- Avantage : peut héberger N8N + WordPress sur le même VPS
- Ubuntu 22.04 + Nginx + PM2 pour N8N
- **Recommandé si tu veux N8N en production sur le serveur**

> 💡 **Recommandation** : VPS Starter si tu veux tout centraliser (N8N + WP)
> OVH Pro 1 si tu veux WordPress simple sans gérer un serveur

---

### ÉTAPE 2 — Configuration DNS (15 min après achat domaine)

Une fois le domaine acheté, configurer dans OVH Manager → Zones DNS :

```
# Enregistrements A (remplacer IP_DU_SERVEUR par l'IP OVH)
@          A     IP_DU_SERVEUR        # nexusconformite.fr
www        A     IP_DU_SERVEUR        # www.nexusconformite.fr

# CNAME pour sous-domaines
n8n        CNAME nexusconformite.fr.  # n8n.nexusconformite.fr → N8N
app        CNAME nexusconformite.fr.  # app.nexusconformite.fr → N8N (alias)

# MX pour email (Brevo / OVH Mail)
@          MX    10  mail.nexusconformite.fr.

# TXT pour validation Brevo DKIM
@          TXT   "v=spf1 include:sendinblue.com ~all"
```

> 🕐 Propagation DNS : 1-24h (généralement < 30 min chez OVH)

---

### ÉTAPE 3 — N8N Production (si VPS) (1h)

**3.1 Connexion VPS**
```bash
ssh ubuntu@IP_DU_SERVEUR
```

**3.2 Installation automatique** (script prêt ci-dessous)
```bash
# Copier le script depuis le projet
scp NEXUS-N8N/deploy-n8n-vps.sh ubuntu@IP:/home/ubuntu/
ssh ubuntu@IP "chmod +x deploy-n8n-vps.sh && ./deploy-n8n-vps.sh"
```

**3.3 Variables d'environnement sur le VPS**
```bash
# Sur le VPS, créer /etc/n8n/.env avec les vraies clés
sudo nano /etc/n8n/.env
```

**3.4 Webhook URLs à mettre à jour** dans les workflows :
- `https://nexusconformite.fr/webhook/lead-annuaire` (WF-06) ✅ déjà dans la landing
- `https://nexusconformite.fr/webhook/gumroad-webhook` (WF-07) → configurer dans Gumroad
- `https://nexusconformite.fr/webhook/stripe-subscription-new` (WF-05) → configurer dans Stripe

---

### ÉTAPE 4 — WordPress (si OVH Pro) (30 min)

**Plugins à installer en priorité :**
1. **Yoast SEO** — référencement
2. **Elementor** — page builder (page de vente)
3. **WooCommerce** — boutique (si vente directe)
4. **Really Simple SSL** — HTTPS auto
5. **WP Rocket** ou **W3 Total Cache** — performances
6. **Contact Form 7** — formulaire contact
7. **UpdraftPlus** — backups automatiques
8. **MonsterInsights** — Google Analytics

**Pages à créer :**
- `/` — Redirection vers landing page ou page d'accueil WP
- `/mentions-legales` — À remplir (template DOCX dans le projet)
- `/politique-confidentialite` — À remplir (template DOCX)
- `/cgv` — Conditions générales de vente
- `/kit-rgpd` — Page de vente du produit

---

### ÉTAPE 5 — Tests N8N Production (1h)

Ordre de test recommandé :

```
WF-07 → WF-06 → WF-03 → WF-09 → WF-08 → WF-04 → WF-01
```

**WF-07 — Livraison Gumroad** (priorité)
```bash
curl -X POST https://nexusconformite.fr/webhook/gumroad-webhook \
  -H "Content-Type: application/json" \
  -d '{"email":"seallia81@gmail.com","product_name":"Kit RGPD","price":9700,"sale_id":"TEST-PROD-01"}'
```
→ Attendre : email livraison dans la boîte seallia81@gmail.com

**WF-06 — Lead Annuaire**
```bash
curl -X POST https://nexusconformite.fr/webhook/lead-annuaire \
  -H "Content-Type: application/json" \
  -d '{"company":"Test SARL","contactEmail":"seallia81@gmail.com","contactName":"Dow","sector":"Tech","employees":10}'
```

**WF-03 — Newsletter Hebdo** (manuel)
→ Ouvrir N8N → WF-03 → Execute workflow manuellement

---

### ÉTAPE 6 — Gumroad + Stripe Configuration (30 min)

**Gumroad Webhook** :
1. Gumroad Dashboard → Settings → Advanced → Webhooks
2. URL : `https://nexusconformite.fr/webhook/gumroad-webhook`
3. Events : `sale`

**Stripe Webhook** :
1. Stripe Dashboard → Developers → Webhooks → Add endpoint
2. URL : `https://nexusconformite.fr/webhook/stripe-subscription-new`
3. Events : `checkout.session.completed`, `customer.subscription.created`
4. Copier le `whsec_...` → mettre dans `.env` → `STRIPE_WEBHOOK_SECRET`

---

### ÉTAPE 7 — Documents légaux (30 min)

Fichiers DOCX à remplir dans le projet :
```
Projet V2 WEB/
├── mentions-legales.docx        → Nom, adresse, SIRET, hébergeur
├── politique-confidentialite.docx → DPO, cookies, RGPD
└── cgv.docx                     → Prix, délais, remboursement
```
Placeholders à remplacer : `[NOM]`, `[ADRESSE]`, `[SIRET]`, `[EMAIL_CONTACT]`

---

## 📋 CHECKLIST COMPLÈTE SESSION 9

### Matin (priorité)
- [ ] Acheter nexusconformite.fr sur OVH
- [ ] Choisir hébergement (VPS ou Pro)
- [ ] Configurer DNS
- [ ] Confirmer que git-commit-session8.bat a été exécuté

### Après-midi
- [ ] Déployer N8N en production
- [ ] Configurer Nginx + SSL pour n8n.nexusconformite.fr
- [ ] Import des 9 workflows en production
- [ ] Configurer .env production (toutes les clés)
- [ ] Test WF-07 en production → email reçu ✓
- [ ] Test WF-06 en production → email reçu ✓

### Fin de journée
- [ ] Configurer webhook Gumroad
- [ ] Configurer webhook Stripe
- [ ] Installer WordPress + plugins
- [ ] Remplir les 3 documents légaux
- [ ] Test WF-03, WF-08, WF-09
- [ ] Commit final Session 9

---

## 🗂 ARCHITECTURE CIBLE

```
nexusconformite.fr (OVH)
├── / → Landing page (nexusconformite-landing.html)
├── /blog → WordPress
├── /kit-rgpd → Page de vente WooCommerce
├── /mentions-legales → Page WP
└── n8n.nexusconformite.fr → N8N (port 5678 via Nginx reverse proxy)

Webhooks N8N production:
├── POST /webhook/lead-annuaire        → WF-06
├── POST /webhook/gumroad-webhook      → WF-07
├── POST /webhook/stripe-subscription-new → WF-05
└── POST /webhook/newsletter-subscribe → WF-03 (à vérifier)

Services externes:
├── Brevo SMTP — emails transactionnels
├── Gumroad — vente Kit RGPD (97€)
├── Stripe — abonnements annuaire
├── Google Sheets — CRM + dashboard
├── Telegram — alertes admin
└── Beehiiv — newsletter
```

---

## 🔑 RÉFÉRENCE RAPIDE — IDs N8N (instance locale actuelle)

| Workflow | ID N8N local | Statut local |
|----------|-------------|-------------|
| WF-06 | `IyCbovytZPrdxDU5` | ✅ Actif + testé |
| WF-07 | À récupérer via `node import-workflows.js` | 🔧 Fix à appliquer |

**Credential SMTP (local) :**
- ID : `ITliUTfuwkRQE3DM`
- Nom : `Brevo SMTP NEXUS`

---

## 📦 FICHIERS CLÉS DU PROJET

```
Projet V2 WEB/
├── nexusconformite-landing.html     ← Page principale (✅ 2026 UX/UI)
├── NEXUS-N8N/
│   ├── .env.example                 ← Template config (copier → .env)
│   ├── workflows/
│   │   ├── WF-06-leads-annuaire.json    ← ✅ email corrigé
│   │   ├── WF-07-livraison-gumroad.json ← ✅ email corrigé
│   │   └── WF-04-alertes-revenus.json   ← ✅ JSON réparé
│   ├── import-workflows.js          ← Importer/MAJ workflows dans N8N
│   ├── setup-n8n-credentials.js     ← Configurer les credentials
│   └── deploy-n8n-vps.sh            ← ⬅ À CRÉER en session 9
├── git-commit-session8.bat          ← ✅ Exécuter ce soir
└── SESSION-09-BRIEFING.md           ← Ce fichier
```

---

*Généré le 30/03/2026 — Fin de Session 8*
