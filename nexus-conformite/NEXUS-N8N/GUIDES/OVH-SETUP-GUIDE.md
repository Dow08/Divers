# OVH — Guide de configuration NEXUS CONFORMITÉ

## 1. Acheter le domaine nexusconformite.fr

1. Aller sur https://www.ovhcloud.com/fr/domains/
2. Rechercher `nexusconformite.fr`
3. Ajouter au panier → Passer commande
4. **Options recommandées :**
   - ✅ Protection WHOIS (gratuit, cache tes coordonnées personnelles)
   - ✅ DNS OVH (laissé par défaut)
   - ❌ Ne PAS prendre l'email OVH (on utilise Brevo)
5. Prix : ~4,99 €/an + ~0,99 € pour la protection WHOIS

---

## 2. Choisir l'hébergement

### Option A — VPS Starter (Recommandé)
- **Prix :** 5,99 €/mois
- **Lien :** https://www.ovhcloud.com/fr/vps/starter/
- **Config :** 2 vCPU, 2 Go RAM, 40 Go SSD, Ubuntu 22.04
- **Pour qui :** Tu veux héberger N8N + WordPress sur le même serveur
- **Avantages :** Contrôle total, N8N en production, performances

### Option B — Hébergement Pro 1 (Simple)
- **Prix :** 4,49 €/mois
- **Lien :** https://www.ovhcloud.com/fr/web-hosting/
- **Config :** 100 Go SSD, PHP 8.2, MySQL, SSL inclus, 1 domaine
- **Pour qui :** Tu veux juste WordPress sans gérer un serveur
- **Limite :** N8N devra rester en local ou sur un service cloud séparé

> **Recommandation finale :** VPS Starter si budget OK.
> Permet d'avoir N8N + WordPress en production sur un seul serveur.

---

## 3. Configuration DNS (après achat)

### Accès à la zone DNS
1. OVH Manager (https://www.ovh.com/manager)
2. Menu gauche → Web Cloud → Noms de domaine → nexusconformite.fr
3. Onglet **Zone DNS**
4. Cliquer **Ajouter une entrée**

### Enregistrements à créer

| Type | Sous-domaine | Valeur | TTL |
|------|-------------|--------|-----|
| A | @ | `IP_DU_VPS` | 3600 |
| A | www | `IP_DU_VPS` | 3600 |
| A | n8n | `IP_DU_VPS` | 3600 |
| CNAME | mail | nexusconformite.fr. | 3600 |
| TXT | @ | `v=spf1 include:sendinblue.com ~all` | 3600 |

> L'IP du VPS est visible dans OVH Manager → Bare Metal Cloud → VPS

### Validation DKIM Brevo
Brevo fournit une clé DKIM à ajouter en TXT. Dans Brevo :
1. Settings → Senders, Domains & Dedicated IPs → Domains
2. Add a domain → `nexusconformite.fr`
3. Copier l'enregistrement DKIM TXT fourni → l'ajouter dans OVH DNS

### Délai propagation
- OVH : généralement 30 min à 2h
- Vérifier : `nslookup nexusconformite.fr 8.8.8.8`
- Ou en ligne : https://dnschecker.org/#A/nexusconformite.fr

---

## 4. Connexion au VPS

```bash
# Depuis ton terminal Windows (PowerShell ou Git Bash)
ssh ubuntu@IP_DU_VPS

# Ou si clé SSH :
ssh -i ~/.ssh/id_rsa ubuntu@IP_DU_VPS
```

### Première connexion — sécurisation
```bash
# Changer le mot de passe root
passwd ubuntu

# Mettre à jour
sudo apt update && sudo apt upgrade -y

# Installer fail2ban (protection brute-force)
sudo apt install fail2ban -y
```

---

## 5. Déploiement N8N sur le VPS

### Upload du script de déploiement
```bash
# Depuis ton PC (PowerShell)
scp "NEXUS-N8N/deploy-n8n-vps.sh" ubuntu@IP_DU_VPS:/home/ubuntu/

# Sur le VPS
chmod +x deploy-n8n-vps.sh
sudo ./deploy-n8n-vps.sh
```

### En cas de DNS pas encore propagé
```bash
# Lancer le script sans SSL (ajouter --skip-ssl)
sudo ./deploy-n8n-vps.sh --skip-ssl

# Une fois DNS propagé, ajouter le SSL :
sudo certbot --nginx -d nexusconformite.fr -d www.nexusconformite.fr -d n8n.nexusconformite.fr
```

### Remplir les credentials sur le VPS
```bash
sudo nano /etc/n8n/.env
# Remplacer tous les REPLACE_WITH_xxx par les vraies valeurs
```

---

## 6. Upload landing page

```bash
# Depuis ton PC Windows (PowerShell)
scp "nexusconformite-landing.html" ubuntu@IP_DU_VPS:/var/www/nexus/nexusconformite-landing.html

# Ou en renommant en index.html
scp "nexusconformite-landing.html" ubuntu@IP_DU_VPS:/var/www/nexus/index.html
```

---

## 7. Vérifications post-déploiement

```bash
# Sur le VPS — statut N8N
pm2 status
pm2 logs nexus-n8n --lines 30

# Test webhook
curl -X POST https://n8n.nexusconformite.fr/webhook/lead-annuaire \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","company":"Test"}'

# SSL
curl -I https://nexusconformite.fr

# Nginx
sudo nginx -t
sudo systemctl status nginx
```

---

## 8. Commandes utiles VPS

```bash
# N8N
pm2 restart nexus-n8n        # Redémarrer N8N
pm2 stop nexus-n8n           # Arrêter N8N
pm2 logs nexus-n8n           # Voir les logs
pm2 status                   # Statut de tous les process

# Nginx
sudo systemctl restart nginx
sudo tail -f /var/log/nginx/error.log

# N8N logs directs
tail -f /var/log/n8n/out.log
tail -f /var/log/n8n/error.log

# Mise à jour N8N
sudo npm install -g n8n
pm2 restart nexus-n8n

# Espace disque
df -h
du -sh /home/n8n/.n8n/
```

---

## 9. Coûts mensuels récapitulatifs

| Service | Prix |
|---------|------|
| nexusconformite.fr (domaine) | ~0,42 €/mois (4,99 €/an) |
| OVH VPS Starter | 5,99 €/mois |
| Brevo (300 emails/j gratuit) | 0 € |
| Beehiiv (newsletter gratuit) | 0 € |
| Gumroad (5% commission) | Variable |
| **TOTAL fixe** | **~6,41 €/mois** |

---

*Mis à jour Session 8 — 30/03/2026*
