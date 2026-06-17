#!/bin/bash
# =============================================================
#  NEXUS CONFORMITÉ — Deploy N8N sur VPS Ubuntu 22.04
#  Usage : chmod +x deploy-n8n-vps.sh && sudo ./deploy-n8n-vps.sh
#
#  Ce script installe et configure :
#    - Node.js 22 LTS
#    - N8N (latest)
#    - PM2 (gestionnaire de processus)
#    - Nginx (reverse proxy + SSL)
#    - Certbot (certificat Let's Encrypt gratuit)
#
#  Prérequis :
#    - Ubuntu 22.04 LTS
#    - DNS configuré : n8n.nexusconformite.fr → IP du VPS
#    - Port 80 et 443 ouverts dans le pare-feu OVH
# =============================================================

set -e  # Arrêt en cas d'erreur

# ─── CONFIGURATION ──────────────────────────────────────────
DOMAIN="nexusconformite.fr"
N8N_SUBDOMAIN="n8n.${DOMAIN}"
N8N_PORT=5678
N8N_USER="n8n"
N8N_DATA_DIR="/home/${N8N_USER}/.n8n"
ADMIN_EMAIL="seallia81@gmail.com"

# Couleurs terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo ""
echo "=============================================="
echo "  NEXUS CONFORMITÉ — N8N VPS Deployment"
echo "  Domain: ${DOMAIN}"
echo "  N8N: https://${N8N_SUBDOMAIN}"
echo "=============================================="
echo ""

# ─── 1. MISE À JOUR SYSTÈME ──────────────────────────────────
info "Mise à jour du système..."
apt-get update -qq && apt-get upgrade -y -qq
apt-get install -y -qq curl wget git nginx certbot python3-certbot-nginx ufw jq
log "Système à jour"

# ─── 2. NODE.JS 22 LTS ───────────────────────────────────────
info "Installation Node.js 22 LTS..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y nodejs
    log "Node.js $(node --version) installé"
else
    log "Node.js $(node --version) déjà présent"
fi

# ─── 3. PM2 ──────────────────────────────────────────────────
info "Installation PM2..."
npm install -g pm2 --quiet
pm2 startup systemd -u root --hp /root > /dev/null 2>&1 || true
log "PM2 $(pm2 --version) installé"

# ─── 4. CRÉATION UTILISATEUR N8N ─────────────────────────────
info "Création utilisateur dédié '${N8N_USER}'..."
if ! id "${N8N_USER}" &> /dev/null; then
    useradd -m -s /bin/bash "${N8N_USER}"
    log "Utilisateur ${N8N_USER} créé"
else
    log "Utilisateur ${N8N_USER} déjà existant"
fi

# ─── 5. INSTALLATION N8N ─────────────────────────────────────
info "Installation N8N..."
npm install -g n8n --quiet
log "N8N $(n8n --version 2>/dev/null || echo 'latest') installé"

# ─── 6. CONFIGURATION ENV N8N ────────────────────────────────
info "Création du fichier de configuration N8N..."
mkdir -p /etc/n8n
mkdir -p "${N8N_DATA_DIR}"
chown -R "${N8N_USER}:${N8N_USER}" "${N8N_DATA_DIR}"

# Générer une clé d'encryption aléatoire si pas encore définie
ENCRYPTION_KEY=$(openssl rand -hex 32)

# Créer le fichier .env N8N production
cat > /etc/n8n/.env << ENV_EOF
# ============================================================
# NEXUS CONFORMITÉ — Configuration N8N Production
# ============================================================

# N8N — Serveur
N8N_HOST=0.0.0.0
N8N_PORT=${N8N_PORT}
N8N_PROTOCOL=https
WEBHOOK_URL=https://${N8N_SUBDOMAIN}/
N8N_EDITOR_BASE_URL=https://${N8N_SUBDOMAIN}/
VUE_APP_URL_BASE_API=https://${N8N_SUBDOMAIN}/

# N8N — Sécurité
N8N_ENCRYPTION_KEY=${ENCRYPTION_KEY}
N8N_USER_MANAGEMENT_DISABLED=false
N8N_BASIC_AUTH_ACTIVE=false

# N8N — Données
N8N_USER_FOLDER=${N8N_DATA_DIR}
DB_TYPE=sqlite
EXECUTIONS_DATA_SAVE_ON_SUCCESS=none
EXECUTIONS_DATA_SAVE_ON_ERROR=all
EXECUTIONS_DATA_MAX_AGE=168

# N8N — Performance
EXECUTIONS_PROCESS=main
N8N_DEFAULT_BINARY_DATA_MODE=filesystem

# ============================================================
# CREDENTIALS — À REMPLIR avec les vraies valeurs
# ============================================================

# Brevo SMTP
BREVO_SMTP_HOST=smtp-relay.brevo.com
BREVO_SMTP_PORT=587
BREVO_SMTP_LOGIN=REPLACE_WITH_BREVO_LOGIN
BREVO_SMTP_KEY=REPLACE_WITH_BREVO_KEY

# Admin
ADMIN_EMAIL=${ADMIN_EMAIL}

# Telegram
TELEGRAM_BOT_TOKEN=REPLACE_WITH_BOT_TOKEN
TELEGRAM_CHAT_ID=REPLACE_WITH_CHAT_ID

# Google Sheets
GOOGLE_SHEETS_ID=REPLACE_WITH_SHEET_ID

# Stripe
STRIPE_WEBHOOK_SECRET=REPLACE_WITH_WHSEC

# Beehiiv
BEEHIIV_PUBLICATION_ID=REPLACE_WITH_PUB_ID
BEEHIIV_API_KEY=REPLACE_WITH_API_KEY

# Gemini
GEMINI_API_KEY=REPLACE_WITH_KEY

# Anthropic
ANTHROPIC_API_KEY=REPLACE_WITH_KEY
ENV_EOF

chmod 600 /etc/n8n/.env
chown root:root /etc/n8n/.env
log "Fichier /etc/n8n/.env créé (à remplir avec les vraies clés !)"

# ─── 7. PM2 ECOSYSTEM FILE ───────────────────────────────────
info "Configuration PM2 pour N8N..."
cat > /etc/n8n/ecosystem.config.js << 'PM2_EOF'
module.exports = {
  apps: [{
    name: 'nexus-n8n',
    script: 'n8n',
    args: 'start',
    cwd: '/home/n8n',
    user: 'n8n',
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env_file: '/etc/n8n/.env',
    error_file: '/var/log/n8n/error.log',
    out_file: '/var/log/n8n/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss',
  }]
};
PM2_EOF

mkdir -p /var/log/n8n
chown "${N8N_USER}:${N8N_USER}" /var/log/n8n
log "PM2 ecosystem configuré"

# ─── 8. NGINX REVERSE PROXY ──────────────────────────────────
info "Configuration Nginx..."
cat > /etc/nginx/sites-available/nexus-n8n << NGINX_EOF
# NEXUS CONFORMITÉ — N8N Reverse Proxy
# Auto-configuré par deploy-n8n-vps.sh

server {
    listen 80;
    server_name ${N8N_SUBDOMAIN};

    # Redirect HTTP → HTTPS (après SSL)
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${N8N_SUBDOMAIN};

    # SSL — géré par Certbot
    # ssl_certificate et ssl_certificate_key ajoutés par certbot

    # Sécurité headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

    # Gzip
    gzip on;
    gzip_types text/plain application/json text/css application/javascript;

    # Proxy N8N
    location / {
        proxy_pass http://127.0.0.1:${N8N_PORT};
        proxy_http_version 1.1;

        # WebSocket (requis pour N8N editor)
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";

        # Headers proxy
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # Timeout (N8N peut prendre du temps pour les exécutions longues)
        proxy_read_timeout 300;
        proxy_connect_timeout 300;
        proxy_send_timeout 300;

        # Buffer
        proxy_buffering off;
        proxy_cache off;
    }

    # Webhook endpoint — accès public sans auth
    location /webhook/ {
        proxy_pass http://127.0.0.1:${N8N_PORT}/webhook/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 300;
    }
}
NGINX_EOF

# Page landing nexusconformite.fr
cat > /etc/nginx/sites-available/nexus-landing << NGINX_LAND_EOF
# NEXUS CONFORMITÉ — Landing Page principale
server {
    listen 80;
    server_name ${DOMAIN} www.${DOMAIN};

    root /var/www/nexus;
    index nexusconformite-landing.html index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Cache static
    location ~* \.(css|js|png|jpg|ico|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }
}
NGINX_LAND_EOF

# Activer les sites
ln -sf /etc/nginx/sites-available/nexus-n8n /etc/nginx/sites-enabled/
ln -sf /etc/nginx/sites-available/nexus-landing /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Tester la config nginx
nginx -t && systemctl reload nginx
log "Nginx configuré"

# ─── 9. DOSSIER LANDING PAGE ─────────────────────────────────
info "Création dossier landing page..."
mkdir -p /var/www/nexus
# Note: uploader nexusconformite-landing.html via scp après déploiement
cat > /var/www/nexus/index.html << 'HTML_EOF'
<!DOCTYPE html>
<html lang="fr">
<head><meta charset="UTF-8"><title>NEXUS CONFORMITÉ</title></head>
<body>
  <h1>NEXUS CONFORMITÉ</h1>
  <p>Site en cours de déploiement...</p>
  <p>Uploader nexusconformite-landing.html ici.</p>
</body>
</html>
HTML_EOF
log "Dossier /var/www/nexus créé (landing à uploader)"

# ─── 10. PARE-FEU UFW ────────────────────────────────────────
info "Configuration pare-feu UFW..."
ufw --force reset > /dev/null
ufw default deny incoming > /dev/null
ufw default allow outgoing > /dev/null
ufw allow ssh > /dev/null
ufw allow 80/tcp > /dev/null    # HTTP
ufw allow 443/tcp > /dev/null   # HTTPS
ufw --force enable > /dev/null
log "Pare-feu configuré (SSH + HTTP + HTTPS)"

# ─── 11. SSL CERTBOT ─────────────────────────────────────────
info "Installation certificat SSL Let's Encrypt..."
echo ""
warn "Le DNS doit être propagé avant cette étape."
warn "Si DNS pas encore propagé, appuyer Ctrl+C et réexécuter avec --skip-ssl"
echo ""

if [[ "$1" == "--skip-ssl" ]]; then
    warn "SSL skippé — lancer manuellement : certbot --nginx -d ${N8N_SUBDOMAIN} -d ${DOMAIN} -d www.${DOMAIN}"
else
    certbot --nginx \
        -d "${DOMAIN}" \
        -d "www.${DOMAIN}" \
        -d "${N8N_SUBDOMAIN}" \
        --email "${ADMIN_EMAIL}" \
        --agree-tos \
        --non-interactive \
        --redirect && log "SSL installé !" || warn "SSL échoué — vérifier DNS puis lancer : certbot --nginx -d ${N8N_SUBDOMAIN}"

    # Renouvellement automatique
    (crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet") | crontab -
    log "Renouvellement SSL auto configuré (cron 3h)"
fi

# ─── 12. DÉMARRAGE N8N ───────────────────────────────────────
info "Démarrage N8N via PM2..."
su -c "pm2 start /etc/n8n/ecosystem.config.js" "${N8N_USER}" 2>/dev/null || \
    pm2 start /etc/n8n/ecosystem.config.js
pm2 save
log "N8N démarré"

# ─── 13. RÉSUMÉ ──────────────────────────────────────────────
echo ""
echo "=============================================="
echo -e "  ${GREEN}DÉPLOIEMENT TERMINÉ !${NC}"
echo "=============================================="
echo ""
echo "  N8N :      https://${N8N_SUBDOMAIN}"
echo "  Landing :  https://${DOMAIN}"
echo ""
echo "  PROCHAINES ÉTAPES :"
echo "  1. Remplir /etc/n8n/.env avec les vraies clés"
echo "     sudo nano /etc/n8n/.env"
echo ""
echo "  2. Uploader la landing page :"
echo "     scp nexusconformite-landing.html ubuntu@IP:/var/www/nexus/"
echo ""
echo "  3. Importer les workflows dans N8N :"
echo "     node import-workflows.js"
echo "     (depuis ton PC local en pointant vers https://${N8N_SUBDOMAIN})"
echo ""
echo "  4. Vérifier le statut N8N :"
echo "     pm2 status"
echo "     pm2 logs nexus-n8n --lines 50"
echo ""
echo "  5. Configurer les webhooks Gumroad + Stripe"
echo "     vers https://${N8N_SUBDOMAIN}/webhook/..."
echo "=============================================="
