import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import admin from "firebase-admin";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, "..");
const DAYS = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];

function parseCsv(text) {
  const clean = text
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n")
    .replace(/^\uFEFF/, "");
  const rows = [];
  let row = [],
    field = "",
    inQuotes = false;
  for (let i = 0; i < clean.length; i++) {
    const c = clean[i];
    if (c === '"') {
      if (inQuotes && clean[i + 1] === '"') {
        field += '"';
        i++;
      } else inQuotes = !inQuotes;
    } else if (!inQuotes && c === ";") {
      row.push(field);
      field = "";
    } else if (!inQuotes && c === "\n") {
      row.push(field);
      rows.push(row);
      row = [];
      field = "";
    } else field += c;
  }
  if (field.length || row.length) {
    row.push(field);
    rows.push(row);
  }
  return rows;
}

const normalize = (s) =>
  s
    .trim()
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");

const slugify = (s) =>
  normalize(s)
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");

function loadCsv(path) {
  const rows = parseCsv(readFileSync(path, "utf8"));
  const headers = rows[0].map(normalize);
  const data = rows.slice(1).filter((r) => r.some((v) => v.trim() !== ""));
  const col = (name) => headers.indexOf(normalize(name));
  return { headers, data, col };
}

function parseDay(cell) {
  if (!cell || !cell.trim()) return [];
  return cell
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean)
    .map((t) => {
      const [start, end] = t.split("-").map((x) => x.trim());
      return { start, end };
    });
}

const parseInsurers = (cell) =>
  (cell || "")
    .split(",")
    .map((s) => s.trim().toUpperCase())
    .filter(Boolean);

const hospitals = loadCsv(join(ROOT, "assets/data/hospitals.csv"));
const hCode = hospitals.col("Código de Centro Normalizado REGCESS (CCN)");
const hName = hospitals.col("Nombre de Centro");
const hRegion = hospitals.col("Comunidad Autónoma");
const hDependence = hospitals.col("Dependencia Funcional");

const centerByCode = new Map();
for (const r of hospitals.data) {
  centerByCode.set(r[hCode].trim(), {
    name: r[hName].trim(),
    region: r[hRegion].trim(),
    dependence: r[hDependence].trim(),
  });
}

const doctors = loadCsv(join(ROOT, "assets/data/doctors.csv"));
const dCode = doctors.col("centerCode");
const dName = doctors.col("name");
const dSpec = doctors.col("specialty");
const dIns = doctors.col("insurers");
const dSlot = doctors.col("slotMinutes");

const docs = [];
for (const r of doctors.data) {
  const centerCode = r[dCode].trim();
  const name = r[dName].trim();
  if (!centerCode || !name) continue;

  const center = centerByCode.get(centerCode);
  if (!center) {
    console.warn(
      `⚠ centerCode ${centerCode} no está en hospitals.csv (${name})`
    );
  }

  const insurers = parseInsurers(r[dIns]);
  const centerInsurers = center
    ? parseInsurers(
        hospitals.data.find((h) => h[hCode].trim() === centerCode)?.[
          hospitals.col("Aseguradoras")
        ] ?? ""
      )
    : [];

  if (insurers.some((i) => !centerInsurers.includes(i))) {
    console.warn(
      `⚠ ${name}: insurers fuera del concierto del hospital ${centerCode}`
    );
  }

  const weekly = {};
  for (const day of DAYS) weekly[day] = parseDay(r[doctors.col(day)] ?? "");

  docs.push({
    id: `${centerCode}_${slugify(name)}`,
    data: {
      name,
      specialty: r[dSpec].trim(),
      insurers,
      centerCode,
      centerName: center?.name ?? "",
      region: center?.region ?? "",
      slotMinutes: Number(r[dSlot]) || 20,
      weekly,
    },
  });
}

const serviceAccount = JSON.parse(
  readFileSync(join(__dirname, "serviceAccountKey.json"), "utf8")
);
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

let batch = db.batch();
let n = 0;
for (const { id, data } of docs) {
  batch.set(db.collection("Doctors").doc(id), data, { merge: true });
  if (++n % 400 === 0) {
    await batch.commit();
    batch = db.batch();
  }
}
await batch.commit();

console.log(`${docs.length} médicos subidos a la colección "Doctors".`);
process.exit(0);
