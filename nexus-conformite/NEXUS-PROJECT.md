# NEXUS CONFORMITÉ — Hub Intermédiaire Réglementaire TPE/PME France
## PROJECT.md v2 — Mis à jour le 28/03/2026

> **"La fenêtre de tir, c'est maintenant. Septembre 2026 arrive."**
> Modèle 100% intermédiaire — 0 responsabilité conseil — 100% automatisé — mobile-first

---

## 🎯 Vision & Périmètre

Devenir LA référence digitale francophone pour accompagner les 7 millions de TPE/PME françaises face à leurs 4 obligations réglementaires simultanées. Rôle **pur d'éditeur de contenu informatif et de mise en relation** — jamais de conseil personnalisé.

| | |
|---|---|
| **Porteur** | Dow Poncelet |
| **Statut légal** | Nom propre → micro-entreprise à maturité (seuil 500€+/mois récurrent) |
| **Marché cible** | TPE/PME France + Belgique + Suisse francophone |
| **Objectif M12** | 12 300 – 23 500€/mois |
| **Objectif M24** | 20 000 – 35 000€/mois (extension NIS2 + ANC + nouveaux règlements) |
| **Fenêtre critique** | Maintenant → Septembre 2026 |
| **Nom de domaine cible** | **nexusconformite.fr** (LIBRE — vérifié 28/03/2026) |
| **Domaine backup** | conformite-hub.fr (LIBRE) · hub-conformite.fr (LIBRE) |

> ✅ **Action immédiate domaine :** nexusconformite.fr disponible → acheter chez OVH (~7€/an).
> Aucune marque déposée à ce jour sous ce nom (vérifier INPI avant achat).

---

## 💰 COÛTS INFRASTRUCTURE — VERSION OPTIMISÉE

### Objectif : descendre à 15-25€/mois au démarrage

| Couche | Outil retenu | Alternative évitée | Coût/mois |
|---|---|---|---|
| **Serveur VPS** | Hetzner CX11 (2vCPU, 2GB, 20GB SSD) | Oracle Free Tier (limité) | **3,99€** |
| **WordPress** | Sur même VPS (Nginx/Caddy) | Hébergement séparé | **0€** |
| **Thème WP** | Astra gratuit + Elementor free | Divi payant | **0€** |
| **SEO WP** | Rank Math gratuit | Yoast Premium | **0€** |
| **Newsletter** | Beehiiv (gratuit ≤2500 abonnés) | Mailchimp (payant) | **0€** |
| **Webinaire test** | Systeme.io plan GRATUIT (3 funnels) | Systeme.io 27€/mois | **0€** → 27€ à M3+ |
| **Produits num.** | Gumroad (0€ + 10% commission) | Lemon Squeezy | **0€** |
| **Annuaire WP** | Business Directory Plugin (achat unique 99€) | Directories Pro mensuel | **~3€** amorti/mois |
| **IA Contenu** | Claude Haiku API (x5 moins cher que Sonnet) | Claude Sonnet systématique | **~4-6€** |
| **Cookie RGPD** | Axeptio plan gratuit | Didomi payant | **0€** |
| **Analytics** | GA4 + Microsoft Clarity | Matomo payant | **0€** |
| **Reverse proxy** | Caddy (open source) | Nginx payant | **0€** |
| **Backups** | N8N → Google Drive (15GB gratuit) | Backup service payant | **0€** |
| **Nom de domaine** | OVH .fr | Gandi (plus cher) | **~0,58€** |
| **Bot alertes** | Telegram Bot API (0€) | Slack payant | **0€** |
| **Dashboard gains** | Google Looker Studio (gratuit) | Databox payant | **0€** |
| **SMTP envoi** | Brevo (ex-Sendinblue) 300 emails/j gratuit | Mailgun payant | **0€** |
| **TOTAL DÉMARRAGE** | | | **~12-15€/mois** |
| **TOTAL MATURITÉ (M3+)** | Systeme.io 27€ activé | | **~40-45€/mois** |

> **Règle d'or :** On n'active un outil payant que quand il génère des revenus. Systeme.io reste gratuit (3 funnels) jusqu'au 1er webinaire vendu.

---

## 🔗 MÉCANIQUE D'AFFILIATION — COMMENT JE SUIS RÉMUNÉRÉ

### Fonctionnement technique du lien affilié

```
1. Je m'inscris au programme partenaire de l'outil (ex: Axonaut)
2. Je reçois un lien unique: axonaut.com?ref=NEXUSCONF
3. Ce lien est placé sur mon site/newsletter avec la mention légale "lien partenaire"
4. Le visiteur clique → cookie déposé sur son navigateur (durée: 30 à 90 jours)
5. Il souscrit dans ce délai → la conversion m'est créditée automatiquement
6. Le prestataire me verse la commission le mois suivant (virement SEPA ou PayPal)
```

### Programmes clés confirmés

| Programme | Commission | Durée cookie | Paiement | Lien |
|---|---|---|---|---|
| **Axonaut** | **40% récurrent mensuel** | 90 jours | Virement M+1 | Via dashboard partenaire |
| **Pennylane** | À négocier (~20-30%) | 60 jours | Virement M+1 | programme.pennylane.com |
| **Tiime** | À négocier | 30 jours | — | Contact commercial |
| **Axeptio** | ~20% première souscription | 30 jours | — | axeptio.eu/partenaires |
| **Assureurs cyber** | 5-15% prime annuelle | 90 jours | — | Comparateurs courtage |
| **Gofore / RSSI-as-a-service** | Négocié au lead qualifié | — | Par lead (50-200€) | Partenariat direct |

### Flux de revenus par angle

```
Comparateur PDP → Clic UTM → Inscription PDP → Commission mensuelle récurrente
Newsletter → Email avec lien affilié → Achat abonné → Commission unique ou récurrente
Annuaire → Prestataire paie abonnement Stripe → Débit mensuel automatique
Gumroad → Vente pack PDF → 90% du prix (Gumroad prend 10%)
Webinaire → Achat Systeme.io → 100% du prix (frais Stripe ~1,4%+0,25€)
Veille MRR → Abonnement Stripe 9€ ou 19€ → Débit mensuel automatique
```

### Tracking attribution

Chaque lien affilié utilise des UTM UNIQUES :
```
https://axonaut.com?ref=NEXUSCONF&utm_source=newsletter&utm_medium=email&utm_campaign=nis2-semaine12
https://axonaut.com?ref=NEXUSCONF&utm_source=comparateur&utm_medium=web&utm_campaign=pdp-fiche
```
GA4 enregistre la source exacte de chaque conversion → on sait quel contenu convertit.

---

## 🛡️ PROTECTION JURIDIQUE — ZÉRO RESPONSABILITÉ

### Statut légal de la plateforme

NEXUS CONFORMITÉ est **éditeur d'un service d'information et de mise en relation**, jamais prestataire de services réglementaires. Ce statut est protégé par :

| Risque | Protection mise en place |
|---|---|
| **Responsabilité conseil** | Disclaimer sur CHAQUE page : *"Les informations publiées sur ce site ont un caractère informatif et général. Elles ne constituent pas un conseil juridique, fiscal ou comptable. Pour toute décision, consultez un professionnel qualifié."* |
| **Litige avec prestataire annuaire** | CGU annuaire : *"NEXUS CONFORMITÉ agit comme hébergeur de fiches de présentation. La plateforme ne peut être tenue responsable de la qualité des prestations des professionnels référencés. Tout litige est à régler directement avec le prestataire concerné."* |
| **Responsabilité affiliation** | *"Certains liens présents sur ce site sont des liens affiliés. NEXUS CONFORMITÉ n'est pas responsable des services proposés par les partenaires."* |
| **Contenus IA incorrects** | Validation humaine (Dow) avant publication + disclaimer "à titre informatif" |
| **Identité exposée** | Marque anonyme (NEXUS CONFORMITÉ), aucun nom de personne physique exposé publiquement |
| **Conformité ARPP** | Mention "#lien-affilié" ou "partenariat rémunéré" visible sur chaque recommandation rémunérée |
| **RGPD** | Double opt-in newsletter, politique confidentialité, Axeptio cookie banner, aucune revente de données |

### Modèle de clause anti-responsabilité annuaire (à insérer dans CGU)

> *"Les professionnels référencés dans l'annuaire NEXUS CONFORMITÉ sont des tiers indépendants. La plateforme procède à une vérification formelle de leur existence légale (SIRET) mais ne garantit pas la qualité, les tarifs, ni les résultats de leurs prestations. En cas de litige avec un prestataire, l'utilisateur doit s'adresser directement à ce dernier ou aux autorités compétentes. NEXUS CONFORMITÉ ne peut être désignée comme partie à un litige entre un utilisateur et un prestataire référencé."*

---

## 🤖 AUTOMATISATION COMPLÈTE — PIPELINE N8N (DÈS J1)

### Règle absolue : Si ça peut être automatisé, ça l'est dès maintenant

### A. Workflows N8N prioritaires (Épique 0 — J1-J14)

```
[WORKFLOW-01] BACKUP AUTOMATIQUE
Déclencheur: Cron hebdo dimanche 3h
→ Export JSON workflows N8N
→ Export WordPress (via WP-CLI ou plugin)
→ Upload Google Drive (dossier /NEXUS-BACKUPS/)
→ Notification Telegram "✅ Backup effectué"

[WORKFLOW-02] VEILLE LÉGISLATIVE PROACTIVE
Déclencheur: Cron quotidien 7h
→ Fetch RSS Journal Officiel (legifrance.gouv.fr)
→ Fetch RSS CNIL (cnil.fr/fr/flux-rss)
→ Fetch RSS ANSSI (ssi.gouv.fr/feed)
→ Fetch RSS EUR-Lex (nouveaux règlements UE)
→ Filtrer: mots-clés [facturation, NIS2, RGPD, comptabilité, conformité]
→ Si nouveau: résumé Claude Haiku API (max 150 tokens)
→ Envoi Telegram "🚨 Nouvelle réglementation détectée: [titre]"
→ Créer brouillon article WP pour validation

[WORKFLOW-03] NEWSLETTER HEBDOMADAIRE AUTO
Déclencheur: Cron lundi 6h (envoi mardi 8h)
→ Récupérer dernières actualités (Workflow-02 output)
→ Générer contenu newsletter via Claude Haiku API
→ Insérer liens affiliés UTM dans le contenu
→ Créer draft Beehiiv via API
→ Notification Telegram "📧 Draft newsletter prêt — valider avant lundi 22h"
→ [MANUEL] Dow valide et publie via app Beehiiv mobile

[WORKFLOW-04] ALERTES REVENUS TEMPS RÉEL
Déclencheur: Webhook Stripe (paiement reçu)
→ Notification Telegram immédiate: "💰 Nouveau paiement: [montant]€ — [source]"
→ Log dans Google Sheets (tableau revenus)
→ Mise à jour dashboard Looker Studio

[WORKFLOW-05] ONBOARDING PRESTATAIRE ANNUAIRE
Déclencheur: Webhook Stripe (abonnement annuaire activé)
→ Email confirmation automatique au prestataire
→ Création fiche annuaire en brouillon WP
→ Notification Telegram à Dow "🏢 Nouveau prestataire — valider fiche"
→ Si pas de validation dans 24h → relance email

[WORKFLOW-06] SUIVI LEADS ANNUAIRE (mise en relation)
Déclencheur: Formulaire "mise en relation" soumis
→ Email auto au prestataire concerné (lead qualifié)
→ Email confirmation à l'entreprise qui demande
→ Log dans Google Sheets (CRM minimal)
→ Relance auto si prestataire ne répond pas sous 48h

[WORKFLOW-07] LIVRAISON GUMROAD AUTOMATIQUE
Déclencheur: Webhook Gumroad (vente effectuée)
→ Email de livraison avec lien téléchargement
→ Email de suivi J+7 (feedback + upsell webinaire)
→ Log vente dans Google Sheets

[WORKFLOW-08] DASHBOARD HEBDO SYNTHÈSE
Déclencheur: Cron vendredi 18h
→ Agrège: revenus Stripe semaine + ventes Gumroad + stats Beehiiv
→ Génère rapport texte synthèse
→ Envoi Telegram: "📊 Bilan semaine S[n]: [total]€ — [nb] nouveaux abonnés"

[WORKFLOW-09] COLD EMAIL B2B (RGPD-compliant)
Déclencheur: Manuel par Dow (via interface N8N)
→ Source: liste CSV enrichie (SIRET + email contact pro)
→ Vérification opt-out avant envoi (liste noire interne)
→ Envoi via SMTP Brevo (max 300/j gratuit)
→ Tracking ouvertures via Brevo analytics
→ Si ouverture → tag "chaud" → séquence relance J+3
```

### B. Optimisation appels API Claude (anti-gaspillage)

```
RÈGLE 1 — Utiliser Haiku (pas Sonnet) pour 90% des tâches automatisées
  → Prix Haiku: 0.25$/M tokens | Sonnet: 3$/M tokens (x12 moins cher)
  → Haiku pour: résumés, emails, fiches PDP, social posts, cold emails
  → Sonnet uniquement pour: articles longs SEO (2000+ mots), contenu sensible

RÈGLE 2 — Batching hebdomadaire (pas daily)
  → Newsletter: 1 appel API/semaine, pas quotidien
  → Fiches PDP: batch de 10 à la fois, pas une par une
  → Résumés veille: regrouper en 1 prompt multi-sources

RÈGLE 3 — Cache local des résultats
  → Stocker les résumés veille dans Google Sheets
  → Réutiliser dans plusieurs canaux (newsletter + article + social)

RÈGLE 4 — Prompt engineering pour minimiser les tokens
  → Instructions concises, sortie structurée (JSON), pas de prose inutile
  → Max 500 tokens de réponse sauf articles longs
```

---

## 📱 MOBILE-FIRST — ACCÈS SMARTPHONE/TABLETTE

### Tout doit fonctionner depuis un téléphone

| Action | Outil mobile | Disponibilité |
|---|---|---|
| **Stats newsletter** | App Beehiiv iOS/Android | ✅ App native |
| **Revenus Stripe** | App Stripe Dashboard | ✅ App native |
| **Ventes Gumroad** | App Gumroad | ✅ App native |
| **Alertes revenus** | Telegram Bot (notifications) | ✅ Gratuit, push immédiat |
| **Dashboard global** | Google Looker Studio (web mobile) | ✅ Responsive |
| **Valider brouillons** | WordPress app mobile | ✅ App native |
| **Gérer workflows N8N** | Interface N8N web (responsive) | ✅ Accessible via HTTPS |
| **Annuaire leads** | Google Sheets app | ✅ App native |
| **Synthèse hebdo** | Telegram (reçu automatiquement) | ✅ Push notification |

### Architecture Telegram Bot (alertes mobiles)

```
Bot Telegram @NexusConformiteBot (privé, Dow uniquement)
Messages reçus automatiquement:
  💰 [VENTE] Pack Gumroad — 67€ — Source: newsletter_nis2_s14
  👤 [ABONNÉ] +1 newsletter — Total: 347 abonnés
  🏢 [ANNUAIRE] Nouveau prestataire — Valider fiche WP
  📰 [VEILLE] Nouvelle réglementation: [titre JO]
  📊 [HEBDO] Bilan S14: 1 847€ — +127 abonnés — 3 nouvelles fiches
  ⚠️ [ALERTE] Prestataire n'a pas répondu au lead depuis 48h
```

---

## 📧 ACQUISITION DATA — INDEXATION EMAILS B2B

### Sources légales pour constituer une base de prospects

| Source | Données disponibles | Coût | Légalité |
|---|---|---|---|
| **Infogreffe / Societe.com** | SIRET, raison sociale, dirigeant | Gratuit/limité | ✅ Données publiques |
| **LinkedIn Sales Navigator** | Email pro, poste, secteur | ~80€/mois | ✅ B2B opt-in |
| **Formulaire opt-in site** | Email qualifié + intention | 0€ | ✅ Meilleure source |
| **Beehiiv referral** | Email qualifié + réseau | 0€ | ✅ Via parrainage |
| **Annuaire pages jaunes** | Téléphone, parfois email | 0€ | ✅ Données pro publiques |
| **Salons/événements** | Carte de visite + email | Variable | ✅ Consentement explicite |

### Cold Email B2B — Cadre CNIL France

> En France, le cold email est **légal** en B2B si :
> 1. Le message est **pertinent par rapport à l'activité professionnelle** du destinataire
> 2. L'adresse email est **professionnelle** (pas d'email perso)
> 3. Un **lien de désinscription** est présent dans chaque email
> 4. L'expéditeur est **clairement identifiable**
> Source: CNIL, Délibération n°2013-420 et Lignes directrices ePrivacy

### Workflow N8N — Enrichissement base prospects

```
[WORKFLOW-COLD-EMAIL]
1. Importer CSV (SIRET + raison sociale + secteur)
2. Vérifier email contact via Hunter.io API (100 vérifications/mois gratuites)
3. Vérifier contre liste noire optout interne (Google Sheets)
4. Générer email personnalisé via Claude Haiku (60 tokens/email)
5. Envoi via Brevo SMTP (300/jour gratuit) avec tracking
6. Si ouverture → tag "intéressé" → relance J+3 (séquence 3 emails max)
7. Si désinscription → ajout liste noire automatique
```

---

## 🤝 SYSTÈME DE PARRAINAGE

### Mécanisme Beehiiv Referral (natif, 0€)

Beehiiv intègre nativement un système de parrainage depuis 2024 :

```
Chaque abonné reçoit son lien unique: newsletter.nexusconformite.fr?ref=ABC123
Si quelqu'un s'abonne via ce lien → parrain notifié et récompensé

Paliers de récompenses:
  1 parrainage → Accès 1 mois GRATUIT à la Veille Premium (valeur 19€)
  3 parrainages → Pack PDF Conformité offert (valeur 67€)
  5 parrainages → Fiche Annuaire 3 mois GRATUIT (valeur 147€ pour prestataires)
  10 parrainages → Accès VIP webinaire (valeur 97€)
```

### Tracking parrainage multi-canal

```
N8N surveille:
→ Nouveaux abonnés Beehiiv avec ref= → attribue récompense
→ Ventes Gumroad avec coupon code PARRAIN_[pseudo] → commission 10%
→ Tableau de bord Google Sheets : Top parrains, conversions, récompenses envoyées
```

---

## 📊 DASHBOARD SUIVI GAINS — INTERFACE COMPLÈTE

### Architecture Dashboard (0€)

```
Google Looker Studio (gratuit, web + mobile)
  ├── Connecteur GA4: trafic, conversions, sources
  ├── Connecteur Stripe (via Google Sheets intermédiaire N8N)
  │     └── CA total / MRR / new vs récurrent / churn
  ├── Connecteur Gumroad (via webhook N8N → Google Sheets)
  │     └── Ventes totales / produit le plus vendu
  └── Connecteur Beehiiv (via API N8N → Google Sheets)
        └── Abonnés total / taux ouverture / croissance semaine

Telegram Bot: alertes temps réel (voir section mobile)

Google Sheets "NEXUS-REVENUS.gsheet":
  Onglet 1: Revenus par angle (Stripe annuaire / Gumroad / Affiliation / Webinaire)
  Onglet 2: Abonnés newsletter (évolution semaine par semaine)
  Onglet 3: Leads annuaire (prestataires + entreprises)
  Onglet 4: Base cold email (prospects + statut)
  Onglet 5: Parrainages actifs
```

### Page de suivi interne (WordPress admin)

Une page WP privée (visible seulement connecté) embed le dashboard Looker Studio :
- Accès sur smartphone depuis n'importe où
- Iframe Looker Studio = données temps réel
- Protégée par mot de passe WP (admin only)

---

## 📐 ARCHITECTURE STACK — VERSION DÉFINITIVE

```
COUCHE SERVEUR (3,99€/mois — Hetzner CX11)
  ├── Ubuntu 22.04 LTS
  ├── Caddy (reverse proxy HTTPS automatique)
  ├── WordPress (nexusconformite.fr)
  ├── N8N self-hosted (:5678 → caddy proxy)
  └── fail2ban + SSH clé uniquement

COUCHE CONTENU
  ├── WordPress + Astra Theme (gratuit)
  ├── Rank Math SEO (gratuit)
  ├── Business Directory Plugin (99€ one-shot)
  └── Elementor Free (pages landing)

COUCHE MARKETING
  ├── Beehiiv (newsletter + parrainage)
  ├── Gumroad (produits numériques)
  ├── Systeme.io gratuit → 27€ (webinaire M3+)
  └── Brevo SMTP (cold email 300/j gratuit)

COUCHE MONÉTISATION
  ├── Stripe (annuaire abonnements + veille MRR)
  ├── Gumroad (ventes directes)
  └── PayPal (versements affiliés si SEPA indisponible)

COUCHE IA
  ├── Claude Haiku API (contenu auto → ~4-6€/mois)
  └── Claude Sonnet (articles premium uniquement)

COUCHE ANALYTICS
  ├── Google Analytics 4
  ├── Microsoft Clarity (heatmaps gratuit)
  └── Google Looker Studio (dashboard global)

COUCHE AUTOMATISATION (N8N)
  ├── Workflow-01: Backup auto
  ├── Workflow-02: Veille législative RSS
  ├── Workflow-03: Newsletter hebdo
  ├── Workflow-04: Alertes revenus (Telegram)
  ├── Workflow-05: Onboarding prestataires
  ├── Workflow-06: Suivi leads annuaire
  ├── Workflow-07: Livraison Gumroad
  ├── Workflow-08: Dashboard hebdo
  └── Workflow-09: Cold email B2B

COUCHE MOBILITÉ
  └── Telegram Bot (alertes push toutes actions)
      Apps: Stripe, Beehiiv, Gumroad, WP Admin
      Looker Studio (mobile web)
```

### Phase de lancement : D'ABORD EN LOCAL, ENSUITE VPS

```
PHASE 1 — LOCAL (Semaine 1)
  → Installer N8N en local (npx n8n)
  → Créer et tester TOUS les workflows en local
  → WordPress en local (LocalWP ou XAMPP)
  → Rédiger tous les contenus offline
  → Tester intégrations API (Beehiiv, Stripe sandbox, Gumroad test)

PHASE 2 — VPS (Semaine 2, quand tout est validé en local)
  → Déployer VPS Hetzner CX11
  → Migrer N8N (export JSON workflows → import)
  → Migrer WordPress (UpdraftPlus)
  → Basculer DNS nexusconformite.fr → VPS
  → Tests de smoke (1h de monitoring actif)
  → Mise en ligne officielle
```

---

## 🌍 ÉVOLUTIVITÉ — PROACTIVITÉ SUR LES NOUVELLES NORMES

### Sources officielles surveillées automatiquement (Workflow-02)

| Source | RSS / API | Mots-clés filtrés |
|---|---|---|
| Journal Officiel | legifrance.gouv.fr/rss | facturation, comptabilité, PME, RGPD |
| CNIL | cnil.fr/fr/flux-rss | données personnelles, mise en demeure |
| ANSSI | ssi.gouv.fr/feed | NIS2, cybersécurité, entreprises |
| EUR-Lex | eur-lex.europa.eu/RSSXML | règlement UE, directive |
| DGFIP Actualités | impots.gouv.fr (scraping) | facture électronique, PDP |
| DARES / INSEE | dares.travail-emploi.gouv.fr | normes sociales PME |

### Critères d'ajout d'un nouveau axe de revenu

Quand une nouvelle réglementation est détectée :
1. ✅ Concerne-t-elle les TPE/PME françaises ?
2. ✅ Y a-t-il un coût de conformité pour l'entreprise (→ marché d'outils) ?
3. ✅ Existe-t-il des prestataires à référencer ou des affiliés à activer ?
4. ✅ La niche est-elle peu adressée sur Google (vérif Search Console) ?
→ Si 3/4 OUI → lancer un nouveau module en 2 semaines

### Axes d'extension identifiés (M12-M24)

| Extension | Déclencheur | Revenu potentiel |
|---|---|---|
| **Accessibilité numérique RGAA** | Obligation sites PME 2027 | +1 000-3 000€/mois |
| **Bilan carbone obligatoire CSRD** | Directive UE 2026-2027 | +2 000-5 000€/mois |
| **IA Act UE** | Application progressive 2026 | +1 000-3 000€/mois |
| **Extension Belgique/Suisse** | Francophones mêmes enjeux | x1,3 sur tous les revenus |
| **Marketplace prestataires** | À M12 si annuaire >100 fiches | Commission sur mise en relation |

---

## 🗺️ ROADMAP — 6 ÉPIQUES + INFRASTRUCTURE

### ⚡ Épique 0 — Infrastructure & Légal (Semaines 1-2) 🔴 BLOQUANT

- [ ] **TASK-001** — Acheter nexusconformite.fr sur OVH (~7€/an)
  - ⚠️ Vérifier INPI avant achat (marque déposée ?)
- [ ] **TASK-002** — Installer N8N EN LOCAL (npx n8n) + tester workflows
- [ ] **TASK-003** — Installer WordPress EN LOCAL (LocalWP) + thème Astra
- [ ] **TASK-004** — Rédiger mentions légales + CGU + CGV + politique confidentialité
  - ⚠️ BLOQUANT : aucune collecte email avant cette étape
- [ ] **TASK-005** — Créer compte Stripe (mode test) + simuler paiements
- [ ] **TASK-006** — Ouvrir comptes : Beehiiv + Gumroad + Systeme.io (gratuit)
- [ ] **TASK-007** — Déployer VPS Hetzner CX11 (une fois local validé)
  - Sécurité : SSH clé uniquement, fail2ban, Caddy HTTPS auto
- [ ] **TASK-008** — Migrer WP + N8N sur VPS + basculer DNS nexusconformite.fr
- [ ] **TASK-009** — Installer Axeptio (cookie banner), GA4, Microsoft Clarity
- [ ] **TASK-010** — Configurer Telegram Bot alertes revenus
- [ ] **TASK-011** — Créer Google Sheets "NEXUS-REVENUS" + Looker Studio

### 📧 Épique 2 — Newsletter "Conformité PME" (Semaines 2-4) 🔴 P0

- [ ] **TASK-201** — Créer compte Beehiiv + configurer domaine d'envoi personnalisé
- [ ] **TASK-202** — Rédiger séquence de bienvenue 5 emails (J0, J2, J5, J10, J21)
  - J0 : Bienvenue + calendrier des deadlines 2026-2027 (PDF gratuit = lead magnet)
  - J2 : NIS2 — êtes-vous concerné ? (lien affilié outil diagnostic + affilié assureur cyber)
  - J5 : Facturation électronique — par où commencer (lien comparateur PDP)
  - J10 : RGPD 2026 — les nouvelles obligations (affilié Axeptio + DPO freelance annuaire)
  - J21 : Pack conformité complet — 67€ (lien Gumroad direct)
- [ ] **TASK-203** — Activer Beehiiv Referral Program + définir paliers récompenses
- [ ] **TASK-204** — Workflow N8N-03 : newsletter hebdo auto (Claude Haiku → Beehiiv API)
- [ ] **TASK-205** — Landing page opt-in + lead magnet "Calendrier Deadlines 2026-2027" PDF
- [ ] **TASK-206** — S'inscrire : Axonaut (40%), Pennylane, Axeptio, Tiime
- [ ] **TASK-207** — Page "Sponsoring" avec tarifs (500€/1000€/2000€ par placement)

### 📦 Épique 5 — Pack Gumroad (Semaines 2-4) 🔴 P0 — PREMIER REVENU

- [ ] **TASK-501** — Créer "Pack Conformité TPE/PME 2026" :
  - Checklist facturation électronique (20 points)
  - Guide NIS2 simplifié (15 pages)
  - Template politique RGPD adaptable (Word)
  - Calendrier deadlines 2026-2027 (PDF + Excel)
  - Comparatif top 10 PDPs par secteur (tableau)
- [ ] **TASK-502** — Design professionnel Canva (couverture + mise en page identité NEXUS)
- [ ] **TASK-503** — Publier sur Gumroad à 67€ (offre lancement) → 97€ (prix normal)
- [ ] **TASK-504** — Page de vente WP avec témoignages + FAQ + garantie satisfait
- [ ] **TASK-505** — Workflow N8N-07 : livraison auto + email suivi J+7 (feedback + upsell webinaire)

### 🔍 Épique 1 — Comparateur PDP (Semaines 3-6) 🟡 P1

- [ ] **TASK-101** — Lister 101 PDPs agréées DGFiP + créer fiche structurée 20 meilleures
- [ ] **TASK-102** — Installer Business Directory Plugin sur WP + configurer comparateur
  - Critères : tarif, secteurs, formats (Factur-X/UBL), intégrations ERP, taille entreprise
- [ ] **TASK-103** — Rédiger fiches 20 PDPs (Claude Haiku batch → validation Dow)
- [ ] **TASK-104** — Contacter 5 PDPs pour programme affiliation : Pennylane, Axonaut, Tiime, Sage
- [ ] **TASK-105** — Page quiz interactif "Quelle PDP pour mon secteur ?"
- [ ] **TASK-106** — 5 articles SEO longue traîne (Claude Sonnet → validation Dow)
  - Ex : "Meilleure plateforme facture électronique artisan bâtiment 2026"
- [ ] **TASK-107** — Formulaire "être rappelé par un expert PDP" (lead gen annuaire)

### 📋 Épique 3 — Annuaire Prestataires (Semaines 4-7) 🟡 P1

- [ ] **TASK-301** — Installer Business Directory Plugin (même plugin que comparateur)
- [ ] **TASK-302** — Catégories : Expert-comptable / RSSI freelance / Avocat RGPD / Intégrateur PDP / Formateur NIS2
- [ ] **TASK-303** — Rédiger CGU annuaire avec clause non-responsabilité prestataires
- [ ] **TASK-304** — Configurer Stripe abonnements : 49€/mois Standard / 149€/mois Premium
- [ ] **TASK-305** — Cold email 50 premiers prestataires (N8N-09) — offre 3 mois gratuits early adopters
- [ ] **TASK-306** — Page "Référencer mon cabinet" + formulaire inscription
- [ ] **TASK-307** — Workflow N8N-05 : onboarding prestataire automatisé
- [ ] **TASK-308** — Formulaire "Mise en relation" (TPE → Prestataire) → N8N-06

### 🎥 Épique 4 — Webinaire Evergreen (Semaines 5-8) 🟢 P2

- [ ] **TASK-401** — Script webinaire 45 min (Claude Sonnet → validation Dow)
- [ ] **TASK-402** — Enregistrement screen recording + voix (pas de caméra — anonymat)
- [ ] **TASK-403** — Configurer replay Systeme.io (activer plan 27€ uniquement à ce stade)
- [ ] **TASK-404** — Page de vente : 47€ basique / 97€ premium (+ pack PDF inclus)
- [ ] **TASK-405** — Workflow N8N-07 étendu : post-achat webinaire → email accès + upsell
- [ ] **TASK-406** — Promo mensuelle auto dans newsletter

### 🔔 Épique 6 — Veille MRR Freemium (Semaines 7-10) 🟢 P2

- [ ] **TASK-601** — Segment "Alertes" Beehiiv (liste séparée gratuit vs premium)
- [ ] **TASK-602** — Workflow N8N-02 étendu : sources officielles → résumé Haiku → envoi auto
- [ ] **TASK-603** — Page inscription freemium + page upgrade payant (Stripe)
- [ ] **TASK-604** — Stripe : 9€/mois Standard / 19€/mois Premium
- [ ] **TASK-605** — Fiche action mensuelle : Claude Haiku → PDF → envoi abonnés premium
- [ ] **TASK-606** — Dashboard MRR : Stripe + Google Sheets + Looker Studio

---

## 💰 Projections Financières

| Période | Comparateur PDP | Newsletter | Annuaire | Webinaire | Gumroad | Veille MRR | TOTAL |
|---|---|---|---|---|---|---|---|
| **M1-2** | 0€ | 0-100€ | 0€ | 0€ | 100-300€ | 0€ | **100-400€** |
| **M3** | 200-500€ | 300-700€ | 200-500€ | 200-400€ | 300-600€ | 100€ | **1 300-2 800€** |
| **M6** | 800-1 500€ | 1 000-2 500€ | 800-2 000€ | 500-1 000€ | 500-1 000€ | 500€ | **4 100-8 500€** |
| **M9** | 1 500-3 000€ | 2 000-4 000€ | 1 500-4 000€ | 800-1 500€ | 600-1 200€ | 1 500€ | **7 900-15 200€** |
| **M12** | 2 500-5 000€ | 3 000-6 000€ | 2 000-6 000€ | 1 000-2 000€ | 800-1 500€ | 3 000€ | **12 300-23 500€** |

**Seuil rentabilité :** ~400-600€/mois → atteint dès M2-3 (Pack Gumroad + premiers affiliés)

---

## 📊 Tracking & Analytics

| Signal | Outil | Objectif |
|---|---|---|
| Trafic organique | Google Search Console | Mots-clés qui convertissent |
| Comportement | Microsoft Clarity | Où les visiteurs décrochent |
| Conversion affiliés | UTM unique par lien | Quel contenu génère des ventes |
| Email performance | Beehiiv analytics | Sujets qui engagent + taux clic |
| Ventes produits | Gumroad + Stripe | CA par source |
| MRR veille | Stripe + Google Sheets | Courbe abonnés + churn |
| Leads annuaire | N8N → Google Sheets | Qualité et volume leads |
| Parrainages | Beehiiv Referral + N8N | Top parrains + conversions |
| Dashboard global | Google Looker Studio | Vue unifiée mobile-friendly |
| Alertes temps réel | Telegram Bot | Push sur chaque événement |

---

## 📌 Décisions Stratégiques

| Décision | Alternative écartée | Raison |
|---|---|---|
| WordPress vs Webflow | Webflow | Flexibilité plugins + plugins gratuits |
| Beehiiv vs Mailchimp | Mailchimp | Monétisation native + referral natif |
| Stripe vs PayPal | PayPal pour revenus directs | Stripe moins risque gel compte |
| Systeme.io gratuit vs 27€ | 27€ dès J1 | Activer seulement quand webinaire prêt |
| Hetzner CX11 vs Oracle Free | Oracle Free Tier | Hetzner plus stable + support + SLA |
| Haiku vs Sonnet API | Sonnet partout | Haiku x12 moins cher — suffisant 90% cas |
| Local d'abord vs VPS direct | VPS direct | Évite erreurs de config en prod |
| Nom propre vs micro-ent | Micro dès J1 | Test avant structure légale |
| Cold email vs SEO pur | SEO uniquement | Cold email = revenu M1, SEO = M3+ |
| Business Dir. Plugin ($99) vs Directories Pro | Directories Pro mensuel | One-shot moins cher long terme |

---

## ✅ SESSION LOG — Historique des sessions

### Session #1 — 27-28 Mars 2026
**Fait :**
- Étude de marché complète (6 angles validés)
- Architecture business définie (stack + coûts)
- Projections financières établies (M1 → M12)
- Noms de domaine vérifiés (nexusconformite.fr LIBRE)
- PROJECT.md v1 + v2 créés
- Rapport Word NEXUS-session-report.docx généré (20KB)
- Deck slides NEXUS-session-slides.pptx généré (431KB, 10 slides, QA PASS)

**Décisions prises :**
- Modèle intermédiaire pur (0 responsabilité conseil)
- 6 angles de revenu complémentaires
- Stack N8N + WP + Beehiiv + Gumroad + Stripe
- Budget optimisé : 12-15€/mois démarrage → 40-45€ maturité
- Claude Haiku pour 90% des appels API
- Lancement local d'abord, VPS ensuite
- Mobile-first via Telegram Bot + apps natives

**Prochaine session — priorité absolue :**
- Épique 0 TASK-001 : Acheter nexusconformite.fr sur OVH
- Épique 0 TASK-002 : Installer N8N en local + tester workflows 01 à 09
- Épique 5 TASK-501 : Créer contenu Pack Gumroad (1er revenu potentiel J+14)

---

*NEXUS CONFORMITÉ — PROJECT.md v2 — 28 Mars 2026*
*"On n'automatise pas plus tard. On automatise maintenant."*
