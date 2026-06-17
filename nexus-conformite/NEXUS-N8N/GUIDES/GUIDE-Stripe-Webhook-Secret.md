# Guide Stripe Webhook Secret - Configuration Pas à Pas

## Objectif
Configurer le webhook Stripe pour que les événements de paiement (souscriptions, paiements) soient automatiquement transmis à N8N (WF-04).

**Prérequis :**
- Compte Stripe actif avec credentials API
- Accès au tableau de bord Stripe
- Accès à N8N (adresse IP publique connue)

---

## Étape 1 : Accéder au Tableau de Bord Stripe

1. Ouvrir votre navigateur et aller à **https://dashboard.stripe.com**
2. Se connecter avec vos identifiants Stripe (email + mot de passe)
3. Vous devriez voir le tableau de bord principal avec les statistiques de paiement

![Capture : Vue d'accueil tableau de bord Stripe avec menu à gauche]

---

## Étape 2 : Naviguer vers les Webhooks

1. Dans le menu de gauche, cliquer sur **Développeurs** (ou "Developers")
2. Un sous-menu doit s'afficher :
   - Clés API
   - Webhooks
   - Événements
   - Journaux

3. Cliquer sur **Webhooks**

![Capture : Menu Développeurs Stripe déroulé, option Webhooks visible]

---

## Étape 3 : Créer un Nouveau Webhook

1. Vous êtes maintenant sur la page **Webhooks**
2. Cliquer sur le bouton **Ajouter un endpoint** (ou "+ Add an endpoint")
3. Une boîte de dialogue s'affiche avec le champ **URL de l'endpoint**

---

## Étape 4 : Configurer l'URL du Webhook

### Pour développement (test local) :
```
http://[IP_PUBLIQUE_VPS]:5678/webhook/stripe-webhook
```

### Pour production (VPS OVH final) :
```
http://nexusconformite.fr:5678/webhook/stripe-webhook
```
ou
```
https://nexusconformite.fr/webhook/stripe-webhook
```

**Note importante :** Remplacer `[IP_PUBLIQUE_VPS]` par :
- L'adresse IP publique attribuée par OVH lors du déploiement VPS
- Ou le domaine `nexusconformite.fr` une fois configuré

![Capture : Champ URL endpoint avec exemple d'adresse IP]

---

## Étape 5 : Sélectionner les Événements à Transmettre

Après avoir saisi l'URL, vous devez sélectionner **les événements à monitorer**.

**Événements critiques à sélectionner :**

1. **customer.subscription.created**
   - Déclenché quand un client crée un nouvel abonnement
   - Utilisé par WF-05 pour créer l'utilisateur dans WordPress

2. **payment_intent.succeeded**
   - Déclenché quand un paiement réussit
   - Utilisé par WF-07 pour livrer les produits Gumroad

3. **charge.refunded**
   - Déclenché quand une charge est remboursée
   - Utilisé pour tracer les remboursements

**Étapes :**
- Cocher la case **Sélectionner les événements**
- Chercher et cocher : `customer.subscription.created`
- Chercher et cocher : `payment_intent.succeeded`
- Chercher et cocher : `charge.refunded`

![Capture : Liste des événements avec checkboxes, 3 cochées]

---

## Étape 6 : Créer et Récupérer le Signing Secret

1. Cliquer sur **Créer un endpoint** (ou "Create endpoint")
2. L'endpoint est maintenant créé et affiché dans la liste
3. Cliquer sur l'endpoint pour voir ses détails
4. **Sélectionner et copier le Signing Secret** (commence par `whsec_`)

Exemple :
```
whsec_test_00000000000000000000000000000000
```

![Capture : Détails du webhook avec le Signing Secret surligné et bouton Copier]

---

## Étape 7 : Configurer dans N8N (.env)

1. Accéder au fichier `.env` de N8N situé à :
   ```
   /path/to/NEXUS-N8N/.env
   ```

2. Ajouter ou mettre à jour la variable :
   ```env
   STRIPE_WEBHOOK_SECRET=whsec_test_00000000000000000000000000000000
   ```

3. **Sauvegarder le fichier**

4. **Redémarrer N8N** pour charger la nouvelle configuration :
   ```bash
   npm run start
   # ou avec Docker :
   docker restart n8n
   ```

---

## Étape 8 : Tester le Webhook dans N8N

### Test manuel dans Stripe :

1. Retourner à **Développeurs > Webhooks** dans Stripe
2. Cliquer sur votre endpoint
3. Scroller jusqu'à la section **Événements de test**
4. Cliquer sur **Envoyer un événement de test**
5. Sélectionner `payment_intent.succeeded`
6. Cliquer **Envoyer l'événement**

Stripe doit afficher : ✅ **Livré avec succès** (200 OK)

![Capture : Événement de test envoyé avec statut 200]

### Test dans N8N :

1. Ouvrir le workflow **WF-04** (ou le workflow qui contient le webhook Stripe)
2. Vérifier que la section "Webhook Stripe" affiche :
   - ✅ Webhook en écoute
   - ✅ Secret webhook validé

3. Dans Stripe, envoyer un événement de test
4. Le workflow doit se déclencher automatiquement
5. Vérifier les logs dans N8N pour confirmer la réception

---

## Étape 9 : Vérifier la Sécurité

Le Signing Secret permet à N8N de **vérifier que les événements viennent vraiment de Stripe** et non d'une source malveillante.

N8N effectue automatiquement :
- ✅ Validation de la signature de chaque événement reçu
- ✅ Rejet des événements non authentifiés
- ✅ Journalisation des tentatives suspectes

---

## Troubleshooting

### Erreur : "Webhook URL returned a non-200 status code"

**Cause probable :** N8N n'est pas accessible à l'adresse spécifiée.

**Solution :**
1. Vérifier que N8N s'exécute sur le port 5678
2. Vérifier l'IP publique du VPS (ne pas utiliser `localhost`)
3. Vérifier les règles de firewall OVH (port 5678 doit être ouvert)

### Erreur : "Invalid signing secret"

**Cause probable :** Le secret dans `.env` ne correspond pas au secret Stripe.

**Solution :**
1. Copier le secret exact depuis le tableau de bord Stripe
2. Vérifier qu'il commence bien par `whsec_`
3. Redémarrer N8N après modification

### Webhook ne se déclenche pas

**Cause probable :** Les événements ne sont pas sélectionnés ou N8N n'écoute pas.

**Solution :**
1. Vérifier que les événements souhaités sont cochés dans Stripe
2. Tester avec "Envoyer un événement de test" dans Stripe
3. Vérifier les logs N8N : `npm run logs` ou interface UI

---

## Résumé des configurations

| Paramètre | Valeur |
|-----------|--------|
| **URL Endpoint** | `http://[IP_PUBLIQUE]:5678/webhook/stripe-webhook` |
| **Événements** | `customer.subscription.created`, `payment_intent.succeeded`, `charge.refunded` |
| **Secret Variable** | `STRIPE_WEBHOOK_SECRET` |
| **Fichier .env** | `/NEXUS-N8N/.env` |
| **Port N8N** | `5678` |

---

## Prochaines étapes

Une fois le webhook configuré et testé :

1. ✅ Workflow **WF-04** prêt à recevoir les événements Stripe
2. ✅ Workflow **WF-05** peut créer des utilisateurs WordPress automatiquement
3. ✅ Workflow **WF-07** peut livrer les produits Gumroad

**Les paiements et abonnements sont maintenant automatisés !**

---

*Dernière mise à jour : 2026-03-30*