// Helper membaca data JSON
function displayValue(val, property) {
  if (val === null || val === undefined) return "-";
  if (typeof val === "object" && property) {
    const exactKey = Object.keys(val).find(k => k.toLowerCase() === property.toLowerCase());
    return exactKey ? val[exactKey] : "-";
  }
  return val;
}

// Manajemen Navigasi Tab
function setActiveTab(type) {
  document.getElementById("btnLevel").classList.remove("active");
  document.getElementById("btnCoins").classList.remove("active");
  document.getElementById("btnScore").classList.remove("active");
  
  if (type === 'level') document.getElementById("btnLevel").classList.add("active");
  if (type === 'coins') document.getElementById("btnCoins").classList.add("active");
  if (type === 'score') document.getElementById("btnScore").classList.add("active");
}

// Manajemen Modal Box
const modal = document.getElementById("playerModal");
const modalLoading = document.getElementById("modalLoading");
const modalData = document.getElementById("modalData");

function closeModal() {
  modal.style.display = "none";
}

// Menutup modal jika klik di area gelap (overlay)
window.onclick = function(event) {
  if (event.target == modal) closeModal();
}

// ==========================================
// RENDER TABEL LEADERBOARD (HALAMAN DEPAN)
// ==========================================
async function loadLeaderboard(type) {
  setActiveTab(type);
  const tbody = document.getElementById("lbBody");
  const headerValue = document.getElementById("lbValueHeader");
  
  if (type === "coins") headerValue.textContent = "Total Coins";
  if (type === "level") headerValue.textContent = "Player Level";
  if (type === "score") headerValue.textContent = "Total Quiz Score";

  tbody.innerHTML = `<tr><td colspan="6" class="loader">MEMUAT SERVER DATA...</td></tr>`;

  try {
    const response = await fetch(`/api/leaderboard/${type}`);
    const data = await response.json();

    if (!response.ok) throw new Error("Gagal mengambil data dari server");

    if (data.length === 0) {
      tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:30px; color:var(--text-muted);">Belum ada data terekam.</td></tr>`;
      return;
    }

    tbody.innerHTML = "";
    data.forEach((player) => {
      const tr = document.createElement("tr");
      
      let rankStyle = "color: var(--text-muted);";
      if (player.rank === 1) rankStyle = "color: #ffd700; font-weight: bold; font-size: 16px;";
      else if (player.rank === 2) rankStyle = "color: #c0c0c0; font-weight: bold;";
      else if (player.rank === 3) rankStyle = "color: #cd7f32; font-weight: bold;";

      // Gunakan fallback gambar jika avatar tidak ditemukan
      const avatarSrc = player.avatar ? player.avatar : "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='45' height='45' fill='%2327272a'><rect width='100%' height='100%'/></svg>";

      tr.innerHTML = `
        <td style="${rankStyle}">#${player.rank}</td>
        <td>
          <div class="avatar-cell">
            <img src="${avatarSrc}" class="avatar-img" alt="Ava">
            <div>
              <div style="font-weight: bold; color: #fff;">${player.displayName}</div>
              <div style="font-size: 12px; color: var(--text-muted); font-family: monospace;">@${player.username}</div>
            </div>
          </div>
        </td>
        <td style="font-weight: 500;">${player.rpName}</td>
        <td>${player.school}</td>
        <td>${player.class}</td>
        <td style="text-align: right;" class="val-highlight">${player.value.toLocaleString('id-ID')}</td>
      `;
      
      // Buka Modal kalau baris diklik
      tr.onclick = () => openPlayerDetail(player.userId);

      tbody.appendChild(tr);
    });

  } catch (error) {
    tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:30px; color:#ff4d4d;">Error: ${error.message}</td></tr>`;
  }
}

// ==========================================
// RENDER DETAIL MODAL (SAAT DIKLIK)
// ==========================================
async function openPlayerDetail(userId) {
  modal.style.display = "flex";
  modalLoading.style.display = "block";
  modalData.style.display = "none";

  try {
    const response = await fetch(`/api/player/${userId}`);
    const data = await response.json();

    if (!response.ok) throw new Error("Data tidak ditemukan");

    // Identitas Roblox Asli
    document.getElementById("modAvatar").src = data.RobloxAccount.avatar || "";
    document.getElementById("modDisplayName").textContent = data.RobloxAccount.displayName;
    document.getElementById("modUsername").textContent = data.RobloxAccount.name;
    document.getElementById("modUserId").textContent = userId;

    // Data Eco & Academic
    const eco = data.RoleplayEcoDB_V4;
    document.getElementById("resCoins").textContent = displayValue(eco, "Coins");
    document.getElementById("resLevel").textContent = displayValue(eco, "Level");
    document.getElementById("resStreak").textContent = displayValue(eco, "LoginStreak");
    document.getElementById("resSchool").textContent = displayValue(eco, "School");
    document.getElementById("resClass").textContent = displayValue(eco, "Class");

    // Data Profil (RP Name)
    document.getElementById("resRpName").textContent = displayValue(data.RoleplayProfileDB_V3);

    // Data Kuis
    document.getElementById("scoreTruth").textContent = displayValue(data.Scores.Truth);
    document.getElementById("scoreTime").textContent = displayValue(data.Scores.Time);
    document.getElementById("scoreMagic").textContent = displayValue(data.Scores.Magic);
    document.getElementById("scoreKind").textContent = displayValue(data.Scores.Kind);
    document.getElementById("scoreTrust").textContent = displayValue(data.Scores.Trust);

    modalLoading.style.display = "none";
    modalData.style.display = "block";

  } catch (error) {
    modalLoading.textContent = "GAGAL MEMUAT DATA: " + error.message;
  }
}

// Fungsi tombol pencarian manual
document.getElementById("searchBtn").addEventListener("click", () => {
  const userId = document.getElementById("userIdInput").value;
  if (userId) openPlayerDetail(userId);
});
document.getElementById("userIdInput").addEventListener("keypress", (e) => {
  if (e.key === "Enter") {
    const userId = document.getElementById("userIdInput").value;
    if (userId) openPlayerDetail(userId);
  }
});

// Render otomatis leaderboard saat halaman pertama kali dibuka
window.addEventListener("DOMContentLoaded", () => {
  loadLeaderboard('level');
});