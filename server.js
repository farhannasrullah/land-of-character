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
// KONFIGURASI BEBAN SERVER & CACHE ENGINE
// ==========================================
const MAX_USERS_FETCH = 100;
const CACHE_TTL = 3 * 60 * 1000; // 3 Menit Cooldown

const serverCache = new Map();
const pendingRequests = new Map();

/**
 * ENGINE: REQUEST COALESCING & CACHING
 * Mencegah Cache Stampede dengan mem-bypass request duplikat.
 */
async function getCachedOrFetch(cacheKey, fetchFunction) {
  // 1. Cek apakah ada data di memori yang masih fresh
  const cached = serverCache.get(cacheKey);
  if (cached && (Date.now() - cached.timestamp < CACHE_TTL)) {
    console.log(`[CACHE HIT] Mengirim data dari memori untuk: ${cacheKey}`);
    return cached.data;
  }

  // 2. MENCEGAH CACHE STAMPEDE
  if (pendingRequests.has(cacheKey)) {
    console.log(`[STAMPEDE PREVENTED] Nebeng request yang sedang berjalan untuk: ${cacheKey}`);
    return pendingRequests.get(cacheKey);
  }

  // 3. Jika kosong, mulai fetch API dan simpan Promisenya
  console.log(`[API FETCH] Menarik data baru dari Roblox untuk: ${cacheKey}`);
  const requestPromise = fetchFunction()
    .then(data => {
      serverCache.set(cacheKey, { data, timestamp: Date.now() });
      pendingRequests.delete(cacheKey);
      return data;
    })
    .catch(err => {
      pendingRequests.delete(cacheKey);
      throw err;
    });

  pendingRequests.set(cacheKey, requestPromise);
  return requestPromise;
}

// ==========================================
// HELPER: ROBLOX API FETCHERS
// ==========================================

function getEntryUserId(entry) {
  return String(entry?.key ?? entry?.id ?? "");
}

async function fetchRobloxUsername(userId) {
  try {
    const response = await fetch(`https://users.roblox.com/v1/users/${userId}`);
    if (!response.ok) return { name: "Unknown", displayName: "Unknown" };
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
      headers: { "x-api-key": ROBLOX_API_KEY },
    });
    if (response.status === 404) return null;
    if (!response.ok) throw new Error(`Status: ${response.status}`);
    return await response.json();
  } catch (error) {
    return null;
  }
}

// ==========================================
// HELPER: ROLEPLAY DATA EXTRACTORS
// ==========================================

async function fetchEcoSmart(userId) {
  let data = await fetchRobloxData("RoleplayEcoDB_V4", String(userId));
  if (!data) data = await fetchRobloxData("RoleplayEcoDB_V4", `Player_${userId}`);
  return data;
}

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

async function fetchJourneyData(userId) {
  const [activeLock, j5Type] = await Promise.all([
    fetchRobloxData("JourneyLockDB_V1", `${userId}_ActiveLock`),
    fetchRobloxData("JourneyStateDB_V5", `${userId}_J5_Type`),
  ]);
  return { activeLock, j5Type };
}

async function fetchRewardData(userId) {
  const completedQuizzes = await fetchRobloxData("RoleplayRewardDB_V1", `${userId}_CompletedQuizzes`);
  return { completedQuizzes };
}

// ==========================================
// ENDPOINT 1: PLAYER DETAIL
// ==========================================

app.get("/api/player/:userId", async (req, res) => {
  const userId = String(req.params.userId);
  const cacheKey = `player_${userId}`;

  try {
    const data = await getCachedOrFetch(cacheKey, async () => {
      const [
        robloxUser, avatarUrl, ecoData, profileData, journeyData, rewardData,
        scoreTruth, scoreTime, scoreMagic, scoreKind, scoreTrust,
        scoreTTS_Time, scoreTTS_Truth, scoreTTS_Kind, scoreTTS_Trust, scoreTTS_Magic,
      ] = await Promise.all([
        fetchRobloxUsername(userId), fetchRobloxAvatar(userId),
        fetchEcoSmart(userId), fetchProfileData(userId),
        fetchJourneyData(userId), fetchRewardData(userId),
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

      return {
        RobloxAccount: { ...robloxUser, avatar: avatarUrl },
        RoleplayEcoDB_V4: ecoData,
        RoleplayProfileDB_V3: profileData,
        JourneyLockDB_V1: journeyData,
        RoleplayRewardDB_V1: rewardData,
        Scores: {
          Truth: scoreTruth, Time: scoreTime, Magic: scoreMagic, Kind: scoreKind, Trust: scoreTrust,
          TTS_Time: scoreTTS_Time, TTS_Truth: scoreTTS_Truth, TTS_Kind: scoreTTS_Kind, TTS_Trust: scoreTTS_Trust, TTS_Magic: scoreTTS_Magic,
        },
      };
    });

    res.json(data);
  } catch (error) {
    console.error(`[/api/player/${userId}] Error:`, error);
    res.status(500).json({ error: "Terjadi kesalahan internal server." });
  }
});

// ==========================================
// ENDPOINT 2: LEADERBOARD
// ==========================================

app.get("/api/leaderboard/:type", async (req, res) => {
  const type = req.params.type;
  const cacheKey = `leaderboard_${type}`;

  let odsName = "";
  if (type === "coins") odsName = "Leaderboard_Coins";
  else if (type === "level") odsName = "Leaderboard_Level";
  else if (type === "score") odsName = "Leaderboard_TotalScore";
  else return res.status(400).json({ error: "Kategori invalid" });

  try {
    const data = await getCachedOrFetch(cacheKey, async () => {
      const url = `https://apis.roblox.com/ordered-data-stores/v1/universes/${UNIVERSE_ID}/orderedDataStores/${odsName}/scopes/global/entries?max_page_size=50&order_by=desc`;
      
      const response = await fetch(url, {
        method: "GET",
        headers: { "x-api-key": ROBLOX_API_KEY },
      });

      if (response.status === 404) return [];
      if (!response.ok) throw new Error(`Status ${response.status}`);

      const responseData = await response.json();
      if (!responseData.entries) return [];

      const leaderboardData = await Promise.all(
        responseData.entries.map(async (entry, index) => {
          const userId = getEntryUserId(entry);
          if (!userId) return null;

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

      return leaderboardData.filter(Boolean);
    });

    res.json(data);
  } catch (error) {
    console.error(`[/api/leaderboard/${type}] Error:`, error);
    res.status(500).json({ error: "Gagal mengambil leaderboard." });
  }
});

// ==========================================
// ENDPOINT 3: ALL USERS
// ==========================================

app.get("/api/users", async (req, res) => {
  const cacheKey = "all_users";

  try {
    const data = await getCachedOrFetch(cacheKey, async () => {
      const url = `https://apis.roblox.com/ordered-data-stores/v1/universes/${UNIVERSE_ID}/orderedDataStores/Leaderboard_Level/scopes/global/entries?max_page_size=${MAX_USERS_FETCH}&order_by=desc`;
      
      const response = await fetch(url, {
        method: "GET",
        headers: { "x-api-key": ROBLOX_API_KEY },
      });

      if (response.status === 404) return [];
      if (!response.ok) throw new Error(`Status ${response.status}`);

      const responseData = await response.json();
      if (!responseData.entries) return [];

      const usersData = await Promise.all(
        responseData.entries.map(async (entry) => {
          const userId = getEntryUserId(entry);
          if (!userId) return null;

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

      return usersData.filter(Boolean);
    });

    res.json(data);
  } catch (error) {
    console.error("[/api/users] Error:", error);
    res.status(500).json({ error: "Gagal mengambil daftar pemain." });
  }
});

// ==========================================
// START SERVER
// ==========================================

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log("==================================================");
  console.log(`[🚀] Dashboard Server Aktif di Port: ${PORT}`);
  console.log(`[⚙️] MAX_USERS_FETCH disetel ke: ${MAX_USERS_FETCH}`);
  console.log(`[🛡️] SISTEM CACHE AKTIF (Request Coalescing ON)`);
  console.log(`[⏱️] Durasi Cooldown Cache: ${CACHE_TTL / 60000} Menit`);
  console.log("==================================================");
});