require("dotenv").config();

const express = require("express");
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: process.env.FIREBASE_DATABASE_URL,
});

const db = admin.database();
const app = express();

app.use(express.json());

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

    let path = "";

    if (kind === "playerSnapshot") {
      path = `players/${key}/profile`;
    } else if (kind === "quizAttempt") {
      path = `players/${key}/quizzes/${payload.quizType}/latest`;
    } else if (kind === "quizBest") {
      path = `players/${key}/quizzes/${payload.quizType}`;
    } else if (kind === "leaderboard") {
      path = `leaderboards/${payload.quizType}/${key}`;
    } else {
      return res.status(400).json({ ok: false, message: "Unknown kind" });
    }

    await db.ref(path).set(payload);

    return res.json({ ok: true, path });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ ok: false, message: "Server error" });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log("Server running on port", PORT);
});