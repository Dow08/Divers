/**
 * ============================================================
 *  NEXUS CONFORMITÉ — Import automatique des 9 workflows N8N
 *  Script Node.js à exécuter depuis le dossier NEXUS-N8N
 *
 *  Prérequis :
 *    - N8N en cours d'exécution sur localhost:5678
 *    - Fichier .env renseigné (voir .env.example)
 *    - Les fichiers JSON dans le sous-dossier ./workflows/
 *
 *  Lancement :
 *      node import-workflows.js
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

const BASIC_USER = ENV.N8N_BASIC_AUTH_USER || 'nexus';
const BASIC_PASS = ENV.N8N_BASIC_AUTH_PASSWORD;
if (!BASIC_PASS) {
  console.error('❌ Variable N8N_BASIC_AUTH_PASSWORD requise dans .env');
  process.exit(1);
}
const BASIC_HDR  = 'Basic ' + Buffer.from(`${BASIC_USER}:${BASIC_PASS}`).toString('base64');

// Dossier contenant les fichiers JSON des workflows
// (chemin relatif par rapport à l'emplacement de ce script)
const WORKFLOWS_DIR = path.join(__dirname, 'workflows');

// Ordre d'import imposé : WF-04 en premier (il reçoit les webhooks Stripe),
// puis les autres dans l'ordre numérique
const IMPORT_ORDER = [
  'WF-04-alertes-revenus.json',
  'WF-01-backup-auto.json',
  'WF-02-veille-legislative.json',
  'WF-03-newsletter-hebdo.json',
  'WF-05-onboarding-annuaire.json',
  'WF-06-leads-annuaire.json',
  'WF-07-livraison-gumroad.json',
  'WF-08-dashboard-hebdo.json',
  'WF-09-cold-email-b2b.json',
];

// ─── HELPERS HTTP ────────────────────────────────────────────
function request(method, urlPath, body, extraHeaders = {}) {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : '';
    const headers = {
      'Content-Type':   'application/json',
      'Accept':         'application/json',
      'Authorization':  BASIC_HDR,
      'Content-Length': Buffer.byteLength(payload),
      ...extraHeaders
    };
    const req = http.request(
      { hostname: N8N_HOST, port: N8N_PORT, path: urlPath, method, headers },
      (res) => {
        let data = '';
        res.on('data', c => data += c);
        res.on('end', () => {
          try   { resolve({ status: res.statusCode, headers: res.headers, body: JSON.parse(data) }); }
          catch { resolve({ status: res.statusCode, headers: res.headers, body: data }); }
        });
      }
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

function extractCookies(setCookieHeaders) {
  if (!setCookieHeaders) return '';
  const arr = Array.isArray(setCookieHeaders) ? setCookieHeaders : [setCookieHeaders];
  return arr.map(c => c.split(';')[0]).join('; ');
}

// ─── MAIN ────────────────────────────────────────────────────
async function main() {
  console.log('\n══════════════════════════════════════════════════');
  console.log(' NEXUS CONFORMITÉ — Import des 9 workflows N8N');
  console.log('══════════════════════════════════════════════════\n');

  // ÉTAPE 1 : Login
  console.log('🔐 Connexion à N8N...');
  const loginRes = await request('POST', '/rest/login', {
    emailOrLdapLoginId: N8N_EMAIL,
    password:           N8N_PASS
  });
  if (loginRes.status !== 200) {
    console.error('❌ Login échoué :', loginRes.status, JSON.stringify(loginRes.body));
    process.exit(1);
  }
  const sessionCookie = extractCookies(loginRes.headers['set-cookie']);
  console.log('✅ Connecté !\n');

  const authHeaders = { 'Cookie': sessionCookie };

  // ÉTAPE 2 : Récupérer les workflows existants (pour éviter les doublons)
  console.log('📋 Récupération des workflows existants...');
  const listRes = await request('GET', '/rest/workflows', null, authHeaders);
  const existingWorkflows = (listRes.status === 200 && listRes.body.data)
    ? listRes.body.data
    : [];
  console.log(`   ${existingWorkflows.length} workflow(s) existant(s)\n`);

  // ÉTAPE 3 : Import de chaque workflow dans l'ordre défini
  let successCount = 0;
  let skipCount    = 0;
  let errorCount   = 0;

  for (const filename of IMPORT_ORDER) {
    const filePath = path.join(WORKFLOWS_DIR, filename);

    // Vérifier que le fichier existe
    if (!fs.existsSync(filePath)) {
      console.warn(`⚠️  Fichier introuvable : ${filename} — ignoré`);
      errorCount++;
      continue;
    }

    // Lire et parser le JSON du workflow
    let workflowData;
    try {
      const raw = fs.readFileSync(filePath, 'utf-8');
      workflowData = JSON.parse(raw);
    } catch (e) {
      console.error(`❌ Erreur de lecture/parsing pour ${filename} :`, e.message);
      errorCount++;
      continue;
    }

    const wfName = workflowData.name || filename.replace('.json', '');
    console.log(`📥 Import : "${wfName}"`);

    // Vérifier si un workflow du même nom existe déjà
    const existing = existingWorkflows.find(w => w.name === wfName);
    if (existing) {
      console.log(`   ⏭  Déjà présent [ID: ${existing.id}] — mise à jour...`);

      // PUT pour mettre à jour le workflow existant
      const updateBody = { ...workflowData };
      delete updateBody.id;
      updateBody.tags = [];

      const updateRes = await request(
        'PUT',
        `/rest/workflows/${existing.id}`,
        updateBody,
        authHeaders
      );
      if (updateRes.status === 200) {
        console.log(`   ✅ Mis à jour ! [ID: ${existing.id}]`);
        successCount++;
      } else {
        console.error(`   ❌ Échec mise à jour (${updateRes.status}) :`,
          JSON.stringify(updateRes.body).substring(0, 200));
        errorCount++;
      }
    } else {
      // POST pour créer un nouveau workflow
      const createBody = { ...workflowData };
      delete createBody.id;
      createBody.tags = [];

      const createRes = await request('POST', '/rest/workflows', createBody, authHeaders);
      if (createRes.status === 200 || createRes.status === 201) {
        const newId = createRes.body.data?.id || createRes.body.id || '?';
        console.log(`   ✅ Créé ! [ID: ${newId}]`);
        successCount++;
      } else {
        console.error(`   ❌ Échec création (${createRes.status}) :`,
          JSON.stringify(createRes.body).substring(0, 300));
        errorCount++;
      }
    }
    console.log();
  }

  // RÉSUMÉ
  console.log('══════════════════════════════════════════════════');
  console.log(` ✅ Import terminé : ${successCount} succès, ${skipCount} ignorés, ${errorCount} erreurs`);
  console.log('══════════════════════════════════════════════════\n');

  if (errorCount > 0) {
    console.log('⚠️  Certains workflows n\'ont pas pu être importés.');
    console.log('   Vérifie les messages d\'erreur ci-dessus.\n');
  }

  console.log('📌 Prochaines étapes :');
  console.log('   1. Dans N8N, ouvrir chaque workflow et vérifier les credentials assignés');
  console.log('   2. Activer WF-04 (alertes revenus) en premier');
  console.log('   3. Tester WF-04 avec un paiement Stripe sandbox');
  console.log('   4. Créer le bot Telegram (@BotFather) pour WF-03/08\n');
}

main().catch(err => {
  console.error('\n💥 Erreur inattendue :', err.message);
  process.exit(1);
});
