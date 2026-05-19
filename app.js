// app.js
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-app.js";
import { getDatabase, ref, onValue } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-database.js";

const configResponse = await fetch("./firebase-config.json");
const firebaseConfig = await configResponse.json();

const app = initializeApp(firebaseConfig);
const db = getDatabase(app);

const leaderboardBody = document.querySelector("#leaderboardTable tbody");
const jsonOutput = document.getElementById("jsonOutput");

const leaderboardRef = ref(db, "leaderboard");
const rootRef = ref(db, "/");

function formatTime(unixSeconds) {
  if (!unixSeconds) return "-";
  const d = new Date(unixSeconds * 1000);
  return d.toLocaleString("id-ID");
}

onValue(rootRef, (snapshot) => {
  const data = snapshot.val();
  jsonOutput.textContent = JSON.stringify(data, null, 2);
}, (error) => {
  jsonOutput.textContent = "Error: " + error.message;
});

onValue(leaderboardRef, (snapshot) => {
  const data = snapshot.val();

  if (!data) {
    leaderboardBody.innerHTML = `
      <tr>
        <td colspan="8">Tidak ada data leaderboard.</td>
      </tr>
    `;
    return;
  }

  const rows = Object.entries(data)
    .map(([key, value]) => ({
      key,
      ...value
    }))
    .sort((a, b) => (b.bestScore || 0) - (a.bestScore || 0));

  if (rows.length === 0) {
    leaderboardBody.innerHTML = `
      <tr>
        <td colspan="8">Tidak ada data leaderboard.</td>
      </tr>
    `;
    return;
  }

  leaderboardBody.innerHTML = "";

  rows.forEach((player, index) => {
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>${index + 1}</td>
      <td>${player.username ?? "-"}</td>
      <td>${player.rpName ?? "-"}</td>
      <td>${player.quizType ?? "-"}</td>
      <td>${player.level ?? "-"}</td>
      <td>${player.bestScore ?? 0}</td>
      <td>${player.coins ?? 0}</td>
      <td>${formatTime(player.updatedAt)}</td>
    `;
    leaderboardBody.appendChild(tr);
  });
}, (error) => {
  leaderboardBody.innerHTML = `
    <tr>
      <td colspan="8">Error: ${error.message}</td>
    </tr>
  `;
});