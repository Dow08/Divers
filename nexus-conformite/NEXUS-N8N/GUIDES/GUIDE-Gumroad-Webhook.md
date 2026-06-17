# Guide Gumroad Webhook - Configuration Pas à Pas

## Objectif
Configurer le webhook Gumroad pour que les événements de vente (commandes réussies, licences générées) soient automatiquement transmis à N8N (WF-07).

**Prérequis :**
- Compte Gumroad actif (créateur/vendeur)
- Accès à l'interface Gumroad
- Accès à N8N (adresse IP publique connue)
- Produits digitaux créés sur Gumroad

---

## Étape 1 : Se Connecter à Gumroad

1. Ouvrir **https://app.gumroad.com**
2. Se connecter avec email + mot de passe
3. Accueil Gumroad avec votre tableau de bord

![Capture : Tableau de bord Gumroad avec liste des produits]

---

## Étape 2 : Accéder aux Paramètres

1. Dans le coin **supérieur droit**, cliquer sur votre **avatar/profil**
2. Un menu déroulant apparaît
3. Cliquer sur **Settings** (ou "Paramètres")

![Capture : Menu profil Gumroad déroulé]

---

## Étape 3 : Naviguer vers la Section Webhooks

1. Vous êtes maintenant dans les paramètres de compte
2. Dans le menu latéral gauche, chercher et cliquer sur **Advanced** (ou "Avancé")
3. Scroller jusqu'à trouver la section **Webhooks**

![Capture : Menu latéral Settings avec option Advanced mise en évidence]

---

## Étape 4 : Ajouter une URL de Webhook

### Localiser la section Webhooks

Une fois dans **Advanced** :
- Vous verrez un champ texte **Webhook URL** (ou "URL du webhook")
- Un bouton **Save** ou **Add Webhook**

### Ajouter l'URL du Webhook

**Pour développement (test local) :**
```
http://[IP_PUBLIQUE_VPS]:5678/webhook/gumroad-webhook
```

**Pour production (VPS OVH final) :**
```
http://nexusconformite.fr:5678/webhook/gumroad-webhook
```
ou
```
https://nexusconformite.fr/webhook/gumroad-webhook
```

**Note importante :** Remplacer `[IP_PUBLIQUE_VPS]` par l'adresse IP publique OVH ou le domaine final.

![Capture : Champ URL du webhook Gumroad rempli avec adresse IP]

---

## Étape 5 : Récupérer le Webhook Secret

Gumroad affiche le **Webhook Secret** après que vous ayez ajouté l'URL.

**Important :** Gumroad envoie le secret dans les en-têtes HTTP de chaque requête webhook sous la clé `X-Gumroad-Signature`.

**Étapes pour récupérer le secret :**

1. Après avoir saisi l'URL du webhook, Gumroad génère automatiquement un secret
2. **Copier le secret affiché à l'écran**
3. Il sera utilisé pour valider les webhooks côté N8N

Exemple de secret Gumroad :
```
gumroad_secret_abc123def456ghi789jkl012
```

![Capture : Webhook Secret affiché et bouton Copier/Afficher]

---

## Étape 6 : Configurer dans N8N (.env)

1. Accéder au fichier `.env` de N8N :
   ```
   /path/to/NEXUS-N8N/.env
   ```

2. Ajouter ou mettre à jour la variable :
   ```env
   GUMROAD_WEBHOOK_SECRET=gumroad_secret_abc123def456ghi789jkl012
   ```

3. **Sauvegarder le fichier**

4. **Redémarrer N8N** :
   ```bash
   npm run start
   # ou avec Docker :
   docker restart n8n
   ```

---

## Étape 7 : Configurer les Événements Webhook dans N8N

Le webhook Gumroad transmet automatiquement **tous les événements de vente**.

Les événements clés reçus :

| Événement | Description |
|-----------|-------------|
| `sale.completed` | Une commande a été réalisée avec succès |
| `subscription.updated` | Un abonnement a été mis à jour |
| `refund.created` | Un remboursement a été émis |
| `license.created` | Une nouvelle licence a été générée (pour produits avec licence) |

**N8N doit être configuré pour :**
- ✅ Recevoir les données de vente (client, produit, montant)
- ✅ Récupérer le lien de téléchargement du produit
- ✅ Envoyer l'email de livraison (WF-07)
- ✅ Enregistrer la transaction dans la base de données

---

## Étape 8 : Tester avec une Vente Test Gumroad

### Option A : Créer une Vente Test

1. Retourner à votre profil Gumroad
2. Aller dans **Products** (Produits)
3. Sélectionner un produit de test
4. Vous pouvez tester un achat en utilisant une **carte de crédit test Stripe** :
   - Numéro : `4242 4242 4242 4242`
   - Expiration : `12/30`
   - CVC : `123`

5. Effectuer l'achat via la page produit Gumroad
6. Vérifier que N8N reçoit le webhook

### Option B : Simuler un Webhook Manuellement

Si Gumroad offre une interface de test (webhook replay) :

1. Aller dans **Settings > Advanced > Webhooks**
2. Chercher un bouton **Test** ou **Send Test Webhook**
3. Sélectionner un événement de test
4. Vérifier la réception dans N8N

---

## Étape 9 : Vérifier la Réception dans N8N

### Test du workflow WF-07 :

1. Ouvrir le workflow **WF-07** (Livraison Gumroad)
2. Vérifier que le nœud "Webhook Gumroad" affiche :
   - ✅ Webhook en écoute
   - ✅ Secret webhook validé

3. Effectuer une vente test Gumroad (voir Étape 8)
4. Le workflow doit se déclencher automatiquement
5. Vérifier :
   - ✅ Les données de vente reçues
   - ✅ L'email de livraison envoyé
   - ✅ Aucune erreur dans les logs

### Vérifier les logs N8N :

```bash
npm run logs
```

Vous devriez voir :
```
[WF-07] Webhook Gumroad reçu ✓
[WF-07] Données vente : {client, produit, montant}
[WF-07] Email livraison envoyé à [client@example.com]
```

---

## Étape 10 : Validation de Sécurité

Gumroad envoie une **signature** dans les en-têtes HTTP pour valider l'authenticité des webhooks.

**Validation automatique par N8N :**
- ✅ Vérification de la signature `X-Gumroad-Signature`
- ✅ Comparaison avec le secret stocké dans `.env`
- ✅ Rejet des requêtes non authentifiées
- ✅ Journalisation des tentatives suspectes

---

## Configuration N8N - Nœud Webhook Gumroad

Pour que WF-07 traite correctement les données Gumroad, le nœud doit :

```
Node : Webhook Gumroad
├─ Méthode : POST
├─ Path : /webhook/gumroad-webhook
├─ Authentification : Secret (GUMROAD_WEBHOOK_SECRET)
├─ Données extraites :
│  ├─ license_key (clé de licence, si applicable)
│  ├─ email (email acheteur)
│  ├─ product_id (ID produit Gumroad)
│  ├─ product_name (nom du produit)
│  ├─ price (montant payé)
│  └─ download_url (URL de téléchargement)
```

Les données sont ensuite transmises à :
1. **Node Email** → Envoi du kit via Brevo
2. **Node Database** → Enregistrement de la transaction
3. **Node Delay** → Attendre 7 jours
4. **Node Email Suivi** → Envoi email suivi J+7

---

## Troubleshooting

### Erreur : "Webhook URL not valid"

**Cause :** L'URL n'est pas accessible depuis Gumroad.

**Solution :**
1. Vérifier que N8N s'exécute sur le port 5678
2. Vérifier l'IP publique du VPS (pas `localhost`)
3. Tester l'accessibilité : `curl http://[IP]:5678/webhook/gumroad-webhook`

### Webhooks ne sont pas reçus

**Cause :** URL non valide, secret incorrect, ou N8N arrêté.

**Solution :**
1. Vérifier que N8N est en cours d'exécution
2. Vérifier le secret dans `.env`
3. Redémarrer N8N : `npm run start`
4. Effectuer une nouvelle vente test

### Email de livraison ne s'envoie pas

**Cause :** Brevo non configuré ou données manquantes.

**Solution :**
1. Vérifier que **BREVO_API_KEY** est dans `.env`
2. Vérifier que l'email du client est bien extrait du webhook
3. Vérifier les logs : `npm run logs | grep WF-07`

---

## Résumé des Configurations

| Paramètre | Valeur |
|-----------|--------|
| **URL Webhook** | `http://[IP_PUBLIQUE]:5678/webhook/gumroad-webhook` |
| **Secret Variable** | `GUMROAD_WEBHOOK_SECRET` |
| **Fichier .env** | `/NEXUS-N8N/.env` |
| **Port N8N** | `5678` |
| **Workflow** | `WF-07` (Livraison Gumroad) |

---

## Prochaines Étapes

Une fois le webhook Gumroad configuré et testé :

1. ✅ WF-07 reçoit automatiquement les ventes Gumroad
2. ✅ Clients reçoivent l'email de livraison immédiatement
3. ✅ Suite d'emails automatiques : suivi J+7, etc.
4. ✅ Toutes les ventes sont enregistrées en base de données

**La livraison de produits Gumroad est maintenant entièrement automatisée !**

---

*Dernière mise à jour : 2026-03-30*