import admin from "firebase-admin";
import { readFileSync } from "node:fs";

const serviceAccount = JSON.parse(
  readFileSync(new URL("./serviceAccountKey.json", import.meta.url), "utf8"),
);

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

const db = admin.firestore();
const COUNT = Number(process.argv[2] ?? 2);
const now = Date.now();

const users = await db.collection("Users").listDocuments();

for (const userRef of users) {
  const snap = await userRef.collection("appointments").get();
  if (snap.empty) continue;

  const base = snap.docs.map((d) => d.data()).find((x) => x.medicalCenter && x.doctorId);
  if (!base) continue;

  for (let i = 1; i <= COUNT; i++) {
    const date = new Date(now + i * 86400000);
    date.setHours(10, 0, 0, 0);

    const data = {
      ...base,
      status: "scheduled",
      date: admin.firestore.Timestamp.fromDate(date),
      queueNumber: null,
      checkedInAt: null,
      calledAt: null,
      checkInSignature: null,
      roomCode: "C1",
      roomLabel: "Consulta 1",
    };
    delete data.slotId;

    await userRef.collection("appointments").add(data);
  }

  console.log(`Sembradas ${COUNT} citas para ${userRef.id}`);
}

process.exit(0);
