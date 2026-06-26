local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SG = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local SPS = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local CS = game:GetService("CollectionService")

print("[Sistem Theory V2.1] Membersihkan state lama...")
if SPS:FindFirstChild("TheoryClientLogic") then SPS.TheoryClientLogic:Destroy() end 
if Workspace:FindFirstChild("TheoryTerminals") then Workspace.TheoryTerminals:Destroy() end
if RS:FindFirstChild("TheoryData") then RS.TheoryData:Destroy() end
if SG:FindFirstChild("TheoryUI") then SG.TheoryUI:Destroy() end
if SSS:FindFirstChild("QuizServerScript") then SSS.QuizServerScript:Destroy() end

print("[Sistem Theory V2.1] Membangun 5 Terminal & UI...")

-- 1. SETUP 5 TERMINAL WORKSPACE UNTUK MATERI
local terminalsFolder = Instance.new("Folder")
terminalsFolder.Name = "TheoryTerminals"
terminalsFolder.Parent = Workspace

local theoryTypes = {
	{ID = "Time", Name = "Materi: Waktu", Color = Color3.fromRGB(0, 170, 255), Pos = Vector3.new(-20, 2.5, -30)},
	{ID = "Truth", Name = "Materi: Jujur", Color = Color3.fromRGB(255, 215, 0), Pos = Vector3.new(-10, 2.5, -30)},
	{ID = "Trust", Name = "Materi: Amanah", Color = Color3.fromRGB(46, 204, 113), Pos = Vector3.new(0, 2.5, -30)},
	{ID = "Kind", Name = "Materi: Baik", Color = Color3.fromRGB(255, 105, 180), Pos = Vector3.new(10, 2.5, -30)},
	{ID = "Magic", Name = "Materi: 3 Magic Words", Color = Color3.fromRGB(155, 89, 182), Pos = Vector3.new(20, 2.5, -30)}
}

for _, tData in ipairs(theoryTypes) do
	local part = Instance.new("Part")
	part.Name = "Terminal_Theory_" .. tData.ID
	part.Size = Vector3.new(4, 5, 4)
	part.Position = tData.Pos
	part.Anchored = true
	part.Material = Enum.Material.Glass
	part.Color = tData.Color
	part.Transparency = 0.4
	part:SetAttribute("TheoryType", tData.ID) 
	part:SetAttribute("ThemeColor", tData.Color)
	CS:AddTag(part, "TheoryTerminal")
	part.Parent = terminalsFolder

	local core = Instance.new("Part")
	core.Size = Vector3.new(2, 2, 2)
	core.Position = tData.Pos
	core.Anchored = true
	core.CanCollide = false
	core.Material = Enum.Material.Neon
	core.Color = tData.Color
	core.Shape = Enum.PartType.Cylinder
	core.Parent = part

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Baca Materi 📖"
	prompt.ObjectText = tData.Name
	prompt.HoldDuration = 0.5
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = 12
	prompt.Parent = part
end

-- 2. SETUP REPLICATED STORAGE (DATA MATERI SLIDESHOW)
local theoryDataScript = Instance.new("ModuleScript")
theoryDataScript.Name = "TheoryData"
theoryDataScript.Parent = RS
theoryDataScript.Source = [=[
return {
	["Time"] = {
		Title = "⏳ MASTER OF TIME",
		IntroLore = "Selamat datang di tahap awal perjalananmu menjadi Master of Time!\n\nDi Land of Character, perjalanan ini terbagi menjadi 3 fase utama:\n1. Membaca Teori Karakter 📖\n2. Menyelesaikan Teka-Teki Silang (TTS) 🧩\n3. Ujian Akhir (Quiz) 🏆\n\nPahami materi ini dengan baik agar kamu bisa menaklukkan tantangan berikutnya!",
		Slides = {
			{
				Chapter = "A. TAHAP AWAL",
				Image = "", 
				Content = "Pemahaman awal mengenai konsep karakter disiplin pada anak usia dini melalui definisi serta beberapa ilustrasi gambar sikap disiplin dalam game Land of Character.\n\nDengan mengetahui terkait definisi dan ilustrasi, pengguna diharapkan mampu memahami konsep dasar disiplin.",
				ReadTime = 5
			},
			{
				Chapter = "B. DEFINISI KARAKTER",
				Image = "", 
				Content = "Di Land of Character ada kekuatan bernama Master of Time. Kekuatan ini membuat kamu mampu mengatur waktu dan dirimu sendiri dengan baik.\n\nKamu tahu kapan harus melakukan sesuatu dan tetap mengikuti aturan yang ada. Bahkan saat tidak ada yang melihat, kamu tetap melakukan hal yang benar.",
				ReadTime = 5
			},
			{
				Chapter = "C. MANFAAT DISIPLIN",
				Image = "", 
				Content = "Master of Time membuat kamu menjadi lebih teratur, fokus, dan bisa diandalkan dalam berbagai situasi. Orang yang memiliki disiplin waktu tinggi akan selalu dihormati oleh teman-teman dan gurunya.",
				ReadTime = 4
			}
		}
	},
	["Truth"] = {
		Title = "🌟 MASTER OF TRUTH",
		IntroLore = "Selamat datang di tahap awal perjalananmu menjadi Master of Truth!\n\nDi Land of Character, perjalanan ini terbagi menjadi 3 fase utama:\n1. Membaca Teori Karakter 📖\n2. Menyelesaikan Teka-Teki Silang (TTS) 🧩\n3. Ujian Akhir (Quiz) 🏆\n\nPelajari tentang kejujuran di sini!",
		Slides = {
			{ Chapter = "A. APA ITU JUJUR?", Image = "", Content = "Jujur adalah kesesuaian antara perkataan dan perbuatan dengan kenyataan yang sebenarnya. Di Land of Character, ini adalah tameng terkuat dari segala masalah!", ReadTime = 4 },
			{ Chapter = "B. CONTOH JUJUR", Image = "", Content = "Contoh sikap jujur adalah:\n1. Mengakui jika tidak sengaja merusak barang.\n2. Tidak mencontek saat ujian.\n3. Mengembalikan barang yang bukan milik kita.", ReadTime = 5 }
		}
	},
	["Trust"] = {
		Title = "🤝 MASTER OF TRUST",
		IntroLore = "Selamat datang di tahap awal perjalananmu menjadi Master of Trust!\n\nDi Land of Character, perjalanan ini terbagi menjadi 3 fase utama:\n1. Membaca Teori Karakter 📖\n2. Menyelesaikan Teka-Teki Silang (TTS) 🧩\n3. Ujian Akhir (Quiz) 🏆\n\nPelajari tentang sifat amanah!",
		Slides = {
			{ Chapter = "A. SIFAT AMANAH", Image = "", Content = "Amanah berarti dapat dipercaya. Jika kamu diberi pesan, kamu harus menyampaikannya. Jika dipinjami barang, kembalikan dengan utuh dan tidak merusaknya.", ReadTime = 5 },
			{ Chapter = "B. TEPATI JANJI", Image = "", Content = "Sebuah janji harus selalu ditepati. Anak yang selalu menepati janji akan dipercaya untuk memegang kekuatan magis Master of Trust selamanya!", ReadTime = 4 }
		}
	},
	["Kind"] = {
		Title = "💖 MASTER OF KIND",
		IntroLore = "Selamat datang di tahap awal perjalananmu menjadi Master of Kind!\n\nDi Land of Character, perjalanan ini terbagi menjadi 3 fase utama:\n1. Membaca Teori Karakter 📖\n2. Menyelesaikan Teka-Teki Silang (TTS) 🧩\n3. Ujian Akhir (Quiz) 🏆\n\nPelajari betapa hebatnya kebaikan kecilmu!",
		Slides = {
			{ Chapter = "A. BERBUAT BAIK", Image = "", Content = "Membantu teman yang jatuh, berbagi bekal makanan, dan menolong sesama tanpa mengharapkan hadiah atau pamrih adalah ciri pahlawan sejati.", ReadTime = 4 },
			{ Chapter = "B. KASIH SAYANG", Image = "", Content = "Tidak hanya kepada manusia, berbuat baik juga dilakukan kepada hewan dan tumbuhan dengan merawat dan menyayanginya setiap hari.", ReadTime = 4 }
		}
	},
	["Magic"] = {
		Title = "🌈 3 MAGIC WORDS",
		IntroLore = "Selamat datang di tahap awal perjalananmu menjadi Master 3 Magic Words!\n\nDi Land of Character, perjalanan ini terbagi menjadi 3 fase utama:\n1. Membaca Teori Karakter 📖\n2. Menyelesaikan Teka-Teki Silang (TTS) 🧩\n3. Ujian Akhir (Quiz) 🏆\n\nKuasai 3 mantra ajaib ini!",
		Slides = {
			{ Chapter = "A. TOLONG & MAAF", Image = "", Content = "Gunakan kata 'Tolong' saat meminta bantuan kepada siapapun. Gunakan kata 'Maaf' jika kamu melakukan kesalahan, meskipun kamu tidak sengaja.", ReadTime = 5 },
			{ Chapter = "B. TERIMA KASIH", Image = "", Content = "Gunakan kata 'Terima Kasih' setelah dibantu atau diberi sesuatu oleh orang lain. Tiga kata sakti ini bisa menghancurkan monster kesedihan dan permusuhan lho!", ReadTime = 5 }
		}
	}
}
]=]

-- 3. BUILD UI THEORY
local theoryUI = Instance.new("ScreenGui")
theoryUI.Name = "TheoryUI"
theoryUI.ResetOnSpawn = false
theoryUI.IgnoreGuiInset = true
theoryUI.Enabled = false 
theoryUI.Parent = SG

local UIContainer = Instance.new("Frame")
UIContainer.Name = "UIContainer"
UIContainer.AnchorPoint = Vector2.new(0.50, 0.50)
UIContainer.Size = UDim2.new(0.95, 0.00, 0.85, 0.00)
UIContainer.Position = UDim2.new(0.50, 0.00, 0.50, 0.00)
UIContainer.BackgroundTransparency = 1
UIContainer.Parent = theoryUI

local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
UIAspectRatioConstraint.AspectRatio = 1.35
UIAspectRatioConstraint.Parent = UIContainer

local UISizeConstraint = Instance.new("UISizeConstraint")
UISizeConstraint.MinSize = Vector2.new(300.00, 222.00)
UISizeConstraint.MaxSize = Vector2.new(650.00, 480.00)
UISizeConstraint.Parent = UIContainer

local DropShadow = Instance.new("Frame")
DropShadow.Name = "DropShadow"
DropShadow.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
DropShadow.Position = UDim2.new(0.00, 0.00, 0.03, 0.00)
DropShadow.BackgroundColor3 = Color3.new(0.14, 0.16, 0.25)
DropShadow.Parent = UIContainer
Instance.new("UICorner", DropShadow).CornerRadius = UDim.new(0.08, 0.00)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
MainFrame.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
MainFrame.Parent = UIContainer
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0.08, 0.00)

local MainUIStroke = Instance.new("UIStroke")
MainUIStroke.Color = Color3.new(0.18, 0.21, 0.25)
MainUIStroke.Thickness = 6
MainUIStroke.Parent = MainFrame

-- [FIX 1] Ditambahkan Kurung Kurawal { } pada ColorSequence.new
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.new(1.00, 0.94, 0.98)), 
	ColorSequenceKeypoint.new(1.00, Color3.new(0.82, 0.92, 1.00))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

local HeaderDeco = Instance.new("Frame")
HeaderDeco.Name = "HeaderDeco"
HeaderDeco.AnchorPoint = Vector2.new(0.50, 0.50)
HeaderDeco.Size = UDim2.new(0.40, 0.00, 0.12, 0.00)
HeaderDeco.Position = UDim2.new(0.50, 0.00, 0.00, 0.00)
HeaderDeco.BackgroundColor3 = Color3.new(0.98, 0.77, 0.19)
HeaderDeco.Parent = UIContainer
Instance.new("UICorner", HeaderDeco).CornerRadius = UDim.new(0.50, 0.00)

local HeaderDecoStroke = Instance.new("UIStroke")
HeaderDecoStroke.Color = Color3.new(0.18, 0.21, 0.25)
HeaderDecoStroke.Thickness = 4
HeaderDecoStroke.Parent = HeaderDeco

local HeaderText = Instance.new("TextLabel")
HeaderText.Name = "HeaderText"
HeaderText.Size = UDim2.new(1, 0, 1, 0)
HeaderText.BackgroundTransparency = 1
HeaderText.Font = Enum.Font.FredokaOne
HeaderText.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderText.TextScaled = true
HeaderText.Text = "✨ MATERI TEORI ✨"
HeaderText.Parent = HeaderDeco
local HTStroke = Instance.new("UIStroke")
HTStroke.Thickness = 2 HTStroke.Color = Color3.new(0.18, 0.21, 0.25) HTStroke.Parent = HeaderText

-- ==========================================
-- INTRO FRAME (PENJELASAN 3 FASE JOURNEY)
-- ==========================================
local IntroFrame = Instance.new("Frame")
IntroFrame.Name = "IntroFrame"
IntroFrame.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
IntroFrame.BackgroundTransparency = 1
IntroFrame.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.TextWrapped = true
TitleLabel.TextScaled = true
TitleLabel.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
TitleLabel.Size = UDim2.new(0.90, 0.00, 0.15, 0.00)
TitleLabel.TextColor3 = Color3.new(0.42, 0.36, 0.91)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0.05, 0.00, 0.10, 0.00)
TitleLabel.Text = "⏳ MASTER OF TIME"
TitleLabel.Parent = IntroFrame
local TitleStroke = Instance.new("UIStroke", TitleLabel) TitleStroke.Color = Color3.new(1,1,1) TitleStroke.Thickness = 3

local LoreBg = Instance.new("Frame")
LoreBg.Name = "LoreBg"
LoreBg.Size = UDim2.new(0.86, 0.00, 0.50, 0.00)
LoreBg.Position = UDim2.new(0.07, 0.00, 0.28, 0.00)
LoreBg.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
LoreBg.Parent = IntroFrame
Instance.new("UICorner", LoreBg).CornerRadius = UDim.new(0.06, 0.00)
local LoreStroke = Instance.new("UIStroke", LoreBg) LoreStroke.Color = Color3.new(0.64, 0.61, 1.00) LoreStroke.Thickness = 3

local LoreText = Instance.new("TextLabel")
LoreText.Name = "LoreText"
LoreText.TextWrapped = true
LoreText.TextScaled = true
LoreText.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
LoreText.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
LoreText.TextColor3 = Color3.new(0.33, 0.37, 0.47)
LoreText.BackgroundTransparency = 1
LoreText.TextXAlignment = Enum.TextXAlignment.Left
LoreText.TextYAlignment = Enum.TextYAlignment.Top
LoreText.Parent = LoreBg
local LPadding = Instance.new("UIPadding", LoreText) 
LPadding.PaddingBottom = UDim.new(0.05, 0) LPadding.PaddingTop = UDim.new(0.05, 0) LPadding.PaddingLeft = UDim.new(0.05, 0) LPadding.PaddingRight = UDim.new(0.05, 0)

local StartBtnContainer = Instance.new("Frame")
StartBtnContainer.Name = "StartBtnContainer"
StartBtnContainer.Size = UDim2.new(0.45, 0.00, 0.15, 0.00)
StartBtnContainer.Position = UDim2.new(0.28, 0.00, 0.80, 0.00)
StartBtnContainer.BackgroundTransparency = 1
StartBtnContainer.Parent = IntroFrame

local StartShadow = Instance.new("Frame")
StartShadow.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
StartShadow.BackgroundColor3 = Color3.new(0.13, 0.55, 0.45)
StartShadow.Parent = StartBtnContainer
Instance.new("UICorner", StartShadow).CornerRadius = UDim.new(0.40, 0.00)
local SShadStroke = Instance.new("UIStroke", StartShadow) SShadStroke.Color = Color3.new(0.18, 0.21, 0.25) SShadStroke.Thickness = 4

local StartButton = Instance.new("TextButton")
StartButton.Name = "StartButton"
StartButton.TextWrapped = true
StartButton.TextScaled = true
StartButton.BackgroundColor3 = Color3.new(0.20, 1.00, 0.49)
StartButton.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
StartButton.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
StartButton.TextColor3 = Color3.new(1.00, 1.00, 1.00)
StartButton.Text = "BACA TEORI 📖"
StartButton.Position = UDim2.new(0.00, 0.00, -0.15, 0.00)
StartButton.Parent = StartBtnContainer
Instance.new("UICorner", StartButton).CornerRadius = UDim.new(0.40, 0.00)
local SBStroke = Instance.new("UIStroke", StartButton) SBStroke.Color = Color3.new(0.18, 0.21, 0.25) SBStroke.Thickness = 4

local ExitIntroBtn = Instance.new("TextButton")
ExitIntroBtn.Name = "ExitIntroBtn"
ExitIntroBtn.TextWrapped = true
ExitIntroBtn.TextScaled = true
ExitIntroBtn.BackgroundColor3 = Color3.new(1.00, 0.42, 0.42)
ExitIntroBtn.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
ExitIntroBtn.Size = UDim2.new(0.10, 0.00, 0.10, 0.00)
ExitIntroBtn.TextColor3 = Color3.new(1.00, 1.00, 1.00)
ExitIntroBtn.Text = "✖"
ExitIntroBtn.Position = UDim2.new(0.87, 0.00, 0.05, 0.00)
ExitIntroBtn.Parent = IntroFrame
Instance.new("UICorner", ExitIntroBtn).CornerRadius = UDim.new(1.00, 0.00)
local EIStroke = Instance.new("UIStroke", ExitIntroBtn) EIStroke.Color = Color3.new(0.18, 0.21, 0.25) EIStroke.Thickness = 3


-- =====================================================
-- TAMBAHKAN DI BAGIAN UI BUILD, SETELAH ExitIntroBtn
-- =====================================================
local ConfirmOverlay = Instance.new("Frame")
ConfirmOverlay.Name = "ConfirmOverlay"
ConfirmOverlay.Size = UDim2.new(1, 0, 1, 0)
ConfirmOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
ConfirmOverlay.BackgroundTransparency = 0.35
ConfirmOverlay.Visible = false
ConfirmOverlay.ZIndex = 50
ConfirmOverlay.Parent = MainFrame

local ConfirmCard = Instance.new("Frame")
ConfirmCard.Name = "ConfirmCard"
ConfirmCard.AnchorPoint = Vector2.new(0.5, 0.5)
ConfirmCard.Position = UDim2.new(0.5, 0, 0.5, 0)
ConfirmCard.Size = UDim2.new(0.7, 0, 0.45, 0)
ConfirmCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ConfirmCard.ZIndex = 51
ConfirmCard.Parent = ConfirmOverlay
Instance.new("UICorner", ConfirmCard).CornerRadius = UDim.new(0.06, 0)

local ConfirmStroke = Instance.new("UIStroke")
ConfirmStroke.Color = Color3.fromRGB(120, 120, 255)
ConfirmStroke.Thickness = 3
ConfirmStroke.Parent = ConfirmCard

local ConfirmTitle = Instance.new("TextLabel")
ConfirmTitle.Name = "ConfirmTitle"
ConfirmTitle.Size = UDim2.new(0.9, 0, 0.22, 0)
ConfirmTitle.Position = UDim2.new(0.05, 0, 0.08, 0)
ConfirmTitle.BackgroundTransparency = 1
ConfirmTitle.Text = "Konfirmasi"
ConfirmTitle.TextScaled = true
ConfirmTitle.Font = Enum.Font.FredokaOne
ConfirmTitle.TextColor3 = Color3.fromRGB(60, 60, 120)
ConfirmTitle.ZIndex = 52
ConfirmTitle.Parent = ConfirmCard

local ConfirmText = Instance.new("TextLabel")
ConfirmText.Name = "ConfirmText"
ConfirmText.Size = UDim2.new(0.9, 0, 0.28, 0)
ConfirmText.Position = UDim2.new(0.05, 0, 0.32, 0)
ConfirmText.BackgroundTransparency = 1
ConfirmText.TextWrapped = true
ConfirmText.TextScaled = true
ConfirmText.Font = Enum.Font.FredokaOne
ConfirmText.TextColor3 = Color3.fromRGB(70, 70, 70)
ConfirmText.ZIndex = 52
ConfirmText.Parent = ConfirmCard

local ConfirmNo = Instance.new("TextButton")
ConfirmNo.Name = "ConfirmNo"
ConfirmNo.Size = UDim2.new(0.38, 0, 0.18, 0)
ConfirmNo.Position = UDim2.new(0.08, 0, 0.72, 0)
ConfirmNo.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
ConfirmNo.Text = "BATAL"
ConfirmNo.TextScaled = true
ConfirmNo.Font = Enum.Font.FredokaOne
ConfirmNo.TextColor3 = Color3.new(1,1,1)
ConfirmNo.ZIndex = 52
ConfirmNo.Parent = ConfirmCard
Instance.new("UICorner", ConfirmNo).CornerRadius = UDim.new(0.25, 0)

local ConfirmYes = Instance.new("TextButton")
ConfirmYes.Name = "ConfirmYes"
ConfirmYes.Size = UDim2.new(0.38, 0, 0.18, 0)
ConfirmYes.Position = UDim2.new(0.54, 0, 0.72, 0)
ConfirmYes.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
ConfirmYes.Text = "YA"
ConfirmYes.TextScaled = true
ConfirmYes.Font = Enum.Font.FredokaOne
ConfirmYes.TextColor3 = Color3.new(1,1,1)
ConfirmYes.ZIndex = 52
ConfirmYes.Parent = ConfirmCard
Instance.new("UICorner", ConfirmYes).CornerRadius = UDim.new(0.25, 0)
-- ==========================================
-- SLIDE FRAME (MATERI UTAMA)
-- ==========================================
local SlideFrame = Instance.new("Frame")
SlideFrame.Name = "SlideFrame"
SlideFrame.Visible = false
SlideFrame.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
SlideFrame.BackgroundTransparency = 1
SlideFrame.Parent = MainFrame


local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1.00, 0.00, 0.12, 0.00)
TopBar.Position = UDim2.new(0.00, 0.00, 0.05, 0.00)
TopBar.BackgroundTransparency = 1
TopBar.Parent = SlideFrame

local ProgressLabel = Instance.new("TextLabel")
ProgressLabel.Name = "ProgressLabel"
ProgressLabel.TextWrapped = true
ProgressLabel.TextScaled = true
ProgressLabel.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
ProgressLabel.TextXAlignment = Enum.TextXAlignment.Left
ProgressLabel.Size = UDim2.new(0.50, 0.00, 0.70, 0.00)
ProgressLabel.TextColor3 = Color3.new(0.42, 0.36, 0.91)
ProgressLabel.BackgroundTransparency = 1
ProgressLabel.Position = UDim2.new(0.05, 0.00, 0.15, 0.00)
ProgressLabel.Parent = TopBar

local ExitButton = Instance.new("TextButton")
ExitButton.Name = "ExitButton"
ExitButton.TextWrapped = true
ExitButton.TextScaled = true
ExitButton.BackgroundColor3 = Color3.new(1.00, 0.42, 0.42)
ExitButton.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
ExitButton.Size = UDim2.new(0.10, 0.00, 0.80, 0.00)
ExitButton.TextColor3 = Color3.new(1.00, 1.00, 1.00)
ExitButton.Text = "✖"
ExitButton.Position = UDim2.new(0.85, 0.00, 0.10, 0.00)
ExitButton.Parent = TopBar
Instance.new("UICorner", ExitButton).CornerRadius = UDim.new(1.00, 0.00)
local EStroke2 = Instance.new("UIStroke", ExitButton) EStroke2.Color = Color3.new(0.18, 0.21, 0.25) EStroke2.Thickness = 3

local ContentBoard = Instance.new("Frame")
ContentBoard.Name = "ContentBoard"
ContentBoard.Size = UDim2.new(0.90, 0.00, 0.65, 0.00)
ContentBoard.Position = UDim2.new(0.05, 0.00, 0.18, 0.00)
ContentBoard.BackgroundColor3 = Color3.new(1.00, 1.00, 1.00)
ContentBoard.Parent = SlideFrame
Instance.new("UICorner", ContentBoard).CornerRadius = UDim.new(0.06, 0.00)
local CBStroke = Instance.new("UIStroke", ContentBoard) CBStroke.Color = Color3.new(0.42, 0.36, 0.91) CBStroke.Thickness = 4

local ChapterLabel = Instance.new("TextLabel")
ChapterLabel.Name = "ChapterLabel"
ChapterLabel.Size = UDim2.new(0.90, 0.00, 0.15, 0.00)
ChapterLabel.Position = UDim2.new(0.05, 0.00, 0.05, 0.00)
ChapterLabel.BackgroundTransparency = 1
ChapterLabel.Text = "A. TAHAP AWAL"
ChapterLabel.TextColor3 = Color3.new(1.00, 0.62, 0.26)
ChapterLabel.TextScaled = true
ChapterLabel.Font = Enum.Font.FredokaOne
ChapterLabel.TextXAlignment = Enum.TextXAlignment.Left
ChapterLabel.Parent = ContentBoard

local BodyContainer = Instance.new("Frame")
BodyContainer.Name = "BodyContainer"
BodyContainer.Size = UDim2.new(0.90, 0.00, 0.75, 0.00)
BodyContainer.Position = UDim2.new(0.05, 0.00, 0.20, 0.00)
BodyContainer.BackgroundTransparency = 1
BodyContainer.Parent = ContentBoard

local Layout = Instance.new("UIListLayout", BodyContainer)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Padding = UDim.new(0.02, 0)

-- IMAGE CONTAINER (Bisa disembunyikan jika tidak ada gambar)
local ImageFrame = Instance.new("Frame")
ImageFrame.Name = "ImageFrame"
ImageFrame.Size = UDim2.new(1.00, 0.00, 0.45, 0.00)
ImageFrame.BackgroundTransparency = 1
ImageFrame.LayoutOrder = 1
ImageFrame.Visible = false
ImageFrame.Parent = BodyContainer

local SlideImage = Instance.new("ImageLabel")
SlideImage.Name = "SlideImage"
SlideImage.Size = UDim2.new(1.00, 0.00, 1.00, 0.00)
SlideImage.BackgroundTransparency = 1
SlideImage.ScaleType = Enum.ScaleType.Fit
SlideImage.Parent = ImageFrame
Instance.new("UICorner", SlideImage).CornerRadius = UDim.new(0.05, 0)

-- TEXT SCROLL CONTAINER
local TextScroll = Instance.new("ScrollingFrame")
TextScroll.Name = "TextScroll"
TextScroll.Size = UDim2.new(1.00, 0.00, 0.50, 0.00)
TextScroll.BackgroundTransparency = 1
TextScroll.ScrollBarThickness = 6
TextScroll.LayoutOrder = 2
TextScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
TextScroll.CanvasSize = UDim2.new(0,0,0,0)
TextScroll.Parent = BodyContainer

local ContentText = Instance.new("TextLabel")
ContentText.Name = "ContentText"
ContentText.Size = UDim2.new(1.00, -10, 0.00, 0.00)
ContentText.BackgroundTransparency = 1
ContentText.TextColor3 = Color3.new(0.33, 0.37, 0.47)
ContentText.TextSize = 20
ContentText.Font = Enum.Font.FredokaOne
ContentText.TextWrapped = true
ContentText.TextXAlignment = Enum.TextXAlignment.Left
ContentText.TextYAlignment = Enum.TextYAlignment.Top
ContentText.AutomaticSize = Enum.AutomaticSize.Y
ContentText.Parent = TextScroll

local FooterFrame = Instance.new("Frame")
FooterFrame.Name = "FooterFrame"
FooterFrame.Size = UDim2.new(0.90, 0.00, 0.12, 0.00)
FooterFrame.Position = UDim2.new(0.05, 0.00, 0.85, 0.00)
FooterFrame.BackgroundTransparency = 1
FooterFrame.Parent = SlideFrame

local PrevBtnContainer = Instance.new("Frame")
PrevBtnContainer.Name = "PrevBtnContainer"
PrevBtnContainer.Size = UDim2.new(0.25, 0.00, 1.00, 0.00)
PrevBtnContainer.BackgroundTransparency = 1
PrevBtnContainer.Parent = FooterFrame
local PShadow = Instance.new("Frame", PrevBtnContainer) PShadow.Size = UDim2.new(1,0,1,0) PShadow.BackgroundColor3 = Color3.fromRGB(200, 150, 20) Instance.new("UICorner", PShadow).CornerRadius = UDim.new(0.3,0)
local PShadStroke = Instance.new("UIStroke", PShadow) PShadStroke.Color = Color3.new(0.18, 0.21, 0.25) PShadStroke.Thickness = 3
local PrevBtn = Instance.new("TextButton", PrevBtnContainer)
PrevBtn.Name = "PrevBtn"
PrevBtn.Size = UDim2.new(1, 0, 1, 0)
PrevBtn.Position = UDim2.new(0, 0, -0.15, 0)
PrevBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 40)
PrevBtn.Text = "⬅ KEMBALI"
PrevBtn.TextColor3 = Color3.new(1,1,1)
PrevBtn.TextScaled = true
PrevBtn.Font = Enum.Font.FredokaOne
Instance.new("UICorner", PrevBtn).CornerRadius = UDim.new(0.3, 0)
local PrevStroke = Instance.new("UIStroke", PrevBtn) PrevStroke.Color = Color3.new(0.18, 0.21, 0.25) PrevStroke.Thickness = 3

local NextBtnContainer = Instance.new("Frame")
NextBtnContainer.Name = "NextBtnContainer"
NextBtnContainer.Size = UDim2.new(0.30, 0.00, 1.00, 0.00)
NextBtnContainer.Position = UDim2.new(0.70, 0.00, 0.00, 0.00)
NextBtnContainer.BackgroundTransparency = 1
NextBtnContainer.Parent = FooterFrame
local NShadow = Instance.new("Frame", NextBtnContainer) NShadow.Size = UDim2.new(1,0,1,0) NShadow.BackgroundColor3 = Color3.fromRGB(20, 150, 70) Instance.new("UICorner", NShadow).CornerRadius = UDim.new(0.3,0)
local NShadStroke = Instance.new("UIStroke", NShadow) NShadStroke.Color = Color3.new(0.18, 0.21, 0.25) NShadStroke.Thickness = 3
local NextBtn = Instance.new("TextButton", NextBtnContainer)
NextBtn.Name = "NextBtn"
NextBtn.Size = UDim2.new(1, 0, 1, 0)
NextBtn.Position = UDim2.new(0, 0, -0.15, 0)
NextBtn.BackgroundColor3 = Color3.new(0.20, 1.00, 0.49)
NextBtn.Text = "LANJUT ➡"
NextBtn.TextColor3 = Color3.new(1,1,1)
NextBtn.TextScaled = true
NextBtn.Font = Enum.Font.FredokaOne
Instance.new("UICorner", NextBtn).CornerRadius = UDim.new(0.3, 0)
local NextStroke = Instance.new("UIStroke", NextBtn) NextStroke.Color = Color3.new(0.18, 0.21, 0.25) NextStroke.Thickness = 3


-- 4. CLIENT LOGIC THEORY GUI (DENGAN ANIMASI)
local clientLogic = Instance.new("LocalScript")
clientLogic.Name = "TheoryClientLogic"
clientLogic.Parent = theoryUI
clientLogic.Source = [=[
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local CS = game:GetService("CollectionService")

local TheoryData = require(RS:WaitForChild("TheoryData"))

local gui = script.Parent
local uiCont = gui:WaitForChild("UIContainer")
local mainBg = uiCont:WaitForChild("MainFrame")
local headerText = uiCont:WaitForChild("HeaderDeco"):WaitForChild("HeaderText")

local introFrame = mainBg:WaitForChild("IntroFrame")
local titleLbl = introFrame:WaitForChild("TitleLabel")
local loreText = introFrame:WaitForChild("LoreBg"):WaitForChild("LoreText")
local startBtnContainer = introFrame:WaitForChild("StartBtnContainer")
local startBtn = startBtnContainer:WaitForChild("StartButton")
local exitIntroBtn = introFrame:WaitForChild("ExitIntroBtn")
local confirmOverlay = mainBg:WaitForChild("ConfirmOverlay")
local confirmCard = confirmOverlay:WaitForChild("ConfirmCard")
local confirmTitle = confirmCard:WaitForChild("ConfirmTitle")
local confirmText = confirmCard:WaitForChild("ConfirmText")
local confirmNo = confirmCard:WaitForChild("ConfirmNo")
local confirmYes = confirmCard:WaitForChild("ConfirmYes")

local pendingConfirmAction = nil

local function showConfirm(title, message, yesText, noText, onYes)
	pendingConfirmAction = onYes
	confirmTitle.Text = title or "Konfirmasi"
	confirmText.Text = message or "Apakah Anda yakin?"
	confirmYes.Text = yesText or "YA"
	confirmNo.Text = noText or "BATAL"
	confirmOverlay.Visible = true
end

local function hideConfirm()
	confirmOverlay.Visible = false
	pendingConfirmAction = nil
end

confirmNo.MouseButton1Click:Connect(function()
	hideConfirm()
end)

confirmYes.MouseButton1Click:Connect(function()
	local cb = pendingConfirmAction
	hideConfirm()
	if cb then
		cb()
	end
end)

local slideFrame = mainBg:WaitForChild("SlideFrame")
local topBar = slideFrame:WaitForChild("TopBar")
local progressLbl = topBar:WaitForChild("ProgressLabel")
local exitBtn = topBar:WaitForChild("ExitButton")

local contentBoard = slideFrame:WaitForChild("ContentBoard")
local chapterLbl = contentBoard:WaitForChild("ChapterLabel")
local bodyCont = contentBoard:WaitForChild("BodyContainer")
local imageFrame = bodyCont:WaitForChild("ImageFrame")
local slideImage = imageFrame:WaitForChild("SlideImage")
local textScroll = bodyCont:WaitForChild("TextScroll")
local contentText = textScroll:WaitForChild("ContentText")

local footer = slideFrame:WaitForChild("FooterFrame")
local prevBtnCont = footer:WaitForChild("PrevBtnContainer")
local prevBtn = prevBtnCont:WaitForChild("PrevBtn")
local nextBtnCont = footer:WaitForChild("NextBtnContainer")
local nextBtn = nextBtnCont:WaitForChild("NextBtn")

local activeType = ""
local currentSlides = {}
local currentSlideIndex = 1
local readSlides = {}

local timerActive = false
local currentTimer = 0

local responsiveSize = UDim2.new(0.95, 0, 0.85, 0)

local function animateBtn3D(btn, isPressing)
	if isPressing then
		TS:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Position = UDim2.new(0, 0, 0, 0)}):Play()
	else
		TS:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Bounce), {Position = UDim2.new(0, 0, -0.15, 0)}):Play()
	end
end

local function animateExitBtn(btn, isPressing)
	local origPos = btn.Position
	if isPressing then
		TS:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(btn.Size.X.Scale*0.9, 0, btn.Size.Y.Scale*0.9, 0)}):Play()
	else
		TS:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Bounce), {Size = UDim2.new(btn.Size.X.Scale/0.9, 0, btn.Size.Y.Scale/0.9, 0)}):Play()
	end
end

local function updateSlideUI()
	local slide = currentSlides[currentSlideIndex]
	if not slide then return end
	
	chapterLbl.Text = slide.Chapter
	contentText.Text = slide.Content
	
	if slide.Image and slide.Image ~= "" then
		slideImage.Image = slide.Image
		imageFrame.Visible = true
		textScroll.Size = UDim2.new(1, 0, 0.5, 0)
	else
		slideImage.Image = ""
		imageFrame.Visible = false
		textScroll.Size = UDim2.new(1, 0, 0.98, 0)
	end
	
	textScroll.CanvasPosition = Vector2.new(0,0)
	progressLbl.Text = "Halaman " .. currentSlideIndex .. "/" .. #currentSlides
	prevBtnCont.Visible = (currentSlideIndex > 1)
	
	timerActive = false
	if not readSlides[currentSlideIndex] and slide.ReadTime > 0 then
		timerActive = true
		currentTimer = slide.ReadTime
		nextBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
		nextBtnCont:WaitForChild("Frame").BackgroundColor3 = Color3.fromRGB(100, 100, 110)
		nextBtn.Text = "Tunggu " .. currentTimer .. "s"
		
		task.spawn(function()
			while timerActive and currentTimer > 0 and gui.Enabled do
				task.wait(1)
				if not timerActive then break end
				currentTimer = currentTimer - 1
				if currentTimer > 0 then
					nextBtn.Text = "Tunggu " .. currentTimer .. "s"
				else
					readSlides[currentSlideIndex] = true
					timerActive = false
					nextBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 126)
					nextBtnCont:WaitForChild("Frame").BackgroundColor3 = Color3.fromRGB(20, 150, 70)
					nextBtn.Text = (currentSlideIndex == #currentSlides) and "SELESAI ✨" or "LANJUT ➡"
				end
			end
		end)
	else
		nextBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 126)
		nextBtnCont:WaitForChild("Frame").BackgroundColor3 = Color3.fromRGB(20, 150, 70)
		nextBtn.Text = (currentSlideIndex == #currentSlides) and "SELESAI ✨" or "LANJUT ➡"
	end
end

local function finishJourney()
	showConfirm(
		"Konfirmasi Tahap Berikutnya",
		"Apakah Anda yakin ingin melanjutkan ke tahap berikutnya?",
		"LANJUT",
		"TIDAK",
		function()
			closeUI()
			-- kalau nanti ada tahap berikutnya, panggil di sini
			-- contoh: Remotes.StartQuiz:FireServer(activeType)
		end
	)
end

local function nextSlide()
	if timerActive and currentTimer > 0 then return end
	if currentSlideIndex < #currentSlides then
		currentSlideIndex = currentSlideIndex + 1
		updateSlideUI()
	else
		finishJourney()
	end
end

local function prevSlide()
	if currentSlideIndex > 1 then
		currentSlideIndex = currentSlideIndex - 1
		updateSlideUI()
	end
end

function openUI()
	gui.Enabled = true
	uiCont.Size = UDim2.new(0, 0, 0, 0)
	TS:Create(uiCont, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = responsiveSize}):Play()
	introFrame.Visible = true
	slideFrame.Visible = false
end

function closeUI()
	timerActive = false
	hideConfirm()
	local tween = TS:Create(uiCont, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
	tween:Play()
	tween.Completed:Wait()
	gui.Enabled = false
end

startBtn.MouseEnter:Connect(function() animateBtn3D(startBtn, true) end)
startBtn.MouseLeave:Connect(function() animateBtn3D(startBtn, false) end)
startBtn.MouseButton1Click:Connect(function()
	animateBtn3D(startBtn, true)
	task.wait(0.1)
	animateBtn3D(startBtn, false)

	showConfirm(
		"Mulai Journey",
		"Apakah Anda ingin memulai Journey tentang " .. tostring(titleLbl.Text) .. "?",
		"MULAI",
		"BATAL",
		function()
			introFrame.Visible = false
			slideFrame.Visible = true
			updateSlideUI()
		end
	)
end)

nextBtn.MouseEnter:Connect(function() if not timerActive then animateBtn3D(nextBtn, true) end end)
nextBtn.MouseLeave:Connect(function() animateBtn3D(nextBtn, false) end)
nextBtn.MouseButton1Click:Connect(function()
	if not timerActive then
		animateBtn3D(nextBtn, true) task.wait(0.1) animateBtn3D(nextBtn, false)
		nextSlide()
	end
end)

prevBtn.MouseEnter:Connect(function() animateBtn3D(prevBtn, true) end)
prevBtn.MouseLeave:Connect(function() animateBtn3D(prevBtn, false) end)
prevBtn.MouseButton1Click:Connect(function()
	animateBtn3D(prevBtn, true) task.wait(0.1) animateBtn3D(prevBtn, false)
	prevSlide()
end)

local function askExitJourney()
	showConfirm(
		"Akhiri Journey",
		"Apakah Anda yakin ingin keluar? Jika keluar, journey akan diakhiri.",
		"KELUAR",
		"TETAP",
		function()
			closeUI()
		end
	)
end

exitBtn.MouseEnter:Connect(function() animateExitBtn(exitBtn, true) end)
exitBtn.MouseLeave:Connect(function() animateExitBtn(exitBtn, false) end)
exitBtn.MouseButton1Click:Connect(askExitJourney)

exitIntroBtn.MouseEnter:Connect(function() animateExitBtn(exitIntroBtn, true) end)
exitIntroBtn.MouseLeave:Connect(function() animateExitBtn(exitIntroBtn, false) end)
exitIntroBtn.MouseButton1Click:Connect(askExitJourney)

local function bindPrompt(part)
	local prompt = part:WaitForChild("ProximityPrompt", 10)
	if prompt then
		prompt.Triggered:Connect(function(player)
			if player == Players.LocalPlayer then
				activeType = part:GetAttribute("TheoryType")
				local tData = TheoryData[activeType]
				if not tData then return end
				
				currentSlides = tData.Slides
				currentSlideIndex = 1
				readSlides = {}
				
				titleLbl.Text = tData.Title
				loreText.Text = tData.IntroLore
				
				local themeColor = part:GetAttribute("ThemeColor")
				local uiGradient = mainBg:FindFirstChild("BgGradient")
				if uiGradient then
					uiGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(1, themeColor)
					})
				end
				
				openUI()
			end
		end)
	end
end

for _, p in ipairs(CS:GetTagged("TheoryTerminal")) do task.spawn(bindPrompt, p) end
CS:GetInstanceAddedSignal("TheoryTerminal"):Connect(bindPrompt)
]=]

-- 5. GENERATE SERVER SCRIPT (Backend TETAP 100% AMAN, patokan Local Lighting dipertahankan)
local serverScript = Instance.new("Script")
serverScript.Name = "QuizServerScript"
serverScript.Parent = SSS
serverScript.Source = [=[local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local InsertService = game:GetService("InsertService")
local DataStoreService = game:GetService("DataStoreService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local AllQuizData = require(ReplicatedStorage:WaitForChild("QuizData"))
local Remotes = ReplicatedStorage:WaitForChild("QuizRemotes")

-- DATASTORES
local ProfileStore = DataStoreService:GetDataStore("RoleplayProfileDB_V3")
local EcoStore = DataStoreService:GetDataStore("RoleplayEcoDB_V4")
local ScoreDS = DataStoreService:GetDataStore("LandOfCharacter_Scores_V2")
local RewardDS = DataStoreService:GetDataStore("RoleplayRewardDB_V1")

-- ORDERED DATASTORES
local CoinsLeaderboard = DataStoreService:GetOrderedDataStore("Leaderboard_Coins")
local LevelLeaderboard = DataStoreService:GetOrderedDataStore("Leaderboard_Level")
local TotalScoreLeaderboard = DataStoreService:GetOrderedDataStore("Leaderboard_TotalScore")

local sessions = {}
local activeQuizzes = {}
local avatarCooldowns = {}

local profileEvent = ReplicatedStorage:WaitForChild("ProfileEvent")
local shopEvent = ReplicatedStorage:WaitForChild("ShopEvent")
local dailyEvent = ReplicatedStorage:WaitForChild("DailyRewardEvent")
local equipEvent = ReplicatedStorage:WaitForChild("EquipBagEvent")
local spawnEvent = ReplicatedStorage:WaitForChild("SpawnVehicleEvent")

local AvatarEvent = ReplicatedStorage:FindFirstChild("AvatarEvent") 
if not AvatarEvent then
	AvatarEvent = Instance.new("RemoteEvent")
	AvatarEvent.Name = "AvatarEvent"
	AvatarEvent.Parent = ReplicatedStorage
end

local GetBestScore = Remotes:FindFirstChild("GetBestScore") or Instance.new("RemoteFunction", Remotes)
GetBestScore.Name = "GetBestScore"

local TTSScoreEvent = Remotes:FindFirstChild("TTSScoreEvent") or Instance.new("RemoteEvent", Remotes)
TTSScoreEvent.Name = "TTSScoreEvent"

local StartQuiz = Remotes:FindFirstChild("StartQuiz") or Instance.new("RemoteEvent", Remotes)
StartQuiz.Name = "StartQuiz"

local ExitQuiz = Remotes:FindFirstChild("ExitQuiz") or Instance.new("RemoteEvent", Remotes)
ExitQuiz.Name = "ExitQuiz"

local SubmitAnswer = Remotes:FindFirstChild("SubmitAnswer") or Instance.new("RemoteFunction", Remotes)
SubmitAnswer.Name = "SubmitAnswer"

local QuizRewardEvent = Remotes:FindFirstChild("QuizRewardEvent") or Instance.new("RemoteEvent", Remotes)
QuizRewardEvent.Name = "QuizRewardEvent"

local QUIZ_FIRST_COINS   = 500
local TTS_FIRST_COINS    = 500
local QUIZ_GACHA_MIN     = 50
local QUIZ_GACHA_MAX     = 100
local QUIZ_MAX_SCORE     = 1000
local TTS_MAX_SCORE      = 1250
local TTS_TIME_LIMIT     = 600
local QUIZ_SCORE_PER_Q   = 100

function saveEcoData(player)
	if not player:FindFirstChild("leaderstats") then return end
	local ecoData = {
		Coins = player.leaderstats.Coins.Value, Level = player.leaderstats.Level.Value,
		FreeRenames = player.FreeRenames.Value, FreeRestores = player.FreeRestores.Value,
		OwnedBags = player.OwnedBags.Value, LastLoginDay = player.LastLoginDay.Value, LoginStreak = player.LoginStreak.Value
	}
	pcall(function()
		EcoStore:SetAsync(player.UserId, ecoData)
		CoinsLeaderboard:SetAsync(player.UserId, ecoData.Coins)
		LevelLeaderboard:SetAsync(player.UserId, ecoData.Level)
	end)
end

-- [A] SISTEM SIKLUS WAKTU
local dayLength = 12 local cycleTime = dayLength * 60 local minutesInADay = 24 * 60 local timeRatio = minutesInADay / cycleTime
local currentDay = Lighting:FindFirstChild("CurrentDay")
if not currentDay then currentDay = Instance.new("IntValue") currentDay.Name = "CurrentDay" currentDay.Value = 1 currentDay.Parent = Lighting end
local startTime = tick() - (Lighting:GetMinutesAfterMidnight() / minutesInADay) * cycleTime local endTime = startTime + cycleTime

RunService.Heartbeat:Connect(function()
	local currentTime = tick()
	if currentTime > endTime then startTime = endTime endTime = startTime + cycleTime currentDay.Value = (currentDay.Value % 7) + 1 end
	Lighting:SetMinutesAfterMidnight((currentTime - startTime) * timeRatio)
end)

-- [B] SISTEM EVENT (SHOP, DAILY, SPAWN)
shopEvent.OnServerEvent:Connect(function(player, action, itemId)
	if action == "BuyBag" and itemId then
		local coins = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Coins")
		local ownedBags = player:FindFirstChild("OwnedBags")
		if coins and coins.Value >= 100 and ownedBags then
			local itemIdStr = tostring(itemId) local alreadyOwned = false
			for _, owned in ipairs(string.split(ownedBags.Value, ",")) do if owned == itemIdStr then alreadyOwned = true break end end
			if not alreadyOwned then coins.Value -= 100 ownedBags.Value = ownedBags.Value .. "," .. itemIdStr saveEcoData(player) end
		end
	end
end)

dailyEvent.OnServerEvent:Connect(function(player)
	local canClaim = player:FindFirstChild("CanClaimDaily") local coins = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Coins")
	local lastLogin = player:FindFirstChild("LastLoginDay") local streak = player:FindFirstChild("LoginStreak")
	if canClaim and canClaim.Value and coins and lastLogin and streak then
		local currentRealDay = math.floor(os.time() / 86400) coins.Value += 50 + (streak.Value * 10) 
		canClaim.Value = false lastLogin.Value = currentRealDay saveEcoData(player)
	end
end)

spawnEvent.OnServerEvent:Connect(function(player, vehicleType)
	if type(vehicleType) ~= "string" then return end
	local vehicleTemplate = ReplicatedStorage:FindFirstChild(vehicleType) if not vehicleTemplate then return end
	local oldVehicleName = player.Name .. "_Vehicle" local existingVehicle = Workspace:FindFirstChild(oldVehicleName)
	if existingVehicle then existingVehicle:Destroy() end
	local char = player.Character if char and char:FindFirstChild("HumanoidRootPart") then
		local newVehicle = vehicleTemplate:Clone() newVehicle.Name = oldVehicleName
		local spawnCFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
		if newVehicle:IsA("Model") and newVehicle.PrimaryPart then newVehicle:SetPrimaryPartCFrame(spawnCFrame)
		elseif newVehicle:IsA("BasePart") then newVehicle.CFrame = spawnCFrame end
		newVehicle.Parent = Workspace
	end
end)

-- [C] SISTEM EQUIP TAS
equipEvent.OnServerEvent:Connect(function(player, bagId)
	local char = player.Character if char and char:FindFirstChild("Humanoid") then
		local hum = char.Humanoid for _, acc in pairs(char:GetChildren()) do if acc:IsA("Accessory") and acc.Name == "RoleplayLoadedBag" then acc:Destroy() end end
		if bagId == 0 or bagId == "Unequip" then return end
		local success, model = pcall(function() return InsertService:LoadAsset(tonumber(bagId)) end)
		if success and model then
			local accessory = model:GetChildren()[1] if accessory and accessory:IsA("Accessory") then accessory.Name = "RoleplayLoadedBag" hum:AddAccessory(accessory) end
			model:Destroy()
		end
	end
end)

-- [D] SISTEM SCORE CACHE & LEADERBOARD
local quizTypesList = {"Truth", "Time", "Magic", "Kind", "Trust", "TTS_Truth", "TTS_Time", "TTS_Magic", "TTS_Kind", "TTS_Trust"}

local function loadPlayerScores(player)
	sessions[player.UserId] = sessions[player.UserId] or { Scores = {} }
	task.spawn(function()
		for _, qt in ipairs(quizTypesList) do
			pcall(function()
				local s = ScoreDS:GetAsync(player.UserId .. "_" .. qt)
				sessions[player.UserId].Scores[qt] = (s and type(s) == "number") and s or 0
			end)
		end
	end)
end

GetBestScore.OnServerInvoke = function(player, quizType)
	if type(quizType) ~= "string" then return 0 end
	if sessions[player.UserId] and sessions[player.UserId].Scores then return sessions[player.UserId].Scores[quizType] or 0 end return 0
end

local ALLOWED_TTS_TYPES = { Truth = true, Time = true, Magic = true, Kind = true, Trust = true }

local function UpdateTotalScoreLeaderboard(player)
	task.spawn(function()
		local total = 0
		if sessions[player.UserId] and sessions[player.UserId].Scores then
			for _, qt in ipairs(quizTypesList) do total += (sessions[player.UserId].Scores[qt] or 0) end
		end
		pcall(function() TotalScoreLeaderboard:SetAsync(player.UserId, total) end)
	end)
end

local function saveTTSScore(player, ttsType, score)
	if type(ttsType) ~= "string" or not ALLOWED_TTS_TYPES[ttsType] or type(score) ~= "number" then return end
	score = math.max(0, math.floor(score))
	if sessions[player.UserId] and sessions[player.UserId].Scores then
		local currentBest = sessions[player.UserId].Scores[ttsType] or 0
		if score > currentBest then sessions[player.UserId].Scores[ttsType] = score else return end
	end
	pcall(function() ScoreDS:SetAsync(player.UserId .. "_TTS_" .. ttsType, score) end)
	UpdateTotalScoreLeaderboard(player)
end

TTSScoreEvent.OnServerEvent:Connect(function(player, ttsType, score)
	saveTTSScore(player, string.sub(ttsType, 5), score) 
end)

-- [G] QUIZ SYSTEM HANDLERS
local function hasCompleted(player, key)
	local cq = player:FindFirstChild("CompletedQuizzes") if not cq then return false end
	for _, v in ipairs(string.split(cq.Value, ",")) do if v == key then return true end end return false
end

local function markCompleted(player, key)
	local cq = player:FindFirstChild("CompletedQuizzes") if not cq then return end
	if hasCompleted(player, key) then return end
	if cq.Value == "" then cq.Value = key else cq.Value = cq.Value .. "," .. key end
	pcall(function() RewardDS:SetAsync(player.UserId .. "_CompletedQuizzes", cq.Value) end)
end

local function giveQuizReward(player, quizKey, isTTS, finalScore)
	local coins = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Coins")
	local level = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Level")
	if not coins or not level then return end

	local isFirst = not hasCompleted(player, quizKey)
	local coinsGiven = isFirst and (isTTS and TTS_FIRST_COINS or QUIZ_FIRST_COINS) or math.random(QUIZ_GACHA_MIN, QUIZ_GACHA_MAX)

	coins.Value += coinsGiven
	if isFirst then level.Value += 1 markCompleted(player, quizKey) end

	saveEcoData(player)
	QuizRewardEvent:FireClient(player, {CoinsGiven = coinsGiven, IsFirst = isFirst, DidLevelUp = isFirst, FinalScore = finalScore, NewLevel = level.Value, NewCoins = coins.Value})
end

StartQuiz.OnServerEvent:Connect(function(player, quizType)
	if not AllQuizData[quizType] then return end
	activeQuizzes[player.UserId] = {Type = quizType, IsTTS = string.sub(quizType, 1, 4) == "TTS_", CurrentQ = 1, Corrects = 0, Wrongs = 0, StartTime = os.time()}
end)
ExitQuiz.OnServerEvent:Connect(function(player) if activeQuizzes[player.UserId] then activeQuizzes[player.UserId] = nil end end)

SubmitAnswer.OnServerInvoke = function(player, answerIndex)
	if type(answerIndex) ~= "number" or answerIndex < 1 or answerIndex ~= math.floor(answerIndex) then return false, false, 0, 0, 1 end
	local session = activeQuizzes[player.UserId] if not session then return false, false, 0, 0, 1 end

	if (os.time() - session.StartTime) > TTS_TIME_LIMIT + 5 then activeQuizzes[player.UserId] = nil return false, false, session.Corrects, session.Wrongs, session.CurrentQ end

	local qData = AllQuizData[session.Type] local currentQuestionData = qData.Questions[session.CurrentQ]
	if not currentQuestionData then activeQuizzes[player.UserId] = nil return false, false, session.Corrects, session.Wrongs, session.CurrentQ end

	local isCorrect = (answerIndex == currentQuestionData.A)
	if isCorrect then session.Corrects += 1 else session.Wrongs += 1 end session.CurrentQ += 1

	local nextQ = session.CurrentQ
	if not qData.Questions[nextQ] then
		local finalScore = 0 local quizKey = ""
		if session.IsTTS then
			local timeRemaining = math.max(0, TTS_TIME_LIMIT - (os.time() - session.StartTime))
			finalScore = math.floor(TTS_MAX_SCORE * (timeRemaining / TTS_TIME_LIMIT) * (session.Corrects / 10))
			saveTTSScore(player, string.sub(session.Type, 5), finalScore) quizKey = "TTS_" .. string.sub(session.Type, 5)
		else
			finalScore = session.Corrects * QUIZ_SCORE_PER_Q
			if sessions[player.UserId] and sessions[player.UserId].Scores then
				if finalScore > (sessions[player.UserId].Scores[session.Type] or 0) then
					sessions[player.UserId].Scores[session.Type] = finalScore
					pcall(function() ScoreDS:SetAsync(player.UserId .. "_" .. session.Type, finalScore) end) UpdateTotalScoreLeaderboard(player)
				end
			end
			quizKey = "Quiz_" .. session.Type
		end
		if session.Wrongs <= 4 then giveQuizReward(player, quizKey, session.IsTTS, finalScore)
		else QuizRewardEvent:FireClient(player, {CoinsGiven = 0, IsFirst = false, DidLevelUp = false, FinalScore = finalScore, Failed = true, NewLevel = player.leaderstats and player.leaderstats.Level.Value or 1, NewCoins = player.leaderstats and player.leaderstats.Coins.Value or 0}) end
		activeQuizzes[player.UserId] = nil
	end
	return true, isCorrect, session.Corrects, session.Wrongs, nextQ
end

-- [E] DATASTORE & NAMETAG LOGIC
local function getTitleFromLevel(level)
	if level == 1 then return "Pendatang Baru" elseif level == 2 then return "Siswa Baru" elseif level >= 3 then return "Siswa Aktif" else return "Pendatang Baru" end
end

local function createOrUpdateNameTag(char, nameText, playerLevel)
	if not char then return end local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 5) local hum = char:FindFirstChild("Humanoid") or char:WaitForChild("Humanoid", 5)
	if not head or not hum then return end
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	for _, child in pairs(char:GetDescendants()) do if child.Name == "RPNameTag" and child:IsA("BillboardGui") then child:Destroy() end end
	local template = ReplicatedStorage:FindFirstChild("RPNameTag") if not template then return end
	local newTag = template:Clone() newTag.Adornee = head newTag.Parent = head
	local infoFrame = newTag:FindFirstChild("Info")
	if infoFrame then
		local nLabel = infoFrame:FindFirstChild("PlayerDisplayName") local tLabel = infoFrame:FindFirstChild("PlayerName")
		if nLabel then nLabel.Text = nameText end if tLabel then tLabel.Text = getTitleFromLevel(playerLevel) end
	end
end

local function getSavedRPName(player)
	local rpName = player.DisplayName pcall(function() local savedName = ProfileStore:GetAsync(player.UserId .. "_RPName") if savedName then rpName = savedName end end) return rpName
end

local function saveProfileData(player)
	pcall(function() ProfileStore:SetAsync(player.UserId .. "_School", player:FindFirstChild("School") and player.School.Value or "") ProfileStore:SetAsync(player.UserId .. "_Class", player:FindFirstChild("Class") and player.Class.Value or "") end)
end

local function setupPlayer(player)
	if player:FindFirstChild("leaderstats") then return end
	local leaderstats = Instance.new("Folder", player) leaderstats.Name = "leaderstats"
	local levelStat = Instance.new("IntValue", leaderstats) levelStat.Name = "Level" levelStat.Value = 1
	local coinsStat = Instance.new("IntValue", leaderstats) coinsStat.Name = "Coins" coinsStat.Value = 0

	local freeRenames = Instance.new("IntValue", player) freeRenames.Name = "FreeRenames" freeRenames.Value = 1
	local freeRestores = Instance.new("IntValue", player) freeRestores.Name = "FreeRestores" freeRestores.Value = 1
	local ownedBags = Instance.new("StringValue", player) ownedBags.Name = "OwnedBags" ownedBags.Value = "103537903282418"
	local school = Instance.new("StringValue", player) school.Name = "School"
	local class = Instance.new("StringValue", player) class.Name = "Class"
	local lastLoginDay = Instance.new("IntValue", player) lastLoginDay.Name = "LastLoginDay"
	local loginStreak = Instance.new("IntValue", player) loginStreak.Name = "LoginStreak" loginStreak.Value = 1
	local canClaimDaily = Instance.new("BoolValue", player) canClaimDaily.Name = "CanClaimDaily" canClaimDaily.Value = true
	local completedQuizzes = Instance.new("StringValue", player) completedQuizzes.Name = "CompletedQuizzes"

	local currentRealDay = math.floor(os.time() / 86400)

	task.spawn(function()
		pcall(function()
			local ecoData = EcoStore:GetAsync(player.UserId)
			if ecoData then
				coinsStat.Value = ecoData.Coins or 0 levelStat.Value = ecoData.Level or 1
				freeRenames.Value = ecoData.FreeRenames or 1 freeRestores.Value = ecoData.FreeRestores or 1
				ownedBags.Value = ecoData.OwnedBags or "103537903282418"
				if currentRealDay > (ecoData.LastLoginDay or 0) then
					canClaimDaily.Value = true
					loginStreak.Value = (currentRealDay > (ecoData.LastLoginDay or 0) + 1) and 1 or math.min(7, (ecoData.LoginStreak or 1) + 1)
				else canClaimDaily.Value = false loginStreak.Value = ecoData.LoginStreak or 1 end
				lastLoginDay.Value = ecoData.LastLoginDay or 0
			end
		end)
		pcall(function() player.School.Value = ProfileStore:GetAsync(player.UserId .. "_School") or "" player.Class.Value = ProfileStore:GetAsync(player.UserId .. "_Class") or "" end)
		pcall(function() completedQuizzes.Value = RewardDS:GetAsync(player.UserId .. "_CompletedQuizzes") or "" end)
		loadPlayerScores(player)
	end)

	player.CharacterAdded:Connect(function(char) createOrUpdateNameTag(char, getSavedRPName(player), levelStat.Value) end)
	if player.Character then task.spawn(function() createOrUpdateNameTag(player.Character, getSavedRPName(player), levelStat.Value) end) end
end

Players.PlayerAdded:Connect(setupPlayer) for _, p in pairs(Players:GetPlayers()) do task.spawn(setupPlayer, p) end
Players.PlayerRemoving:Connect(function(player)
	saveEcoData(player) saveProfileData(player)
	if player:FindFirstChild("CompletedQuizzes") then pcall(function() RewardDS:SetAsync(player.UserId .. "_CompletedQuizzes", player.CompletedQuizzes.Value) end) end
	sessions[player.UserId] = nil activeQuizzes[player.UserId] = nil avatarCooldowns[player.UserId] = nil
end)

-- [H] AVATAR EVENT
AvatarEvent.OnServerEvent:Connect(function(player, targetInput)
	local now = tick() if avatarCooldowns[player.UserId] and now - avatarCooldowns[player.UserId] < 5 then return end avatarCooldowns[player.UserId] = now
	local char = player.Character if char and char:FindFirstChild("Humanoid") then
		local success = pcall(function()
			local validId = tonumber(targetInput) or Players:GetUserIdFromNameAsync(tostring(targetInput))
			if validId and validId > 0 then local desc = Players:GetHumanoidDescriptionFromUserId(validId) if desc then char.Humanoid:ApplyDescription(desc) end end
		end)
		if success then task.spawn(function() task.wait(1) createOrUpdateNameTag(char, getSavedRPName(player), player.leaderstats and player.leaderstats.Level.Value or 1) end) end
	end
end)

-- [F] PROFILE EVENT
profileEvent.OnServerEvent:Connect(function(player, action, newName, newSchool, newClass)
	local char = player.Character if not char then return end
	local coins = player.leaderstats.Coins local fRename = player.FreeRenames local fRestore = player.FreeRestores local level = player.leaderstats.Level.Value

	if action == "Save" and newName and newName ~= "" then
		if type(newName) ~= "string" or #newName > 30 then return end
		if fRename.Value > 0 then fRename.Value -= 1 elseif coins.Value >= 50 then coins.Value -= 50 else return end
		local finalName = newName local success, filtered = pcall(function() return TextService:FilterStringAsync(newName, player.UserId):GetNonChatStringForBroadcastAsync() end) if success and filtered then finalName = filtered end
		player.School.Value = newSchool or "" player.Class.Value = newClass or "" createOrUpdateNameTag(char, finalName, level)
		pcall(function() ProfileStore:SetAsync(player.UserId .. "_RPName", finalName) end) saveProfileData(player) saveEcoData(player)
	elseif action == "Reset" then
		if fRestore.Value > 0 then fRestore.Value -= 1 elseif coins.Value >= 25 then coins.Value -= 25 else return end
		player.School.Value = "" player.Class.Value = "" createOrUpdateNameTag(char, player.DisplayName, level)
		pcall(function() ProfileStore:RemoveAsync(player.UserId .. "_RPName") end) saveProfileData(player) saveEcoData(player)
	end
end)
]=]