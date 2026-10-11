import admin from "firebase-admin";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const serviceAccount = JSON.parse(
  readFileSync(join(__dirname, "serviceAccountKey.json"), "utf8")
);

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

if (process.env.CONFIRM !== "YES") {
  console.error(
    "Esto BORRA todos los Users (incl. subcolecciones) y TODAS las cuentas de Auth."
  );
  console.error("Vuelve a ejecutarlo con: CONFIRM=YES node reset_users.mjs");
  process.exit(1);
}

// 1) Subcolecciones huérfanas: Users/{uid}/appointments  (via collection group)
const appts = await db.collectionGroup("appointments").get();
const parents = new Set();
for (const doc of appts.docs) {
  const parts = doc.ref.path.split("/");
  if (parts[0] === "Users" && parts[1]) parents.add(parts[1]);
}
console.log(`appointments encontradas: ${appts.size} (en ${parents.size} usuarios)`);

for (const uid of parents) {
  await db.recursiveDelete(db.collection("Users").doc(uid));
}
console.log(`subcolecciones borradas para ${parents.size} usuarios`);

// 2) Colección Users (docs y restos)
await db.recursiveDelete(db.collection("Users"));
console.log("colección Users borrada");

// 3) Cuentas de Firebase Auth
let token;
let total = 0;
do {
  const list = await admin.auth().listUsers(1000, token);
  const uids = list.users.map((u) => u.uid);
  if (uids.length) {
    const res = await admin.auth().deleteUsers(uids);
    total += res.successCount;
    for (const e of res.errors) {
      console.error(`  fallo uid=${uids[e.index]}: ${e.error.message}`);
    }
  }
  token = list.pageToken;
} while (token);
console.log(`cuentas de Auth borradas: ${total}`);

process.exit(0);
