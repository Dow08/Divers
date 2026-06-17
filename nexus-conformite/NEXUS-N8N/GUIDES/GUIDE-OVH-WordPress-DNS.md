# Guide Complet OVH - Domaine, Hébergement & WordPress

## Objectif
Mettre en place une infrastructure complète pour NEXUS CONFORMITÉ :
- Enregistrement du domaine `nexusconformite.fr`
- Hébergement WordPress
- Configuration DNS
- Configuration WordPress + connexion N8N

**Coût estimé : ~8€/mois (4€ domaine + 4€ hébergement)**

---

## PARTIE 1 : Domaine OVH

### Étape 1.1 : Accéder OVH Domaines

1. Ouvrir **https://www.ovh.com/fr/domaines/**
2. Se connecter avec identifiants OVH (ou créer compte)
3. Vous êtes sur la page d'accueil des domaines

![Capture : Page d'accueil OVH domaines avec barre de recherche]

### Étape 1.2 : Rechercher le Domaine

1. Dans la **barre de recherche**, taper : `nexusconformite.fr`
2. Cliquer sur **Rechercher** ou appuyer sur Entrée
3. OVH affiche les résultats :
   - `nexusconformite.fr` → **DISPONIBLE** ✅ (~4,99€/an)
   - Variantes avec extensions différentes (.com, .eu, etc.)

![Capture : Résultat recherche nexusconformite.fr - Disponible]

### Étape 1.3 : Configurer l'Offre

1. Cliquer sur **nexusconformite.fr** → le sélectionner
2. Choisir la **durée** :
   - 1 an = ~4,99€ ✅ **Recommandé** pour débuter
   - 3 ans ou plus = tarifs réduits si engagement long terme

3. **Options supplémentaires** (cochez selon besoins) :
   - ✅ **Protection de la vie privée WHOIS** (~0,99€/an) - Recommandé
   - Authentification forte DNSSEC (optionnel)

4. Cliquer **Ajouter au panier**

![Capture : Configuration domaine avec durée et options]

### Étape 1.4 : Passer la Commande

1. Aller au **panier** (en haut à droite)
2. Vérifier les articles :
   - Domaine `nexusconformite.fr` (1 an)
   - Protection WHOIS (optionnel)
   - **Total estimé : 4,99€ - 6€**

3. Cliquer **Procéder à la commande** ou **Commander**
4. Saisir les **coordonnées** du propriétaire domaine :
   - Prénom, Nom
   - Email (important !)
   - Adresse complète
   - Téléphone

5. **Accepter les conditions** d'enregistrement
6. **Paiement** : Carte bancaire
7. **Confirmation** : Email reçu avec détails du domaine

### Étape 1.5 : Récupérer les Nameservers

Après confirmation :

1. Aller sur https://www.ovh.com/fr/cgi-bin/order/renew.cgi ou **Mon compte OVH**
2. Chercher les **domaines enregistrés**
3. Cliquer sur **nexusconformite.fr**
4. Dans les détails, noter les **nameservers (serveurs de noms)** :
   ```
   ns1.ovh.net
   ns2.ovh.net
   ns3.ovh.net
   ```

**Ces serveurs seront utilisés dans la configuration DNS.**

---

## PARTIE 2 : Hébergement WordPress

### Option A : OVH Hébergement Perso (RECOMMANDÉ)

**Avantages :**
- Gestion centralisée (domaine + hébergement chez OVH)
- Installatif WordPress 1-clic
- Support en français
- Prix : ~4€/mois (~1,99€ promo première année)

#### Étape 2.1 : Souscrire à l'Hébergement OVH

1. Aller à **https://www.ovh.com/fr/hebergement/hebergement-web/**
2. Chercher l'offre **Hébergement Perso** ou **Hébergement Web Perso**
3. Cliquer **Commander** ou **Ajouter au panier**
4. Dans le panier, **lier le domaine** `nexusconformite.fr`
5. **Durée** : 12 mois recommandé
6. **Paiement** : Finalisez comme pour le domaine

#### Étape 2.2 : Passer à Option B si déjà établi

Si vous préférez un hébergement externe (exemple : **WPSandbox**, **Infomaniak**) :

### Option B : WPSandbox (Alternatif)

- **URL :** https://wpsandbox.fr/
- **Prix :** ~3€/mois (très économique)
- **Avantages :** WordPress pré-installé, support chat
- **Configuration :** Plus simple, interface française

### Option C : Infomaniak (Alternatif Premium)

- **URL :** https://www.infomaniak.com/hebergement-web
- **Prix :** ~3-5€/mois
- **Avantages :** Support premium, backups quotidiens
- **Configuration :** Excellente, suisse

---

## PARTIE 3 : Configuration DNS & SSL

### Étape 3.1 : Pointer le Domaine vers l'Hébergement

**Si hébergement OVH :**
- Les nameservers sont déjà configurés automatiquement
- Aller à **Mon compte OVH > Domaines > nexusconformite.fr**
- Vérifier que les serveurs DNS pointent vers l'hébergement OVH ✅

**Si hébergement externe :**

1. Aller dans l'interface de gestion du domaine OVH
2. Chercher **Serveurs DNS** ou **Nameservers**
3. Remplacer les nameservers OVH par ceux fournis par l'hébergeur :
   - Exemple Infomaniak :
     ```
     ns1.infomaniak.com
     ns2.infomaniak.com
     ```
4. **Sauvegarder**
5. **Attendre 24-48h** pour la propagation DNS

![Capture : Configuration serveurs DNS OVH]

### Étape 3.2 : Activer le Certificat SSL

**Sur OVH :**

1. Aller à **Mon compte OVH > Hebergement > nexusconformite.fr**
2. Chercher la section **SSL/TLS**
3. Cliquer **Activer SSL Let's Encrypt** (gratuit) ✅
4. **Attendre 15-30 min** pour l'activation
5. Vérifier que le certificat est **Actif** ✅

**Résultat :**
```
✅ https://nexusconformite.fr (sécurisé)
```

![Capture : Certificat SSL actif avec cadenas HTTPS]

### Étape 3.3 : Vérifier HTTPS

1. Ouvrir **https://nexusconformite.fr**
2. Vous devez voir un **cadenas vert** 🔒
3. Cliquer sur le cadenas → vérifier le certificat Let's Encrypt

Si erreur :
- Attendre 24h (propagation DNS)
- Vider le cache du navigateur

---

## PARTIE 4 : Installation et Configuration WordPress

### Étape 4.1 : Installer WordPress

**Sur OVH (installation 1-clic) :**

1. Aller à **Mon compte OVH > Hebergement > nexusconformite.fr**
2. Chercher **WordPress** ou **Installation facile** / **Modules**
3. Cliquer **Installer** ou **+ Ajouter un module**
4. Suivre l'assistant :
   - Domaine cible : `nexusconformite.fr`
   - Nom du blog : "NEXUS CONFORMITÉ"
   - Email admin : `admin@nexusconformite.fr`
   - Mot de passe admin : **Générer un mot de passe fort** 🔐
   - Langue : Français

5. **Installer**
6. **Email de confirmation** reçu avec identifiants

![Capture : Assistant installation WordPress 1-clic OVH]

### Étape 4.2 : Accéder à l'Administración WordPress

1. Aller à **https://nexusconformite.fr/wp-admin/**
2. Email : identifiant OVH + email configuré
3. Mot de passe : fourni à l'installation
4. **Se connecter** ✅

Vous êtes maintenant dans le **tableau de bord WordPress**.

![Capture : Tableau de bord WordPress avec menu latéral]

### Étape 4.3 : Créer un Mot de Passe d'Application

**Objectif :** Générer un mot de passe spécifique pour N8N (pour ne pas exposer le mot de passe administrateur).

**Étapes :**

1. Aller à **Utilisateurs** (en bas du menu latéral)
2. Cliquer sur votre **profil utilisateur** (ou "Votre profil")
3. Scroller jusqu'à **Mots de passe d'application** (en bas de la page)
4. Cliquer **Ajouter un nouveau mot de passe d'application**
5. **Nom de l'app** : `N8N NEXUS`
6. Cliquer **Créer un mot de passe d'application**

![Capture : Création mot de passe d'application WordPress]

### Étape 4.4 : Copier le Mot de Passe d'Application

WordPress génère un mot de passe unique : par exemple :

```
MyXH wQ1Y f8cP kL9m nO3Q rS7T
```

**Actions :**
1. **Copier le mot de passe** (bouton à côté)
2. **Ne pas le partager** en clair
3. Le stocker dans un endroit sécurisé

### Étape 4.5 : Configurer N8N avec le Mot de Passe d'Application

1. Ouvrir le fichier `.env` de N8N :
   ```
   /path/to/NEXUS-N8N/.env
   ```

2. Ajouter/mettre à jour les variables WordPress :
   ```env
   WORDPRESS_URL=https://nexusconformite.fr
   WORDPRESS_USERNAME=admin
   WORDPRESS_APP_PASSWORD=MyXH wQ1Y f8cP kL9m nO3Q rS7T
   ```

3. **Sauvegarder**

4. **Redémarrer N8N** :
   ```bash
   npm run start
   ```

### Étape 4.6 : Réactiver les Nœuds WordPress dans N8N

Une fois le mot de passe configuré :

1. Ouvrir N8N
2. Aller sur **WF-01** (Premier workflow utilisant WordPress)
3. Chercher les nœuds WordPress (créer utilisateur, créer post, etc.)
4. Vérifier que les nœuds **passent au vert** ✅ (pas d'erreur d'authentification)

**Workflows concernés :**
- ✅ WF-01 : Création article blog automatique
- ✅ WF-02 : Mise à jour profil utilisateur
- ✅ WF-05 : Création compte utilisateur après abonnement

---

## Configuration Récapitulative

### Coûts

| Service | Prix/mois | Annuel |
|---------|-----------|--------|
| Domaine `nexusconformite.fr` | ~0,42€ | 4,99€ |
| Hébergement OVH Perso | ~4€ | ~48€ |
| SSL Let's Encrypt | **Gratuit** | - |
| **TOTAL** | **~4,42€** | **~53€** |

✅ **Budget très économique pour une infrastructure complète !**

### Accès WordPress

| Information | Valeur |
|-----------|--------|
| **URL Admin** | https://nexusconformite.fr/wp-admin |
| **URL Frontend** | https://nexusconformite.fr |
| **Email** | admin@nexusconformite.fr (ou autre) |
| **Mot de passe** | App password (stocké en .env) |
| **Base de données** | Gérée par OVH |

### Configuration N8N

```env
WORDPRESS_URL=https://nexusconformite.fr
WORDPRESS_USERNAME=admin
WORDPRESS_APP_PASSWORD=XXX (généré depuis WordPress)
STRIPE_WEBHOOK_SECRET=whsec_... (configuré dans Stripe)
GUMROAD_WEBHOOK_SECRET=gumroad_... (configuré dans Gumroad)
BREVO_API_KEY=... (pour emails)
```

---

## Étapes Suivantes Après Configuration

1. ✅ **Domaine + Hébergement** : Configurés et actifs
2. ✅ **WordPress** : Installé et sécurisé
3. ✅ **SSL** : Certificat HTTPS en place
4. **À faire :**
   - Configurer les pages WordPress (Accueil, À propos, Contact)
   - Installer des plugins essentiels (Yoast SEO, Wordfence security)
   - Configurer l'email Brevo pour les envois
   - Réactiver les workflows N8N
   - Tester les webhooks Stripe & Gumroad
   - Lancer les campagnes de vente ! 🚀

---

## Support & Troubleshooting

### DNS ne propage pas

- **Attendre 24-48h**
- Vérifier les nameservers dans l'interface OVH
- Utiliser https://dnschecker.org pour vérifier la propagation

### WordPress ne charge pas

- Vérifier que le certificat SSL est actif
- Vérifier que le domaine pointe vers l'hébergement OVH
- Attendre 1h après activation

### N8N ne se connecte pas à WordPress

- Vérifier que le mot de passe d'application est correct
- Vérifier que WordPress accepte les connexions App (REST API activée)
- Redémarrer N8N : `npm run start`

### Email ne s'envoie pas

- Vérifier la clé Brevo API dans `.env`
- Vérifier que Brevo a des credits email
- Tester l'envoi manuel dans WordPress

---

## Ressources Utiles

- **OVH Support FR :** https://help.ovh.com/
- **WordPress Documentation :** https://wordpress.org/support/
- **Let's Encrypt :** https://letsencrypt.org/
- **DNS Propagation Tool :** https://dnschecker.org/

---

*Dernière mise à jour : 2026-03-30*
**Budget total : ~8€/mois pour une infrastructure professionnelle complète !** 🎯