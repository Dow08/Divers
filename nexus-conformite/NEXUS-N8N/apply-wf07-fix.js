/**
 * apply-wf07-fix.js
 *
 * Applique le fix WF-07 (paramètres email corrects) dans l'instance N8N locale.
 *
 * Usage: node apply-wf07-fix.js
 *
 * Requis: N8N doit tourner sur http://127.0.0.1:5678
 *         Configurer N8N_EMAIL + N8N_PASSWORD ci-dessous
 */

const http = require('http');
const fs = require('fs');
const path = require('path');

// ─── CONFIG ───────────────────────────────────────────────────────────────────
const N8N_BASE = 'http://127.0.0.1:5678';
const N8N_EMAIL = process.env.N8N_EMAIL || 'admin@nexusconformite.fr';
const N8N_PASSWORD = process.env.N8N_PASSWORD || '';   // Set via: SET N8N_PASSWORD=yourpassword
const WF07_NAME = 'WF-07'; // Partial match on workflow name
// ──────────────────────────────────────────────────────────────────────────────

const WF07_JSON_PATH = path.join(__dirname, 'workflows', 'WF-07-livraison-gumroad.json');

// ─── HTTP HELPERS ─────────────────────────────────────────────────────────────
function request(method, path, body, headers = {}) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const options = {
      hostname: '127.0.0.1',
      port: 5678,
      path,
      method,
      headers: {
        'Content-Type': 'application/json',
        ...headers,
        ...(data ? { 'Content-Length': Buffer.byteLength(data) } : {})
      }
    };

    const req = http.request(options, (res) => {
      let chunks = '';
      res.on('data', chunk => chunks += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.status || res.statusCode, body: JSON.parse(chunks), raw: chunks });
        } catch {
          resolve({ status: res.statusCode, body: null, raw: chunks });
        }
      });
    });

    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

// ─── MAIN ─────────────────────────────────────────────────────────────────────
async function main() {
  console.log('🔧 NEXUS CONFORMITÉ — Apply WF-07 Email Fix');
  console.log('='.repeat(50));

  // 1. Login to get session cookie
  console.log('\n1️⃣  Authenticating with N8N...');
  const loginRes = await request('POST', '/rest/login', {
    email: N8N_EMAIL,
    password: N8N_PASSWORD
  });

  if (loginRes.status !== 200) {
    console.error('❌ Login failed. Status:', loginRes.status);
    console.error('   Response:', loginRes.raw.substring(0, 200));
    console.log('\n💡 Set credentials: SET N8N_EMAIL=youremail && SET N8N_PASSWORD=yourpassword');
    process.exit(1);
  }

  // Extract session cookie
  const cookies = loginRes.raw; // we need the Set-Cookie header
  // Actually, use the response headers
  console.log('✅ Logged in successfully');

  // N8N uses cookie-based auth — we need to do this differently with http.request
  // Let's use the API key approach instead
  console.log('\n⚠️  Note: This script uses N8N API key auth.');
  console.log('   Get your API key from N8N Settings → API → Create API Key');
  console.log('   Then run: SET N8N_API_KEY=yourkey && node apply-wf07-fix.js\n');

  const apiKey = process.env.N8N_API_KEY;
  if (!apiKey) {
    console.error('❌ N8N_API_KEY not set.');
    console.log('\n📋 MANUAL INSTRUCTIONS:');
    console.log('   1. Open http://127.0.0.1:5678 in your browser');
    console.log('   2. Go to Settings → n8n API → Create API key');
    console.log('   3. Run: SET N8N_API_KEY=<your_key> && node apply-wf07-fix.js');
    process.exit(1);
  }

  const authHeaders = { 'X-N8N-API-KEY': apiKey };

  // 2. Get all workflows to find WF-07's ID
  console.log('2️⃣  Fetching workflow list...');
  const listRes = await request('GET', '/api/v1/workflows?limit=50', null, authHeaders);

  if (listRes.status !== 200) {
    console.error('❌ Could not list workflows. Status:', listRes.status);
    process.exit(1);
  }

  const workflows = listRes.body.data || [];
  const wf07 = workflows.find(wf => wf.name.includes(WF07_NAME));

  if (!wf07) {
    console.log('⚠️  WF-07 not found in N8N. Available workflows:');
    workflows.forEach(wf => console.log(`   - [${wf.id}] ${wf.name}`));
    console.log('\n💡 WF-07 may need to be imported first.');
    console.log('   Run: node import-workflows.js');
    process.exit(1);
  }

  console.log(`✅ Found WF-07: [${wf07.id}] "${wf07.name}" (active: ${wf07.active})`);

  // 3. Fetch full WF-07 from N8N
  console.log('\n3️⃣  Fetching full WF-07 from N8N...');
  const fetchRes = await request('GET', `/api/v1/workflows/${wf07.id}`, null, authHeaders);

  if (fetchRes.status !== 200) {
    console.error('❌ Could not fetch WF-07. Status:', fetchRes.status);
    process.exit(1);
  }

  const currentWF = fetchRes.body;
  console.log(`✅ Fetched — ${currentWF.nodes.length} nodes, versionId: ${currentWF.versionId}`);

  // 4. Load the fixed JSON from disk
  console.log('\n4️⃣  Loading fixed WF-07 JSON from disk...');
  const fixedJSON = JSON.parse(fs.readFileSync(WF07_JSON_PATH, 'utf8'));

  // 5. Merge: apply fixed node parameters from disk JSON into current N8N workflow
  console.log('\n5️⃣  Merging fixed email parameters...');
  let fixCount = 0;

  const updatedNodes = currentWF.nodes.map(currentNode => {
    const fixedNode = fixedJSON.nodes.find(n => n.name === currentNode.name);
    if (!fixedNode) return currentNode;

    if (currentNode.type === 'n8n-nodes-base.emailSend') {
      const oldFormat = currentNode.parameters.emailFormat || currentNode.parameters.emailType || 'MISSING';
      const newFormat = fixedNode.parameters.emailFormat;
      const oldHtml = currentNode.parameters.html || currentNode.parameters.message || '';
      const newHtml = fixedNode.parameters.html || '';

      if (oldFormat !== newFormat || oldHtml.length !== newHtml.length) {
        console.log(`  ✏️  "${currentNode.name}": emailFormat ${oldFormat}→${newFormat}, html ${oldHtml.length}→${newHtml.length} chars`);
        fixCount++;

        return {
          ...currentNode,
          parameters: {
            ...currentNode.parameters,
            // Remove old wrong keys
            emailType: undefined,
            message: undefined,
            // Apply correct keys
            emailFormat: fixedNode.parameters.emailFormat,
            html: fixedNode.parameters.html,
            subject: fixedNode.parameters.subject || currentNode.parameters.subject,
            toEmail: fixedNode.parameters.toEmail || currentNode.parameters.toEmail,
          }
        };
      }
    }
    return currentNode;
  });

  // Clean up undefined keys
  const cleanNodes = JSON.parse(JSON.stringify(updatedNodes));

  if (fixCount === 0) {
    console.log('✅ No fixes needed — WF-07 email nodes already correct!');
    process.exit(0);
  }

  console.log(`\n  → Applied ${fixCount} fix(es)`);

  // 6. PATCH the workflow
  console.log('\n6️⃣  Saving updated workflow to N8N...');
  const patchBody = {
    ...currentWF,
    nodes: cleanNodes
  };

  const patchRes = await request('PATCH', `/api/v1/workflows/${wf07.id}`, patchBody, authHeaders);

  if (patchRes.status !== 200) {
    console.error('❌ PATCH failed. Status:', patchRes.status);
    console.error('   Response:', patchRes.raw.substring(0, 500));
    process.exit(1);
  }

  console.log('✅ WF-07 updated successfully!');

  // 7. Activate if not active
  if (!wf07.active) {
    console.log('\n7️⃣  Activating WF-07...');
    const newVersionId = patchRes.body.versionId;
    const activateRes = await request('POST', `/rest/workflows/${wf07.id}/activate`,
      { versionId: newVersionId }, authHeaders);

    if (activateRes.status === 200) {
      console.log('✅ WF-07 activated!');
    } else {
      console.log(`⚠️  Activation returned status ${activateRes.status} — activate manually in N8N UI`);
    }
  } else {
    console.log('\n✅ WF-07 was already active');
  }

  console.log('\n' + '='.repeat(50));
  console.log('🎉 WF-07 fix applied successfully!');
  console.log('\n📋 Next: Test with a Gumroad webhook payload:');
  console.log('   curl -X POST http://127.0.0.1:5678/webhook/gumroad-livraison \\');
  console.log('     -H "Content-Type: application/json" \\');
  console.log('     -d \'{"email":"test@example.com","product_name":"Kit RGPD NEXUS","price":97,"sale_id":"TEST123"}\'');
}

main().catch(err => {
  console.error('❌ Fatal error:', err.message);
  process.exit(1);
});
