local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local InsertService = game:GetService("InsertService")
local DataStoreService = game:GetService("DataStoreService")
local TextService = game:GetService("TextService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local AllQuizData = require(ReplicatedStorage:WaitForChild("QuizData"))
local Remotes = ReplicatedStorage:WaitForChild("QuizRemotes")

-- DATASTORES
local ProfileStore = DataStoreService:GetDataStore("RoleplayProfileDB_V3")
local EcoStore = DataStoreService:GetDataStore("RoleplayEcoDB_V4")
local ScoreDS = DataStoreService:GetDataStore("LandOfCharacter_Scores_V2")

-- ORDERED DATASTORES
local CoinsLeaderboard = DataStoreService:GetOrderedDataStore("Leaderboard_Coins")
local LevelLeaderboard = DataStoreService:GetOrderedDataStore("Leaderboard_Level")
local TotalScoreLeaderboard = DataStoreService:GetOrderedDataStore("Leaderboard_TotalScore")

local sessions = {}

--------------------------------------------------------------------
-- [A] SISTEM SIKLUS WAKTU
--------------------------------------------------------------------

local dayLength = 12
local cycleTime = dayLength * 60
local minutesInADay = 24 * 60
local timeRatio = minutesInADay / cycleTime

local currentDay = Instance.new("IntValue")
currentDay.Name = "CurrentDay"
currentDay.Value = 1
currentDay.Parent = Lighting

local startTime = tick() - (Lighting:GetMinutesAfterMidnight() / minutesInADay) * cycleTime
local endTime = startTime + cycleTime

RunService.Heartbeat:Connect(function()
    local currentTime = tick()

    if currentTime > endTime then
        startTime = endTime
        endTime = startTime + cycleTime
        currentDay.Value = (currentDay.Value % 7) + 1
    end

    Lighting:SetMinutesAfterMidnight((currentTime - startTime) * timeRatio)
end)

--------------------------------------------------------------------
-- [B] SISTEM SPAWN KENDARAAN
--------------------------------------------------------------------

local spawnEvent = ReplicatedStorage:WaitForChild("SpawnVehicleEvent")

spawnEvent.OnServerEvent:Connect(function(player, vehicleType)
    if type(vehicleType) ~= "string" then return end

    local vehicleTemplate = ReplicatedStorage:FindFirstChild(vehicleType)
    if not vehicleTemplate then return end

    local oldVehicleName = player.Name .. "_Vehicle"

    local existingVehicle = Workspace:FindFirstChild(oldVehicleName)
    if existingVehicle then
        existingVehicle:Destroy()
    end

    local char = player.Character

    if char and char:FindFirstChild("HumanoidRootPart") then
        local newVehicle = vehicleTemplate:Clone()
        newVehicle.Name = oldVehicleName

        local spawnCFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)

        if newVehicle:IsA("Model") and newVehicle.PrimaryPart then
            newVehicle:SetPrimaryPartCFrame(spawnCFrame)
        elseif newVehicle:IsA("BasePart") then
            newVehicle.CFrame = spawnCFrame
        end

        newVehicle.Parent = Workspace
    end
end)

--------------------------------------------------------------------
-- [C] SISTEM EQUIP TAS
--------------------------------------------------------------------

local equipEvent = ReplicatedStorage:WaitForChild("EquipBagEvent")

equipEvent.OnServerEvent:Connect(function(player, bagId)
    local char = player.Character

    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid

        for _, acc in pairs(char:GetChildren()) do
            if acc:IsA("Accessory") and acc.Name == "RoleplayLoadedBag" then
                acc:Destroy()
            end
        end

        if bagId == 0 or bagId == "Unequip" then
            return
        end

        local success, model = pcall(function()
            return InsertService:LoadAsset(tonumber(bagId))
        end)

        if success and model then
            local accessory = model:GetChildren()[1]

            if accessory and accessory:IsA("Accessory") then
                accessory.Name = "RoleplayLoadedBag"
                hum:AddAccessory(accessory)
            end

            model:Destroy()
        else
            warn("InsertService gagal memuat tas ID: " .. tostring(bagId))
        end
    end
end)

--------------------------------------------------------------------
-- [D] PROFILE, NAMETAG, ECONOMY
--------------------------------------------------------------------

local profileEvent = ReplicatedStorage:WaitForChild("ProfileEvent")
local shopEvent = ReplicatedStorage:WaitForChild("ShopEvent")
local dailyEvent = ReplicatedStorage:WaitForChild("DailyRewardEvent")

local TTSScoreEvent = Remotes:FindFirstChild("TTSScoreEvent")
if not TTSScoreEvent then
    TTSScoreEvent = Instance.new("RemoteEvent")
    TTSScoreEvent.Name = "TTSScoreEvent"
    TTSScoreEvent.Parent = Remotes
end

local ALLOWED_TTS_TYPES = {
    Truth = true,
    Time = true,
    Magic = true,
    Kind = true,
    Trust = true,
}

local function saveTTSScore(player, ttsType, score)
    if type(ttsType) ~= "string" then
        return
    end

    if not ALLOWED_TTS_TYPES[ttsType] then
        return
    end

    if type(score) ~= "number" then
        return
    end

    score = math.max(0, math.floor(score))

    pcall(function()
        ScoreDS:SetAsync(player.UserId .. "_TTS_" .. ttsType, score)
    end)

    UpdateTotalScoreLeaderboard(player)
end

TTSScoreEvent.OnServerEvent:Connect(function(player, ttsType, score)
    saveTTSScore(player, ttsType, score)
end)

local function getTitleFromLevel(level)
    if level == 1 then
        return "Pendatang Baru"
    elseif level == 2 then
        return "Siswa Baru"
    elseif level >= 3 then
        return "Siswa Aktif"
    else
        return "Pendatang Baru"
    end
end

local function createOrUpdateNameTag(char, nameText, playerLevel)
    local head = char:WaitForChild("Head", 5)
    local hum = char:WaitForChild("Humanoid", 5)

    if not head or not hum then
        return
    end

    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

    local tag = head:FindFirstChild("RPNameTag")

    if not tag then
        local template = ReplicatedStorage:FindFirstChild("RPNameTag")

        if template then
            tag = template:Clone()
            tag.Parent = head
        end
    end

    if tag then
        local infoFrame = tag:FindFirstChild("Info")

        if infoFrame then
            local nLabel = infoFrame:FindFirstChild("PlayerDisplayName")
            local tLabel = infoFrame:FindFirstChild("PlayerName")

            if nLabel then
                nLabel.Text = nameText
            end

            if tLabel then
                tLabel.Text = getTitleFromLevel(playerLevel)
            end
        end
    end
end

local function getSavedRPName(player)
    local rpName = player.DisplayName

    pcall(function()
        local savedName = ProfileStore:GetAsync(player.UserId .. "_RPName")

        if savedName then
            rpName = savedName
        end
    end)

    return rpName
end

--------------------------------------------------------------------
-- SAVE PROFILE DATA
--------------------------------------------------------------------

local function saveProfileData(player)
    local school = player:FindFirstChild("School")
    local class = player:FindFirstChild("Class")

    pcall(function()
        ProfileStore:SetAsync(player.UserId .. "_School", school and school.Value or "")
        ProfileStore:SetAsync(player.UserId .. "_Class", class and class.Value or "")
    end)
end

--------------------------------------------------------------------
-- TOTAL SCORE LEADERBOARD
--------------------------------------------------------------------

local function UpdateTotalScoreLeaderboard(player)
    task.spawn(function()
        local total = 0

        local quizTypes = {
            "Truth",
            "Time",
            "Magic",
            "Kind",
            "Trust",
            "TTS_Truth",
            "TTS_Time",
            "TTS_Magic",
            "TTS_Kind",
            "TTS_Trust"
        }

        for _, qt in ipairs(quizTypes) do
            pcall(function()
                local s = ScoreDS:GetAsync(player.UserId .. "_" .. qt)

                if s and type(s) == "number" then
                    total += s
                end
            end)
        end

        pcall(function()
            TotalScoreLeaderboard:SetAsync(player.UserId, total)
        end)
    end)
end

--------------------------------------------------------------------
-- SAVE ECO DATA
--------------------------------------------------------------------

local function saveEcoData(player)
    if not player:FindFirstChild("leaderstats") then
        return
    end

    local ecoData = {
        Coins = player.leaderstats.Coins.Value,
        Level = player.leaderstats.Level.Value,
        FreeRenames = player.FreeRenames.Value,
        FreeRestores = player.FreeRestores.Value,
        OwnedBags = player.OwnedBags.Value,
        LastLoginDay = player.LastLoginDay.Value,
        LoginStreak = player.LoginStreak.Value
    }

    pcall(function()
        EcoStore:SetAsync(player.UserId, ecoData)

        CoinsLeaderboard:SetAsync(player.UserId, ecoData.Coins)
        LevelLeaderboard:SetAsync(player.UserId, ecoData.Level)
    end)
end

--------------------------------------------------------------------
-- SETUP PLAYER
--------------------------------------------------------------------

local function setupPlayer(player)
    if player:FindFirstChild("leaderstats") then
        return
    end

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local levelStat = Instance.new("IntValue")
    levelStat.Name = "Level"
    levelStat.Value = 1
    levelStat.Parent = leaderstats

    local coinsStat = Instance.new("IntValue")
    coinsStat.Name = "Coins"
    coinsStat.Value = 0
    coinsStat.Parent = leaderstats

    local freeRenames = Instance.new("IntValue")
    freeRenames.Name = "FreeRenames"
    freeRenames.Value = 1
    freeRenames.Parent = player

    local freeRestores = Instance.new("IntValue")
    freeRestores.Name = "FreeRestores"
    freeRestores.Value = 1
    freeRestores.Parent = player

    local ownedBags = Instance.new("StringValue")
    ownedBags.Name = "OwnedBags"
    ownedBags.Value = "103537903282418"
    ownedBags.Parent = player

    local school = Instance.new("StringValue")
    school.Name = "School"
    school.Value = ""
    school.Parent = player

    local class = Instance.new("StringValue")
    class.Name = "Class"
    class.Value = ""
    class.Parent = player

    local lastLoginDay = Instance.new("IntValue")
    lastLoginDay.Name = "LastLoginDay"
    lastLoginDay.Value = 0
    lastLoginDay.Parent = player

    local loginStreak = Instance.new("IntValue")
    loginStreak.Name = "LoginStreak"
    loginStreak.Value = 1
    loginStreak.Parent = player

    local canClaimDaily = Instance.new("BoolValue")
    canClaimDaily.Name = "CanClaimDaily"
    canClaimDaily.Value = true
    canClaimDaily.Parent = player

    local currentRealDay = math.floor(os.time() / 86400)

    pcall(function()
        local ecoData = EcoStore:GetAsync(player.UserId)

        if ecoData then
            coinsStat.Value = ecoData.Coins or 0
            levelStat.Value = ecoData.Level or 1
            freeRenames.Value = ecoData.FreeRenames or 1
            freeRestores.Value = ecoData.FreeRestores or 1
            ownedBags.Value = ecoData.OwnedBags or "103537903282418"

            local savedLastDay = ecoData.LastLoginDay or 0
            local savedStreak = ecoData.LoginStreak or 1

            if currentRealDay > savedLastDay then
                canClaimDaily.Value = true

                if currentRealDay > savedLastDay + 1 then
                    loginStreak.Value = 1
                else
                    loginStreak.Value = savedStreak + 1

                    if loginStreak.Value > 7 then
                        loginStreak.Value = 1
                    end
                end
            else
                canClaimDaily.Value = false
                loginStreak.Value = savedStreak
            end

            lastLoginDay.Value = savedLastDay
        end
    end)

    pcall(function()
        local savedSchool = ProfileStore:GetAsync(player.UserId .. "_School")
        local savedClass = ProfileStore:GetAsync(player.UserId .. "_Class")

        if savedSchool then
            school.Value = savedSchool
        end

        if savedClass then
            class.Value = savedClass
        end
    end)

    player.CharacterAdded:Connect(function(char)
        local rpName = getSavedRPName(player)
        createOrUpdateNameTag(char, rpName, levelStat.Value)
    end)

    task.spawn(function()
        saveEcoData(player)
    end)
end

Players.PlayerAdded:Connect(setupPlayer)

for _, p in pairs(Players:GetPlayers()) do
    task.spawn(setupPlayer, p)
end

Players.PlayerRemoving:Connect(function(player)
    saveEcoData(player)
    saveProfileData(player)

    local session = sessions[player.UserId]

    if session then
        endGame(player)
    end
end)

--------------------------------------------------------------------
-- PROFILE EVENT
--------------------------------------------------------------------

profileEvent.OnServerEvent:Connect(function(player, action, newName, newSchool, newClass)
    local char = player.Character

    if not char then
        return
    end

    local coins = player.leaderstats.Coins
    local fRename = player.FreeRenames
    local fRestore = player.FreeRestores
    local level = player.leaderstats.Level.Value

    if action == "Save" and newName and newName ~= "" then

        if fRename.Value > 0 then
            fRename.Value -= 1
        elseif coins.Value >= 50 then
            coins.Value -= 50
        else
            return
        end

        local finalName = newName

        local success, filtered = pcall(function()
            local res = TextService:FilterStringAsync(newName, player.UserId)
            return res:GetNonChatStringForBroadcastAsync()
        end)

        if success and filtered then
            finalName = filtered
        end

        player.School.Value = newSchool or ""
        player.Class.Value = newClass or ""

        createOrUpdateNameTag(char, finalName, level)

        pcall(function()
            ProfileStore:SetAsync(player.UserId .. "_RPName", finalName)
        end)

        saveProfileData(player)
        saveEcoData(player)

    elseif action == "Reset" then

        if fRestore.Value > 0 then
            fRestore.Value -= 1
        elseif coins.Value >= 25 then
            coins.Value -= 25
        else
            return
        end

        player.School.Value = ""
        player.Class.Value = ""

        createOrUpdateNameTag(char, player.DisplayName, level)

        pcall(function()
            ProfileStore:RemoveAsync(player.UserId .. "_RPName")
        end)

        saveProfileData(player)
        saveEcoData(player)
    end
end)