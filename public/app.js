// ==========================================
// FUNGSI BANTUAN
// ==========================================
function displayValue(val, property) {
  if (val === null || val === undefined) return "-";
  
  if (typeof val === "object" && property) {
    const exactKey = Object.keys(val).find(k => k.toLowerCase() === property.toLowerCase());
    return exactKey ? val[exactKey] : "-";
  }
  
  return val;
}

// ==========================================
// SISTEM PENCARIAN DATA LENGKAP
// ==========================================
async function fetchData() {
  const userId = document.getElementById("userIdInput").value;
  const errorMsg = document.getElementById("errorMsg");
  const resultBox = document.getElementById("resultBox");

  errorMsg.style.display = "none";
  resultBox.style.display = "none";

  if (!userId) {
    errorMsg.textContent = "Harap masukkan User ID!";
    errorMsg.style.display = "block";
    return;
  }

  try {
    const response = await fetch(`/api/player/${userId}`);
    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || "Gagal mengambil data dari server.");
    }

    // Tampilkan Data Akun Asli Roblox
    if (data.RobloxAccount) {
      document.getElementById("resUsername").textContent = `@${data.RobloxAccount.name}`;
      document.getElementById("resDisplayName").textContent = data.RobloxAccount.displayName;
    } else {
      document.getElementById("resUsername").textContent = "-";
      document.getElementById("resDisplayName").textContent = "-";
    }

    // Tampilkan Data Eco
    const eco = data.RoleplayEcoDB_V4;
    document.getElementById("resCoins").textContent = displayValue(eco, "Coins");
    document.getElementById("resLevel").textContent = displayValue(eco, "Level");
    document.getElementById("resSchool").textContent = displayValue(eco, "School");
    document.getElementById("resClass").textContent = displayValue(eco, "Class");

    // Tampilkan Data Profile
    document.getElementById("resRpName").textContent = displayValue(data.RoleplayProfileDB_V3);

    // Tampilkan Data Score
    document.getElementById("scoreTruth").textContent = displayValue(data.Scores.Truth);
    document.getElementById("scoreTime").textContent = displayValue(data.Scores.Time);
    document.getElementById("scoreMagic").textContent = displayValue(data.Scores.Magic);
    document.getElementById("scoreKind").textContent = displayValue(data.Scores.Kind);
    document.getElementById("scoreTrust").textContent = displayValue(data.Scores.Trust);
    
    // Tampilkan JSON mentah
    document.getElementById("resRaw").textContent = JSON.stringify(data, null, 2);
    
    resultBox.style.display = "block";

  } catch (error) {
    errorMsg.textContent = error.message;
    errorMsg.style.display = "block";
  }
}

document.getElementById("searchBtn").addEventListener("click", fetchData);
document.getElementById("userIdInput").addEventListener("keypress", function(event) {
  if (event.key === "Enter") fetchData();
});

// ==========================================
// SISTEM LEADERBOARD
// ==========================================
async function loadLeaderboard(type) {
  const tbody = document.getElementById("lbBody");
  const headerValue = document.getElementById("lbValueHeader");
  
  if (type === "coins") headerValue.textContent = "Total Coins";
  if (type === "level") headerValue.textContent = "Player Level";
  if (type === "score") headerValue.textContent = "Total Quiz Score";

  tbody.innerHTML = `
    <tr>
      <td colspan="4" style="text-align: center; padding: 30px; color: #00ff88;">
        Menarik data dari server Roblox...
      </td>
    </tr>
  `;

  try {
    const response = await fetch(`/api/leaderboard/${type}`);
    const data = await response.json();

    if (!response.ok) throw new Error(data.error || "Gagal mengambil leaderboard");

    if (data.length === 0) {
      tbody.innerHTML = `
        <tr>
          <td colspan="4" style="text-align: center; padding: 30px; color: #ff4d4d;">
            Belum ada data pemain di kategori ini. Pastikan ada player yang bermain terlebih dahulu.
          </td>
        </tr>
      `;
      return;
    }

    tbody.innerHTML = "";
    data.forEach((player) => {
      const tr = document.createElement("tr");
      
      let rankStyle = "color: #fff;";
      if (player.rank === 1) rankStyle = "color: #ffd700; font-size: 18px; font-weight: bold;";
      if (player.rank === 2) rankStyle = "color: #c0c0c0; font-weight: bold;";
      if (player.rank === 3) rankStyle = "color: #cd7f32; font-weight: bold;";

      tr.innerHTML = `
        <td style="${rankStyle}">#${player.rank}</td>
        <td>
          <strong style="font-size: 16px;">${player.displayName}</strong><br>
          <span style="font-size: 12px; color: #888;">@${player.username}</span>
        </td>
        <td style="font-family: monospace; color: #aaa;">${player.userId}</td>
        <td style="font-size: 18px; font-weight: bold; color: #00ff88;">${player.value.toLocaleString('id-ID')}</td>
      `;
      
      // Fitur tambahan: Jika baris tabel di-klik, langsung cari detail player tersebut!
      tr.style.cursor = "pointer";
      tr.onclick = () => {
        document.getElementById("userIdInput").value = player.userId;
        fetchData();
        // Scroll otomatis ke bagian bawah (hasil pencarian detail)
        document.getElementById("searchBtn").scrollIntoView({ behavior: 'smooth' });
      };

      tbody.appendChild(tr);
    });

  } catch (error) {
    tbody.innerHTML = `
      <tr>
        <td colspan="4" style="text-align: center; padding: 30px; color: #ff4d4d;">
          Error: ${error.message}
        </td>
      </tr>
    `;
  }
}

// Otomatis memuat daftar pemain (Top Level) saat website pertama kali dibuka
window.addEventListener("DOMContentLoaded", () => {
  loadLeaderboard('level');
});