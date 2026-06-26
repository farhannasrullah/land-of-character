/**
 * =========================================================================
 * LAND OF CHARACTER - EXECUTIVE DASHBOARD CORE LOGIC
 * =========================================================================
 * Deskripsi : Handler untuk Fetching DB, Data Parsing, Sorting, & UI State
 * Architecture: Vanilla JS + DOM Manipulation (Tailwind Utility Classes)
 * =========================================================================
 */

// --- UTILITIES & HELPERS ---
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

// --- DOM REFERENCES ---
const modal = document.getElementById("playerModal");
const modalLoading = document.getElementById("modalLoading");
const modalData = document.getElementById("modalData");
const tbody = document.getElementById("lbBody");
const usersToolbar = document.getElementById("usersToolbar");
const colRank = document.getElementById("colRank");
const lbValueHeader = document.getElementById("lbValueHeader");

// --- MODAL CONTROLS ---
function closeModal() {
  modal.classList.add("hidden");
  modal.classList.remove("flex");
  document.body.style.overflow = ''; // Mengembalikan scroll body
}

// Tutup modal jika mengklik area luar modal (backdrop)
window.onclick = function (event) {
  if (event.target == modal) closeModal();
};

// --- TAB STATE MANAGEMENT ---
function setActiveTab(tabId) {
  // Reset semua tab ke state default (inactive)
  document.querySelectorAll(".tab-btn").forEach(btn => {
    btn.classList.remove("active", "border-brand-500", "text-brand-600", "dark:text-brand-400");
    btn.classList.add("border-gray-200", "dark:border-industrial-700", "text-gray-600", "dark:text-gray-400");
  });
  
  // Set tab terpilih ke state active
  const activeBtn = document.getElementById(tabId);
  if (activeBtn) {
    activeBtn.classList.add("active", "border-brand-500", "text-brand-600", "dark:text-brand-400");
    activeBtn.classList.remove("border-gray-200", "dark:border-industrial-700", "text-gray-600", "dark:text-gray-400");
  }
}

// --- THEME TOGGLE (DARK/LIGHT MODE) ---
const themeToggleBtn = document.getElementById("themeToggleBtn");
if (themeToggleBtn) {
  themeToggleBtn.addEventListener("click", () => {
    const html = document.documentElement;
    html.classList.toggle('dark');
    // Simpan preferensi tema di LocalStorage
    localStorage.setItem("theme", html.classList.contains('dark') ? 'dark' : 'light');
  });
}

// --- DATA STATE ---
let cachedAllUsers = [];
let currentMode = "users";

// Wrapper Fetch dengan error handling JSON
async function fetchJsonSafe(url) {
  const response = await fetch(url);
  const text = await response.text();

  let data;
  try {
    data = JSON.parse(text);
  } catch (err) {
    console.error("Response bukan JSON:", text);
    throw new Error("Server tidak mengembalikan format JSON yang valid");
  }

  if (!response.ok) {
    throw new Error(data?.error || "Gagal melakukan request ke server");
  }

  return data;
}

// Helper untuk membaca input pencarian/sorting saat ini
function currentSearchQuery() {
  return (document.getElementById("searchInput")?.value || "").toLowerCase();
}

function currentSortMethod() {
  return document.getElementById("sortSelect")?.value || "name-asc";
}

// --- FETCH & RENDER: SEMUA PEMAIN ---
async function loadAllUsers() {
  setActiveTab("btnUsers");
  currentMode = "users";
  
  // Tampilkan toolbar pencarian
  usersToolbar.classList.remove("hidden");
  usersToolbar.classList.add("flex");
  colRank.textContent = "ID";
  lbValueHeader.textContent = "Level";

  // Gunakan cache jika data sudah ditarik sebelumnya
  if (cachedAllUsers.length > 0) {
    filterAndSortUsers();
    return;
  }

  tbody.innerHTML = `<tr><td colspan="6" class="p-8 text-center text-brand-500 font-mono loader">[ PULLING MASTER ROSTER... ]</td></tr>`;

  try {
    const data = await fetchJsonSafe("/api/users");
    cachedAllUsers = Array.isArray(data) ? data : [];
    filterAndSortUsers();
  } catch (error) {
    tbody.innerHTML = `<tr><td colspan="6" class="p-8 text-center text-red-500 font-mono bg-red-500/10">ERR: ${escapeHtml(error.message)}</td></tr>`;
  }
}

// --- FILTER & SORTING LOGIC ---
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

// Attach event listeners untuk pencarian live
document.getElementById("searchInput")?.addEventListener("input", filterAndSortUsers);
document.getElementById("sortSelect")?.addEventListener("change", filterAndSortUsers);

// --- FETCH & RENDER: LEADERBOARD ---
async function loadLeaderboard(type) {
  const tabId = "btn" + type.charAt(0).toUpperCase() + type.slice(1);
  setActiveTab(tabId);
  currentMode = "leaderboard";
  
  // Sembunyikan toolbar pencarian
  usersToolbar.classList.add("hidden");
  usersToolbar.classList.remove("flex");
  colRank.textContent = "Rank";

  if (type === "coins") lbValueHeader.textContent = "Total Coins";
  if (type === "level") lbValueHeader.textContent = "Player Level";
  if (type === "score") lbValueHeader.textContent = "Total Quiz Score";

  tbody.innerHTML = `<tr><td colspan="6" class="p-8 text-center text-brand-500 font-mono loader">[ COMPILING LEADERBOARD... ]</td></tr>`;

  try {
    const data = await fetchJsonSafe(`/api/leaderboard/${type}`);
    renderTable(Array.isArray(data) ? data : [], true);
  } catch (error) {
    tbody.innerHTML = `<tr><td colspan="6" class="p-8 text-center text-red-500 font-mono bg-red-500/10">ERR: ${escapeHtml(error.message)}</td></tr>`;
  }
}

// --- RENDER TABLE ENGINE ---
function renderTable(dataArray, isLeaderboard) {
  if (!Array.isArray(dataArray) || dataArray.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" class="p-8 text-center text-gray-500 font-mono">0 Records Found.</td></tr>`;
    return;
  }

  tbody.innerHTML = "";

  dataArray.forEach((player, index) => {
    const tr = document.createElement("tr");
    tr.className = "hover:bg-gray-50 dark:hover:bg-industrial-700/50 cursor-pointer transition-colors";

    // Ranking Styling
    let rankHtml = `<td class="px-6 py-4 font-mono text-gray-500 dark:text-gray-400 font-bold">${index + 1}</td>`;
    if (isLeaderboard) {
      if (player.rank === 1) rankHtml = `<td class="px-6 py-4 font-mono text-yellow-500 font-black text-lg">#1</td>`;
      else if (player.rank === 2) rankHtml = `<td class="px-6 py-4 font-mono text-gray-400 font-bold text-md">#2</td>`;
      else if (player.rank === 3) rankHtml = `<td class="px-6 py-4 font-mono text-amber-600 font-bold text-md">#3</td>`;
      else rankHtml = `<td class="px-6 py-4 font-mono text-gray-500 font-semibold">#${player.rank}</td>`;
    }

    // Fallback avatar kosong
    const avatarSrc = player.avatar
      ? player.avatar
      : "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='45' height='45' fill='none'></svg>";

    const valueToShow = isLeaderboard
      ? getNumericValue(player.value)
      : getNumericValue(player.level);

    tr.innerHTML = `
      ${rankHtml}
      <td class="px-6 py-4">
        <div class="flex items-center gap-4">
          <img src="${escapeHtml(avatarSrc)}" class="w-10 h-10 rounded-md border border-gray-200 dark:border-industrial-600 object-cover bg-gray-100 dark:bg-industrial-800" alt="Ava">
          <div>
            <div class="font-bold text-gray-900 dark:text-white">${escapeHtml(player.displayName || "Unknown")}</div>
            <div class="text-xs text-gray-500 dark:text-gray-400 font-mono">@${escapeHtml(player.username || "unknown")}</div>
          </div>
        </div>
      </td>
      <td class="px-6 py-4 font-medium text-gray-700 dark:text-gray-300">${escapeHtml(player.rpName || "-")}</td>
      <td class="px-6 py-4 text-gray-600 dark:text-gray-400 max-w-[150px] truncate">${escapeHtml(player.school || "-")}</td>
      <td class="px-6 py-4 text-gray-600 dark:text-gray-400">${escapeHtml(player.class || "-")}</td>
      <td class="px-6 py-4 text-right font-mono font-bold text-brand-600 dark:text-brand-400 text-lg">${valueToShow.toLocaleString("id-ID")}</td>
    `;

    tr.onclick = () => openPlayerDetail(player.userId);
    tbody.appendChild(tr);
  });
}

// --- PLAYER DETAIL MODAL ENGINE ---
async function openPlayerDetail(userId) {
  // Buka Modal & Lock Scroll
  modal.classList.remove("hidden");
  modal.classList.add("flex");
  document.body.style.overflow = 'hidden'; 
  
  modalLoading.classList.remove("hidden");
  modalLoading.classList.add("block");
  modalData.classList.add("hidden");

  try {
    const data = await fetchJsonSafe(`/api/player/${userId}`);

    // Set Identity
    document.getElementById("modAvatar").src = data.RobloxAccount?.avatar || "";
    document.getElementById("modDisplayName").textContent = data.RobloxAccount?.displayName || "Unknown";
    document.getElementById("modUsername").textContent = data.RobloxAccount?.name || "unknown";
    document.getElementById("modUserId").textContent = userId;

    // Database Extractor
    const eco = data.RoleplayEcoDB_V4 || {};
    const profile = data.RoleplayProfileDB_V3 || {};
    const scores = data.Scores || {};
    const journey = data.JourneyLockDB_V1 || {};
    const reward = data.RoleplayRewardDB_V1 || {};

    // Populate Economy & Profile
    document.getElementById("resCoins").textContent = displayValue(eco, "Coins");
    document.getElementById("resLevel").textContent = displayValue(eco, "Level");
    document.getElementById("resStreak").textContent = displayValue(eco, "LoginStreak");

    document.getElementById("resSchool").textContent = displayValue(profile, "school");
    document.getElementById("resClass").textContent = displayValue(profile, "class");
    document.getElementById("resRpName").textContent = displayValue(profile, "rpName");
    document.getElementById("resGender").textContent = displayValue(profile, "gender");

    // Populate Journey
    document.getElementById("resActiveLock").textContent =
      journey.activeLock !== null && journey.activeLock !== undefined
        ? String(journey.activeLock)
        : "-";
    document.getElementById("resJ5Type").textContent =
      journey.j5Type !== null && journey.j5Type !== undefined
        ? String(journey.j5Type)
        : "-";

    // Parsing Reward / Progress Bar Logic
    const cq = reward.completedQuizzes;
    let quizzes = [];
    
    if (cq !== null && cq !== undefined) {
      if (Array.isArray(cq)) {
        quizzes = cq;
      } else if (typeof cq === "object") {
        quizzes = Object.keys(cq);
      } else if (typeof cq === "string") {
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
      if (qName.startsWith("Quiz_") || qName === "Quiz") {
        quizCount++;
      } else if (qName.startsWith("TTS_") || qName === "TTS") {
        ttsCount++;
      }
    });

    quizCount = Math.min(quizCount, MAX_QUIZ);
    ttsCount = Math.min(ttsCount, MAX_QUIZ);

    // Apply ke HTML Progress Bar
    document.getElementById("resQuizCount").textContent = `${quizCount}/${MAX_QUIZ}`;
    document.getElementById("resQuizFill").style.width = `${(quizCount / MAX_QUIZ) * 100}%`;

    document.getElementById("resTtsCount").textContent = `${ttsCount}/${MAX_QUIZ}`;
    document.getElementById("resTtsFill").style.width = `${(ttsCount / MAX_QUIZ) * 100}%`;

    // Populate Scores
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

    // Selesai Loading, tampilkan UI
    modalLoading.classList.add("hidden");
    modalLoading.classList.remove("block");
    modalData.classList.remove("hidden");
    
  } catch (error) {
    modalLoading.innerHTML = `<span class="text-red-500">SYSTEM FAILURE: ${error.message}</span>`;
  }
}

// --- EVENT LISTENERS PENCARIAN MANUAL ---
document.getElementById("manualSearchBtn")?.addEventListener("click", () => {
  const userId = document.getElementById("manualUserId").value.trim();
  if (userId) openPlayerDetail(userId);
});

document.getElementById("manualUserId")?.addEventListener("keypress", (e) => {
  if (e.key === "Enter") {
    const userId = document.getElementById("manualUserId").value.trim();
    if (userId) openPlayerDetail(userId);
  }
});

// --- INITIALIZATION ---
window.addEventListener("DOMContentLoaded", () => {
  // Panggil data pemain pertama kali dibuka
  loadAllUsers();
  
  // Render SVG icons dari Lucide
  if (typeof lucide !== 'undefined') {
    lucide.createIcons();
  }
});