# 🚀 VPS DEPLOYMENT CHECKLIST — OVH
**Date:** 1er avril 2026  
**Projet:** NEXUS CONFORMITÉ N8N + WordPress  
**Hébergeur:** OVH  
**Domaine:** nexusconformite.fr  
**Phase:** Pré-achat VPS

---

## 📋 SPÉCIFICATIONS TECHNIQUES REQUISES

### Serveur OVH (Recommandé)
- **OS:** Ubuntu 22.04 LTS (ou plus récent)
- **CPU:** Minimum 2 cores (4+ recommandé pour N8N)
- **RAM:** Minimum 4 GB (8 GB recommandé)
- **Stockage:** Minimum 50 GB (100 GB recommandé pour backups)
- **Bande passante:** Illimitée
- **Type:** VPS Cloud ou Starter
- **Estimation coût:** 10-20€/mois

### Domaine & DNS
- **Domaine:** nexusconformite.fr (existant ✅)
- **DNS:** À pointer vers IP publique OVH VPS
- **SSL/TLS:** Let's Encrypt (gratuit, auto-renew)
- **Configuration:** Enregistrements A et AAAA

### Dépendances Externes
- **Stripe:** Clés API existantes, mode TEST ✓
- **Google Cloud:** Credentials (Sheets, Drive, Gemini)
- **Brevo:** SMTP relay configuré ✓
- **Telegram:** Bot existant ✓
- **Beehiiv:** API key existante ✓
- **Gumroad:** À configurer webhooks
- **WordPress:** À installer sur OVH

---

## ✅ PRÉ-DÉPLOIEMENT — CHECKLIST LOCALE

### Avant achat VPS:
- [ ] Confirmer IP publique OVH (sera fournie)
- [ ] Configurer DNS records (A, AAAA, CNAME)
- [ ] Tester tous workflows sur localhost (Étape 3)
- [ ] Générer WordPress app password
- [ ] Documenter tous les secrets sensibles
- [ ] Créer plan de rollback en cas d'erreur

### Créer fichier `.env.production`:
```bash
# À créer avec TOUS les secrets production
# Sera versionnée dans un `.env.production` séparé
```

---

## 🔧 CONFIGURATION VPS ÉTAPE PAR ÉTAPE

### PHASE 1: INFRASTRUCTURE DE BASE (30 min)

#### 1.1 Connexion SSH initiale
```bash
# [ ] Connexion root au VPS via SSH
ssh root@[IP_PUBLIQUE_OVH]

# [ ] Mettre à jour le système
apt update && apt upgrade -y

# [ ] Installer dépendances de base
apt install -y curl wget git nano htop ufw
```

#### 1.2 Sécurité de base
```bash
# [ ] Configurer firewall UFW
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 5678/tcp  # N8N (optionnel, restricter)
ufw enable

# [ ] Désactiver login root, créer user applicatif
useradd -m -s /bin/bash nexus
usermod -aG sudo nexus

# [ ] Configurer clé SSH (copier depuis local)
# À faire depuis machine locale:
# ssh-copy-id -i ~/.ssh/id_rsa.pub nexus@[IP_OVH]
```

#### 1.3 DNS & SSL/TLS
```bash
# [ ] Configurer DNS records OVH (via console OVH)
# A record: nexusconformite.fr → [IP_PUBLIQUE_VPS]
# AAAA record: nexusconformite.fr → [IPv6_VPS]
# CNAME: www.nexusconformite.fr → nexusconformite.fr

# [ ] Valider DNS propagation (attendre 24h max)
nslookup nexusconformite.fr
```

---

### PHASE 2: NODEJS & N8N (45 min)

#### 2.1 Installer Node.js
```bash
# [ ] Installer Node.js 18+ (NVM)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18
node -v  # Valider

# [ ] Installer npm packages globalement
npm install -g npm@latest
npm install -g pm2  # Process manager
```

#### 2.2 Cloner & configurer N8N
```bash
# [ ] Cloner le repo NEXUS-N8N
cd /home/nexus
git clone https://github.com/[USER]/nexus-n8n.git NEXUS-N8N
cd NEXUS-N8N

# [ ] Copier .env.production (créé en local)
# À faire depuis machine locale:
# scp .env.production nexus@[IP_OVH]:/home/nexus/NEXUS-N8N/

# [ ] Installer dépendances N8N
npm install

# [ ] Configurer PM2 pour auto-start
pm2 start "npm start" --name n8n
pm2 save
pm2 startup
```

#### 2.3 Nginx reverse proxy pour N8N
```bash
# [ ] Installer Nginx
apt install -y nginx

# [ ] Créer config Nginx pour N8N
cat > /etc/nginx/sites-available/n8n << 'NGINX_EOF'
server {
    listen 80;
    listen [::]:80;
    server_name nexusconformite.fr www.nexusconformite.fr;
    
    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX_EOF

# [ ] Activer site
ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

#### 2.4 SSL/TLS avec Let's Encrypt
```bash
# [ ] Installer Certbot
apt install -y certbot python3-certbot-nginx

# [ ] Générer certificat SSL
certbot --nginx -d nexusconformite.fr -d www.nexusconformite.fr

# [ ] Configurer auto-renewal
systemctl enable certbot.timer
systemctl start certbot.timer

# [ ] Valider: accéder à https://nexusconformite.fr (certificat vert)
```

---

### PHASE 3: WORDPRESS (1 heure)

#### 3.1 Base de données MySQL
```bash
# [ ] Installer MySQL
apt install -y mysql-server

# [ ] Configuration sécurisée
mysql_secure_installation

# [ ] Créer base de données WordPress
mysql -u root -p
CREATE DATABASE nexus_wordpress;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY '[STRONG_PASSWORD]';
GRANT ALL PRIVILEGES ON nexus_wordpress.* TO 'wp_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# [ ] Stocker credentials wp_user dans notes sécurisées
```

#### 3.2 Installer WordPress
```bash
# [ ] Télécharger WordPress
cd /var/www
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
mv wordpress nexusconformite
chown -R www-data:www-data nexusconformite

# [ ] Copier wp-config
cp nexusconformite/wp-config-sample.php nexusconformite/wp-config.php

# [ ] Éditer wp-config.php avec credentials base de données
nano nexusconformite/wp-config.php
# Remplacer DB_NAME, DB_USER, DB_PASSWORD, DB_HOST
```

#### 3.3 Nginx config pour WordPress
```bash
# [ ] Créer config Nginx WordPress
cat > /etc/nginx/sites-available/wordpress << 'WP_EOF'
server {
    listen 80;
    listen [::]:80;
    server_name blog.nexusconformite.fr;
    
    root /var/www/nexusconformite;
    index index.php index.html;
    
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php-fpm.sock;
    }
    
    location ~ /\.ht {
        deny all;
    }
}
WP_EOF

# [ ] Activer
ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

#### 3.4 PHP-FPM pour WordPress
```bash
# [ ] Installer PHP
apt install -y php php-fpm php-mysql php-curl php-gd php-mbstring php-xml

# [ ] Configurer PHP-FPM
nano /etc/php/8.1/fpm/php.ini
# Ajouter: memory_limit = 256M

systemctl restart php8.1-fpm
```

#### 3.5 Finish WordPress installation
```bash
# [ ] Accéder à http://blog.nexusconformite.fr/wp-admin
# [ ] Compléter installation WordPress
# [ ] Créer compte admin (user: dow, password: [STRONG])
# [ ] Générer mot de passe d'application pour N8N
#     Admin > Users > Profile > Application Passwords
#     Label: "N8N-WF-02-WF-05"
```

---

### PHASE 4: INTÉGRATION N8N — WEBHOOKS (30 min)

#### 4.1 Configuration domaine N8N
```bash
# [ ] Éditer .env N8N production
# N8N_HOST=nexusconformite.fr
# N8N_PROTOCOL=https
# N8N_PORT=80  (Nginx reverse proxy gère le 443)
# NODE_ENV=production

# [ ] Redémarrer N8N
pm2 restart n8n
```

#### 4.2 Configurer Stripe webhook
```bash
# [ ] Aller sur https://dashboard.stripe.com/webhooks
# [ ] Créer nouvel endpoint:
#     URL: https://nexusconformite.fr/webhook/stripe-webhook
#     Events: payment_intent.succeeded, charge.dispute.created
# [ ] Copier Webhook Signing Secret (whsec_...)
# [ ] Mettre dans .env.production:
#     STRIPE_WEBHOOK_SECRET=whsec_...
# [ ] Redémarrer N8N
#     pm2 restart n8n
```

#### 4.3 Configurer Gumroad webhook
```bash
# [ ] Aller sur https://app.gumroad.com/settings/advanced
# [ ] Ajouter URL webhook:
#     https://nexusconformite.fr/webhook/gumroad-webhook
# [ ] Copier le Webhook Secret généré
# [ ] Mettre dans .env.production:
#     GUMROAD_WEBHOOK_SECRET=gumroad_secret_...
# [ ] Redémarrer N8N
#     pm2 restart n8n
```

#### 4.4 Tester webhooks
```bash
# [ ] WF-07 Gumroad: effectuer achat test
# [ ] WF-04 Stripe: créer paiement test
# [ ] Vérifier dans logs N8N que webhooks reçus:
#     pm2 logs n8n | grep "webhook"
```

---

### PHASE 5: CONFIGURATION FINALE (15 min)

#### 5.1 Vérifier tous les credentials
```bash
# [ ] N8N Settings > Credentials
# [ ] Valider tous les credentials:
#     ✅ Brevo SMTP (test connection)
#     ✅ Google Sheets (OAuth)
#     ✅ Google Drive (OAuth)
#     ✅ Google Gemini (API)
#     ✅ Beehiiv (API)
#     ✅ Stripe (API + Webhook Secret)
#     ✅ Gumroad (Webhook Secret)
#     ✅ Telegram (Bot Token)
#     ✅ WordPress (API + App Password)
```

#### 5.2 Tester workflows production
```bash
# [ ] Déclencher WF-01 Backup (Google Drive)
# [ ] Déclencher WF-02 Veille Légale (Gemini + Telegram)
# [ ] Déclencher WF-03 Newsletter (Beehiiv)
# [ ] Déclencher WF-04 Revenus (créer test payment)
# [ ] Déclencher WF-05 Onboarding (soumettre formulaire)
# [ ] Déclencher WF-06 Leads (soumettre formulaire)
# [ ] Déclencher WF-07 Gumroad (créer achat test)
# [ ] Déclencher WF-08 Dashboard (synthèse)
# [ ] Déclencher WF-09 Cold Email (envoyer test)
```

#### 5.3 Monitoring & Logs
```bash
# [ ] Configurer log rotation
cat > /etc/logrotate.d/n8n << 'LOG_EOF'
/home/nexus/NEXUS-N8N/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
LOG_EOF

# [ ] Configurer monitoring Telegram (notifications erreurs)
# [ ] Vérifier PM2 monitoring
#     pm2 monit
```

#### 5.4 Backup & Récupération d'urgence
```bash
# [ ] Créer script de backup automatique
cat > /home/nexus/backup.sh << 'BACKUP_EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/nexus/backups"
mkdir -p $BACKUP_DIR

# Backup N8N data
tar -czf $BACKUP_DIR/n8n_$DATE.tar.gz /home/nexus/NEXUS-N8N/

# Backup WordPress
mysqldump -u wp_user -p[PASSWORD] nexus_wordpress > $BACKUP_DIR/wordpress_$DATE.sql

# Upload to Google Drive (optionnel)
# [N8N Workflow automatise ça]

echo "Backup completed: $DATE"
BACKUP_EOF

chmod +x /home/nexus/backup.sh

# [ ] Ajouter cron job pour backup quotidien
crontab -e
# Ajouter: 0 2 * * * /home/nexus/backup.sh
```

---

## 📋 CHECKLIST SPÉCIFIQUE PAR SERVICE

### ☑️ STRIPE WEBHOOK
- [ ] Dashboard Stripe: https://dashboard.stripe.com/webhooks
- [ ] URL: `https://nexusconformite.fr/webhook/stripe-webhook`
- [ ] Événements: `payment_intent.succeeded`, `charge.dispute.created`
- [ ] Secret récupéré: `whsec_...`
- [ ] Clé ajoutée à `.env.production`: `STRIPE_WEBHOOK_SECRET=`
- [ ] Test payment effectué (carte 4242 4242 4242 4242)
- [ ] Webhook reçu confirmé dans logs N8N

### ☑️ GUMROAD WEBHOOK
- [ ] Dashboard Gumroad: https://app.gumroad.com/settings/advanced
- [ ] URL configurée: `https://nexusconformite.fr/webhook/gumroad-webhook`
- [ ] Secret copié depuis Gumroad
- [ ] Clé ajoutée à `.env.production`: `GUMROAD_WEBHOOK_SECRET=`
- [ ] Test sale effectué
- [ ] Webhook reçu confirmé dans logs N8N

### ☑️ WORDPRESS
- [ ] Installation complète sur `blog.nexusconformite.fr`
- [ ] App password généré pour N8N
- [ ] N8N credential configurée avec username + app password
- [ ] Test WF-02 (publication automatique article)
- [ ] Domaine accessible en HTTPS

### ☑️ N8N SÉCURITÉ
- [ ] `N8N_BASIC_AUTH_USER` et `N8N_BASIC_AUTH_PASSWORD` complexes
- [ ] `N8N_ENCRYPTION_KEY` confidentielle
- [ ] HTTPS activé (certificat Let's Encrypt)
- [ ] Firewall UFW active (port 22, 80, 443, 5678 si interne)
- [ ] Clés SSH de l'utilisateur `nexus`

### ☑️ CERTIFICATIONS & CONFORMITÉ
- [ ] SSL/TLS: Let's Encrypt valide (auto-renew)
- [ ] RGPD: Mentions légales remplies
- [ ] RGPD: Politique confidentialité mise à jour
- [ ] Données: Backup automatique géré

---

## 🚨 ERREURS COURANTES À ÉVITER

### DNS & Domaine
❌ Ne pas vérifier propagation DNS (attendre 24h)  
❌ Oublier enregistrements CNAME pour www.  
❌ Certificat SSL expiré (auto-renew non configuré)

### N8N
❌ N8N port 5678 pas accessible en externe  
❌ Credentials mal migrées de local à production  
❌ `.env.production` committée sur Git (secrets exposés)  
❌ Webhook secret vide dans `.env`

### WordPress
❌ Permissions fichiers incorrectes (chown)  
❌ Base de données non créée  
❌ PHP version incompatible (< 7.4)  
❌ App password non généré pour N8N

### Général
❌ Firewall bloquant ports nécessaires  
❌ Pas de script de backup  
❌ Logs non configurés (debug difficile)  
❌ Pas de plan de rollback

---

## 📞 SUPPORT & RESSOURCES

| Service | Documentation |
|---------|------|
| OVH VPS | https://docs.ovh.com/ |
| N8N | https://docs.n8n.io/ |
| WordPress | https://wordpress.org/support/ |
| Stripe | https://stripe.com/docs |
| Gumroad | https://support.gumroad.com |
| Let's Encrypt | https://letsencrypt.org/docs/ |

---

## 🎯 VALIDATION FINALE

Avant de considérer le VPS prêt pour production:

**Tous les workflows fonctionnent? ✅**
- [ ] WF-01 à WF-09 testés
- [ ] Tous les credentials opérationnels
- [ ] Aucun erreur dans logs N8N

**Sécurité validée? ✅**
- [ ] SSH sans mot de passe (clés)
- [ ] Firewall UFW actif
- [ ] HTTPS obligatoire
- [ ] Pas de secrets en clair sur Git

**Monitoring & Alertes? ✅**
- [ ] Logs centralisés
- [ ] Telegram alertes actif
- [ ] Backup automatique planifié
- [ ] PM2 monitoring en place

**Domaine & DNS? ✅**
- [ ] `nexusconformite.fr` résout
- [ ] `blog.nexusconformite.fr` résout
- [ ] Certificats SSL valides
- [ ] DNS records confirmés

---

**Status:** ⏳ PRÉ-ACHAT CHECKLIST  
**Prochaine étape:** Acheter VPS OVH et exécuter phases 1-5  
**Estimé:** 3-4 heures pour déploiement complet

*Checklist créé le 1er avril 2026 — Session #8*
