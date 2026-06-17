/**
 * ============================================================
 *  NEXUS CONFORMITÉ — Setup automatique des credentials N8N
 *  Script Node.js à exécuter UNE SEULE FOIS sur la machine Windows
 *
 *  Prérequis :
 *    - N8N doit être en cours d'exécution sur localhost:5678
 *    - Fichier .env renseigné avec les secrets (voir .env.example)
 *
 *  Lancement (dans le dossier NEXUS-N8N) :
 *      node setup-n8n-credentials.js
 * ============================================================
 */

const http = require('http');
const fs   = require('fs');
const path = require('path');

// ─── CHARGEMENT .ENV ─────────────────────────────────────────
function loadEnv() {
  const envPath = path.join(__dirname, '.env');
  if (!fs.existsSync(envPath)) {
    console.error('❌ Fichier .env introuvable dans le dossier NEXUS-N8N/');
    console.error('   Copier .env.example → .env et remplir les valeurs.');
    process.exit(1);
  }
  const lines = fs.readFileSync(envPath, 'utf-8').split('\n');
  const env = {};
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const eqIdx = trimmed.indexOf('=');
    if (eqIdx === -1) continue;
    const key = trimmed.substring(0, eqIdx).trim();
    const val = trimmed.substring(eqIdx + 1).trim();
    env[key] = val;
  }
  return env;
}

const ENV = loadEnv();

// ─── CONFIG (lue depuis .env) ────────────────────────────────
const N8N_HOST   = '127.0.0.1';
const N8N_PORT   = parseInt(ENV.N8N_PORT || '5678', 10);
const N8N_EMAIL  = ENV.N8N_LOGIN_EMAIL;
const N8N_PASS   = ENV.N8N_LOGIN_PASSWORD;

if (!N8N_EMAIL || !N8N_PASS) {
  console.error('❌ Variables N8N_LOGIN_EMAIL et N8N_LOGIN_PASSWORD requises dans .env');
  console.error('   Ajouter :');
  console.error('   N8N_LOGIN_EMAIL=votre_email@example.com');
  console.error('   N8N_LOGIN_PASSWORD=votre_mot_de_passe_n8n');
  process.exit(1);
}

// Basic Auth gateway (couche protection web)
const BASIC_USER = ENV.N8N_BASIC_AUTH_USER || 'nexus';
const BASIC_PASS = ENV.N8N_BASIC_AUTH_PASSWORD;
if (!BASIC_PASS) {
  console.error('❌ Variable N8N_BASIC_AUTH_PASSWORD requise dans .env');
  process.exit(1);
}
const BASIC_HDR  = 'Basic ' + Buffer.from(`${BASIC_USER}:${BASIC_PASS}`).toString('base64');

// ─── CREDENTIALS À CRÉER (valeurs lues depuis .env) ─────────
const CREDENTIALS = [];

// Anthropic (optionnel — remplacé par Gemini)
if (ENV.ANTHROPIC_API_KEY && !ENV.ANTHROPIC_API_KEY.startsWith('sk-ant-your')) {
  CREDENTIALS.push({
    name: 'Anthropic NEXUS',
    type: 'anthropicApi',
    data: { apiKey: ENV.ANTHROPIC_API_KEY }
  });
}

// Brevo SMTP
if (ENV.BREVO_SMTP_KEY && !ENV.BREVO_SMTP_KEY.startsWith('xsmtpsib-your')) {
  CREDENTIALS.push({
    name: 'Brevo SMTP NEXUS',
    type: 'smtp',
    data: {
      host:     ENV.BREVO_SMTP_HOST || 'smtp-relay.brevo.com',
      port:     parseInt(ENV.BREVO_SMTP_PORT || '587', 10),
      secure:   false,
      user:     ENV.BREVO_SMTP_LOGIN,
      password: ENV.BREVO_SMTP_KEY,
      allowUnauthorizedCerts: false
    }
  });
}

// Telegram Bot
if (ENV.TELEGRAM_BOT_TOKEN && !ENV.TELEGRAM_BOT_TOKEN.startsWith('your_')) {
  CREDENTIALS.push({
    name: 'Telegram NEXUS',
    type: 'telegramApi',
    data: { accessToken: ENV.TELEGRAM_BOT_TOKEN }
  });
}

// Google Sheets — OAuth, nécessite flow OAuth séparé dans l'UI N8N
// Beehiiv — API key en attente (Stripe Identity)
// Stripe — clés test en attente (validation compte)
// WordPress — à configurer avec URL + login

if (CREDENTIALS.length === 0) {
  console.warn('⚠️  Aucun credential à créer. Vérifier que le .env contient des valeurs réelles (pas les placeholders).');
}

// ─── HELPERS HTTP ────────────────────────────────────────────

/** Fait une requête HTTP et retourne { status, headers, body } */
function request(method, path, body, extraHeaders = {}) {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : '';
    const headers = {
      'Content-Type':  'application/json',
      'Accept':        'application/json',
      'Authorization': BASIC_HDR,   // gateway Basic Auth
      'Content-Length': Buffer.byteLength(payload),
      ...extraHeaders
    };

    const req = http.request(
      { hostname: N8N_HOST, port: N8N_PORT, path, method, headers },
      (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode, headers: res.headers, body: JSON.parse(data) });
          } catch {
            resolve({ status: res.statusCode, headers: res.headers, body: data });
          }
        });
      }
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

/** Extrait les cookies Set-Cookie et les formate pour le header Cookie */
function extractCookies(setCookieHeaders) {
  if (!setCookieHeaders) return '';
  const arr = Array.isArray(setCookieHeaders) ? setCookieHeaders : [setCookieHeaders];
  return arr.map(c => c.split(';')[0]).join('; ');
}

// ─── MAIN ────────────────────────────────────────────────────
async function main() {
  console.log('\n══════════════════════════════════════════');
  console.log(' NEXUS CONFORMITÉ — Configuration N8N');
  console.log('══════════════════════════════════════════\n');

  // ÉTAPE 1 : Login pour obtenir le cookie de session
  console.log('🔐 Connexion à N8N...');
  const loginRes = await request('POST', '/rest/login', {
    emailOrLdapLoginId: N8N_EMAIL,
    password:           N8N_PASS
  });

  if (loginRes.status !== 200) {
    console.error('❌ Login échoué (status ' + loginRes.status + ')');
    console.error('   Réponse :', JSON.stringify(loginRes.body));
    process.exit(1);
  }

  // Capturer le cookie de session depuis les headers Set-Cookie
  const sessionCookie = extractCookies(loginRes.headers['set-cookie']);
  if (!sessionCookie) {
    console.error('❌ Aucun cookie de session reçu. Vérifier les logs N8N.');
    process.exit(1);
  }
  console.log('✅ Connecté ! Cookie de session obtenu.\n');

  // Headers réutilisés pour toutes les requêtes authentifiées
  const authHeaders = {
    'Cookie': sessionCookie
  };

  // ÉTAPE 2 : Vérifier les credentials existants (pour éviter les doublons)
  console.log('📋 Récupération des credentials existants...');
  const listRes = await request('GET', '/rest/credentials?includeData=false', null, authHeaders);

  let existingCreds = [];
  if (listRes.status === 200 && listRes.body.data) {
    existingCreds = listRes.body.data;
    console.log(`   ${existingCreds.length} credential(s) existant(s) :`);
    existingCreds.forEach(c => console.log(`   - [${c.id}] ${c.name} (${c.type})`));
  } else {
    console.warn('   ⚠️  Impossible de lister les credentials (status', listRes.status, ')');
    console.warn('   Réponse :', JSON.stringify(listRes.body).substring(0, 200));
  }
  console.log();

  // ÉTAPE 3 : Créer ou mettre à jour chaque credential
  for (const cred of CREDENTIALS) {
    console.log(`🔑 Traitement : "${cred.name}" (${cred.type})`);

    // Chercher si ce credential existe déjà (même nom ou même type)
    const existing = existingCreds.find(
      c => c.name === cred.name || (c.type === cred.type && c.name.toLowerCase().includes('anthropic'))
    );

    if (existing) {
      // Mettre à jour le credential existant via PATCH
      console.log(`   ↻ Mise à jour du credential existant [ID: ${existing.id}]...`);
      const patchRes = await request(
        'PATCH',
        `/rest/credentials/${existing.id}`,
        { name: cred.name, type: cred.type, data: cred.data },
        authHeaders
      );
      if (patchRes.status === 200) {
        console.log(`   ✅ Mis à jour avec succès !`);
      } else {
        console.error(`   ❌ Échec mise à jour (status ${patchRes.status})`);
        console.error('   ', JSON.stringify(patchRes.body).substring(0, 300));
      }
    } else {
      // Créer un nouveau credential via POST
      console.log(`   + Création d'un nouveau credential...`);
      const createRes = await request(
        'POST',
        '/rest/credentials',
        { name: cred.name, type: cred.type, data: cred.data },
        authHeaders
      );
      if (createRes.status === 200 || createRes.status === 201) {
        console.log(`   ✅ Créé ! [ID: ${createRes.body.data?.id || createRes.body.id}]`);
      } else {
        console.error(`   ❌ Échec création (status ${createRes.status})`);
        console.error('   ', JSON.stringify(createRes.body).substring(0, 300));
      }
    }
    console.log();
  }

  // ÉTAPE 4 : Supprimer les anciennes credentials orphelines
  console.log('🔍 Vérification des credentials orphelines...');
  const refreshRes = await request('GET', '/rest/credentials?includeData=false', null, authHeaders);
  const currentCreds = (refreshRes.status === 200 && refreshRes.body.data) ? refreshRes.body.data : [];

  const orphan = currentCreds.find(c =>
    c.name === 'Anthropic account' &&
    !currentCreds.find(x => x.name === 'Anthropic NEXUS')
  );
  if (orphan) {
    console.log(`🗑️  Suppression de l'ancienne credential vide "${orphan.name}" [ID: ${orphan.id}]...`);
    const delRes = await request('DELETE', `/rest/credentials/${orphan.id}`, null, authHeaders);
    if (delRes.status === 200 || delRes.status === 204) {
      console.log('   ✅ Supprimée !');
    } else {
      console.warn('   ⚠️  Impossible de supprimer (status', delRes.status, ')');
    }
  } else {
    console.log('   ✅ Aucune credential orpheline trouvée.');
  }
  console.log();

  console.log('══════════════════════════════════════════');
  console.log(' ✅ Configuration terminée !');
  console.log('══════════════════════════════════════════');
  console.log('\n📌 Prochaines étapes manuelles dans N8N :');
  console.log('   1. Créer le bot Telegram via @BotFather → configurer credential Telegram');
  console.log('   2. Google Sheets → OAuth via le bouton "Connect" dans N8N');
  console.log('   3. Beehiiv API key → dès réception après vérification Stripe Identity');
  console.log('   4. Stripe → clés test dès validation du compte');
  console.log('   5. WordPress → URL + login admin\n');
}

main().catch(err => {
  console.error('\n💥 Erreur inattendue :', err.message);
  process.exit(1);
});
