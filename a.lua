local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SG = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local SPS = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local CS = game:GetService("CollectionService")

print("[Sistem TTS V2] Membersihkan state lama...")
if SPS:FindFirstChild("TTSClientLogic") then SPS.TTSClientLogic:Destroy() end 
if Workspace:FindFirstChild("TTSTerminals") then Workspace.TTSTerminals:Destroy() end
if RS:FindFirstChild("TTSData") then RS.TTSData:Destroy() end
if RS:FindFirstChild("QuizRemotes") then RS.QuizRemotes:Destroy() end
if SSS:FindFirstChild("QuizServerScript") then SSS.QuizServerScript:Destroy() end
if SG:FindFirstChild("TTSUI") then SG.TTSUI:Destroy() end

print("[Sistem TTS V2] Membangun 5 Terminal TTS & Desain Juicy...")

-- 1. SETUP 5 TERMINAL WORKSPACE
local terminalsFolder = Instance.new("Folder")
terminalsFolder.Name = "TTSTerminals"
terminalsFolder.Parent = Workspace

local ttsTypes = {
	{ID = "Time", Name = "TTS: Master of Time", Color = Color3.fromRGB(0, 170, 255), Pos = Vector3.new(-20, 2.5, -20)},
	{ID = "Truth", Name = "TTS: Master of Truth", Color = Color3.fromRGB(255, 215, 0), Pos = Vector3.new(-10, 2.5, -20)},
	{ID = "Trust", Name = "TTS: Master of Trust", Color = Color3.fromRGB(46, 204, 113), Pos = Vector3.new(0, 2.5, -20)},
	{ID = "Kind", Name = "TTS: Master of Kind", Color = Color3.fromRGB(255, 105, 180), Pos = Vector3.new(10, 2.5, -20)},
	{ID = "Magic", Name = "TTS: 3 Magic Words", Color = Color3.fromRGB(155, 89, 182), Pos = Vector3.new(20, 2.5, -20)}
}

for _, tData in ipairs(ttsTypes) do
	local part = Instance.new("Part")
	part.Name = "Terminal_TTS_" .. tData.ID
	part.Size = Vector3.new(4, 5, 4)
	part.Position = tData.Pos
	part.Anchored = true
	part.Material = Enum.Material.ForceField
	part.Color = tData.Color
	part:SetAttribute("TTSType", tData.ID) 
	part:SetAttribute("TTSColor", tData.Color)
	part:SetAttribute("TTSName", tData.Name)
	CS:AddTag(part, "TTSTerminal")
	part.Parent = terminalsFolder

	local core = Instance.new("Part")
	core.Size = Vector3.new(2, 2, 2)
	core.Position = tData.Pos
	core.Anchored = true
	core.CanCollide = false
	core.Material = Enum.Material.Neon
	core.Color = tData.Color
	core.Shape = Enum.PartType.Block
	core.Parent = part

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Main Teka-Teki 🧩"
	prompt.ObjectText = tData.Name
	prompt.HoldDuration = 0.5
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.MaxActivationDistance = 12
	prompt.Parent = part
end

-- 2. SETUP REPLICATED STORAGE (REMOTES & DATA 5 TEMA)
local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "QuizRemotes"
remotesFolder.Parent = RS

Instance.new("RemoteFunction", remotesFolder).Name = "SubmitAnswer"
Instance.new("RemoteFunction", remotesFolder).Name = "GetBestScore"
Instance.new("RemoteEvent", remotesFolder).Name = "StartQuiz"
Instance.new("RemoteEvent", remotesFolder).Name = "ExitQuiz"
Instance.new("RemoteEvent", remotesFolder).Name = "TTSScoreEvent"
Instance.new("RemoteEvent", remotesFolder).Name = "QuizRewardEvent"

local ttsDataScript = Instance.new("ModuleScript")
ttsDataScript.Name = "TTSData"
ttsDataScript.Parent = RS
ttsDataScript.Source = [=[
return {
	["Time"] = {
		{ kata = "TEKUN",   soal = "Sifat orang yang suka bekerja keras dan sungguh-sungguh", baris = 9, kolom = 1, arah = "H" },
		{ kata = "BAIK",    soal = "Lawan kata dari buruk",                                   baris = 3, kolom = 3, arah = "H" },
		{ kata = "WAKTU",   soal = "Sesuatu yang sangat berharga dan tidak bisa diulang",     baris = 13, kolom = 1, arah = "H" },
		{ kata = "BANGUN",  soal = "Kebalikan dari tidur",                                    baris = 11, kolom = 1, arah = "H" },
		{ kata = "TAAT",    soal = "Patuh terhadap aturan",                                   baris = 15, kolom = 5, arah = "H" },
		{ kata = "DISIPLIN",soal = "Sikap patuh dan taat pada aturan",                        baris = 2, kolom = 5, arah = "V" },
		{ kata = "RAJIN",   soal = "Suka bekerja atau belajar dengan giat",                   baris = 2, kolom = 4, arah = "V" },
		{ kata = "BELAJAR", soal = "Jika ingin mendapatkan nilai baik saat ulangan kita harus",baris = 8, kolom = 2, arah = "V" },
		{ kata = "NUNDA",   soal = "Kebiasaan buruk mengulur-ulur waktu (tanpa men-)",        baris = 11, kolom = 6, arah = "V" },
		{ kata = "LAKUKAN", soal = "Jika diperintah oleh orang tua kita harus segera me..",   baris = 1, kolom = 6, arah = "V" }
	},
	["Truth"] = {
		{ kata = "BOHONG",  soal = "Sikap mengatakan hal yang tidak sesuai kenyataan",        baris = 3, kolom = 3, arah = "H" },
		{ kata = "BENAR",   soal = "Sesuai fakta, tidak salah",                               baris = 3, kolom = 3, arah = "V" },
		{ kata = "MENGAKUI",soal = "Menyatakan telah berbuat salah atau jujur atas tindakan", baris = 5, kolom = 1, arah = "H" },
		{ kata = "AMANAH",  soal = "Sifat orang jujur yang selalu dapat dipercaya",           baris = 5, kolom = 5, arah = "V" },
		{ kata = "MAAF",    soal = "Kata yang diucapkan saat melakukan kesalahan",            baris = 7, kolom = 4, arah = "H" },
		{ kata = "FAKTA",   soal = "Kenyataan atau sesuatu yang benar-benar terjadi",         baris = 7, kolom = 7, arah = "V" }
	},
	["Trust"] = {
		{ kata = "AMANAH",  soal = "Sifat menjaga titipan dengan baik",                       baris = 4, kolom = 4, arah = "H" },
		{ kata = "ANDAL",   soal = "Bisa dipercaya dan diandalkan",                           baris = 4, kolom = 4, arah = "V" },
		{ kata = "JANJI",   soal = "Sesuatu yang diucapkan dan wajib ditepati",               baris = 6, kolom = 2, arah = "H" },
		{ kata = "JUJUR",   soal = "Berkata lurus dan tidak berbohong",                       baris = 6, kolom = 5, arah = "V" },
		{ kata = "JELAS",   soal = "Sikap tegas, mudah dimengerti, tidak samar-samar",        baris = 8, kolom = 5, arah = "H" },
		{ kata = "SAHABAT", soal = "Teman dekat yang selalu bisa dipercaya",                  baris = 8, kolom = 9, arah = "V" }
	},
	["Kind"] = {
		{ kata = "BANTU",   soal = "Memberi pertolongan kepada teman yang kesusahan",         baris = 3, kolom = 3, arah = "H" },
		{ kata = "BAIK",    soal = "Sifat hati yang suka menolong",                           baris = 3, kolom = 3, arah = "V" },
		{ kata = "IKHLAS",  soal = "Memberi tanpa mengharapkan imbalan apapun",               baris = 5, kolom = 3, arah = "H" },
		{ kata = "KASIH",   soal = "Perasaan sayang dan peduli kepada sesama",                baris = 5, kolom = 4, arah = "V" },
		{ kata = "SOPAN",   soal = "Sikap hormat dan lembut kepada orang lain",               baris = 7, kolom = 4, arah = "H" },
		{ kata = "PEDULI",  soal = "Sikap memperhatikan keadaan orang di sekitarmu",          baris = 7, kolom = 6, arah = "V" }
	},
	["Magic"] = {
		{ kata = "TOLONG",  soal = "Kata ajaib saat kita membutuhkan bantuan",                baris = 3, kolom = 3, arah = "H" },
		{ kata = "TERIMA",  soal = "... kasih (Mantra ajaib saat mendapat kebaikan)",         baris = 3, kolom = 3, arah = "V" },
		{ kata = "BERI",    soal = "Menyerahkan sesuatu yang baik kepada orang lain",         baris = 5, kolom = 2, arah = "H" },
		{ kata = "IKHLAS",  soal = "Hati yang tulus dalam mengucapkan kata ajaib",            baris = 5, kolom = 5, arah = "V" },
		{ kata = "LEGA",    soal = "Perasaan setelah kita jujur meminta maaf",                baris = 8, kolom = 5, arah = "H" },
		{ kata = "SENYUM",  soal = "Ekspresi wajah yang paling manis saat berterima kasih",   baris = 10, kolom = 5, arah = "H" }
	}
}
]=]
-- Kita siapkan dummy Data untuk quiz (karena script backend juga nyari ini biar gak error)
local quizDataDummy = Instance.new("ModuleScript")
quizDataDummy.Name = "QuizData"
quizDataDummy.Parent = RS
quizDataDummy.Source = "return {}"

-- 3. BUILD UI (JUICY & RESPONSIVE - NO IDLE FLOATING)
local ttsUI = Instance.new("ScreenGui")
ttsUI.Name = "TTSUI"
ttsUI.ResetOnSpawn = false
ttsUI.IgnoreGuiInset = true
ttsUI.Enabled = false 
ttsUI.Parent = SG

-- CONTAINER RESPONSIVE
local uiCont = Instance.new("Frame")
uiCont.Name = "UIContainer"
uiCont.AnchorPoint = Vector2.new(0.5, 0.5)
uiCont.Position = UDim2.new(0.5, 0, 0.5, 0)
uiCont.Size = UDim2.new(0.95, 0, 0.85, 0)
uiCont.BackgroundTransparency = 1
uiCont.Parent = ttsUI

Instance.new("UIAspectRatioConstraint", uiCont).AspectRatio = 1.4
local sizeConstraint = Instance.new("UISizeConstraint", uiCont)
sizeConstraint.MaxSize = Vector2.new(850, 600)
sizeConstraint.MinSize = Vector2.new(400, 280)

-- SHADOW TEBAL KARTUN
local dropShadow = Instance.new("Frame", uiCont)
dropShadow.Size = UDim2.new(1, 0, 1, 0)
dropShadow.Position = UDim2.new(0, 0, 0.025, 0)
dropShadow.BackgroundColor3 = Color3.fromRGB(35, 40, 65)
Instance.new("UICorner", dropShadow).CornerRadius = UDim.new(0.05, 0)

-- MAIN FRAME & GRADIENT
local mainBg = Instance.new("Frame", uiCont)
mainBg.Name = "MainBackground"
mainBg.Size = UDim2.new(1, 0, 1, 0)
mainBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", mainBg).CornerRadius = UDim.new(0.05, 0)
local mainStroke = Instance.new("UIStroke", mainBg)
mainStroke.Thickness = 6 mainStroke.Color = Color3.fromRGB(47, 54, 64)

local gradient = Instance.new("UIGradient", mainBg)
gradient.Name = "BgGradient"
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 250)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 235, 255))
}
gradient.Rotation = 45

-- HEADER DECO
local headerDeco = Instance.new("Frame", uiCont)
headerDeco.Size = UDim2.new(0.35, 0, 0.1, 0)
headerDeco.AnchorPoint = Vector2.new(0.5, 0.5)
headerDeco.Position = UDim2.new(0.5, 0, 0, 0)
headerDeco.BackgroundColor3 = Color3.fromRGB(251, 197, 49)
Instance.new("UICorner", headerDeco).CornerRadius = UDim.new(0.5, 0)
local hStroke = Instance.new("UIStroke", headerDeco)
hStroke.Thickness = 4 hStroke.Color = Color3.fromRGB(47, 54, 64)

local hText = Instance.new("TextLabel", headerDeco)
hText.Size = UDim2.new(1, 0, 1, 0)
hText.BackgroundTransparency = 1
hText.Font = Enum.Font.FredokaOne
hText.TextColor3 = Color3.fromRGB(255, 255, 255)
hText.TextScaled = true
hText.Text = "✨ TEKA-TEKI SILANG ✨"
local hTextStroke = Instance.new("UIStroke", hText)
hTextStroke.Thickness = 2 hTextStroke.Color = Color3.fromRGB(225, 112, 85)

-- HEADER INFO
local header = Instance.new("Frame", mainBg)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0.12, 0)
header.BackgroundTransparency = 1

local titleLabel = Instance.new("TextLabel", header)
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0.4, 0, 0.6, 0)
titleLabel.Position = UDim2.new(0.3, 0, 0.25, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⏳ MASTER OF TIME"
titleLabel.TextColor3 = Color3.fromRGB(108, 92, 231)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.FredokaOne
local tStroke = Instance.new("UIStroke", titleLabel)
tStroke.Thickness = 3 tStroke.Color = Color3.fromRGB(255, 255, 255)

local scoreLabel = Instance.new("TextLabel", header)
scoreLabel.Name = "ScoreLabel"
scoreLabel.Size = UDim2.new(0.2, 0, 0.6, 0)
scoreLabel.Position = UDim2.new(0.03, 0, 0.25, 0)
scoreLabel.BackgroundTransparency = 1
scoreLabel.Text = "⭐ SKOR: 0"
scoreLabel.TextColor3 = Color3.fromRGB(16, 172, 132)
scoreLabel.TextScaled = true
scoreLabel.Font = Enum.Font.FredokaOne
scoreLabel.TextXAlignment = Enum.TextXAlignment.Left

local timerLabel = Instance.new("TextLabel", header)
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(0.15, 0, 0.6, 0)
timerLabel.Position = UDim2.new(0.72, 0, 0.25, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "⏱ 10:00"
timerLabel.TextColor3 = Color3.fromRGB(255, 159, 67)
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.FredokaOne
timerLabel.TextXAlignment = Enum.TextXAlignment.Right

local exitBtn = Instance.new("TextButton", header)
exitBtn.Name = "ExitBtn"
exitBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
exitBtn.Position = UDim2.new(0.9, 0, 0.15, 0)
exitBtn.BackgroundColor3 = Color3.fromRGB(255, 107, 107)
exitBtn.Text = "✖"
exitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exitBtn.TextScaled = true
exitBtn.Font = Enum.Font.FredokaOne
Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0.25, 0)
local eStroke = Instance.new("UIStroke", exitBtn)
eStroke.Thickness = 3 eStroke.Color = Color3.fromRGB(47, 54, 64)

-- GRID PANEL (KIRI)
local gridPanel = Instance.new("Frame", mainBg)
gridPanel.Name = "GridPanel"
gridPanel.Size = UDim2.new(0.55, 0, 0.83, 0)
gridPanel.Position = UDim2.new(0.03, 0, 0.14, 0)
gridPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", gridPanel).CornerRadius = UDim.new(0.04, 0)
local gStroke = Instance.new("UIStroke", gridPanel)
gStroke.Thickness = 4 gStroke.Color = Color3.fromRGB(108, 92, 231)

local gridScroll = Instance.new("ScrollingFrame", gridPanel)
gridScroll.Name = "GridScroll"
gridScroll.Size = UDim2.new(0.96, 0, 0.96, 0)
gridScroll.Position = UDim2.new(0.02, 0, 0.02, 0)
gridScroll.BackgroundTransparency = 1
gridScroll.ScrollBarThickness = 8
gridScroll.CanvasSize = UDim2.new(0, 15 * 40, 0, 15 * 40)

-- QUESTION PANEL (KANAN)
local rightPanel = Instance.new("Frame", mainBg)
rightPanel.Name = "RightPanel"
rightPanel.Size = UDim2.new(0.38, 0, 0.83, 0)
rightPanel.Position = UDim2.new(0.6, 0, 0.14, 0)
rightPanel.BackgroundTransparency = 1

local qBoard = Instance.new("Frame", rightPanel)
qBoard.Size = UDim2.new(1, 0, 0.35, 0)
qBoard.Name = "QuestionBoard"
qBoard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", qBoard).CornerRadius = UDim.new(0.05, 0)
local qbStroke = Instance.new("UIStroke", qBoard)
qbStroke.Thickness = 4 qbStroke.Color = Color3.fromRGB(108, 92, 231)

local qNumLabel = Instance.new("TextLabel", qBoard)
qNumLabel.Name = "QuestionNum"
qNumLabel.Size = UDim2.new(0.9, 0, 0.2, 0)
qNumLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
qNumLabel.BackgroundTransparency = 1
qNumLabel.Text = "👆 Pilih kotak soal!"
qNumLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
qNumLabel.TextScaled = true
qNumLabel.Font = Enum.Font.FredokaOne
qNumLabel.TextXAlignment = Enum.TextXAlignment.Left

local qTextLabel = Instance.new("TextLabel", qBoard)
qTextLabel.Name = "QuestionText"
qTextLabel.Size = UDim2.new(0.9, 0, 0.45, 0)
qTextLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
qTextLabel.BackgroundTransparency = 1
qTextLabel.Text = "Pilih pertanyaan dari daftar di bawah untuk mulai menjawab~"
qTextLabel.TextColor3 = Color3.fromRGB(70, 70, 70)
qTextLabel.TextScaled = true
qTextLabel.TextWrapped = true
qTextLabel.Font = Enum.Font.FredokaOne
qTextLabel.TextXAlignment = Enum.TextXAlignment.Left

local qHintLabel = Instance.new("TextLabel", qBoard)
qHintLabel.Name = "HintLabel"
qHintLabel.Size = UDim2.new(0.9, 0, 0.2, 0)
qHintLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
qHintLabel.BackgroundTransparency = 1
qHintLabel.Text = ""
qHintLabel.TextColor3 = Color3.fromRGB(108, 92, 231)
qHintLabel.TextScaled = true
qHintLabel.Font = Enum.Font.FredokaOne
qHintLabel.TextXAlignment = Enum.TextXAlignment.Left

local inputPanel = Instance.new("Frame", rightPanel)
inputPanel.Size = UDim2.new(1, 0, 0.15, 0)
inputPanel.Name = "InputPanel" 
inputPanel.Position = UDim2.new(0, 0, 0.38, 0)
inputPanel.BackgroundTransparency = 1

local answerBox = Instance.new("TextBox", inputPanel)
answerBox.Name = "AnswerBox"
answerBox.Size = UDim2.new(0.65, 0, 1, 0)
answerBox.BackgroundColor3 = Color3.fromRGB(240, 248, 255)
answerBox.PlaceholderText = "Jawaban..."
answerBox.Text = ""
answerBox.TextColor3 = Color3.fromRGB(70, 40, 120)
answerBox.TextScaled = true
answerBox.Font = Enum.Font.FredokaOne
answerBox.ClearTextOnFocus = true
Instance.new("UICorner", answerBox).CornerRadius = UDim.new(0.2, 0)
local aStroke = Instance.new("UIStroke", answerBox)
aStroke.Thickness = 3 aStroke.Color = Color3.fromRGB(108, 92, 231)

local submitBtn = Instance.new("TextButton", inputPanel)
submitBtn.Name = "SubmitBtn"
submitBtn.Size = UDim2.new(0.32, 0, 1, 0)
submitBtn.Position = UDim2.new(0.68, 0, 0, 0)
submitBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 126)
submitBtn.Text = "JAWAB!"
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.TextScaled = true
submitBtn.Font = Enum.Font.FredokaOne
Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0.2, 0)
local sbStroke = Instance.new("UIStroke", submitBtn)
sbStroke.Thickness = 3 sbStroke.Color = Color3.fromRGB(47, 54, 64)

local questionScroll = Instance.new("ScrollingFrame", rightPanel)
questionScroll.Name = "QuestionScroll"
questionScroll.Size = UDim2.new(1, 0, 0.43, 0)
questionScroll.Position = UDim2.new(0, 0, 0.57, 0)
questionScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
questionScroll.BackgroundTransparency = 0.3
questionScroll.ScrollBarThickness = 6
Instance.new("UICorner", questionScroll).CornerRadius = UDim.new(0.05, 0)
local qsStroke = Instance.new("UIStroke", questionScroll)
qsStroke.Thickness = 3 qsStroke.Color = Color3.fromRGB(108, 92, 231)

local qListLayout = Instance.new("UIListLayout", questionScroll)
qListLayout.Padding = UDim.new(0.03, 0)
qListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- TOAST NOTIFICATION
local toastFrame = Instance.new("Frame", uiCont)
toastFrame.Name = "ToastFrame"
toastFrame.Size = UDim2.new(0.6, 0, 0.12, 0)
toastFrame.Position = UDim2.new(0.2, 0, 0.85, 0)
toastFrame.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
toastFrame.Visible = false
toastFrame.ZIndex = 50
Instance.new("UICorner", toastFrame).CornerRadius = UDim.new(0.5, 0)
local toastStroke = Instance.new("UIStroke", toastFrame)
toastStroke.Thickness = 3 toastStroke.Color = Color3.fromRGB(47, 54, 64)
local toastLabel = Instance.new("TextLabel", toastFrame)
toastLabel.Name = "ToastLabel"
toastLabel.Size = UDim2.new(0.9, 0, 0.8, 0)
toastLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
toastLabel.BackgroundTransparency = 1
toastLabel.Text = ""
toastLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
toastLabel.TextScaled = true
toastLabel.Font = Enum.Font.FredokaOne

-- RESULT PANEL OVERLAY
local resultPanel = Instance.new("Frame", uiCont)
resultPanel.Name = "ResultPanel"
resultPanel.Size = UDim2.new(1, 0, 1, 0)
resultPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
resultPanel.Visible = false
resultPanel.ZIndex = 100
Instance.new("UICorner", resultPanel).CornerRadius = UDim.new(0.05, 0)

local rGrad = Instance.new("UIGradient", resultPanel)
rGrad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 250, 205)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 228, 181))
}
rGrad.Rotation = 45

local rTitle = Instance.new("TextLabel", resultPanel)
rTitle.Name = "ResultTitle"
rTitle.Size = UDim2.new(1, 0, 0.15, 0)
rTitle.Position = UDim2.new(0, 0, 0.1, 0)
rTitle.BackgroundTransparency = 1
rTitle.Text = "🏆 SELAMAT! 🏆"
rTitle.TextColor3 = Color3.fromRGB(255, 140, 0)
rTitle.TextScaled = true
rTitle.Font = Enum.Font.FredokaOne
rTitle.ZIndex = 101
local rtStroke = Instance.new("UIStroke", rTitle)
rtStroke.Thickness = 3 rtStroke.Color = Color3.fromRGB(255, 255, 255)

local rScore = Instance.new("TextLabel", resultPanel)
rScore.Name = "ResultScore"
rScore.Size = UDim2.new(1, 0, 0.1, 0)
rScore.Position = UDim2.new(0, 0, 0.3, 0)
rScore.BackgroundTransparency = 1
rScore.Text = "Skor Akhir: 0"
rScore.TextColor3 = Color3.fromRGB(70, 40, 120)
rScore.TextScaled = true
rScore.Font = Enum.Font.FredokaOne
rScore.ZIndex = 101

local rStars = Instance.new("TextLabel", resultPanel)
rStars.Name = "ResultStars"
rStars.Size = UDim2.new(1, 0, 0.15, 0)
rStars.Position = UDim2.new(0, 0, 0.45, 0)
rStars.BackgroundTransparency = 1
rStars.Text = "⭐ ⭐ ⭐"
rStars.TextColor3 = Color3.fromRGB(255, 215, 0)
rStars.TextScaled = true
rStars.Font = Enum.Font.FredokaOne
rStars.ZIndex = 101

local rMsg = Instance.new("TextLabel", resultPanel)
rMsg.Name = "ResultMsg"
rMsg.Size = UDim2.new(0.8, 0, 0.1, 0)
rMsg.Position = UDim2.new(0.1, 0, 0.65, 0)
rMsg.BackgroundTransparency = 1
rMsg.Text = "Kamu berhasil menyelesaikan teka-teki!"
rMsg.TextColor3 = Color3.fromRGB(70, 150, 70)
rMsg.TextScaled = true
rMsg.Font = Enum.Font.FredokaOne
rMsg.ZIndex = 101

local rCloseBtn = Instance.new("TextButton", resultPanel)
rCloseBtn.Size = UDim2.new(0.4, 0, 0.12, 0)
rCloseBtn.Position = UDim2.new(0.3, 0, 0.8, 0)
rCloseBtn.BackgroundColor3 = Color3.fromRGB(232, 65, 24)
rCloseBtn.Text = "TUTUP"
rCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rCloseBtn.TextScaled = true
rCloseBtn.Font = Enum.Font.FredokaOne
rCloseBtn.ZIndex = 101
Instance.new("UICorner", rCloseBtn).CornerRadius = UDim.new(0.5, 0)
local rcStroke = Instance.new("UIStroke", rCloseBtn)
rcStroke.Thickness = 3 rcStroke.Color = Color3.fromRGB(47, 54, 64)

-- 4. CLIENT LOGIC (ANIMASI & GRID DYNAMIC)
local clientLogic = Instance.new("LocalScript")
clientLogic.Name = "TTSClientLogic"
clientLogic.Parent = ttsUI
clientLogic.Source = [=[
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local CS = game:GetService("CollectionService")

local AllTTSData = require(RS:WaitForChild("TTSData"))
local Remotes = RS:WaitForChild("QuizRemotes")

local gui = script.Parent
local uiCont = gui:WaitForChild("UIContainer")
local mainBg = uiCont:WaitForChild("MainBackground")
local header = mainBg:WaitForChild("Header")
local titleLabel = header:WaitForChild("Title")
local scoreLabel = header:WaitForChild("ScoreLabel")
local timerLabel = header:WaitForChild("TimerLabel")
local exitBtn = header:WaitForChild("ExitBtn")

local gridScroll = mainBg:WaitForChild("GridPanel"):WaitForChild("GridScroll")
local rightPanel = mainBg:WaitForChild("RightPanel")
local qBoard = rightPanel:WaitForChild("QuestionBoard")
local qNum = qBoard:WaitForChild("QuestionNum")
local qText = qBoard:WaitForChild("QuestionText")
local qHint = qBoard:WaitForChild("HintLabel")

local inputPanel = rightPanel:WaitForChild("InputPanel")
local answerBox = inputPanel:WaitForChild("AnswerBox")
local submitBtn = inputPanel:WaitForChild("SubmitBtn")
local questionScroll = rightPanel:WaitForChild("QuestionScroll")

local toastFrame = uiCont:WaitForChild("ToastFrame")
local toastLabel = toastFrame:WaitForChild("ToastLabel")
local resultPanel = uiCont:WaitForChild("ResultPanel")

local activeType = ""
local currentData = {}
local cellMap = {}
local gridCells = {}
local questionButtons = {}

local gameState = {
	score = 0,
	answered = {},
	selectedQ = nil,
	timeLeft = 600,
	gameOver = false
}

local responsiveSize = UDim2.new(0.95, 0, 0.85, 0)

local function animateBtn3D(btn, isPressing)
	if isPressing then
		TS:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Position = UDim2.new(0, 0, 0, 0)}):Play()
	else
		TS:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Bounce), {Position = UDim2.new(0, 0, -0.15, 0)}):Play()
	end
end

local function showToast(msg, isSuccess)
	toastFrame.BackgroundColor3 = isSuccess and Color3.fromRGB(50, 255, 126) or Color3.fromRGB(255, 107, 107)
	toastLabel.Text = msg
	toastFrame.Visible = true
	task.delay(2.5, function() if toastFrame then toastFrame.Visible = false end end)
end

local function buildGridAndList()
	for _, c in ipairs(gridScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	for _, c in ipairs(questionScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
	
	cellMap = {} gridCells = {} questionButtons = {}
	for r = 1, 15 do
		cellMap[r] = {} gridCells[r] = {}
		for c = 1, 15 do
			cellMap[r][c] = { visible = false, nomor = nil }
			
			local cell = Instance.new("Frame")
			cell.Size = UDim2.new(0, 36, 0, 36)
			cell.Position = UDim2.new(0, (c - 1) * 38 + 5, 0, (r - 1) * 38 + 5)
			cell.BackgroundColor3 = Color3.fromRGB(220, 210, 255)
			cell.BackgroundTransparency = 0.5
			Instance.new("UICorner", cell).CornerRadius = UDim.new(0.1, 0)
			
			local numLbl = Instance.new("TextLabel", cell)
			numLbl.Name = "NumLabel"
			numLbl.Size = UDim2.new(0, 12, 0, 12)
			numLbl.Position = UDim2.new(0, 2, 0, 2)
			numLbl.BackgroundTransparency = 1
			numLbl.Text = ""
			numLbl.TextColor3 = Color3.fromRGB(232, 65, 24)
			numLbl.TextScaled = true
			numLbl.Font = Enum.Font.FredokaOne
			numLbl.ZIndex = 3
			
			local letLbl = Instance.new("TextLabel", cell)
			letLbl.Name = "LetterLabel"
			letLbl.Size = UDim2.new(1, 0, 1, 0)
			letLbl.BackgroundTransparency = 1
			letLbl.Text = ""
			letLbl.TextColor3 = Color3.fromRGB(70, 40, 120)
			letLbl.TextScaled = true
			letLbl.Font = Enum.Font.FredokaOne
			letLbl.ZIndex = 2
			
			cell.Parent = gridScroll
			gridCells[r][c] = cell
		end
	end

	for i, data in ipairs(currentData) do
		gameState.answered[i] = false
		for j = 1, #data.kata do
			local r = data.baris + (data.arah == "V" and (j - 1) or 0)
			local c = data.kolom + (data.arah == "H" and (j - 1) or 0)
			if r >= 1 and r <= 15 and c >= 1 and c <= 15 then
				cellMap[r][c].visible = true
				if j == 1 then
					cellMap[r][c].nomor = cellMap[r][c].nomor and (cellMap[r][c].nomor .. "," .. i) or i
				end
			end
		end
		
		local qBtn = Instance.new("TextButton")
		qBtn.Name = "Q_" .. i
		qBtn.Size = UDim2.new(0.9, 0, 0, 60)
		qBtn.BackgroundColor3 = Color3.fromRGB(240, 248, 255)
		qBtn.Text = ""
		Instance.new("UICorner", qBtn).CornerRadius = UDim.new(0.2, 0)
		local qStroke = Instance.new("UIStroke", qBtn)
		qStroke.Thickness = 2 qStroke.Color = Color3.fromRGB(180, 150, 255)
		
		local qLbl = Instance.new("TextLabel", qBtn)
		qLbl.Size = UDim2.new(0.8, 0, 0.8, 0)
		qLbl.Position = UDim2.new(0.05, 0, 0.1, 0)
		qLbl.BackgroundTransparency = 1
		qLbl.Text = i .. ". " .. data.soal
		qLbl.TextColor3 = Color3.fromRGB(70, 40, 120)
		qLbl.TextScaled = true
		qLbl.TextWrapped = true
		qLbl.Font = Enum.Font.FredokaOne
		qLbl.TextXAlignment = Enum.TextXAlignment.Left
		
		qBtn.Parent = questionScroll
		questionButtons[i] = qBtn
		
		qBtn.MouseButton1Click:Connect(function()
			if not gameState.gameOver then selectQuestion(i) end
		end)
	end
	
	for r = 1, 15 do
		for c = 1, 15 do
			local cell = gridCells[r][c]
			if cellMap[r][c].visible then
				cell.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				cell.BackgroundTransparency = 0
				if cellMap[r][c].nomor then cell.NumLabel.Text = tostring(cellMap[r][c].nomor) end
			else
				cell.Visible = false
			end
		end
	end
	
	questionScroll.CanvasSize = UDim2.new(0, 0, 0, #currentData * 65)
end

local function highlightCells(qIndex, color)
	local data = currentData[qIndex]
	if not data then return end
	for j = 1, #data.kata do
		local r = data.baris + (data.arah == "V" and (j - 1) or 0)
		local c = data.kolom + (data.arah == "H" and (j - 1) or 0)
		if r >= 1 and r <= 15 and c >= 1 and c <= 15 then
			gridCells[r][c].BackgroundColor3 = color
		end
	end
end

local function fillGridAnswer(qIndex)
	local data = currentData[qIndex]
	if not data then return end
	for j = 1, #data.kata do
		local r = data.baris + (data.arah == "V" and (j - 1) or 0)
		local c = data.kolom + (data.arah == "H" and (j - 1) or 0)
		if r >= 1 and r <= 15 and c >= 1 and c <= 15 then
			gridCells[r][c].LetterLabel.Text = string.sub(data.kata, j, j)
			gridCells[r][c].LetterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			gridCells[r][c].BackgroundColor3 = Color3.fromRGB(50, 255, 126) 
		end
	end
end

local function showResult()
	gameState.gameOver = true
	local totalA = 0
	for _, v in pairs(gameState.answered) do if v then totalA = totalA + 1 end end
	
	resultPanel.ResultScore.Text = "Skor: " .. gameState.score
	if totalA == #currentData then
		resultPanel.ResultStars.Text = "⭐ ⭐ ⭐"
		resultPanel.ResultMsg.Text = "Luar biasa! Kamu menyelesaikan semua teka-teki!"
	else
		resultPanel.ResultStars.Text = "⭐"
		resultPanel.ResultMsg.Text = "Terjawab " .. totalA .. "/" .. #currentData .. ". Tetap Semangat!"
	end
	
	-- FIRING SCORE KE SERVER UNTUK REWARD & LEADERBOARD
	Remotes.TTSScoreEvent:FireServer("TTS_" .. activeType, gameState.score)
	
	resultPanel.Visible = true
end

function selectQuestion(qIndex)
	if gameState.gameOver then return end
	if gameState.selectedQ and not gameState.answered[gameState.selectedQ] then
		highlightCells(gameState.selectedQ, Color3.fromRGB(255, 255, 255))
	end
	
	gameState.selectedQ = qIndex
	local data = currentData[qIndex]
	if not gameState.answered[qIndex] then
		highlightCells(qIndex, Color3.fromRGB(255, 250, 150))
	end
	
	local dir = data.arah == "H" and "Mendatar" or "Menurun"
	qNum.Text = "Soal " .. qIndex .. " (" .. dir .. ")"
	qText.Text = data.soal
	qHint.Text = gameState.answered[qIndex] and "✨ Sudah dijawab!" or "Petunjuk: " .. #data.kata .. " huruf"
	
	answerBox.Text = ""
	if not gameState.answered[qIndex] then answerBox:CaptureFocus() end
end

local function checkAnswer()
	if gameState.gameOver or not gameState.selectedQ then return end
	if gameState.answered[gameState.selectedQ] then return end
	
	local jawaban = string.upper(answerBox.Text)
	local data = currentData[gameState.selectedQ]
	
	if jawaban == string.upper(data.kata) then
		gameState.answered[gameState.selectedQ] = true
		gameState.score = gameState.score + (100 * #data.kata)
		scoreLabel.Text = "⭐ SKOR: " .. gameState.score
		
		fillGridAnswer(gameState.selectedQ)
		showToast("✅ BENAR!", true)
		answerBox.Text = ""
		qHint.Text = "✨ Sudah dijawab!"
		questionButtons[gameState.selectedQ].BackgroundColor3 = Color3.fromRGB(200, 255, 200)
		
		local allDone = true
		for _, v in pairs(gameState.answered) do if not v then allDone = false break end end
		if allDone then task.delay(1.5, showResult) end
	else
		showToast("❌ Ups, masih kurang tepat!", false)
		answerBox.Text = ""
	end
end

submitBtn.MouseButton1Click:Connect(checkAnswer)
answerBox.FocusLost:Connect(function(enter) if enter then checkAnswer() end end)

local function startTimer()
	gameState.timeLeft = 600
	task.spawn(function()
		while gameState.timeLeft > 0 and not gameState.gameOver do
			task.wait(1)
			if gui.Enabled then
				gameState.timeLeft = gameState.timeLeft - 1
				local m = math.floor(gameState.timeLeft / 60)
				local s = gameState.timeLeft % 60
				timerLabel.Text = string.format("⏱ %02d:%02d", m, s)
				if gameState.timeLeft <= 60 then timerLabel.TextColor3 = Color3.fromRGB(255, 71, 87) end
			end
		end
		if not gameState.gameOver and gameState.timeLeft <= 0 then showResult() end
	end)
end

local function openUI()
	gui.Enabled = true
	uiCont.Size = UDim2.new(0, 0, 0, 0)
	resultPanel.Visible = false
	TS:Create(uiCont, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = responsiveSize}):Play()
	startTimer()
	task.defer(function() selectQuestion(1) end)
end

local function closeUI()
	gameState.gameOver = true
	local tween = TS:Create(uiCont, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
	tween:Play()
	tween.Completed:Wait()
	gui.Enabled = false
end

exitBtn.MouseButton1Click:Connect(closeUI)
resultPanel:WaitForChild("TextButton").MouseButton1Click:Connect(closeUI)

local function bindPrompt(part)
	local prompt = part:WaitForChild("ProximityPrompt", 10)
	if prompt then
		prompt.Triggered:Connect(function(player)
			if player == Players.LocalPlayer then
				activeType = part:GetAttribute("TTSType")
				currentData = AllTTSData[activeType]
				
				titleLabel.Text = part:GetAttribute("TTSName")
				local themeColor = part:GetAttribute("TTSColor")
				titleLabel.TextColor3 = themeColor
				uiCont.MainBackground.BgGradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, themeColor)
				}
				
				gameState.score = 0
				gameState.selectedQ = nil
				scoreLabel.Text = "⭐ SKOR: 0"
				timerLabel.TextColor3 = Color3.fromRGB(255, 159, 67)
				
				buildGridAndList()
				openUI()
			end
		end)
	end
end

for _, p in ipairs(CS:GetTagged("TTSTerminal")) do task.spawn(bindPrompt, p) end
CS:GetInstanceAddedSignal("TTSTerminal"):Connect(bindPrompt)
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
	saveTTSScore(player, string.sub(ttsType, 5), score) -- Clean "TTS_" prefix
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

print("[Sistem TTS V2] Terselesaikan! 5 Terminal, TTS Grid Data Lengkap, dan Desain Responsif & Juicy Aktif!")