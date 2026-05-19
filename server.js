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

// [FUNGSI 2] Tarik Data dari DataStore
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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`=================================`);
  console.log(`Web Dashboard Server Berjalan!`);
  console.log(`=================================`);
});