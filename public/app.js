// --- BANTUAN UI ---
function displayValue(val, property) {
  if (val === null || val === undefined) return "-";

  if (typeof val === "object" && property) {
    const exactKey = Object.keys(val).find(
      k => k.toLowerCase() === property.toLowerCase()
    );
    return exactKey ? val[exactKey] : "-";
  }

  return val;
}

function getNumericValue(val, fallback = 0) {
  const n = Number(val);
  return Number.isFinite(n) ? n : fallback;
}

function escapeHtml(str) {
  return String(str ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

const modal = document.getElementById("playerModal");
const modalLoading = document.getElementById("modalLoading");
const modalData = document.getElementById("modalData");
const tbody = document.getElementById("lbBody");
const usersToolbar = document.getElementById("usersToolbar");
const colRank = document.getElementById("colRank");
const lbValueHeader = document.getElementById("lbValueHeader");

function closeModal() {
  modal.style.display = "none";
}

window.onclick = function (event) {
  if (event.target == modal) closeModal();
};

function setActiveTab(tabId) {
  ["btnUsers", "btnLevel", "btnCoins", "btnScore"].forEach(id => {
    document.getElementById(id).classList.remove("active");
  });
  document.getElementById(tabId).classList.add("active");
}

// --- TEMA (LIGHT/DARK MODE TOGGLE) ---
const themeToggleBtn = document.getElementById("themeToggleBtn");
if (themeToggleBtn) {
  themeToggleBtn.addEventListener("click", () => {
    const root = document.documentElement;
    const currentTheme = root.getAttribute("data-theme");
    
    // Logika ganti tema
    const newTheme = currentTheme === "light" ? "dark" : "light";
    
    if (newTheme === "dark") {
      root.removeAttribute("data-theme");
      localStorage.setItem("theme", "dark");
    } else {
      root.setAttribute("data-theme", "light");
      localStorage.setItem("theme", "light");
    }
  });
}

// --- STATE MANAGEMENT ---
let cachedAllUsers = [];
let currentMode = "users";

// helper untuk fetch JSON yang lebih aman
async function fetchJsonSafe(url) {
  const response = await fetch(url);
  const text = await response.text();

  let data;
  try {
    data = JSON.parse(text);
  } catch (err) {
    console.error("Response bukan JSON:", text);
    throw new Error("Server tidak mengembalikan JSON valid");
  }

  if (!response.ok) {
    throw new Error(data?.error || "Request gagal");
  }

  return data;
}

function currentSearchQuery() {
  const el = document.getElementById("searchInput");
  return (el?.value || "").toLowerCase();
}

function currentSortMethod() {
  const el = document.getElementById("sortSelect");
  return el?.value || "name-asc";
}

// --- FETCH SEMUA PEMAIN ---
async function loadAllUsers() {
  setActiveTab("btnUsers");
  currentMode = "users";
  usersToolbar.style.display = "flex";
  colRank.textContent = "ID";
  lbValueHeader.textContent = "Level";

  if (cachedAllUsers.length > 0) {
    filterAndSortUsers();
    return;
  }

  tbody.innerHTML = `<tr><td colspan="6" class="loader">MENARIK DAFTAR SEMUA PEMAIN...</td></tr>`;

  try {
    const data = await fetchJsonSafe("/api/users");
    cachedAllUsers = Array.isArray(data) ? data : [];
    filterAndSortUsers();
  } catch (error) {
    tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:30px; color:var(--danger); border: 1px dashed var(--danger);">System Error: ${escapeHtml(error.message)}</td></tr>`;
  }
}

// --- FILTER & SORT LOGIC ---
function filterAndSortUsers() {
  const query = currentSearchQuery();
  const sortMethod = currentSortMethod();

  let filtered = cachedAllUsers.filter(u => {
    const un = (u.username || "").toLowerCase();
    const dn = (u.displayName || "").toLowerCase();
    const rp = (u.rpName || "").toLowerCase();
    const sc = (u.school || "").toLowerCase();
    const cl = (u.class || "").toLowerCase();

    return (
      un.includes(query) ||
      dn.includes(query) ||
      rp.includes(query) ||
      sc.includes(query) ||
      cl.includes(query)
    );
  });

  filtered.sort((a, b) => {
    if (sortMethod === "name-asc") return (a.username || "").localeCompare(b.username || "");
    if (sortMethod === "name-desc") return (b.username || "").localeCompare(a.username || "");
    if (sortMethod === "rp-asc") return (a.rpName === "-" ? "zz" : (a.rpName || "")).localeCompare(b.rpName === "-" ? "zz" : (b.rpName || ""));
    if (sortMethod === "school-asc") return (a.school === "-" ? "zz" : (a.school || "")).localeCompare(b.school === "-" ? "zz" : (b.school || ""));
    if (sortMethod === "class-asc") return (a.class === "-" ? "zz" : (a.class || "")).localeCompare(b.class === "-" ? "zz" : (b.class || ""));
    if (sortMethod === "level-desc") return getNumericValue(b.level) - getNumericValue(a.level);
    return 0;
  });

  renderTable(filtered, false);
}

document.getElementById("searchInput").addEventListener("input", filterAndSortUsers);
document.getElementById("sortSelect").addEventListener("change", filterAndSortUsers);

// --- FETCH LEADERBOARD ---
async function loadLeaderboard(type) {
  const tabId = "btn" + type.charAt(0).toUpperCase() + type.slice(1);
  setActiveTab(tabId);
  currentMode = "leaderboard";
  usersToolbar.style.display = "none";
  colRank.textContent = "Rank";

  if (type === "coins") lbValueHeader.textContent = "Total Coins";
  if (type === "level") lbValueHeader.textContent = "Player Level";
  if (type === "score") lbValueHeader.textContent = "Total Quiz Score";

  tbody.innerHTML = `<tr><td colspan="6" class="loader">MEMUAT DATABASE...</td></tr>`;

  try {
    const data = await fetchJsonSafe(`/api/leaderboard/${type}`);
    renderTable(Array.isArray(data) ? data : [], true);
  } catch (error) {
    tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:30px; color:var(--danger); border: 1px dashed var(--danger);">System Error: ${escapeHtml(error.message)}</td></tr>`;
  }
}

// --- RENDER TABEL (REUSABLE) ---
function renderTable(dataArray, isLeaderboard) {
  if (!Array.isArray(dataArray) || dataArray.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:30px; color:var(--text-muted);">0 Records Found.</td></tr>`;
    return;
  }

  tbody.innerHTML = "";

  dataArray.forEach((player, index) => {
    const tr = document.createElement("tr");
    tr.className = "data-row";

    let rankHtml = `<td class="idx-col">${index + 1}</td>`;
    if (isLeaderboard) {
      if (player.rank === 1) rankHtml = `<td class="idx-col rank-1">#1</td>`;
      else if (player.rank === 2) rankHtml = `<td class="idx-col rank-2">#2</td>`;
      else if (player.rank === 3) rankHtml = `<td class="idx-col rank-3">#3</td>`;
      else rankHtml = `<td class="idx-col">#${player.rank}</td>`;
    }

    const avatarSrc = player.avatar
      ? player.avatar
      : "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='45' height='45' fill='none'></svg>";

    const valueToShow = isLeaderboard
      ? getNumericValue(player.value)
      : getNumericValue(player.level);

    tr.innerHTML = `
      ${rankHtml}
      <td>
        <div class="avatar-cell">
          <img src="${escapeHtml(avatarSrc)}" class="avatar-img" alt="Ava">
          <div>
            <div style="font-weight: bold; color: var(--text);">${escapeHtml(player.displayName || "Unknown")}</div>
            <div style="font-size: 12px; color: var(--text-muted); font-family: monospace;">@${escapeHtml(player.username || "unknown")}</div>
          </div>
        </div>
      </td>
      <td style="font-weight: 500;">${escapeHtml(player.rpName || "-")}</td>
      <td>${escapeHtml(player.school || "-")}</td>
      <td>${escapeHtml(player.class || "-")}</td>
      <td style="text-align: right;" class="val-highlight">${valueToShow.toLocaleString("id-ID")}</td>
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
    const data = await fetchJsonSafe(`/api/player/${userId}`);

    document.getElementById("modAvatar").src = data.RobloxAccount?.avatar || "";
    document.getElementById("modDisplayName").textContent = data.RobloxAccount?.displayName || "Unknown";
    document.getElementById("modUsername").textContent = data.RobloxAccount?.name || "unknown";
    document.getElementById("modUserId").textContent = userId;

    const eco = data.RoleplayEcoDB_V4 || {};
    const profile = data.RoleplayProfileDB_V3 || {};
    const scores = data.Scores || {};
    const journey = data.JourneyLockDB_V1 || {};
    const reward = data.RoleplayRewardDB_V1 || {};

    document.getElementById("resCoins").textContent = displayValue(eco, "Coins");
    document.getElementById("resLevel").textContent = displayValue(eco, "Level");
    document.getElementById("resStreak").textContent = displayValue(eco, "LoginStreak");

    document.getElementById("resSchool").textContent = displayValue(profile, "school");
    document.getElementById("resClass").textContent = displayValue(profile, "class");
    document.getElementById("resRpName").textContent = displayValue(profile, "rpName");
    document.getElementById("resGender").textContent = displayValue(profile, "gender");

    // Journey
    document.getElementById("resActiveLock").textContent =
      journey.activeLock !== null && journey.activeLock !== undefined
        ? String(journey.activeLock)
        : "-";
    document.getElementById("resJ5Type").textContent =
      journey.j5Type !== null && journey.j5Type !== undefined
        ? String(journey.j5Type)
        : "-";

    // Reward - Parsing Progress Bar Data
    const cq = reward.completedQuizzes;
    let quizzes = [];
    
    if (cq !== null && cq !== undefined) {
      if (Array.isArray(cq)) {
        quizzes = cq;
      } else if (typeof cq === "object") {
        quizzes = Object.keys(cq);
      } else if (typeof cq === "string") {
        // Handle jika data datang sebagai string panjang
        quizzes = cq.split(",");
      } else {
        quizzes = [String(cq)];
      }
    }

    let quizCount = 0;
    let ttsCount = 0;
    const MAX_QUIZ = 5;

    quizzes.forEach(q => {
      const qName = String(q).trim();
      // Pilah data mana yang Standard Quiz dan mana yang TTS
      if (qName.startsWith("Quiz_") || qName === "Quiz") {
        quizCount++;
      } else if (qName.startsWith("TTS_") || qName === "TTS") {
        ttsCount++;
      }
    });

    // Batasi hitungan supaya bar tidak tembus 100% jika ada duplikat entri dari Roblox
    quizCount = Math.min(quizCount, MAX_QUIZ);
    ttsCount = Math.min(ttsCount, MAX_QUIZ);

    // Apply ke HTML
    document.getElementById("resQuizCount").textContent = `${quizCount}/${MAX_QUIZ}`;
    document.getElementById("resQuizFill").style.width = `${(quizCount / MAX_QUIZ) * 100}%`;

    document.getElementById("resTtsCount").textContent = `${ttsCount}/${MAX_QUIZ}`;
    document.getElementById("resTtsFill").style.width = `${(ttsCount / MAX_QUIZ) * 100}%`;

    // Quiz & TTS Scores
    document.getElementById("scoreTruth").textContent = displayValue(scores, "Truth");
    document.getElementById("scoreTime").textContent = displayValue(scores, "Time");
    document.getElementById("scoreMagic").textContent = displayValue(scores, "Magic");
    document.getElementById("scoreKind").textContent = displayValue(scores, "Kind");
    document.getElementById("scoreTrust").textContent = displayValue(scores, "Trust");

    document.getElementById("scoreTTS_Truth").textContent = displayValue(scores, "TTS_Truth");
    document.getElementById("scoreTTS_Time").textContent = displayValue(scores, "TTS_Time");
    document.getElementById("scoreTTS_Magic").textContent = displayValue(scores, "TTS_Magic");
    document.getElementById("scoreTTS_Kind").textContent = displayValue(scores, "TTS_Kind");
    document.getElementById("scoreTTS_Trust").textContent = displayValue(scores, "TTS_Trust");

    modalLoading.style.display = "none";
    modalData.style.display = "block";
  } catch (error) {
    modalLoading.textContent = "SYSTEM FAILURE: " + error.message;
  }
}

// Event Pencarian Manual Spesifik ID
document.getElementById("manualSearchBtn").addEventListener("click", () => {
  const userId = document.getElementById("manualUserId").value.trim();
  if (userId) openPlayerDetail(userId);
});

document.getElementById("manualUserId").addEventListener("keypress", (e) => {
  if (e.key === "Enter") {
    const userId = document.getElementById("manualUserId").value.trim();
    if (userId) openPlayerDetail(userId);
  }
});

// INIT AWAL
window.addEventListener("DOMContentLoaded", () => {
  loadAllUsers();
  // Merender ikon SVG Lucide setelah DOM siap
  lucide.createIcons();
});