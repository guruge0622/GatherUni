// Usage: node set_admin.js /path/to/serviceAccount.json UID
// Or set env var SA_PATH and run: node set_admin.js UID

const admin = require('firebase-admin');
const path = require('path');

async function main() {
  const args = process.argv.slice(2);
  let keyPath = args[0];
  let uid = args[1];

  if (!uid && keyPath && keyPath.match(/^[a-zA-Z0-9_-]{6,}$/)) {
    // If only one arg and it looks like a UID, treat it as uid
    uid = keyPath;
    keyPath = process.env.SA_PATH;
  }

  if (!keyPath) {
    console.error('Service account JSON path required (arg1) or set SA_PATH env var.');
    process.exit(1);
  }
  if (!uid) {
    console.error('UID required as second argument.');
    process.exit(1);
  }

  const fullPath = path.resolve(keyPath);
  const serviceAccount = require(fullPath);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  const db = admin.firestore();

  try {
    await db.collection('users').doc(uid).set({ role: 'admin' }, { merge: true });
    console.log(`Set users/${uid}.role = "admin"`);
  } catch (err) {
    console.error('Error setting admin role:', err);
    process.exit(1);
  }
}

main();
