require("dotenv").config();
const express = require("express");
const cors = require("cors");
const path = require("path");

const app = express();
app.use(cors());
app.use(express.static(path.join(__dirname, "public"))); 

const ROBLOX_API_KEY = process.env.ROBLOX_API_KEY;
const UNIVERSE_ID = process.env.UNIVERSE_ID;

// ==========================================
// KONFIGURASI BEBAN SERVER
// ==========================================
// Atur berapa maksimal data pemain yang ditarik sekaligus di tab "Semua Pemain"
// Semakin kecil angkanya, semakin ringan dan cepat server memprosesnya.
const MAX_USERS_FETCH = 100; 
// ==========================================

async function fetchRobloxUsername(userId) {
  try {
    const response = await fetch(`https://users.roblox.com/v1/users/${userId}`);
    if (!response.ok) return { name: "Unknown", displayName: "Unknown" };
    const data = await response.json();
    return { name: data.name, displayName: data.displayName };
  } catch (error) {
    return { name: "Unknown", displayName: "Unknown" };
  }
}

async function fetchRobloxAvatar(userId) {
  try {
    const response = await fetch(`https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=${userId}&size=150x150&format=Png&isCircular=true`);
    const data = await response.json();
    if (data && data.data && data.data.length > 0) {
      return data.data[0].imageUrl;
    }
    return "";
  } catch (error) {
    return "";
  }
}

async function fetchRobloxData(datastoreName, entryKey) {
  const url = `https://apis.roblox.com/datastores/v1/universes/${UNIVERSE_ID}/standard-datastores/datastore/entries/entry?datastoreName=${datastoreName}&entryKey=${entryKey}`;
  try {
    const response = await fetch(url, { method: "GET", headers: { "x-api-key": ROBLOX_API_KEY } });
    if (response.status === 404) return null; 
    if (!response.ok) throw new Error(`Status: ${response.status}`);
    return await response.json();
  } catch (error) {
    return null;
  }
}

// [ENDPOINT 1] Pencarian Spesifik Berdasarkan User ID
app.get("/api/player/:userId", async (req, res) => {
  const userId = req.params.userId;

  try {
    const fetchEcoSmart = async () => {
      let data = await fetchRobloxData("RoleplayEcoDB_V4", `Player_${userId}`);
      if (!data) data = await fetchRobloxData("RoleplayEcoDB_V4", userId);
      return data;
    };

    const [
      robloxUser, avatarUrl, ecoData, profileData,
      scoreTruth, scoreTime, scoreMagic, scoreKind, scoreTrust
    ] = await Promise.all([
      fetchRobloxUsername(userId),
      fetchRobloxAvatar(userId),
      fetchEcoSmart(),
      fetchRobloxData("RoleplayProfileDB_V3", `${userId}_RPName`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Truth`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Time`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Magic`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Kind`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Trust`)
    ]);

    res.json({
      RobloxAccount: { ...robloxUser, avatar: avatarUrl },
      RoleplayEcoDB_V4: ecoData,
      RoleplayProfileDB_V3: profileData,
      Scores: { Truth: scoreTruth, Time: scoreTime, Magic: scoreMagic, Kind: scoreKind, Trust: scoreTrust }
    });
  } catch (error) {
    res.status(500).json({ error: "Terjadi kesalahan internal server." });
  }
});

// [ENDPOINT 2] Leaderboard Kategori Lengkap (Max 50 Top Player)
app.get("/api/leaderboard/:type", async (req, res) => {
  const type = req.params.type;
  let odsName = "";

  if (type === "coins") odsName = "Leaderboard_Coins";
  else if (type === "level") odsName = "Leaderboard_Level";
  else if (type === "score") odsName = "Leaderboard_TotalScore";
  else return res.status(400).json({ error: "Kategori invalid" });

  const url = `https://apis.roblox.com/ordered-data-stores/v1/universes/${UNIVERSE_ID}/orderedDataStores/${odsName}/scopes/global/entries?max_page_size=50&order_by=desc`;

  try {
    const response = await fetch(url, { method: "GET", headers: { "x-api-key": ROBLOX_API_KEY } });
    if (response.status === 404) return res.json([]); 
    if (!response.ok) throw new Error(`Status ${response.status}`);
    
    const data = await response.json();
    if (!data.entries) return res.json([]); 

    const leaderboardData = await Promise.all(
      data.entries.map(async (entry, index) => {
        const userId = entry.id;
        const [user, avatar, profile, eco] = await Promise.all([
          fetchRobloxUsername(userId),
          fetchRobloxAvatar(userId),
          fetchRobloxData("RoleplayProfileDB_V3", `${userId}_RPName`),
          fetchRobloxData("RoleplayEcoDB_V4", `Player_${userId}`).then(res => res || fetchRobloxData("RoleplayEcoDB_V4", userId))
        ]);

        return {
          rank: index + 1,
          userId: userId,
          username: user.name || "Unknown",
          displayName: user.displayName || "Unknown",
          avatar: avatar,
          value: entry.value,
          rpName: profile || "-",
          school: eco?.School || eco?.school || "-",
          class: eco?.Class || eco?.class || "-",
          level: eco?.Level || eco?.level || 1
        };
      })
    );

    res.json(leaderboardData);
  } catch (error) {
    res.status(500).json({ error: "Gagal mengambil leaderboard." });
  }
});

// [ENDPOINT 3] Semua Pemain (Max ditentukan oleh MAX_USERS_FETCH)
app.get("/api/users", async (req, res) => {
  // Disini kita gunakan variabel konfigurasi MAX_USERS_FETCH
  const url = `https://apis.roblox.com/ordered-data-stores/v1/universes/${UNIVERSE_ID}/orderedDataStores/Leaderboard_Level/scopes/global/entries?max_page_size=${MAX_USERS_FETCH}&order_by=desc`;

  try {
    const response = await fetch(url, { method: "GET", headers: { "x-api-key": ROBLOX_API_KEY } });
    if (response.status === 404) return res.json([]); 
    if (!response.ok) throw new Error(`Status ${response.status}`);
    
    const data = await response.json();
    if (!data.entries) return res.json([]); 

    const usersData = await Promise.all(
      data.entries.map(async (entry) => {
        const userId = entry.id;
        const [user, avatar, profile, eco] = await Promise.all([
          fetchRobloxUsername(userId),
          fetchRobloxAvatar(userId),
          fetchRobloxData("RoleplayProfileDB_V3", `${userId}_RPName`),
          fetchRobloxData("RoleplayEcoDB_V4", `Player_${userId}`).then(res => res || fetchRobloxData("RoleplayEcoDB_V4", userId))
        ]);

        return {
          userId: userId,
          username: user.name || "Unknown",
          displayName: user.displayName || "Unknown",
          avatar: avatar,
          value: entry.value, 
          rpName: profile || "-",
          school: eco?.School || eco?.school || "-",
          class: eco?.Class || eco?.class || "-",
          level: eco?.Level || eco?.level || 1
        };
      })
    );

    res.json(usersData);
  } catch (error) {
    res.status(500).json({ error: "Gagal mengambil daftar pemain." });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`=================================`);
  console.log(`Server Monitoring Aktif: Port ${PORT}`);
  console.log(`MAX_USERS_FETCH disetel ke: ${MAX_USERS_FETCH} pemain`);
  console.log(`=================================`);
});