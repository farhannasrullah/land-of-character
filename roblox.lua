
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- ════════════════════════════════════════
--  KONFIGURASI DATABASE SOAL (100% BERKESINAMBUNGAN)
-- ════════════════════════════════════════
local CROSSWORD_DATA = {
    { kata = "TEKUN",   soal = "Sifat orang yang suka bekerja keras dan sungguh-sungguh", baris = 9, kolom = 1, arah = "H" },
    { kata = "BAIK",    soal = "Lawan kata dari buruk",                                   baris = 3, kolom = 3, arah = "H" },
    { kata = "WAKTU",   soal = "Sesuatu yang sangat berharga dan tidak bisa diulang",     baris = 13, kolom = 1, arah = "H" },
    { kata = "BANGUN",  soal = "Kebalikan dari tidur",                                    baris = 11, kolom = 1, arah = "H" },
    { kata = "TAAT",    soal = "Patuh terhadap aturan",                                   baris = 15, kolom = 5, arah = "H" },
    { kata = "DISIPLIN",soal = "Sikap patuh dan taat pada aturan",                        baris = 2, kolom = 5, arah = "V" },
    { kata = "RAJIN",   soal = "Suka bekerja atau belajar dengan giat",                   baris = 2, kolom = 4, arah = "V" },
    { kata = "BELAJAR", soal = "Jika ingin mendapatkan nilai baik saat ulangan kita harus",baris = 8, kolom = 2, arah = "V" },
    { kata = "NUNDA",   soal = "Kebiasaan buruk mengulur-ulur waktu (tanpa men-)",        baris = 11, kolom = 6, arah = "V" },
    { kata = "LAKUKAN", soal = "Jika kita di perintah oleh orang tua kita harus segera me..",baris = 1, kolom = 6, arah = "V" },
}

local GRID_SIZE = 15
local CELL_SIZE = UDim2.new(0, 42, 0, 42)
local TOTAL_QUESTIONS = #CROSSWORD_DATA

-- ════════════════════════════════════════
--  SETUP FOLDER DI WORKSPACE & PROXIMITY PROMPT
-- ════════════════════════════════════════
local function setupWorkspace()
    local oldFolder = workspace:FindFirstChild("TekaTekiSilang")
    if oldFolder then oldFolder:Destroy() end

    local folder = Instance.new("Folder")
    folder.Name = "TekaTekiSilang"
    folder.Parent = workspace

    local lighting = game:GetService("Lighting")
    lighting.Ambient = Color3.fromRGB(200, 200, 255)
    lighting.Brightness = 3
    lighting.ClockTime = 12

    local base = Instance.new("Part")
    base.Name = "Baseplate"
    base.Size = Vector3.new(512, 1, 512)
    base.Position = Vector3.new(0, -0.5, 0)
    base.Anchored = true
    base.Material = Enum.Material.Grass
    base.BrickColor = BrickColor.new("Bright green")
    base.Parent = folder

    local spawn = Instance.new("SpawnLocation")
    spawn.Size = Vector3.new(6, 1, 6)
    spawn.Position = Vector3.new(0, 0.5, 0)
    spawn.Anchored = true
    spawn.BrickColor = BrickColor.new("Bright yellow")
    spawn.Parent = folder

    -- ── PAPAN BERMAIN & PROXIMITY PROMPT ──
    local gameBoard = Instance.new("Part")
    gameBoard.Name = "GameBoard"
    gameBoard.Size = Vector3.new(10, 6, 1)
    gameBoard.Position = Vector3.new(0, 3, -10)
    gameBoard.Anchored = true
    gameBoard.Material = Enum.Material.SmoothPlastic
    gameBoard.BrickColor = BrickColor.new("Deep blue")
    gameBoard.Parent = folder

    local boardDecal = Instance.new("TextLabel")
    local boardGui = Instance.new("SurfaceGui")
    boardGui.Parent = gameBoard
    boardGui.Face = Enum.NormalId.Front
    boardDecal.Size = UDim2.new(1, 0, 1, 0)
    boardDecal.BackgroundTransparency = 1
    boardDecal.Text = "⏳ KUIS MASTER OF TIME"
    boardDecal.TextColor3 = Color3.fromRGB(255, 215, 0)
    boardDecal.TextScaled = true
    boardDecal.Font = Enum.Font.FredokaOne

    local decalStroke = Instance.new("UIStroke")
    decalStroke.Color = Color3.fromRGB(50, 20, 100)
    decalStroke.Thickness = 5
    decalStroke.Parent = boardDecal

    boardDecal.Parent = boardGui

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "PlayPrompt"
    prompt.ActionText = "Mulai Ujian Disiplin"
    prompt.ObjectText = "Land of Character"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 10
    prompt.Parent = gameBoard

    print("[TekaTekiSilang] Workspace & Proximity Prompt setup selesai!")
    return folder
end

-- ════════════════════════════════════════
--  BUILD GUI UTAMA (RESPONSIVE)
-- ════════════════════════════════════════
local function buildGUI()
    local starterGui = game:GetService("StarterGui")
    local oldGui = starterGui:FindFirstChild("TekaTekiSilangGUI")
    if oldGui then oldGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TekaTekiSilangGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true 
    screenGui.Enabled = false 
    screenGui.Parent = starterGui

    -- ── BACKGROUND UTAMA (RESPONSIVE WRAPPER) ──
    local mainBg = Instance.new("Frame")
    mainBg.Name = "MainBackground"
    mainBg.AnchorPoint = Vector2.new(0.5, 0.5)
    mainBg.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainBg.Size = UDim2.new(0.9, 0, 0.9, 0) 
    mainBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mainBg.BorderSizePixel = 0
    mainBg.Parent = screenGui

    local uiAspectRatio = Instance.new("UIAspectRatioConstraint")
    uiAspectRatio.AspectRatio = 1.5 
    uiAspectRatio.Parent = mainBg

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 24)
    bgCorner.Parent = mainBg

    -- Tema Master of Time: Gold -> Magic Purple -> Sky Blue
    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 223, 100)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255)),
    })
    uiGradient.Rotation = 45
    uiGradient.Parent = mainBg

    -- ── HEADER ──
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 80)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    header.BackgroundTransparency = 0.2
    header.BorderSizePixel = 0
    header.Parent = mainBg

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 24)
    headerCorner.Parent = header

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    titleLabel.Position = UDim2.new(0.25, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⏳ MASTER OF TIME (DISIPLIN) ⏳"
    titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.FredokaOne
    titleLabel.Parent = header

    local titleStroke = Instance.new("UIStroke")
    titleStroke.Color = Color3.fromRGB(70, 40, 120)
    titleStroke.Thickness = 4
    titleStroke.Parent = titleLabel

    local scoreFrame = Instance.new("Frame")
    scoreFrame.Name = "ScoreFrame"
    scoreFrame.Size = UDim2.new(0, 180, 0, 50)
    scoreFrame.Position = UDim2.new(0, 15, 0, 15)
    scoreFrame.BackgroundColor3 = Color3.fromRGB(255, 223, 0)
    scoreFrame.BorderSizePixel = 0
    scoreFrame.Parent = header

    local scoreCorner = Instance.new("UICorner")
    scoreCorner.CornerRadius = UDim.new(0, 16)
    scoreCorner.Parent = scoreFrame

    local scoreLabel = Instance.new("TextLabel")
    scoreLabel.Name = "ScoreLabel"
    scoreLabel.Size = UDim2.new(1, 0, 1, 0)
    scoreLabel.BackgroundTransparency = 1
    scoreLabel.Text = "⭐ SKOR: 0"
    scoreLabel.TextColor3 = Color3.fromRGB(70, 40, 120)
    scoreLabel.TextScaled = true
    scoreLabel.Font = Enum.Font.FredokaOne
    scoreLabel.Parent = scoreFrame

    local timerFrame = Instance.new("Frame")
    timerFrame.Name = "TimerFrame"
    timerFrame.Size = UDim2.new(0, 160, 0, 50)
    timerFrame.Position = UDim2.new(1, -240, 0, 15)
    timerFrame.BackgroundColor3 = Color3.fromRGB(70, 40, 120)
    timerFrame.BorderSizePixel = 0
    timerFrame.Parent = header

    local timerCorner = Instance.new("UICorner")
    timerCorner.CornerRadius = UDim.new(0, 16)
    timerCorner.Parent = timerFrame

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "TimerLabel"
    timerLabel.Size = UDim2.new(1, 0, 1, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "⏱ 10:00"
    timerLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    timerLabel.TextScaled = true
    timerLabel.Font = Enum.Font.FredokaOne
    timerLabel.Parent = timerFrame

    -- TOMBOL KELUAR 
    local exitBtn = Instance.new("TextButton")
    exitBtn.Name = "ExitBtn"
    exitBtn.Size = UDim2.new(0, 50, 0, 50)
    exitBtn.Position = UDim2.new(1, -65, 0, 15)
    exitBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    exitBtn.BorderSizePixel = 0
    exitBtn.Text = "✖"
    exitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    exitBtn.TextScaled = true
    exitBtn.Font = Enum.Font.FredokaOne
    exitBtn.Parent = header

    local exitCorner = Instance.new("UICorner")
    exitCorner.CornerRadius = UDim.new(0, 16)
    exitCorner.Parent = exitBtn

    -- ── CONTAINER UTAMA ──
    local mainContainer = Instance.new("Frame")
    mainContainer.Name = "MainContainer"
    mainContainer.Size = UDim2.new(1, -20, 1, -100)
    mainContainer.Position = UDim2.new(0, 10, 0, 90)
    mainContainer.BackgroundTransparency = 1
    mainContainer.Parent = mainBg

    -- ── PANEL KIRI - GRID TEKA TEKI ──
    local gridPanel = Instance.new("Frame")
    gridPanel.Name = "GridPanel"
    gridPanel.Size = UDim2.new(0.58, -5, 1, 0)
    gridPanel.Position = UDim2.new(0, 0, 0, 0)
    gridPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    gridPanel.BackgroundTransparency = 0.2
    gridPanel.BorderSizePixel = 0
    gridPanel.Parent = mainContainer

    local gridPanelCorner = Instance.new("UICorner")
    gridPanelCorner.CornerRadius = UDim.new(0, 24)
    gridPanelCorner.Parent = gridPanel

    local gridPanelStroke = Instance.new("UIStroke")
    gridPanelStroke.Color = Color3.fromRGB(255, 255, 255)
    gridPanelStroke.Thickness = 4
    gridPanelStroke.Parent = gridPanel

    local gridTitle = Instance.new("TextLabel")
    gridTitle.Name = "GridTitle"
    gridTitle.Size = UDim2.new(1, 0, 0, 40)
    gridTitle.Position = UDim2.new(0, 0, 0, 10)
    gridTitle.BackgroundTransparency = 1
    gridTitle.Text = "⏳ DIMENSI WAKTU"
    gridTitle.TextColor3 = Color3.fromRGB(70, 40, 120)
    gridTitle.TextScaled = true
    gridTitle.Font = Enum.Font.FredokaOne
    gridTitle.Parent = gridPanel

    local gridScroll = Instance.new("ScrollingFrame")
    gridScroll.Name = "GridScroll"
    gridScroll.Size = UDim2.new(1, -20, 1, -60)
    gridScroll.Position = UDim2.new(0, 10, 0, 50)
    gridScroll.BackgroundTransparency = 1
    gridScroll.ScrollBarThickness = 8
    gridScroll.ScrollBarImageColor3 = Color3.fromRGB(180, 150, 255)
    gridScroll.CanvasSize = UDim2.new(0, GRID_SIZE * 43 + 10, 0, GRID_SIZE * 43 + 10)
    gridScroll.Parent = gridPanel

    local gridCells = {}
    for row = 1, GRID_SIZE do
        gridCells[row] = {}
        for col = 1, GRID_SIZE do
            local cell = Instance.new("Frame")
            cell.Name = "Cell_" .. row .. "_" .. col
            cell.Size = UDim2.new(0, 40, 0, 40)
            cell.Position = UDim2.new(0, (col - 1) * 43 + 5, 0, (row - 1) * 43 + 5)
            cell.BackgroundColor3 = Color3.fromRGB(240, 248, 255)
            cell.BorderSizePixel = 0
            cell.Parent = gridScroll

            local cellCorner = Instance.new("UICorner")
            cellCorner.CornerRadius = UDim.new(0, 8)
            cellCorner.Parent = cell

            local cellStroke = Instance.new("UIStroke")
            cellStroke.Color = Color3.fromRGB(180, 150, 255)
            cellStroke.Thickness = 2
            cellStroke.Parent = cell

            local numLabel = Instance.new("TextLabel")
            numLabel.Name = "NumLabel"
            numLabel.Size = UDim2.new(0, 14, 0, 14)
            numLabel.Position = UDim2.new(0, 2, 0, 2)
            numLabel.BackgroundTransparency = 1
            numLabel.Text = ""
            numLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            numLabel.TextScaled = true
            numLabel.Font = Enum.Font.FredokaOne
            numLabel.ZIndex = 3
            numLabel.Parent = cell

            local letterLabel = Instance.new("TextLabel")
            letterLabel.Name = "LetterLabel"
            letterLabel.Size = UDim2.new(1, 0, 1, 0)
            letterLabel.Position = UDim2.new(0, 0, 0, 0)
            letterLabel.BackgroundTransparency = 1
            letterLabel.Text = ""
            letterLabel.TextColor3 = Color3.fromRGB(70, 40, 120)
            letterLabel.TextScaled = true
            letterLabel.Font = Enum.Font.FredokaOne
            letterLabel.ZIndex = 2
            letterLabel.Parent = cell

            gridCells[row][col] = cell
        end
    end

    -- ── PANEL KANAN ──
    local rightPanel = Instance.new("Frame")
    rightPanel.Name = "RightPanel"
    rightPanel.Size = UDim2.new(0.42, -5, 1, 0)
    rightPanel.Position = UDim2.new(0.58, 5, 0, 0)
    rightPanel.BackgroundTransparency = 1
    rightPanel.Parent = mainContainer

    local questionPanel = Instance.new("Frame")
    questionPanel.Name = "QuestionPanel"
    questionPanel.Size = UDim2.new(1, 0, 0, 130)
    questionPanel.Position = UDim2.new(0, 0, 0, 0)
    questionPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    questionPanel.BackgroundTransparency = 0.2
    questionPanel.BorderSizePixel = 0
    questionPanel.Parent = rightPanel

    local qPanelCorner = Instance.new("UICorner")
    qPanelCorner.CornerRadius = UDim.new(0, 24)
    qPanelCorner.Parent = questionPanel

    local qPanelStroke = Instance.new("UIStroke")
    qPanelStroke.Color = Color3.fromRGB(255, 255, 255)
    qPanelStroke.Thickness = 4
    qPanelStroke.Parent = questionPanel

    local qNumLabel = Instance.new("TextLabel")
    qNumLabel.Name = "QuestionNum"
    qNumLabel.Size = UDim2.new(1, -20, 0, 30)
    qNumLabel.Position = UDim2.new(0, 10, 0, 10)
    qNumLabel.BackgroundTransparency = 1
    qNumLabel.Text = "⏳ Pilih nomor tugasmu!"
    qNumLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
    qNumLabel.TextScaled = true
    qNumLabel.Font = Enum.Font.FredokaOne
    qNumLabel.TextXAlignment = Enum.TextXAlignment.Left
    qNumLabel.Parent = questionPanel

    local qTextLabel = Instance.new("TextLabel")
    qTextLabel.Name = "QuestionText"
    qTextLabel.Size = UDim2.new(1, -20, 0, 50)
    qTextLabel.Position = UDim2.new(0, 10, 0, 45)
    qTextLabel.BackgroundTransparency = 1
    qTextLabel.Text = "Klik nomor di bawah untuk membuka ujian Master of Time~"
    qTextLabel.TextColor3 = Color3.fromRGB(70, 70, 70)
    qTextLabel.TextScaled = true
    qTextLabel.Font = Enum.Font.Cartoon
    qTextLabel.TextWrapped = true
    qTextLabel.TextXAlignment = Enum.TextXAlignment.Left
    qTextLabel.Parent = questionPanel

    local qHintLabel = Instance.new("TextLabel")
    qHintLabel.Name = "HintLabel"
    qHintLabel.Size = UDim2.new(1, -20, 0, 24)
    qHintLabel.Position = UDim2.new(0, 10, 0, 100)
    qHintLabel.BackgroundTransparency = 1
    qHintLabel.Text = ""
    qHintLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    qHintLabel.TextScaled = true
    qHintLabel.Font = Enum.Font.FredokaOne
    qHintLabel.TextXAlignment = Enum.TextXAlignment.Left
    qHintLabel.Parent = questionPanel

    local inputPanel = Instance.new("Frame")
    inputPanel.Name = "InputPanel"
    inputPanel.Size = UDim2.new(1, 0, 0, 65)
    inputPanel.Position = UDim2.new(0, 0, 0, 140)
    inputPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    inputPanel.BackgroundTransparency = 0.2
    inputPanel.BorderSizePixel = 0
    inputPanel.Parent = rightPanel

    local iPanelCorner = Instance.new("UICorner")
    iPanelCorner.CornerRadius = UDim.new(0, 24)
    iPanelCorner.Parent = inputPanel

    local iPanelStroke = Instance.new("UIStroke")
    iPanelStroke.Color = Color3.fromRGB(255, 255, 255)
    iPanelStroke.Thickness = 4
    iPanelStroke.Parent = inputPanel

    local answerBox = Instance.new("TextBox")
    answerBox.Name = "AnswerBox"
    answerBox.Size = UDim2.new(0.65, -10, 0, 45)
    answerBox.Position = UDim2.new(0, 10, 0.5, -22.5)
    answerBox.BackgroundColor3 = Color3.fromRGB(240, 248, 255)
    answerBox.BorderSizePixel = 0
    answerBox.PlaceholderText = "Ketik jawaban di sini..."
    answerBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    answerBox.Text = ""
    answerBox.TextColor3 = Color3.fromRGB(70, 40, 120)
    answerBox.TextScaled = true
    answerBox.Font = Enum.Font.FredokaOne
    answerBox.ClearTextOnFocus = true
    answerBox.Parent = inputPanel

    local answerCorner = Instance.new("UICorner")
    answerCorner.CornerRadius = UDim.new(0, 16)
    answerCorner.Parent = answerBox

    local answerStroke = Instance.new("UIStroke")
    answerStroke.Color = Color3.fromRGB(180, 150, 255)
    answerStroke.Thickness = 3
    answerStroke.Parent = answerBox

    local submitBtn = Instance.new("TextButton")
    submitBtn.Name = "SubmitBtn"
    submitBtn.Size = UDim2.new(0.32, -10, 0, 45)
    submitBtn.Position = UDim2.new(0.68, 0, 0.5, -22.5)
    submitBtn.BackgroundColor3 = Color3.fromRGB(70, 200, 100)
    submitBtn.BorderSizePixel = 0
    submitBtn.Text = "✨ JAWAB"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.TextScaled = true
    submitBtn.Font = Enum.Font.FredokaOne
    submitBtn.AutoButtonColor = false
    submitBtn.Parent = inputPanel

    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 16)
    submitCorner.Parent = submitBtn

    local listTitle = Instance.new("TextLabel")
    listTitle.Name = "ListProgressLabel"
    listTitle.Size = UDim2.new(1, 0, 0, 30)
    listTitle.Position = UDim2.new(0, 0, 0, 215)
    listTitle.BackgroundTransparency = 1
    listTitle.Text = "📚 DAFTAR UJIAN  |  0/" .. TOTAL_QUESTIONS .. " Selesai"
    listTitle.TextColor3 = Color3.fromRGB(70, 40, 120)
    listTitle.TextScaled = true
    listTitle.Font = Enum.Font.FredokaOne
    listTitle.Parent = rightPanel

    local questionScroll = Instance.new("ScrollingFrame")
    questionScroll.Name = "QuestionScroll"
    questionScroll.Size = UDim2.new(1, 0, 1, -255)
    questionScroll.Position = UDim2.new(0, 0, 0, 250)
    questionScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    questionScroll.BackgroundTransparency = 0.2
    questionScroll.BorderSizePixel = 0
    questionScroll.ScrollBarThickness = 8
    questionScroll.ScrollBarImageColor3 = Color3.fromRGB(180, 150, 255)
    questionScroll.CanvasSize = UDim2.new(0, 0, 0, TOTAL_QUESTIONS * 80)
    questionScroll.Parent = rightPanel

    local qScrollCorner = Instance.new("UICorner")
    qScrollCorner.CornerRadius = UDim.new(0, 24)
    qScrollCorner.Parent = questionScroll

    local qScrollStroke = Instance.new("UIStroke")
    qScrollStroke.Color = Color3.fromRGB(255, 255, 255)
    qScrollStroke.Thickness = 4
    qScrollStroke.Parent = questionScroll

    local questionButtons = {}
    for i, data in ipairs(CROSSWORD_DATA) do
        local qBtn = Instance.new("TextButton")
        qBtn.Name = "Q_" .. i
        qBtn.Size = UDim2.new(1, -20, 0, 75)
        qBtn.Position = UDim2.new(0, 10, 0, (i - 1) * 80 + 5)
        qBtn.BackgroundColor3 = Color3.fromRGB(255, 250, 240)
        qBtn.BorderSizePixel = 0
        qBtn.Text = ""
        qBtn.AutoButtonColor = false
        qBtn.Parent = questionScroll

        local qBtnCorner = Instance.new("UICorner")
        qBtnCorner.CornerRadius = UDim.new(0, 16)
        qBtnCorner.Parent = qBtn

        local qBtnStroke = Instance.new("UIStroke")
        qBtnStroke.Color = Color3.fromRGB(200, 220, 255)
        qBtnStroke.Thickness = 3
        qBtnStroke.Parent = qBtn

        local qBadge = Instance.new("Frame")
        qBadge.Size = UDim2.new(0, 44, 0, 44)
        qBadge.Position = UDim2.new(0, 10, 0.5, -22)
        qBadge.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        qBadge.BorderSizePixel = 0
        qBadge.Parent = qBtn

        local qBadgeCorner = Instance.new("UICorner")
        qBadgeCorner.CornerRadius = UDim.new(1, 0)
        qBadgeCorner.Parent = qBadge

        local qBadgeNum = Instance.new("TextLabel")
        qBadgeNum.Size = UDim2.new(1, 0, 1, 0)
        qBadgeNum.BackgroundTransparency = 1
        qBadgeNum.Text = tostring(i)
        qBadgeNum.TextColor3 = Color3.fromRGB(255, 255, 255)
        qBadgeNum.TextScaled = true
        qBadgeNum.Font = Enum.Font.FredokaOne
        qBadgeNum.Parent = qBadge

        local dirLabel = Instance.new("TextLabel")
        dirLabel.Name = "DirLabel"
        dirLabel.Size = UDim2.new(0, 32, 0, 20)
        dirLabel.Position = UDim2.new(0, 65, 0, 8)
        dirLabel.BackgroundColor3 = data.arah == "H" and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(30, 144, 255)
        dirLabel.BorderSizePixel = 0
        dirLabel.Text = data.arah
        dirLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        dirLabel.TextScaled = true
        dirLabel.Font = Enum.Font.FredokaOne
        dirLabel.Parent = qBtn

        local dirCorner = Instance.new("UICorner")
        dirCorner.CornerRadius = UDim.new(0, 8)
        dirCorner.Parent = dirLabel

        local qSoalText = Instance.new("TextLabel")
        qSoalText.Name = "SoalText"
        qSoalText.Size = UDim2.new(1, -110, 0, 40)
        qSoalText.Position = UDim2.new(0, 65, 0, 30)
        qSoalText.BackgroundTransparency = 1
        qSoalText.Text = data.soal
        qSoalText.TextColor3 = Color3.fromRGB(70, 70, 70)
        qSoalText.TextScaled = true
        qSoalText.Font = Enum.Font.Cartoon
        qSoalText.TextWrapped = true
        qSoalText.TextXAlignment = Enum.TextXAlignment.Left
        qSoalText.Parent = qBtn

        local lenLabel = Instance.new("TextLabel")
        lenLabel.Name = "LenLabel"
        lenLabel.Size = UDim2.new(0, 60, 0, 20)
        lenLabel.Position = UDim2.new(1, -65, 0, 8)
        lenLabel.BackgroundTransparency = 1
        lenLabel.Text = "(" .. #data.kata .. " huruf)"
        lenLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        lenLabel.TextScaled = true
        lenLabel.Font = Enum.Font.FredokaOne
        lenLabel.Parent = qBtn

        local statusIcon = Instance.new("TextLabel")
        statusIcon.Name = "StatusIcon"
        statusIcon.Size = UDim2.new(0, 30, 0, 30)
        statusIcon.Position = UDim2.new(1, -40, 0.5, -15)
        statusIcon.BackgroundTransparency = 1
        statusIcon.Text = "○"
        statusIcon.TextColor3 = Color3.fromRGB(200, 200, 200)
        statusIcon.TextScaled = true
        statusIcon.Font = Enum.Font.FredokaOne
        statusIcon.Parent = qBtn

        questionButtons[i] = qBtn
    end

    local resultPanel = Instance.new("Frame")
    resultPanel.Name = "ResultPanel"
    resultPanel.Size = UDim2.new(0.8, 0, 0.7, 0)
    resultPanel.Position = UDim2.new(0.1, 0, 0.15, 0)
    resultPanel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    resultPanel.BorderSizePixel = 0
    resultPanel.Visible = false
    resultPanel.ZIndex = 100
    resultPanel.Parent = mainBg

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 36)
    rCorner.Parent = resultPanel

    local rStroke = Instance.new("UIStroke")
    rStroke.Color = Color3.fromRGB(255, 215, 0)
    rStroke.Thickness = 6
    rStroke.Parent = resultPanel

    local rGrad = Instance.new("UIGradient")
    rGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 250, 205)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 228, 181)),
    })
    rGrad.Rotation = 45
    rGrad.Parent = resultPanel

    local rTitle = Instance.new("TextLabel")
    rTitle.Name = "ResultTitle"
    rTitle.Size = UDim2.new(1, 0, 0, 100)
    rTitle.Position = UDim2.new(0, 0, 0, 30)
    rTitle.BackgroundTransparency = 1
    rTitle.Text = "🏆 SELAMAT MASTER! 🏆"
    rTitle.TextColor3 = Color3.fromRGB(255, 140, 0)
    rTitle.TextScaled = true
    rTitle.Font = Enum.Font.FredokaOne
    rTitle.ZIndex = 101
    rTitle.Parent = resultPanel

    local rScore = Instance.new("TextLabel")
    rScore.Name = "ResultScore"
    rScore.Size = UDim2.new(1, 0, 0, 70)
    rScore.Position = UDim2.new(0, 0, 0, 130)
    rScore.BackgroundTransparency = 1
    rScore.Text = "Skor Akhir: 0"
    rScore.TextColor3 = Color3.fromRGB(70, 40, 120)
    rScore.TextScaled = true
    rScore.Font = Enum.Font.FredokaOne
    rScore.ZIndex = 101
    rScore.Parent = resultPanel

    local rStars = Instance.new("TextLabel")
    rStars.Name = "ResultStars"
    rStars.Size = UDim2.new(1, 0, 0, 80)
    rStars.Position = UDim2.new(0, 0, 0, 200)
    rStars.BackgroundTransparency = 1
    rStars.Text = "⭐ ⭐ ⭐"
    rStars.TextColor3 = Color3.fromRGB(255, 215, 0)
    rStars.TextScaled = true
    rStars.Font = Enum.Font.FredokaOne
    rStars.ZIndex = 101
    rStars.Parent = resultPanel

    local rMsg = Instance.new("TextLabel")
    rMsg.Name = "ResultMsg"
    rMsg.Size = UDim2.new(0.9, 0, 0, 60)
    rMsg.Position = UDim2.new(0.05, 0, 0, 290)
    rMsg.BackgroundTransparency = 1
    rMsg.Text = "Kamu berhasil menguasai waktumu!"
    rMsg.TextColor3 = Color3.fromRGB(70, 150, 70)
    rMsg.TextScaled = true
    rMsg.Font = Enum.Font.FredokaOne
    rMsg.TextWrapped = true
    rMsg.ZIndex = 101
    rMsg.Parent = resultPanel

    local rRestartBtn = Instance.new("TextButton")
    rRestartBtn.Name = "RestartBtn"
    rRestartBtn.Size = UDim2.new(0, 250, 0, 70)
    rRestartBtn.Position = UDim2.new(0.5, -125, 1, -100)
    rRestartBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    rRestartBtn.BorderSizePixel = 0
    rRestartBtn.Text = "🔄 MAIN LAGI YUK!"
    rRestartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rRestartBtn.TextScaled = true
    rRestartBtn.Font = Enum.Font.FredokaOne
    rRestartBtn.AutoButtonColor = false
    rRestartBtn.ZIndex = 101
    rRestartBtn.Parent = resultPanel

    local rRestartCorner = Instance.new("UICorner")
    rRestartCorner.CornerRadius = UDim.new(0, 24)
    rRestartCorner.Parent = rRestartBtn

    local toastFrame = Instance.new("Frame")
    toastFrame.Name = "ToastFrame"
    toastFrame.Size = UDim2.new(0, 350, 0, 70)
    toastFrame.Position = UDim2.new(0.5, -175, 1, -100)
    toastFrame.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    toastFrame.BorderSizePixel = 0
    toastFrame.Visible = false
    toastFrame.ZIndex = 200
    toastFrame.Parent = mainBg

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 24)
    tCorner.Parent = toastFrame

    local toastLabel = Instance.new("TextLabel")
    toastLabel.Name = "ToastLabel"
    toastLabel.Size = UDim2.new(1, -20, 1, 0)
    toastLabel.Position = UDim2.new(0, 10, 0, 0)
    toastLabel.BackgroundTransparency = 1
    toastLabel.Text = ""
    toastLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toastLabel.TextScaled = true
    toastLabel.Font = Enum.Font.FredokaOne
    toastLabel.ZIndex = 201
    toastLabel.Parent = toastFrame

    print("[TekaTekiSilang] GUI berhasil dibuat!")
    return screenGui, gridCells, questionButtons
end

-- ════════════════════════════════════════
--  SETUP GRID UNTUK PREVIEW STUDIO
-- ════════════════════════════════════════
local function setupGridFromData(gridCells)
    local cellMap = {}
    for r = 1, GRID_SIZE do
        cellMap[r] = {}
        for c = 1, GRID_SIZE do
            cellMap[r][c] = { visible = false, nomor = nil }
        end
    end

    for i, data in ipairs(CROSSWORD_DATA) do
        for j = 1, #data.kata do
            local r = data.baris + (data.arah == "V" and (j - 1) or 0)
            local c = data.kolom + (data.arah == "H" and (j - 1) or 0)
            if r >= 1 and r <= GRID_SIZE and c >= 1 and c <= GRID_SIZE then
                cellMap[r][c].visible = true
                if j == 1 then
                    if not cellMap[r][c].nomor then
                        cellMap[r][c].nomor = i
                    else
                        cellMap[r][c].nomor = cellMap[r][c].nomor .. "," .. i
                    end
                end
            end
        end
    end

    for r = 1, GRID_SIZE do
        for c = 1, GRID_SIZE do
            local cell = gridCells[r][c]
            if cell then
                if cellMap[r][c].visible then
                    cell.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    local cellStroke = cell:FindFirstChildOfClass("UIStroke")
                    if cellStroke then cellStroke.Color = Color3.fromRGB(200, 200, 200) end
                    if cellMap[r][c].nomor then
                        local numLbl = cell:FindFirstChild("NumLabel")
                        if numLbl then numLbl.Text = tostring(cellMap[r][c].nomor) end
                    end
                else
                    cell.BackgroundColor3 = Color3.fromRGB(220, 210, 255)
                    cell.BackgroundTransparency = 0.5
                    local cellStroke = cell:FindFirstChildOfClass("UIStroke")
                    if cellStroke then
                        cellStroke.Color = Color3.fromRGB(180, 150, 255)
                        cellStroke.Transparency = 0.5
                    end
                end
            end
        end
    end

    return cellMap
end

-- ════════════════════════════════════════
--  MAIN EXECUTION (COMMAND BAR)
-- ════════════════════════════════════════
print("╔══════════════════════════════════════╗")
print("║  MASTER OF TIME - MEMBANGUN GAME     ║")
print("╚══════════════════════════════════════╝")

local folder = setupWorkspace()
local screenGui, gridCells, questionButtons = buildGUI()
setupGridFromData(gridCells) 

-- ════════════════════════════════════════
--  INJEKSI SCRIPT KE CLIENT (TERMASUK LOGIKA PROMPT)
-- ════════════════════════════════════════
local localScript = Instance.new("LocalScript")
localScript.Name = "GameLogicClient"
localScript.Parent = screenGui

localScript.Source = [=[
local Players = game:GetService("Players")

local CROSSWORD_DATA = {
    { kata = "TEKUN",   soal = "Sifat orang yang suka bekerja keras dan sungguh-sungguh", baris = 9, kolom = 1, arah = "H" },
    { kata = "BAIK",    soal = "Lawan kata dari buruk",                                   baris = 3, kolom = 3, arah = "H" },
    { kata = "WAKTU",   soal = "Sesuatu yang sangat berharga dan tidak bisa diulang",     baris = 13, kolom = 1, arah = "H" },
    { kata = "BANGUN",  soal = "Kebalikan dari tidur",                                    baris = 11, kolom = 1, arah = "H" },
    { kata = "TAAT",    soal = "Patuh terhadap aturan",                                   baris = 15, kolom = 5, arah = "H" },
    { kata = "DISIPLIN",soal = "Sikap patuh dan taat pada aturan",                        baris = 2, kolom = 5, arah = "V" },
    { kata = "RAJIN",   soal = "Suka bekerja atau belajar dengan giat",                   baris = 2, kolom = 4, arah = "V" },
    { kata = "BELAJAR", soal = "Jika ingin mendapatkan nilai baik saat ulangan kita harus",baris = 8, kolom = 2, arah = "V" },
    { kata = "NUNDA",   soal = "Kebiasaan buruk mengulur-ulur waktu (tanpa men-)",        baris = 11, kolom = 6, arah = "V" },
    { kata = "LAKUKAN", soal = "Jika kita di perintah oleh orang tua kita harus segera me..",baris = 1, kolom = 6, arah = "V" },
}

local GRID_SIZE = 15
local TOTAL_QUESTIONS = #CROSSWORD_DATA

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = playerGui:WaitForChild("TekaTekiSilangGUI")
local mainBg = screenGui:WaitForChild("MainBackground")
local mainCont = mainBg:WaitForChild("MainContainer")
local gridPanel = mainCont:WaitForChild("GridPanel")
local gridScroll = gridPanel:WaitForChild("GridScroll")
local rightPanel = mainCont:WaitForChild("RightPanel")
local questionScroll = rightPanel:WaitForChild("QuestionScroll")

local gridCells = {}
for row = 1, GRID_SIZE do
    gridCells[row] = {}
    for col = 1, GRID_SIZE do
        gridCells[row][col] = gridScroll:WaitForChild("Cell_" .. row .. "_" .. col)
    end
end

local questionButtons = {}
for i = 1, TOTAL_QUESTIONS do
    questionButtons[i] = questionScroll:WaitForChild("Q_" .. i)
end

-- ── KONEKSI PROXIMITY PROMPT & TOMBOL KELUAR ──
local gameBoard = workspace:WaitForChild("TekaTekiSilang"):WaitForChild("GameBoard")
local playPrompt = gameBoard:WaitForChild("PlayPrompt")
local exitBtn = mainBg:WaitForChild("Header"):WaitForChild("ExitBtn")

playPrompt.Triggered:Connect(function(player)
    if player == Players.LocalPlayer then
        screenGui.Enabled = true
    end
end)

exitBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

local function setupGridFromData(gridCells)
    local cellMap = {} 
    for r = 1, GRID_SIZE do
        cellMap[r] = {}
        for c = 1, GRID_SIZE do
            cellMap[r][c] = { visible = false, nomor = nil }
        end
    end

    for i, data in ipairs(CROSSWORD_DATA) do
        for j = 1, #data.kata do
            local r = data.baris + (data.arah == "V" and (j - 1) or 0)
            local c = data.kolom + (data.arah == "H" and (j - 1) or 0)
            if r >= 1 and r <= GRID_SIZE and c >= 1 and c <= GRID_SIZE then
                cellMap[r][c].visible = true
                if j == 1 then
                    if not cellMap[r][c].nomor then
                        cellMap[r][c].nomor = i
                    else
                        cellMap[r][c].nomor = cellMap[r][c].nomor .. "," .. i
                    end
                end
            end
        end
    end
    return cellMap
end

local function setupGameLogic(screenGui, gridCells, questionButtons, cellMap)
    local gameState = {
        score = 0,
        answered = {},
        selectedQ = nil,
        timeLeft = 600, 
        gameOver = false,
    }

    for i = 1, TOTAL_QUESTIONS do
        gameState.answered[i] = false
    end

    local header = mainBg:WaitForChild("Header")
    local scoreLabel = header:WaitForChild("ScoreFrame"):WaitForChild("ScoreLabel")
    local timerLabel = header:WaitForChild("TimerFrame"):WaitForChild("TimerLabel")
    local questionPanel = rightPanel:WaitForChild("QuestionPanel")
    local qNumLabel = questionPanel:WaitForChild("QuestionNum")
    local qTextLabel = questionPanel:WaitForChild("QuestionText")
    local qHintLabel = questionPanel:WaitForChild("HintLabel")
    local inputPanel = rightPanel:WaitForChild("InputPanel")
    local answerBox = inputPanel:WaitForChild("AnswerBox")
    local submitBtn = inputPanel:WaitForChild("SubmitBtn")
    local progressLabel = rightPanel:WaitForChild("ListProgressLabel")
    local resultPanel = mainBg:WaitForChild("ResultPanel")
    local toastFrame = mainBg:WaitForChild("ToastFrame")
    local toastLabel = toastFrame:WaitForChild("ToastLabel")

    local function updateScore()
        scoreLabel.Text = "⭐ SKOR: " .. gameState.score
    end

    local function updateProgress()
        local count = 0
        for _, v in pairs(gameState.answered) do
            if v then count = count + 1 end
        end
        progressLabel.Text = "📚 DAFTAR UJIAN  |  " .. count .. "/" .. TOTAL_QUESTIONS .. " Selesai"
        return count
    end

    local function showToast(msg, isSuccess)
        toastFrame.BackgroundColor3 = isSuccess and Color3.fromRGB(50, 205, 50) or Color3.fromRGB(255, 69, 0)
        toastLabel.Text = msg
        toastFrame.Visible = true
        task.delay(2.5, function()
            if toastFrame then toastFrame.Visible = false end
        end)
    end

    local function highlightCells(qIndex, color)
        local data = CROSSWORD_DATA[qIndex]
        if not data then return end
        for j = 1, #data.kata do
            local r = data.baris + (data.arah == "V" and (j - 1) or 0)
            local c = data.kolom + (data.arah == "H" and (j - 1) or 0)
            if r >= 1 and r <= GRID_SIZE and c >= 1 and c <= GRID_SIZE then
                local cell = gridCells[r][c]
                if cell then cell.BackgroundColor3 = color end
            end
        end
    end

    local function fillGridAnswer(qIndex)
        local data = CROSSWORD_DATA[qIndex]
        if not data then return end
        for j = 1, #data.kata do
            local r = data.baris + (data.arah == "V" and (j - 1) or 0)
            local c = data.kolom + (data.arah == "H" and (j - 1) or 0)
            if r >= 1 and r <= GRID_SIZE and c >= 1 and c <= GRID_SIZE then
                local cell = gridCells[r][c]
                if cell then
                    local letterLbl = cell:FindFirstChild("LetterLabel")
                    if letterLbl then
                        letterLbl.Text = string.sub(data.kata, j, j)
                        letterLbl.TextColor3 = Color3.fromRGB(0, 100, 0) 
                    end
                    cell.BackgroundColor3 = Color3.fromRGB(255, 215, 0) 
                end
            end
        end
    end

    local function showResult()
        gameState.gameOver = true
        local rScore = resultPanel:FindFirstChild("ResultScore")
        local rStars = resultPanel:FindFirstChild("ResultStars")
        local rMsg = resultPanel:FindFirstChild("ResultMsg")

        local totalAnswered = 0
        for _, v in pairs(gameState.answered) do
            if v then totalAnswered = totalAnswered + 1 end
        end

        rScore.Text = "Skor Akhir: " .. gameState.score .. " poin"
        local percent = totalAnswered / TOTAL_QUESTIONS
        local stars, msg
        if percent >= 0.9 then
            stars = "⭐ ⭐ ⭐"
            msg = "LUAR BIASA! Kamu Master of Time sejati! Terus pertahankan kedisiplinanmu."
        elseif percent >= 0.6 then
            stars = "⭐ ⭐"
            msg = "BAGUS SEKALI! Pemahaman disiplinmu sudah oke. Terus semangat!"
        else
            stars = "⭐"
            msg = "Kamu menjawab " .. totalAnswered .. "/" .. TOTAL_QUESTIONS .. " soal. Jangan menyerah, ayo belajar disiplin lagi!"
        end
        rStars.Text = stars 
        rMsg.Text = msg 
        resultPanel.Visible = true
    end

    local function selectQuestion(qIndex)
        if gameState.gameOver then return end
        if gameState.selectedQ then
            if not gameState.answered[gameState.selectedQ] then
                highlightCells(gameState.selectedQ, Color3.fromRGB(255, 255, 255))
            end
            local oldBtn = questionButtons[gameState.selectedQ]
            if oldBtn then
                local oldStroke = oldBtn:FindFirstChildOfClass("UIStroke")
                if oldStroke then
                    oldStroke.Color = Color3.fromRGB(200, 220, 255)
                    oldStroke.Thickness = 3
                end
            end
        end

        gameState.selectedQ = qIndex
        local data = CROSSWORD_DATA[qIndex]

        if not gameState.answered[qIndex] then
            highlightCells(qIndex, Color3.fromRGB(255, 250, 150)) 
        end

        local selBtn = questionButtons[qIndex]
        if selBtn then
            local selStroke = selBtn:FindFirstChildOfClass("UIStroke")
            if selStroke then
                selStroke.Color = Color3.fromRGB(255, 165, 0) 
                selStroke.Thickness = 5
            end
        end

        local dir = data.arah == "H" and "➡ Mendatar" or "⬇ Menurun"
        qNumLabel.Text = "Soal " .. qIndex .. " | " .. dir
        qTextLabel.Text = data.soal 
        
        if gameState.answered[qIndex] then
            qHintLabel.Text = "✨ Hebat! Sudah dijawab: " .. data.kata
            qHintLabel.TextColor3 = Color3.fromRGB(50, 205, 50)
        else
            qHintLabel.Text = "Petunjuk: Ada " .. #data.kata .. " huruf"
            qHintLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
        end

        answerBox.Text = ""
        if not gameState.answered[qIndex] then
            answerBox:CaptureFocus()
        end
    end

    local function checkAnswer()
        if gameState.gameOver then return end
        if not gameState.selectedQ then
            showToast("⚠️ Klik nomor soal dulu ya!", false)
            return
        end
        if gameState.answered[gameState.selectedQ] then
            showToast("✨ Soal ini sudah berhasil dijawab!", false)
            return
        end

        local jawaban = string.upper(answerBox.Text)
        local data = CROSSWORD_DATA[gameState.selectedQ]
        local benar = string.upper(data.kata)

        if jawaban == benar then
            gameState.answered[gameState.selectedQ] = true
            gameState.score = gameState.score + (100 * #data.kata)
            fillGridAnswer(gameState.selectedQ)
            updateScore()
            local count = updateProgress()
            showToast("✅ BENAR! Hore, +" .. (100 * #data.kata) .. " poin!", true)

            local qBtn = questionButtons[gameState.selectedQ]
            if qBtn then
                qBtn.BackgroundColor3 = Color3.fromRGB(200, 255, 200)
                local statusIcon = qBtn:FindFirstChild("StatusIcon")
                if statusIcon then
                    statusIcon.Text = "⭐"
                    statusIcon.TextColor3 = Color3.fromRGB(255, 215, 0)
                end
            end

            qHintLabel.Text = "✨ Hebat! Sudah dijawab: " .. data.kata
            qHintLabel.TextColor3 = Color3.fromRGB(50, 205, 50)
            answerBox.Text = ""

            if count >= TOTAL_QUESTIONS then
                task.delay(1.5, showResult)
            end
        else
            showToast("❌ Ups, masih kurang tepat! Coba lagi ya...", false)
            local origPos = answerBox.Position
            for _ = 1, 3 do
                answerBox.Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + 10, origPos.Y.Scale, origPos.Y.Offset)
                task.wait(0.05)
                answerBox.Position = UDim2.new(origPos.X.Scale, origPos.X.Offset - 10, origPos.Y.Scale, origPos.Y.Offset)
                task.wait(0.05)
            end
            answerBox.Position = origPos
            answerBox.Text = ""
        end
    end

    task.spawn(function()
        while gameState.timeLeft > 0 and not gameState.gameOver do
            task.wait(1)
            if screenGui.Enabled then
                gameState.timeLeft = gameState.timeLeft - 1
                local mins = math.floor(gameState.timeLeft / 60)
                local secs = gameState.timeLeft % 60
                timerLabel.Text = string.format("⏱ %02d:%02d", mins, secs)
                if gameState.timeLeft <= 60 then
                    timerLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                elseif gameState.timeLeft <= 180 then
                    timerLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
                end
            end
        end
        if not gameState.gameOver and gameState.timeLeft <= 0 then
            showResult()
        end
    end)

    submitBtn.MouseButton1Click:Connect(checkAnswer)
    submitBtn.MouseEnter:Connect(function() submitBtn.BackgroundColor3 = Color3.fromRGB(90, 220, 120) end)
    submitBtn.MouseLeave:Connect(function() submitBtn.BackgroundColor3 = Color3.fromRGB(70, 200, 100) end)

    answerBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then checkAnswer() end
    end)

    for i, btn in ipairs(questionButtons) do
        btn.MouseButton1Click:Connect(function() selectQuestion(i) end)
        btn.MouseEnter:Connect(function()
            if not gameState.answered[i] then btn.BackgroundColor3 = Color3.fromRGB(255, 235, 205) end
        end)
        btn.MouseLeave:Connect(function()
            if not gameState.answered[i] then btn.BackgroundColor3 = Color3.fromRGB(255, 250, 240) end
        end)
    end

    local restartBtn = resultPanel:FindFirstChild("RestartBtn")
    if restartBtn then
        restartBtn.MouseButton1Click:Connect(function()
            resultPanel.Visible = false
            gameState.score = 0
            gameState.timeLeft = 600
            gameState.gameOver = false
            gameState.selectedQ = nil
            for i = 1, TOTAL_QUESTIONS do gameState.answered[i] = false end
            updateScore()
            updateProgress()
            timerLabel.Text = "⏱ 10:00"
            timerLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            
            for r = 1, GRID_SIZE do
                for c = 1, GRID_SIZE do
                    local cell = gridCells[r][c]
                    if cell then
                        local letterLbl = cell:FindFirstChild("LetterLabel")
                        if letterLbl then letterLbl.Text = "" end
                    end
                end
            end
            
            local cMap = setupGridFromData(gridCells)
            for r = 1, GRID_SIZE do
                for c = 1, GRID_SIZE do
                    local cell = gridCells[r][c]
                    if cell then
                        if cMap[r][c].visible then
                            cell.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        else
                            cell.BackgroundColor3 = Color3.fromRGB(220, 210, 255)
                        end
                    end
                end
            end

            for i2, btn2 in ipairs(questionButtons) do
                btn2.BackgroundColor3 = Color3.fromRGB(255, 250, 240)
                local sIcon = btn2:FindFirstChild("StatusIcon")
                if sIcon then
                    sIcon.Text = "○"
                    sIcon.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
                local oldStroke = btn2:FindFirstChildOfClass("UIStroke")
                if oldStroke then
                    oldStroke.Color = Color3.fromRGB(200, 220, 255)
                    oldStroke.Thickness = 3
                end
            end
            
            qNumLabel.Text = "⏳ Pilih nomor tugasmu!"
            qTextLabel.Text = "Klik nomor di bawah untuk membuka ujian Master of Time~"
            qHintLabel.Text = ""

            task.spawn(function()
                while gameState.timeLeft > 0 and not gameState.gameOver do
                    task.wait(1)
                    if screenGui.Enabled then
                        gameState.timeLeft = gameState.timeLeft - 1
                        local mins2 = math.floor(gameState.timeLeft / 60)
                        local secs2 = gameState.timeLeft % 60
                        timerLabel.Text = string.format("⏱ %02d:%02d", mins2, secs2)
                        if gameState.timeLeft <= 60 then
                            timerLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                        elseif gameState.timeLeft <= 180 then
                            timerLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
                        end
                    end
                end
                if not gameState.gameOver and gameState.timeLeft <= 0 then showResult() end
            end)
        end)
        restartBtn.MouseEnter:Connect(function() restartBtn.BackgroundColor3 = Color3.fromRGB(124, 252, 0) end)
        restartBtn.MouseLeave:Connect(function() restartBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50) end)
    end

    task.defer(function() selectQuestion(1) end)
end

local cellMap = setupGridFromData(gridCells)
setupGameLogic(screenGui, gridCells, questionButtons, cellMap)
]=]

print("")
print("✅ MASTER OF TIME: TEKA-TEKI SILANG SELESAI DIBUAT!")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔲 Tema Database  : Disiplin & Waktu")
print("🧩 Sistem Grid    : 100% Berkesinambungan")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("▶ Klik PLAY, hampiri papan Master of Time, dan rasakan magisnya!")