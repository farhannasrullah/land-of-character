// --- BANTUAN UI ---
function displayValue(val, property) {
  if (val === null || val === undefined) return "-";
  if (typeof val === "object" && property) {
    const exactKey = Object.keys(val).find(k => k.toLowerCase() === property.toLowerCase());
    return exactKey ? val[exactKey] : "-";
  }
  return val;
}

const modal = document.getElementById("playerModal");
const modalLoading = document.getElementById("modalLoading");
const modalData = document.getElementById("modalData");
const tbody = document.getElementById("lbBody");
const usersToolbar = document.getElementById("usersToolbar");
const colRank = document.getElementById("colRank");
const lbValueHeader = document.getElementById("lbValueHeader");

function closeModal() { modal.style.display = "none"; }
window.onclick = function(event) { if (event.target == modal) closeModal(); }

function setActiveTab(tabId) {
  ["btnUsers", "btnLevel", "btnCoins", "btnScore"].forEach(id => {
    document.getElementById(id).classList.remove("active");
  });
  document.getElementById(tabId).classList.add("active");
}

// --- STATE MANAGEMENT ---
let cachedAllUsers = []; 
let currentMode = "users"; // "users" atau "leaderboard"

// --- FETCH SEMUA PEMAIN ---
async function loadAllUsers() {
  setActiveTab("btnUsers");
  currentMode = "users";
  usersToolbar.style.display = "flex";
  colRank.textContent = "No";
  lbValueHeader.textContent = "Level";

  if (cachedAllUsers.length > 0) {
    filterAndSortUsers();
    return;
  }

  tbody.innerHTML = `<tr><td colspan="6" class="loader">MENARIK DAFTAR SEMUA PEMAIN...</td></tr>`;

  try {
    const response = await fetch(`/api/users`);
    const data = await response.json();
    if (!response.ok) throw new Error("Gagal mengambil data pemain.");
    
    cachedAllUsers = data;
    filterAndSortUsers();
  } catch (error) {
    tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:30px; color:#ff4d4d;">Error: ${error.message}</td></tr>`;
  }
}

// --- FILTER & SORT LOGIC ---
function filterAndSortUsers() {
  const query = document.getElementById("searchInput").value.toLowerCase();
  const sortMethod = document.getElementById("sortSelect").value;

  // Filter Search
  let filtered = cachedAllUsers.filter(u => {
    const un = (u.username || "").toLowerCase();
    const dn = (u.displayName || "").toLowerCase();
    const rp = (u.rpName || "").toLowerCase();
    const sc = (u.school || "").toLowerCase();
    return un.includes(query) || dn.includes(query) || rp.includes(query) || sc.includes(query);
  });

  // Sort
  filtered.sort((a, b) => {
    if (sortMethod === 'name-asc') return a.username.localeCompare(b.username);
    if (sortMethod === 'name-desc') return b.username.localeCompare(a.username);
    if (sortMethod === 'rp-asc') return (a.rpName === "-" ? "zz" : a.rpName).localeCompare((b.rpName === "-" ? "zz" : b.rpName));
    if (sortMethod === 'school-asc') return (a.school === "-" ? "zz" : a.school).localeCompare((b.school === "-" ? "zz" : b.school));
    if (sortMethod === 'level-desc') return (b.level || 0) - (a.level || 0);
    return 0;
  });

  renderTable(filtered, false);
}

// Event Listener untuk Search & Sort Instan
document.getElementById("searchInput").addEventListener("input", filterAndSortUsers);
document.getElementById("sortSelect").addEventListener("change", filterAndSortUsers);

// --- FETCH LEADERBOARD ---
async function loadLeaderboard(type) {
  let tabId = "btn" + type.charAt(0).toUpperCase() + type.slice(1);
  setActiveTab(tabId);
  currentMode = "leaderboard";
  usersToolbar.style.display = "none";
  colRank.textContent = "Rank";

  if (type === "coins") lbValueHeader.textContent = "Total Coins";
  if (type === "level") lbValueHeader.textContent = "Player Level";
  if (type === "score") lbValueHeader.textContent = "Total Quiz Score";

  tbody.innerHTML = `<tr><td colspan="6" class="loader">MEMUAT LEADERBOARD...</td></tr>`;

  try {
    const response = await fetch(`/api/leaderboard/${type}`);
    const data = await response.json();
    if (!response.ok) throw new Error("Gagal mengambil leaderboard");
    
    renderTable(data, true);
  } catch (error) {
    tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:30px; color:#ff4d4d;">Error: ${error.message}</td></tr>`;
  }
}

// --- RENDER TABEL (REUSABLE) ---
function renderTable(dataArray, isLeaderboard) {
  if (dataArray.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:30px; color:var(--text-muted);">Tidak ada data yang cocok.</td></tr>`;
    return;
  }

  tbody.innerHTML = "";
  dataArray.forEach((player, index) => {
    const tr = document.createElement("tr");
    tr.className = "data-row";
    
    // Index atau Rank Number
    let rankHtml = `<td class="idx-col">${index + 1}</td>`;
    if (isLeaderboard) {
      if (player.rank === 1) rankHtml = `<td style="color:#ffd700; font-weight:bold; font-size:16px;">#1</td>`;
      else if (player.rank === 2) rankHtml = `<td style="color:#c0c0c0; font-weight:bold;">#2</td>`;
      else if (player.rank === 3) rankHtml = `<td style="color:#cd7f32; font-weight:bold;">#3</td>`;
      else rankHtml = `<td class="idx-col">#${player.rank}</td>`;
    }

    const avatarSrc = player.avatar ? player.avatar : "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='45' height='45' fill='%2327272a'><rect width='100%' height='100%'/></svg>";

    tr.innerHTML = `
      ${rankHtml}
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
      <td style="text-align: right;" class="val-highlight">${(player.value || player.level).toLocaleString('id-ID')}</td>
    `;
    
    tr.onclick = () => openPlayerDetail(player.userId);
    tbody.appendChild(tr);
  });
}

// --- MODAL & PENCARIAN MANUAL ---
async function openPlayerDetail(userId) {
  modal.style.display = "flex";
  modalLoading.style.display = "block";
  modalData.style.display = "none";

  try {
    const response = await fetch(`/api/player/${userId}`);
    const data = await response.json();

    if (!response.ok) throw new Error("Data tidak ditemukan");

    document.getElementById("modAvatar").src = data.RobloxAccount.avatar || "";
    document.getElementById("modDisplayName").textContent = data.RobloxAccount.displayName;
    document.getElementById("modUsername").textContent = data.RobloxAccount.name;
    document.getElementById("modUserId").textContent = userId;

    const eco = data.RoleplayEcoDB_V4;
    document.getElementById("resCoins").textContent = displayValue(eco, "Coins");
    document.getElementById("resLevel").textContent = displayValue(eco, "Level");
    document.getElementById("resStreak").textContent = displayValue(eco, "LoginStreak");
    document.getElementById("resSchool").textContent = displayValue(eco, "School");
    document.getElementById("resClass").textContent = displayValue(eco, "Class");

    document.getElementById("resRpName").textContent = displayValue(data.RoleplayProfileDB_V3);

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

// Event Pencarian Manual Spesifik ID
document.getElementById("manualSearchBtn").addEventListener("click", () => {
  const userId = document.getElementById("manualUserId").value;
  if (userId) openPlayerDetail(userId);
});
document.getElementById("manualUserId").addEventListener("keypress", (e) => {
  if (e.key === "Enter") {
    const userId = document.getElementById("manualUserId").value;
    if (userId) openPlayerDetail(userId);
  }
});

// INIT AWAL
window.addEventListener("DOMContentLoaded", () => {
  loadAllUsers();
});