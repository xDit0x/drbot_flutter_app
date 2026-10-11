import admin from "firebase-admin";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));
const serviceAccount = JSON.parse(
  readFileSync(join(__dirname, "serviceAccountKey.json"), "utf8")
);

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

const emails = process.argv.slice(2);

if (emails.length === 0) {
  console.error("Uso: node delete_user.mjs <email> [email2 ...]");
  process.exit(1);
}

for (const email of emails) {
  try {
    const user = await admin.auth().getUserByEmail(email);
    await admin.auth().deleteUser(user.uid);
    await admin.firestore().collection("Users").doc(user.uid).delete();
    console.log(`borrado: ${email} (uid=${user.uid})`);
  } catch (e) {
    if (e.code === "auth/user-not-found") {
      console.log(`no existe en Auth: ${email}`);
    } else {
      console.error(`fallo ${email}: ${e.message}`);
    }
  }
}

process.exit(0);
