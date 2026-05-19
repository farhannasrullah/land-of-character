require("dotenv").config();
const express = require("express");
const cors = require("cors");
const path = require("path");

const app = express();
app.use(cors());
app.use(express.static(path.join(__dirname, "public"))); 

const ROBLOX_API_KEY = process.env.ROBLOX_API_KEY;
const UNIVERSE_ID = process.env.UNIVERSE_ID;

// [FUNGSI 1] Tarik Username Asli Roblox
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

// [FUNGSI 2] Tarik Data dari DataStore Biasa
async function fetchRobloxData(datastoreName, entryKey) {
  const url = `https://apis.roblox.com/datastores/v1/universes/${UNIVERSE_ID}/standard-datastores/datastore/entries/entry?datastoreName=${datastoreName}&entryKey=${entryKey}`;
  
  try {
    const response = await fetch(url, {
      method: "GET",
      headers: { "x-api-key": ROBLOX_API_KEY }
    });

    if (response.status === 404) return null; 
    if (!response.ok) throw new Error(`Status: ${response.status}`);
    
    return await response.json();
  } catch (error) {
    console.error(`[Error] ${datastoreName} -> ${entryKey}:`, error.message);
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

    // Eksekusi semua request secara paralel
    const [
      robloxUser,
      ecoData,
      profileData,
      scoreTruth,
      scoreTime,
      scoreMagic,
      scoreKind,
      scoreTrust
    ] = await Promise.all([
      fetchRobloxUsername(userId),
      fetchEcoSmart(),
      fetchRobloxData("RoleplayProfileDB_V3", `${userId}_RPName`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Truth`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Time`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Magic`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Kind`),
      fetchRobloxData("LandOfCharacter_Scores_V2", `${userId}_Trust`)
    ]);

    // Kirim JSON lengkap ke Frontend
    res.json({
      RobloxAccount: robloxUser,
      RoleplayEcoDB_V4: ecoData,
      RoleplayProfileDB_V3: profileData,
      Scores: {
        Truth: scoreTruth,
        Time: scoreTime,
        Magic: scoreMagic,
        Kind: scoreKind,
        Trust: scoreTrust
      }
    });

  } catch (error) {
    console.error("Fatal Error:", error);
    res.status(500).json({ error: "Terjadi kesalahan internal server." });
  }
});

// [ENDPOINT 2] Endpoint Khusus Leaderboard (Ordered DataStore)
// [ENDPOINT 2] Endpoint Khusus Leaderboard (Ordered DataStore)
app.get("/api/leaderboard/:type", async (req, res) => {
    const type = req.params.type;
    let odsName = "";
  
    // Tentukan DataStore mana yang mau ditarik berdasarkan tombol
    if (type === "coins") odsName = "Leaderboard_Coins";
    else if (type === "level") odsName = "Leaderboard_Level";
    else if (type === "score") odsName = "Leaderboard_TotalScore";
    else return res.status(400).json({ error: "Kategori leaderboard tidak valid" });
  
    // Ambil 50 data teratas secara menurun (descending)
    const url = `https://apis.roblox.com/ordered-data-stores/v1/universes/${UNIVERSE_ID}/orderedDataStores/${odsName}/scopes/global/entries?max_page_size=50&order_by=desc`;
  
    try {
      const response = await fetch(url, {
        method: "GET",
        headers: { "x-api-key": ROBLOX_API_KEY }
      });
  
      // [ANTI-CRASH] Jika OrderedDataStore belum ada/kosong, jangan error! Kirim array kosong.
      if (response.status === 404) {
        return res.json([]); 
      }
  
      // Jika ada error lain selain 404, tangkap pesan aslinya dari Roblox biar gampang di-debug
      if (!response.ok) {
        const errText = await response.text();
        throw new Error(`Roblox API Error (Status ${response.status}): ${errText}`);
      }
  
      const data = await response.json();
  
      // Jika belum ada entry di dalam DataStore
      if (!data.entries) {
        return res.json([]); 
      }
  
      // Ubah User ID menjadi Username secara otomatis
      const leaderboardData = await Promise.all(
        data.entries.map(async (entry, index) => {
          const user = await fetchRobloxUsername(entry.id);
          return {
            rank: index + 1,
            userId: entry.id,
            username: user.name,
            displayName: user.displayName,
            value: entry.value
          };
        })
      );
  
      res.json(leaderboardData);
  
    } catch (error) {
      console.error("Leaderboard Error:", error.message);
      res.status(500).json({ error: "Gagal mengambil data leaderboard. Cek terminal untuk detailnya." });
    }
  });

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`=================================`);
  console.log(`Web Dashboard Server Berjalan!`);
  console.log(`Buka: http://localhost:${PORT}`);
  console.log(`=================================`);
});