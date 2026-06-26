require("dotenv").config();
const express = require("express");
const cors = require("cors");
const path = require("path");

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

const ROBLOX_API_KEY = process.env.ROBLOX_API_KEY;
const UNIVERSE_ID = process.env.UNIVERSE_ID;

// ==========================================
// KONFIGURASI BEBAN SERVER
// ==========================================
const MAX_USERS_FETCH = 100;
// ==========================================

function getEntryUserId(entry) {
  return String(entry?.key ?? entry?.id ?? "");
}

async function fetchRobloxUsername(userId) {
  try {
    const response = await fetch(`https://users.roblox.com/v1/users/${userId}`);

    if (!response.ok) {
      return { name: "Unknown", displayName: "Unknown" };
    }

    const data = await response.json();

    return {
      name: data.name || "Unknown",
      displayName: data.displayName || "Unknown",
    };
  } catch (error) {
    return { name: "Unknown", displayName: "Unknown" };
  }
}

async function fetchRobloxAvatar(userId) {
  try {
    const response = await fetch(
      `https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=${userId}&size=150x150&format=Png&isCircular=true`
    );

    if (!response.ok) return "";

    const data = await response.json();

    if (data && data.data && data.data.length > 0) {
      return data.data[0].imageUrl || "";
    }

    return "";
  } catch (error) {
    return "";
  }
}

async function fetchRobloxData(datastoreName, entryKey) {
  const url = `https://apis.roblox.com/datastores/v1/universes/${UNIVERSE_ID}/standard-datastores/datastore/entries/entry?datastoreName=${encodeURIComponent(
    datastoreName
  )}&entryKey=${encodeURIComponent(String(entryKey))}`;

  try {
    const response = await fetch(url, {
      method: "GET",
      headers: {
        "x-api-key": ROBLOX_API_KEY,
      },
    });

    if (response.status === 404) return null;
    if (!response.ok) throw new Error(`Status: ${response.status}`);

    return await response.json();
  } catch (error) {
    return null;
  }
}

// ==========================================
// ECO DATA
// ==========================================

async function fetchEcoSmart(userId) {
  let data = await fetchRobloxData("RoleplayEcoDB_V4", String(userId));
  if (!data) {
    data = await fetchRobloxData("RoleplayEcoDB_V4", `Player_${userId}`);
  }
  return data;
}

// ==========================================
// PROFILE DATA (Update: Tambah Gender)
// ==========================================

async function fetchProfileData(userId) {
  const [rpName, school, className, gender] = await Promise.all([
    fetchRobloxData("RoleplayProfileDB_V3", `${userId}_RPName`),
    fetchRobloxData("RoleplayProfileDB_V3", `${userId}_School`),
    fetchRobloxData("RoleplayProfileDB_V3", `${userId}_Class`),
    fetchRobloxData("RoleplayProfileDB_V3", `${userId}_Gender`),
  ]);

  return {
    rpName: rpName || "-",
    school: school || "-",
    class: className || "-",
    gender: gender || "-",
  };
}

// ==========================================
// JOURNEY DATA (BARU)
// ==========================================

async function fetchJourneyData(userId) {
  const [activeLock, j5Type] = await Promise.all([
    fetchRobloxData("JourneyLockDB_V1", `${userId}_ActiveLock`),
    fetchRobloxData("JourneyStateDB_V5", `${userId}_J5_Type`),
  ]);
  return { activeLock, j5Type };
}

// ==========================================
// REWARD DATA (BARU)
// ==========================================

async function fetchRewardData(userId) {
  const completedQuizzes = await fetchRobloxData(
    "RoleplayRewardDB_V1",
    `${userId}_CompletedQuizzes`
  );
  return { completedQuizzes };
}

// ==========================================
// ENDPOINT 1: PLAYER DETAIL
// ==========================================

app.get("/api/player/:userId", async (req, res) => {
  const userId = String(req.params.userId);

  try {
    const [
      robloxUser,
      avatarUrl,
      ecoData,
      profileData,
      journeyData,
      rewardData,
      scoreTruth,
      scoreTime,
      scoreMagic,
      scoreKind,
      scoreTrust,
      scoreTTS_Time,
      scoreTTS_Truth,
      scoreTTS_Kind,
      scoreTTS_Trust,
      scoreTTS_Magic,
    ] = await Promise.all([
      fetchRobloxUsername(userId),
      fetchRobloxAvatar(userId),
      fetchEcoSmart(userId),
      fetchProfileData(userId),
      fetchJourneyData(userId),
      fetchRewardData(userId),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Truth`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Time`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Magic`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Kind`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Trust`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_TTS_Time`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_TTS_Truth`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_TTS_Kind`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_TTS_Trust`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_TTS_Magic`),
    ]);

    res.json({
      RobloxAccount: {
        ...robloxUser,
        avatar: avatarUrl,
      },
      RoleplayEcoDB_V4: ecoData,
      RoleplayProfileDB_V3: profileData,
      JourneyLockDB_V1: journeyData,
      RoleplayRewardDB_V1: rewardData,
      Scores: {
        Truth: scoreTruth,
        Time: scoreTime,
        Magic: scoreMagic,
        Kind: scoreKind,
        Trust: scoreTrust,
        TTS_Time: scoreTTS_Time,
        TTS_Truth: scoreTTS_Truth,
        TTS_Kind: scoreTTS_Kind,
        TTS_Trust: scoreTTS_Trust,
        TTS_Magic: scoreTTS_Magic,
      },
    });
  } catch (error) {
    console.error("[/api/player] Error:", error);
    res.status(500).json({
      error: "Terjadi kesalahan internal server.",
    });
  }
});

// ==========================================
// ENDPOINT 2: LEADERBOARD
// ==========================================

app.get("/api/leaderboard/:type", async (req, res) => {
  const type = req.params.type;
  let odsName = "";

  if (type === "coins") odsName = "Leaderboard_Coins";
  else if (type === "level") odsName = "Leaderboard_Level";
  else if (type === "score") odsName = "Leaderboard_TotalScore";
  else return res.status(400).json({ error: "Kategori invalid" });

  const url = `https://apis.roblox.com/ordered-data-stores/v1/universes/${UNIVERSE_ID}/orderedDataStores/${odsName}/scopes/global/entries?max_page_size=50&order_by=desc`;

  try {
    const response = await fetch(url, {
      method: "GET",
      headers: {
        "x-api-key": ROBLOX_API_KEY,
      },
    });

    if (response.status === 404) return res.json([]);
    if (!response.ok) throw new Error(`Status ${response.status}`);

    const data = await response.json();
    if (!data.entries) return res.json([]);

    const leaderboardData = await Promise.all(
      data.entries.map(async (entry, index) => {
        const userId = getEntryUserId(entry);
        if (!userId) {
          return null;
        }

        const [user, avatar, profile, eco] = await Promise.all([
          fetchRobloxUsername(userId),
          fetchRobloxAvatar(userId),
          fetchProfileData(userId),
          fetchEcoSmart(userId),
        ]);

        return {
          rank: index + 1,
          userId,
          username: user.name || "Unknown",
          displayName: user.displayName || "Unknown",
          avatar,
          value: entry.value,
          rpName: profile.rpName || "-",
          school: profile.school || "-",
          class: profile.class || "-",
          level: eco?.Level || eco?.level || 1,
        };
      })
    );

    res.json(leaderboardData.filter(Boolean));
  } catch (error) {
    console.error("[/api/leaderboard] Error:", error);
    res.status(500).json({
      error: "Gagal mengambil leaderboard.",
    });
  }
});

// ==========================================
// ENDPOINT 3: ALL USERS
// ==========================================

app.get("/api/users", async (req, res) => {
  const url = `https://apis.roblox.com/ordered-data-stores/v1/universes/${UNIVERSE_ID}/orderedDataStores/Leaderboard_Level/scopes/global/entries?max_page_size=${MAX_USERS_FETCH}&order_by=desc`;

  try {
    const response = await fetch(url, {
      method: "GET",
      headers: {
        "x-api-key": ROBLOX_API_KEY,
      },
    });

    if (response.status === 404) return res.json([]);
    if (!response.ok) throw new Error(`Status ${response.status}`);

    const data = await response.json();
    if (!data.entries) return res.json([]);

    const usersData = await Promise.all(
      data.entries.map(async (entry) => {
        const userId = getEntryUserId(entry);
        if (!userId) {
          return null;
        }

        const [user, avatar, profile, eco] = await Promise.all([
          fetchRobloxUsername(userId),
          fetchRobloxAvatar(userId),
          fetchProfileData(userId),
          fetchEcoSmart(userId),
        ]);

        return {
          userId,
          username: user.name || "Unknown",
          displayName: user.displayName || "Unknown",
          avatar,
          value: entry.value,
          rpName: profile.rpName || "-",
          school: profile.school || "-",
          class: profile.class || "-",
          level: eco?.Level || eco?.level || 1,
        };
      })
    );

    res.json(usersData.filter(Boolean));
  } catch (error) {
    console.error("[/api/users] Error:", error);
    res.status(500).json({
      error: "Gagal mengambil daftar pemain.",
    });
  }
});

// ==========================================
// START SERVER
// ==========================================

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log("=================================");
  console.log(`Server Monitoring Aktif: Port ${PORT}`);
  console.log(`MAX_USERS_FETCH disetel ke: ${MAX_USERS_FETCH} pemain`);
  console.log("=================================");
});