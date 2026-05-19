// Fungsi pintar untuk membaca data entah itu Objek maupun Nilai/Angka langsung
function displayValue(val, property) {
  if (val === null || val === undefined) return "-";
  
  // Jika data di dalam datastore berbentuk Objek {}
  if (typeof val === "object" && property) {
    // Mencari key secara case-insensitive (mengantisipasi "Coins" atau "coins")
    const exactKey = Object.keys(val).find(k => k.toLowerCase() === property.toLowerCase());
    return exactKey ? val[exactKey] : "-";
  }
  
  // Jika data di dalam datastore langsung berupa Angka/Teks biasa (Primitive)
  return val;
}

async function fetchData() {
  const userId = document.getElementById("userIdInput").value;
  const errorMsg = document.getElementById("errorMsg");
  const resultBox = document.getElementById("resultBox");

  // Reset tampilan
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

    // 1. Tampilkan Data Eco (Membaca dari objek)
    const eco = data.RoleplayEcoDB_V4;
    // Tampilkan Data Akun Asli Roblox
    document.getElementById("resUsername").textContent = `@${data.RobloxAccount.name}`;
    document.getElementById("resDisplayName").textContent = data.RobloxAccount.displayName;
    document.getElementById("resCoins").textContent = displayValue(eco, "Coins");
    document.getElementById("resLevel").textContent = displayValue(eco, "Level");
    document.getElementById("resSchool").textContent = displayValue(eco, "School");
    document.getElementById("resClass").textContent = displayValue(eco, "Class");

    // 2. Tampilkan Data Profile (Membaca langsung teks nama RP)
    document.getElementById("resRpName").textContent = displayValue(data.RoleplayProfileDB_V3);

    // 3. Tampilkan ke-5 Data Score (Membaca langsung angka skor)
    document.getElementById("scoreTruth").textContent = displayValue(data.Scores.Truth);
    document.getElementById("scoreTime").textContent = displayValue(data.Scores.Time);
    document.getElementById("scoreMagic").textContent = displayValue(data.Scores.Magic);
    document.getElementById("scoreKind").textContent = displayValue(data.Scores.Kind);
    document.getElementById("scoreTrust").textContent = displayValue(data.Scores.Trust);
    
    // Tampilkan JSON mentah
    document.getElementById("resRaw").textContent = JSON.stringify(data, null, 2);
    
    // Munculkan hasil
    resultBox.style.display = "block";

  } catch (error) {
    errorMsg.textContent = error.message;
    errorMsg.style.display = "block";
  }
}

// Pasang Event Listener ke tombol
document.getElementById("searchBtn").addEventListener("click", fetchData);

// Pasang Event Listener untuk tekan "Enter"
document.getElementById("userIdInput").addEventListener("keypress", function(event) {
  if (event.key === "Enter") {
    fetchData();
  }
});