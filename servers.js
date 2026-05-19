require("dotenv").config();
const express = require("express");
const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");

// Load credentials
const serviceAccountPath = path.join(__dirname, "serviceAccountKey.json");
let serviceAccount = {};
if (fs.existsSync(serviceAccountPath)) {
  serviceAccount = require(serviceAccountPath);
} else if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
}

// Inisialisasi Firebase
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: process.env.FIREBASE_DATABASE_URL,
  });
}

const db = admin.database();
const app = express();

// MIDDLEWARE CSP: Inject header biar gak diblokir di lokal maupun Vercel
app.use((req, res, next) => {
  res.setHeader(
    "Content-Security-Policy",
    "default-src 'self'; script-src 'self' 'unsafe-inline' https://www.gstatic.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https: http:; connect-src 'self' https://*.firebaseio.com wss://*.firebaseio.com;"
  );
  next();
});

app.use(express.json());

// 1. SERVE FRONTEND (Nanganin halaman utama)
app.use(express.static(__dirname));

// 2. ROBLOX SYNC API (Fungsional v22 dipertahankan)
const SYNC_SECRET = process.env.SYNC_SECRET;
app.post("/api/roblox-sync", async (req, res) => {
  try {
    const secret = req.header("X-Sync-Secret");
    if (secret !== SYNC_SECRET) {
      return res.status(401).json({ ok: false, message: "Unauthorized" });
    }

    const { kind, key, payload } = req.body;
    if (!kind || !key || !payload) {
      return res.status(400).json({ ok: false, message: "Bad payload" });
    }

    let pathRef = "";
    if (kind === "playerSnapshot") {
      pathRef = `players/${key}/profile`;
    } else if (kind === "quizAttempt") {
      pathRef = `players/${key}/quizzes/${payload.quizType}/latest`;
    } else if (kind === "quizBest") {
      pathRef = `players/${key}/quizzes/${payload.quizType}`;
    } else if (kind === "leaderboard") {
      pathRef = `leaderboards/${payload.quizType}/${key}`;
    } else {
      return res.status(400).json({ ok: false, message: "Unknown kind" });
    }

    await db.ref(pathRef).set(payload);
    return res.json({ ok: true, path: pathRef });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ ok: false, message: "Server error" });
  }
});

// 3. FALLBACK ROUTE EXPRESS V5
app.use((req, res) => {
  res.sendFile(path.join(__dirname, "index.html"));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log("Server running on port", PORT);
});

module.exports = app;