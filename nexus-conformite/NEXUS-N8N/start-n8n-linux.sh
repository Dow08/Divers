#!/bin/bash
# =============================================
#   NEXUS CONFORMITE - Démarrage N8N Linux
#   Version validée le 28/03/2026
# =============================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
N8N_DIR="$SCRIPT_DIR/../n8n-install"
NODE_HEADERS_DIR="$SCRIPT_DIR/../node-headers"
N8N_DATA="$HOME/.n8n-nexus"
LOG_FILE="$SCRIPT_DIR/../n8n.log"

echo ""
echo " ============================================="
echo "   NEXUS CONFORMITE - Démarrage N8N Local"
echo " ============================================="
echo ""

# ---- Vérifier .env ----
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "[ERREUR] Fichier .env introuvable !"
    echo "→ Copier .env.example en .env et remplir les valeurs."
    exit 1
fi

# ---- Vérifier Node.js ----
if ! command -v node &>/dev/null; then
    echo "[ERREUR] Node.js n'est pas installé."
    echo "→ curl -fsSL https://deb.nodesource.com/setup_22.x | sudo bash - && sudo apt install -y nodejs"
    exit 1
fi
echo "[OK] Node.js : $(node --version)"

# ---- Installer N8N si absent ----
if [ ! -f "$N8N_DIR/node_modules/.bin/n8n" ]; then
    echo ""
    echo "[INFO] Installation de N8N (peut prendre 3-5 min)..."
    mkdir -p "$N8N_DIR"
    cat > "$N8N_DIR/package.json" << 'PKGJSON'
{
  "name": "nexus-n8n",
  "version": "1.0.0",
  "overrides": { "xlsx": "npm:xlsx@^0.18.5" }
}
PKGJSON
    cd "$N8N_DIR"
    npm install n8n --ignore-scripts
    echo "[OK] N8N installé."
fi

# ---- Compiler sqlite3 si absent ----
SQLITE_BUILD="$N8N_DIR/node_modules/sqlite3/build/Release/node_sqlite3.node"
if [ ! -f "$SQLITE_BUILD" ]; then
    echo ""
    echo "[INFO] Compilation de sqlite3..."

    # Préparer les headers Node si besoin
    if [ ! -f "$NODE_HEADERS_DIR/include/node/node_api.h" ]; then
        mkdir -p "$NODE_HEADERS_DIR/include/node"
        cp /usr/include/node/*.h "$NODE_HEADERS_DIR/include/node/"
        cp /usr/include/node/*.gypi "$NODE_HEADERS_DIR/" 2>/dev/null || true
        cp -r /usr/include/node/uv "$NODE_HEADERS_DIR/include/node/" 2>/dev/null || true
    fi

    cd "$N8N_DIR/node_modules/sqlite3"
    "$N8N_DIR/node_modules/.bin/node-gyp" configure --nodedir="$NODE_HEADERS_DIR"
    "$N8N_DIR/node_modules/.bin/node-gyp" build
    echo "[OK] sqlite3 compilé."
fi

N8N_BIN="$N8N_DIR/node_modules/.bin/n8n"
echo "[OK] N8N : $($N8N_BIN --version 2>/dev/null)"

# ---- Charger .env local ----
echo "[INFO] Chargement du .env..."
set -a; source "$SCRIPT_DIR/.env"; set +a

# ---- Variables N8N (valeurs non-sensibles ; sensibles viennent du .env) ----
export N8N_BASIC_AUTH_ACTIVE=true
export N8N_BASIC_AUTH_USER="${N8N_BASIC_AUTH_USER:-nexus}"
export N8N_PORT="${N8N_PORT:-5678}"
export N8N_PROTOCOL=http
export N8N_HOST=localhost
export EXECUTIONS_DATA_SAVE_ON_SUCCESS=none
export EXECUTIONS_DATA_SAVE_ON_ERROR=all
export N8N_LOG_LEVEL=warn
export N8N_USER_FOLDER="$N8N_DATA"

# Vérifier que les variables sensibles sont définies
if [ -z "$N8N_BASIC_AUTH_PASSWORD" ]; then
    echo "[ERREUR] N8N_BASIC_AUTH_PASSWORD non défini dans .env"
    exit 1
fi
if [ -z "$N8N_ENCRYPTION_KEY" ]; then
    echo "[ERREUR] N8N_ENCRYPTION_KEY non défini dans .env"
    exit 1
fi

mkdir -p "$N8N_DATA"

echo ""
echo " ============================================="
echo "   N8N démarré — ouvrir Chrome :"
echo "   http://localhost:${N8N_PORT}"
echo "   Login : voir fichier .env"
echo " ============================================="
echo "   CTRL+C pour arrêter"
echo ""

cd "$N8N_DIR"
$N8N_BIN start 2>&1 | tee "$LOG_FILE"
