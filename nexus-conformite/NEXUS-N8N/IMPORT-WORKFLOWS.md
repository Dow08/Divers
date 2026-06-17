# NEXUS CONFORMITÉ — Guide d'import des workflows N8N

## Prérequis

1. **Lancer N8N** : Double-cliquer sur `start-n8n.bat`
2. **Ouvrir** Chrome → http://localhost:5678
3. **Se connecter** : nexus / NexusConf2026!

---

## Étape 1 — Configurer les credentials

Avant d'importer les workflows, créer tous les credentials dans :
**N8N → Settings (icône engrenage) → Credentials → + Add Credential**

Consulter `config/credentials-template.json` pour les détails de chaque credential.

**Ordre recommandé :**
1. Claude API NEXUS (Anthropic)
2. NEXUS Bot Telegram
3. Google Sheets NEXUS (OAuth2)
4. Google Drive NEXUS (OAuth2)
5. WordPress API NEXUS
6. Beehiiv API NEXUS
7. Brevo SMTP NEXUS
8. N8N API Key

---

## Étape 2 — Importer les workflows

Dans N8N, pour chaque fichier JSON du dossier `workflows/` :

1. Menu principal → **Workflows** → bouton **+** → **Import from file**
2. Sélectionner le fichier JSON
3. Cliquer **Import**
4. Assigner les credentials aux nœuds (ils apparaissent en rouge si manquants)
5. Sauvegarder (CTRL+S)

**Ordre d'import recommandé :**
| Fichier | Workflow | Priorité |
|---|---|---|
| WF-04-alertes-revenus.json | Alertes Stripe → Telegram | 🔴 1er |
| WF-07-livraison-gumroad.json | Livraison automatique | 🔴 2ème |
| WF-05-onboarding-annuaire.json | Onboarding prestataires | 🔴 3ème |
| WF-06-leads-annuaire.json | Gestion leads | 🟡 4ème |
| WF-02-veille-legislative.json | Veille RSS quotidienne | 🟡 5ème |
| WF-03-newsletter-hebdo.json | Newsletter auto | 🟡 6ème |
| WF-08-dashboard-hebdo.json | Bilan hebdo | 🟢 7ème |
| WF-01-backup-auto.json | Backup hebdo | 🟢 8ème |
| WF-09-cold-email-b2b.json | Cold email B2B | 🟢 9ème (last) |

---

## Étape 3 — Configurer les webhooks

Après import, noter les URLs des webhooks pour chaque workflow :

- **WF-04** : `http://localhost:5678/webhook/stripe-webhook` → à déclarer dans Stripe Dashboard
- **WF-05** : `http://localhost:5678/webhook/stripe-subscription-new` → idem (événement: subscription.created)
- **WF-06** : `http://localhost:5678/webhook/lead-annuaire` → à connecter au formulaire WordPress
- **WF-07** : `http://localhost:5678/webhook/gumroad-webhook` → à déclarer dans Gumroad Settings

En production (VPS), remplacer `localhost:5678` par `https://nexusconformite.fr:5678` ou l'URL N8N configurée.

---

## Étape 4 — Activer les workflows

Une fois les credentials assignés et les webhooks configurés :

1. Ouvrir chaque workflow
2. Cliquer le **toggle Inactive → Active** en haut à droite
3. Vérifier avec un test manuel (bouton ▶️ sur le nœud déclencheur)

---

## Créer le Google Sheet NEXUS-REVENUS

1. Aller sur sheets.google.com → Nouveau classeur → Nommer "NEXUS-REVENUS"
2. Créer les onglets suivants avec les colonnes exactes :

**Onglet "Revenus"** : date | montant | source | type | stripe_id
**Onglet "Ventes"** : saleId | date | email | nom | produit | montant | statut_suivi
**Onglet "Leads"** : leadId | date | entreprise | contact | email | secteur | besoin | prestataire | statut
**Onglet "Prospects"** : email | prenom | nom | entreprise | secteur | statut | date_contact | sequence | optout
**Onglet "Veille"** : date | source | titre | url | resume | publie

3. Copier l'ID du sheet depuis l'URL (entre `/d/` et `/edit`) → mettre dans les credentials.

---

*NEXUS CONFORMITÉ — 9 workflows prêts à l'emploi — Session #1*
