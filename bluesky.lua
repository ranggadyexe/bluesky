local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local WS = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Client = require(ReplicatedStorage.Packages.Replion).Client
local Data = Client:WaitReplion("Data")
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "bluesky | Fish It!",
   Icon = 0,
   LoadingTitle = "bluesky | Fish It!",
   LoadingSubtitle = "by dw",
   ShowText = "bluesky", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Ocean", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "G",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "bluesky", -- Create a custom folder for your hub/game
      FileName =  "Config_" .. LocalPlayer.Name
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = false -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local FishingTab = Window:CreateTab("Fishing", "fish")
local MainTab = Window:CreateTab("Main", "home")
local AutoTab = Window:CreateTab ("Auto", "repeat")
local QuestTab = Window:CreateTab("Quest", "list-checks")
local ShopTab = Window:CreateTab("Shop", "shopping-cart")
local TeleportTab = Window:CreateTab("Teleport", "map-pin")

-- =========================================================
-- ⚙️ Remote References
local netRoot = game:GetService("ReplicatedStorage")
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local ChargeRodRemote       = netRoot:WaitForChild("RF/ChargeFishingRod")
local RequestMiniGameRemote = netRoot:WaitForChild("RF/RequestFishingMinigameStarted")
local FishingCompleteRemote = netRoot:WaitForChild("RE/FishingCompleted")
local FishCaughtRemote      = netRoot:WaitForChild("RE/FishCaught")
local EquipToolRemote       = netRoot:WaitForChild("RE/EquipToolFromHotbar")
local redeemRemote          = netRoot:WaitForChild("RF/RedeemCode")
local RE_TextEffect         = netRoot:WaitForChild("RE/ReplicateTextEffect")
local BaitDestroyedRemote   = netRoot:WaitForChild("RE/BaitDestroyed")
local BaitCastVisual        = netRoot:WaitForChild("RE/BaitCastVisual")
local FishingController     = require(ReplicatedStorage.Controllers:WaitForChild("FishingController"))


-- Tuning
local CLICK_PERIOD  = 0.1  -- > 0.1 s (rate limit di FishingMinigameClick)
local RECAST_DELAY  = 0.2    -- jeda kecil setelah sesi berakhir sebelum recast
local USE_HALF_PWR  = true   -- arg3=true => power 0.5 (sesuai decompile, stabil)
local WATCHDOG_IDLE = 0.5    -- idle tanpa sesi > 0.5s -> paksa cast lagi

-- State
local active     = false
local clicking   = false
local lastGUID   = nil
local lastCastT  = 0

-- Connections (supaya bisa di-disconnect saat toggle OFF)
local hbConn
local baitConn

local function castOnce()
    if not active then return end
    -- jangan cast kalau sesi masih aktif
    local okG, guid = pcall(function() return FishingController:GetCurrentGUID() end)
    if okG and guid then return end

    -- (opsional) kalau mau equip setiap recast, uncomment:
    EquipToolRemote:FireServer(1)

    local cam = WS.CurrentCamera
    local center = cam and Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2) or Vector2.new(0,0)
    local ok = pcall(function()
        FishingController:RequestChargeFishingRod(center, USE_HALF_PWR)
    end)
    if ok then
        lastCastT = time()
    end
end

-- ambil referensi bar minigame dari GUI
local FishingGui = LocalPlayer.PlayerGui:WaitForChild("Fishing")
local MiniGameDisplay = FishingGui.Main.Display
local LeftBar = MiniGameDisplay.CanvasGroup.Left.Bar

local function finishMinigame()
    if clicking then return end
    clicking = true
    while active do
        local ok, guid = pcall(function() return FishingController:GetCurrentGUID() end)
        if (not ok) or (not guid) then break end
        pcall(function() FishingController:RequestFishingMinigameClick() end)
        task.wait(CLICK_PERIOD)
    end
    clicking = false
end

local function startLoop()
    if hbConn then hbConn:Disconnect(); hbConn = nil end
    if baitConn then baitConn:Disconnect(); baitConn = nil end

        hbConn = RunService.Heartbeat:Connect(function()
        if not active then return end
        local ok, guid = pcall(function() return FishingController:GetCurrentGUID() end)
        if not ok then return end

        if guid and not lastGUID then
            finishMinigame()
        end

        lastGUID = guid

        if (not guid) and (not clicking) and (time() - lastCastT > WATCHDOG_IDLE) then
            castOnce()
        end
    end)


    -- 🔔 listen ke BaitDestroyed buat recast
    baitConn = BaitDestroyedRemote.OnClientEvent:Connect(function(...)
        if not active then return end
        -- kasih sedikit delay kalau mau aman, boleh juga RECAST_DELAY langsung
        task.delay(RECAST_DELAY, function()
            if active then
                castOnce()
            end
        end)
    end)

    -- ▶️ equip dulu sebelum cast pertama
    EquipToolRemote:FireServer(1)
    task.wait(0.05)
    castOnce()
end

local function stopLoop()
    active = false
    clicking = false
    lastGUID = nil

    if hbConn then hbConn:Disconnect(); hbConn = nil end
    if baitConn then baitConn:Disconnect(); baitConn = nil end
end

-- ========== Auto Spam Click (tanpa VirtualInput) ==========
local clickConn, lastClick = nil, 0
local CLICK_PERIOD_SAFE = 0.05 -- sesuai guard LastInput<0.1 di FishingController

local function startAutoClickSafe()
    if clickConn then clickConn:Disconnect() end
    lastClick = 0
    clickConn = RunService.Heartbeat:Connect(function()
        local flag = Rayfield.Flags["AutoClickGUI"]
        if not (flag and flag.CurrentValue) then return end

        -- cek GUI minigame aktif
        local pg = LocalPlayer.PlayerGui
        local gui = pg and pg:FindFirstChild("Fishing")
        local mg  = gui and gui.Main and gui.Main.Display and gui.Main.Display.Minigame

        if not (mg and mg.Visible) then return end

        -- opsional: pastikan sesi aktif (GUID ada)
        local ok, guid = pcall(function() return FishingController:GetCurrentGUID() end)
        if not ok or not guid then return end

        -- klik aman via controller (tanpa sentuh mouse)
        if time() - lastClick >= CLICK_PERIOD_SAFE then
            pcall(function() FishingController:RequestFishingMinigameClick() end)
            lastClick = time()
        end
    end)
end

local function stopAutoClickSafe()
    if clickConn then clickConn:Disconnect(); clickConn = nil end
    lastClick = 0
end

local function ResetCharacter()
    -- matikan autofishing dulu kalau ada
    local autoFlag = Rayfield.Flags["AutoFishing"]
    if autoFlag and autoFlag.Set then
        pcall(function()
            autoFlag:Set(false)
        end)
    end

    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end

    -- Simpan posisi sebelum reset
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local lastPos = hrp.CFrame

    -- Matikan karakter (set health 0)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = 0
    end

    -- Tunggu respawn
    player.CharacterAdded:Wait()
    local newChar = player.Character or player.CharacterAdded:Wait()
    local newHrp = newChar:WaitForChild("HumanoidRootPart")

    -- Teleport ke posisi lama
    task.wait(0.5)
    newHrp.CFrame = lastPos
end

local function ResetFishing()
    -- matikan autofishing dulu kalau ada
    local autoFlag = Rayfield.Flags["AutoFishing"]
    if autoFlag and autoFlag.Set then
        pcall(function()
            autoFlag:Set(false)
        end)
    end

    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end

    -- Simpan posisi sebelum reset
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local lastPos = hrp.CFrame

    -- Matikan karakter (set health 0)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Health = 0
    end

    -- Tunggu respawn
    player.CharacterAdded:Wait()
    local newChar = player.Character or player.CharacterAdded:Wait()
    local newHrp = newChar:WaitForChild("HumanoidRootPart")

    -- Teleport ke posisi lama
    task.wait(0.5)
    newHrp.CFrame = lastPos
    task.wait(0.5)
    if autoFlag and autoFlag.Set then
        pcall(function()
            autoFlag:Set(true)
        end)
    end
end

local function waitForCharacter()
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hrp then
        warn("[System] ⚠️ Character respawn timeout — HRP not found.")
        return nil
    end
    return char, hrp
end

local function goToSpot(cf)
    local plr = game.Players.LocalPlayer
    local char, hrp = waitForCharacter()
    if not hrp then return end

    -- Matikan AutoFishing dulu biar aman
    if Rayfield.Flags["AutoFishing"] and Rayfield.Flags["AutoFishing"].CurrentValue then
        Rayfield.Flags["AutoFishing"]:Set(false)
    end

    task.wait(0.3)
    hrp.CFrame = cf
    print("[System] 🚶 Teleported to new fishing spot.")

    -- Jalankan ResetCharacter (akan menyebabkan mati / respawn)
    if Rayfield.Flags["ResetCharacter"] and Rayfield.Flags["ResetCharacter"].Callback then
        print("[System] 🔁 Performing automatic fishing reset...")
        Rayfield.Flags["ResetCharacter"].Callback()
    else
        print("[System] ⚙️ Fallback reset via EquipToolRemote")
        task.wait(1)
        EquipToolRemote:FireServer(1)
    end

    print("[System] ⏳ Waiting for respawn to finish...")
    local newChar, newHrp = waitForCharacter()
    if not newHrp then
        warn("[System] ⚠️ Failed to find HRP after respawn.")
        return
    end

    task.wait(2)
    Rayfield.Flags["AutoFishing"]:Set(true)
    print("[System] ✅ AutoFishing re-enabled after respawn.")
    newHrp.CFrame = cf
    print("[System] 📍 Re-teleported after respawn.")
end

-- =========================================================
-- Coordinates

local spotAncientJungle = CFrame.lookAt(
    Vector3.new(1497.642822265625, 7.417082786560059, -437.892333984375),
    Vector3.new(1497.642822265625, 7.417082786560059, -437.892333984375)
        + Vector3.new(0.9999828338623047, 1.9449498012136246e-08, 0.0058635021559894085)
)

local spotSacredTemple = CFrame.lookAt(
    Vector3.new(1479.1177978515625, -22.125001907348633, -666.4100341796875),
    Vector3.new(1479.1177978515625, -22.125001907348633, -666.4100341796875)
        + Vector3.new(0.993732750415802, 4.227080196983479e-08, -0.11178195476531982)
)

local spotRobotKraken = CFrame.lookAt(
    Vector3.new(-3764.026, -135.074, -994.416),
    Vector3.new(-3764.026, -135.074, -994.416) + Vector3.new(0.694, -8.57e-08, 0.720)
)

local spotCrater = CFrame.lookAt(
    Vector3.new(1044.144775390625, 2.2233667373657227, 5020.09619140625),
    Vector3.new(1044.144775390625, 2.2233667373657227, 5020.09619140625)
        + Vector3.new(-0.5718123912811279, 3.73610191672924e-08, 0.8203843832015991)
)


-- =========================================================
-- Reset Character
local Section = FishingTab:CreateSection("Reset Character")

FishingTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        ResetCharacter()
    end
})


-- ===== Anti Stuck DEBUG (toggle + paragraph + timer + reset after 30s) =====
local antiTimerEnabled = false
local antiTimer = 0

-- Paragraph
local antiTimerPara = FishingTab:CreateParagraph({
    Title = "Anti Stuck Timer",
    Content = "Status: OFF | Timer: 0 s",
})

FishCaughtRemote.OnClientEvent:Connect(function()
    if not antiTimerEnabled then return end

    antiTimer = 0

    if antiTimerPara then
        antiTimerPara:Set({
            Title = "Anti Stuck Timer",
            Content = "Status: ON | Timer: 0 s",
        })
    end
end)


-- Toggle
FishingTab:CreateToggle({
    Name = "Anti Stuck (will reset fishing if 30s not caught fish)",
    CurrentValue = false,
    Flag = "AntiStuckDebug",
    Callback = function(state)
        antiTimerEnabled = state
        antiTimer = 0

        if not state then
            antiTimerPara:Set({
                Title = "Anti Stuck Timer",
                Content = "Status: OFF | Timer: 0 s",
            })
        end
    end,
})

task.spawn(function()
    while task.wait(1) do
        if antiTimerEnabled then
            antiTimer = antiTimer + 1
            antiTimerPara:Set({
                Title = "Anti Stuck Timer",
                Content = string.format("Status: ON | Timer: %d s", antiTimer),
            })

            if antiTimer >= 30 then
                ResetFishing()
                antiTimer = 0
            end
        else
            antiTimer = 0
            antiTimerPara:Set({
                Title = "Anti Stuck Timer",
                Content = "Status: OFF | Timer: 0 s",
            })
        end
    end
end)

local Section = FishingTab:CreateSection("🎣 Auto Fishing (Legit)")

local Fishing = FishingTab:CreateToggle({
    Name = "Auto Fishing (Legit)",
    CurrentValue = false,
    Flag = "AutoFishing",
    Callback = function(value)
        if value then
            active = true
            startLoop()
        else
            stopLoop()
        end
    end
})

FishingTab:CreateToggle({
    Name = "Auto Spam Click (Only Legit)",
    CurrentValue = false,
    Flag = "AutoClickGUI",
    Callback = function(v)
        if v then startAutoClickSafe() else stopAutoClickSafe() end
    end
})

--[[
-- ================== UI: Instant Auto Fishing ==================
-- default delay (detik) setelah tanda "!" sebelum kirim FishingCompleted

local Section = FishingTab:CreateSection("🎣 Auto Fishing (Instant) -- find your sweet spot with the slider")

local exclaimDelay = 2.5  -- default
FishingTab:CreateSlider({
    Name = "Delay to Complete",
    Range = {0, 5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = exclaimDelay,
    Flag = "AF_InstantDelay",
    Callback = function(v) exclaimDelay = tonumber(v) or exclaimDelay end
})

local active, waitingForBite, inProgress = false, false, false
local hbConn, txtConn, caughtConn
local RECAST_DELAY, CHARGE_TO_START = 0.05, 0.025
local SPAM_CAST_PERIOD = 0.02
local spamThread = nil

local function startFishing()
	if not active or inProgress then return end
	inProgress, waitingForBite = true, true

	EquipToolRemote:FireServer(1)
    task.wait(0.05)

	-- Sinkron waktu
	local t0 = workspace:GetServerTimeNow()

	-- Charge
	pcall(function() ChargeRodRemote:InvokeServer(nil,nil,nil,t0) end)
	task.wait(CHARGE_TO_START)

	-- Lempar
	local y, power = -1.2, 1
	pcall(function() RequestMiniGameRemote:InvokeServer(y, power, workspace:GetServerTimeNow()) end)

	inProgress = false
end

local function stopAll()
	active, waitingForBite, inProgress = false, false, false
	if hbConn then hbConn:Disconnect(); hbConn = nil end
	if txtConn then txtConn:Disconnect(); txtConn = nil end
	if caughtConn then caughtConn:Disconnect(); caughtConn = nil end
	local t = spamThread; spamThread = nil
end

local function startSpamCast()
    if spamThread then return end
    spamThread = task.spawn(function()
        while active do
            pcall(startFishing)
            task.wait(SPAM_CAST_PERIOD)
        end
        spamThread = nil
    end)
end

-- Deteksi "!" → delay sesuai slider → FishingCompleted
local function bindExclaim()
	if txtConn then txtConn:Disconnect() end
	txtConn = RE_TextEffect.OnClientEvent:Connect(function(data)
		if not active or not waitingForBite then return end
		local td = data and data.TextData
		if td and (td.EffectType == "Exclaim" or td.Text == "!") then
			waitingForBite = false
			task.delay(exclaimDelay, function()
				if active then pcall(function() FishingCompleteRemote:FireServer() end) end
			end)
		end
	end)
end

-- FishCaught → recast cepat
local function bindCaught()
	if caughtConn then caughtConn:Disconnect() end
	caughtConn = FishCaughtRemote.OnClientEvent:Connect(function()
		if not active then return end
		task.delay(RECAST_DELAY, startFishing)
	end)
end

-- Toggle utama
FishingTab:CreateToggle({
	Name = "Auto Fishing (Instant)",
	CurrentValue = false,
	Flag = "AutoFishingInstant",
	Callback = function(on)
		if on then
			active = true
			bindExclaim()
			bindCaught()
            startSpamCast()
			startFishing()
		else
			stopAll()
		end
	end
})

local getcon = getconnections or (syn and syn.getconnections) or function() return {} end

local noopConn, watchdogConn
local function noop(...) end

local function muteOnce()
    -- putus semua listener kecuali no-op kita
    for _, c in ipairs(getcon(BaitCastVisual.OnClientEvent)) do
        if not (c.Function and rawequal(c.Function, noop)) then
            pcall(function() c:Disable() end)
            pcall(function() c:Disconnect() end)
        end
    end
    -- pasang listener kosong
    if not noopConn then
        noopConn = BaitCastVisual.OnClientEvent:Connect(noop)
    end
end

local function startMute()
    muteOnce()
    -- watchdog ringan (tiap 0.25s) supaya listener baru langsung diputus
    if watchdogConn then return end
    watchdogConn = task.spawn(function()
        while Rayfield.Flags["MuteBaitCastVisual"] and Rayfield.Flags["MuteBaitCastVisual"].CurrentValue do
            muteOnce()
            task.wait(0.25)
        end
        watchdogConn = nil
    end)
end

local function stopMute()
    if watchdogConn then watchdogConn = nil end
    if noopConn then
        pcall(function() noopConn:Disconnect() end)
        noopConn = nil
    end
    -- tidak mengembalikan listener asli; jika script lain butuh, mereka akan rebind sendiri
end

FishingTab:CreateToggle({
    Name = "Disable BaitCastVisual",
    CurrentValue = false,
    Flag = "MuteBaitCastVisual",
    Callback = function(v)
        if v then startMute() else stopMute() end
    end
})
]]

-- =========================================================
-- 🎁 Auto Claim Event Rewards (Loop Every 60 Minutes)
local Section = MainTab:CreateSection("Battlepass Event")

MainTab:CreateToggle({
    Name = "Auto Claim Battlepass (Every 60 Minutes)",
    CurrentValue = false,
    Flag = "AutoClaimEventRewards",
    Callback = function(state)
        _G.AutoClaimEventRewards = state
        if not state then return end

        task.spawn(function()
            local remote = netRoot:WaitForChild("RE/ClaimEventReward")

            while _G.AutoClaimEventRewards do
                -- Klaim semua reward 15
                for i = 1, 15 do
                    if not _G.AutoClaimEventRewards then break end
                    task.wait(0.25)
                    pcall(function()
                        remote:FireServer(i)
                    end)
                end

                -- Tunggu 60 menit sebelum mengulang
                local cooldown = 60 * 60
                for t = 1, cooldown do
                    if not _G.AutoClaimEventRewards then break end
                    task.wait(1)
                end
            end
        end)
    end,
})

local Section = MainTab:CreateSection("Farming FISH")

local player = game.Players.LocalPlayer

--// 🎯 Fokus hanya ke Megalodon Hunt (lokasi baru: workspace.Props["Megalodon Hunt"])
local function getMegalodonProp()
    -- Cari object bernama "Megalodon Hunt" di workspace, tanpa hard index [33]
    local megalodonObj = workspace:FindFirstChild("Megalodon Hunt", true)
    if not megalodonObj then
        warn("[MegalodonFinder] Tidak menemukan 'Megalodon Hunt' di workspace")
        return nil
    end

    -- Ambil part pertama (BasePart) di dalamnya (kalau bentuknya model/folder)
    local part = megalodonObj:FindFirstChildWhichIsA("BasePart", true)
    if part then
        print("[MegalodonFinder] Ditemukan Megalodon Hunt di:", megalodonObj:GetFullName())
        return part.CFrame
    end

    -- Kalau ternyata object-nya sendiri BasePart
    if megalodonObj:IsA("BasePart") then
        print("[MegalodonFinder] Ditemukan Megalodon Hunt (BasePart) di:", megalodonObj:GetFullName())
        return megalodonObj.CFrame
    end

    warn("[MegalodonFinder] 'Megalodon Hunt' ditemukan tapi tidak ada BasePart di dalamnya")
    return nil
end

--// 🪵 Platform Props
local propsPlatform
local activeMode = "BestSpot" -- default
local loopTask

local function createPropsPlatform(cframeTarget)
    if propsPlatform and propsPlatform.Parent then
        propsPlatform:Destroy()
    end
    propsPlatform = Instance.new("Part")
    propsPlatform.Size = Vector3.new(12, 1, 12)
    propsPlatform.Anchored = true
    propsPlatform.CanCollide = true
    propsPlatform.Transparency = 1
    propsPlatform.Name = "[RF]PropsPlatform"
    propsPlatform.CFrame = cframeTarget + Vector3.new(0, 5, 0)
    propsPlatform.Parent = workspace
end

local function removePropsPlatform()
    if propsPlatform and propsPlatform.Parent then
        propsPlatform:Destroy()
    end
    propsPlatform = nil
end

--// 🌀 Start / Stop Loop
local function startAutoMegalodon()
    if loopTask then return end -- biar ga dobel

    goToSpot(spotCrater + Vector3.new(0, 2, 0))
    activeMode = "BestSpot"

    loopTask = task.spawn(function()
        while task.wait(1) do
            pcall(function()
                local targetCFrame = getMegalodonProp()

                if targetCFrame then
                    if activeMode ~= "Megalodon" then
                        createPropsPlatform(targetCFrame)
                        goToSpot(propsPlatform.CFrame + Vector3.new(0, 10, 0))
                        activeMode = "Megalodon"
                    else
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            local dist = (hrp.Position - propsPlatform.Position).Magnitude
                            if dist > 7 then
                                goToSpot(propsPlatform.CFrame + Vector3.new(0, 10, 0))
                            end
                        end
                    end
                else
                    if activeMode ~= "BestSpot" then
                        print("📍 Megalodon hilang → teleport ke BestSpot")
                        removePropsPlatform()
                        goToSpot(spotCrater + Vector3.new(0, 2, 0))
                        activeMode = "BestSpot"
                    end
                end
            end)
        end
    end)
end

local function stopAutoMegalodon()
    if loopTask then
        task.cancel(loopTask)
        loopTask = nil
    end
    removePropsPlatform()
    activeMode = "BestSpot"
end

--// 🟢 Toggle di Rayfield
MainTab:CreateToggle({
    Name = "Farm Megalodon",
    CurrentValue = false,
    Flag = "MegalodonHunt",
    Callback = function(state)
        if state then
            startAutoMegalodon()

            task.wait(5)

            -- ✅ Paksa toggle Auto Fishing ikut nyala
            if not Rayfield.Flags["AutoFishing"].CurrentValue then
                Rayfield.Flags["AutoFishing"]:Set(true)
            end
        else
            stopAutoMegalodon()

            -- 🔴 Matikan Auto Fishing juga
            if Rayfield.Flags["AutoFishing"].CurrentValue then
                Rayfield.Flags["AutoFishing"]:Set(false)
            end
        end
    end,
})

-- =========================================================
-- Robot Kraken

MainTab:CreateToggle({
    Name = "Farm Robot Kraken",
    CurrentValue = false,
    Flag = "AutoRobotKraken",
    Callback = function(state)
        _G.AutoRobotKraken = state

        if not state then
            if Rayfield.Flags["AutoFishing"].CurrentValue then
                Rayfield.Flags["AutoFishing"]:Set(false)
            end
            return
        end

        goToSpot(spotRobotKraken)

        task.spawn(function()
            while _G.AutoRobotKraken do
                if not Rayfield.Flags["AutoFishing"].CurrentValue then
                    Rayfield.Flags["AutoFishing"]:Set(true)
                end
                task.wait(5)
            end
        end)
    end,
})

-- =========================================================
-- Elshark Gran Maja

MainTab:CreateToggle({
    Name = "Farm Elshark Gran Maja",
    CurrentValue = false,
    Flag = "AutoElsharkGranMaja",
    Callback = function(state)
        _G.AutoElsharkGranMaja = state

        if not state then
            if Rayfield.Flags["AutoFishing"].CurrentValue then
                Rayfield.Flags["AutoFishing"]:Set(false)
            end
            return
        end

        -- 🔍 Cek status pintu Sacred Temple
        local templeDoor = workspace:FindFirstChild("JUNGLE INTERACTIONS")
            and workspace["JUNGLE INTERACTIONS"]:FindFirstChild("Doors")
            and workspace["JUNGLE INTERACTIONS"].Doors:FindFirstChild("TempleDoor")

        if templeDoor and templeDoor:FindFirstChild("DELETE_ME_AFTER_UNLOCK") then
            Rayfield:Notify({
                Title = "Access Denied",
                Content = "Open the Sacred Temple door first or complete the Artifact Quest.",
                Duration = 5,
                Image = "triangle-alert",
            })
            _G.AutoElsharkGranMaja = false
            Rayfield.Flags["AutoElsharkGranMaja"]:Set(false)
            return
        end

        -- ✅ Kalau pintu sudah terbuka, lanjut teleport dan mancing
        goToSpot(spotSacredTemple)

        task.spawn(function()
            while _G.AutoElsharkGranMaja do
                if not Rayfield.Flags["AutoFishing"].CurrentValue then
                    Rayfield.Flags["AutoFishing"]:Set(true)
                end
                task.wait(5)
            end
        end)
    end,
})


-- =========================================================
-- Auto Sell

local Section = MainTab:CreateSection("Auto Sell")

MainTab:CreateButton({
    Name = "Sell All Items",
    Callback = function()
        local SellAll = netRoot:WaitForChild("RF/SellAllItems")
        SellAll:InvokeServer() -- langsung jalankan

        Rayfield:Notify({
			Title = "Success!",
			Content = "all the fish were sold successfully",
			Duration = 2,
			Image = "dollar-sign",
		})
    end,
})

local autoSellThread = nil
local autoSellDelay = 30 -- default 3 seconds

-- // TextBox to change delay
MainTab:CreateInput({
    Name = "Auto Sell Delay (seconds)",
    PlaceholderText = "Enter seconds (default 30s)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num > 0 then
            autoSellDelay = num
        end
    end,
})

--- // Toggle Auto Sell
MainTab:CreateToggle({
    Name = "Auto Sell Loop",
    CurrentValue = false,
    Flag = "AutoSellLoop",
    Callback = function(Value)
        _G.AutoSell = Value

        if not Value then
            -- 🔴 Stop the loop
            if autoSellThread then
                task.cancel(autoSellThread)
                autoSellThread = nil
            end
            return
        end

        -- ✅ Start the loop
        autoSellThread = task.spawn(function()
            local SellAll = netRoot:WaitForChild("RF/SellAllItems")

            while _G.AutoSell do
                -- ⏱ tunggu dulu baru sell
                task.wait(autoSellDelay)
                if not _G.AutoSell then break end

                pcall(function()
                    SellAll:InvokeServer()
                end)
            end
        end)
    end,
})

local Section = MainTab:CreateSection("Utility")

-- =========================================================
-- Oxygen Tank

MainTab:CreateToggle({
    Name = "Oxygen Tank",
    CurrentValue = false,
    Flag = "OxygenTank",
    Callback = function(Value)

        if Value then
            -- ✅ Equip
            local EquipTank = netRoot:WaitForChild("RF/EquipOxygenTank")
            EquipTank:InvokeServer(105)
        else
            -- ❌ Unequip
            local UnequipTank = netRoot:WaitForChild("RF/UnequipOxygenTank")
            UnequipTank:InvokeServer()
        end
    end,
})

-- =========================================================
-- Fishing Radar

MainTab:CreateToggle({
    Name = "Fishing Radar",
    CurrentValue = false,
    Flag = "FishingRadar",
    Callback = function(Value)

        local RadarRemote = netRoot:WaitForChild("RF/UpdateFishingRadar")

        -- ✅ Kalau toggle ON, aktifkan radar
        if Value then
            RadarRemote:InvokeServer(true)
        else
            RadarRemote:InvokeServer(false)
        end
    end,
})

-- =========================================================
-- Anti AFK

--// Global flag
_G.AntiAFK = false
local antiAFKConn = nil

--// Toggle di MainTab
MainTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        _G.AntiAFK = Value

        if Value then
            antiAFKConn = game.Players.LocalPlayer.Idled:Connect(function()
                if _G.AntiAFK then
                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    warn("[AntiAFK] Prevented idle kick")
                end
            end)
        else
            if antiAFKConn then
                antiAFKConn:Disconnect()
                antiAFKConn = nil
            end
        end
    end
})

--// Toggle Remove GUI
local removeGUIEnabled = false
local removeLoop

MainTab:CreateToggle({
   Name = "Remove Popup",
   CurrentValue = false,
   Flag = "RemoveGUI",
   Callback = function(Value)
       removeGUIEnabled = Value
       local player = game:GetService("Players").LocalPlayer
       local playerGui = player:WaitForChild("PlayerGui")

       if Value then
           local smallNotif = playerGui:FindFirstChild("Small Notification")
           if smallNotif then smallNotif:Destroy() end

           local textNotif = playerGui:FindFirstChild("Text Notifications")
           if textNotif then textNotif:Destroy() end

           -- start loop only once
           if not removeLoop then
               removeLoop = task.spawn(function()
                   while removeGUIEnabled do
                       pcall(function()
                           local gui = player:WaitForChild("PlayerGui")
                           local daily = gui:FindFirstChild("!!! Daily Login")
                           local update = gui:FindFirstChild("!!! Update Log")
                           if daily then daily.Enabled = false end
                           if update then update.Enabled = false end
                       end)
                       task.wait(600) -- check tiap 10 menit
                   end
               end)
           end
       else
           removeGUIEnabled = false
       end
   end,
})


--// 🔻 Disable VFX on new objects
local function disableVFX(obj)
    if obj:IsA("ParticleEmitter")
    or obj:IsA("Trail")
    or obj:IsA("Beam")
    or obj:IsA("Fire")
    or obj:IsA("Smoke")
    or obj:IsA("Sparkles") then
        obj.Enabled = false
    end
end

--// 🔻 Convert parts to Plastic
local function simplifyPart(obj)
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
    end
end

--// 🔻 Apply low graphics recursively
local function applyLowGraphics(container)
    for _, obj in ipairs(container:GetDescendants()) do
        disableVFX(obj)
        simplifyPart(obj)
    end
end

--// 🟢 Toggle Low Graphic Mode
MainTab:CreateToggle({
    Name = "Low Graphic Mode (Rejoin to reset)",
    CurrentValue = false,
    Flag = "LowGraphics",
    Callback = function(state)
        if state then

            -- 🔅 Atur Lighting
            local lighting = game:GetService("Lighting")
            lighting.GlobalShadows = false
            lighting.Brightness = 1
            lighting.FogEnd = 1e6
            lighting.FogStart = 0
            lighting.EnvironmentSpecularScale = 0
            lighting.EnvironmentDiffuseScale = 0
            lighting.Ambient = Color3.new(1, 1, 1)
            lighting.OutdoorAmbient = Color3.new(1, 1, 1)

            -- 🔨 Destroy semua VFX di ReplicatedStorage
            local rs = game:GetService("ReplicatedStorage")
            if rs:FindFirstChild("VFX") then
                rs.VFX:ClearAllChildren()
            end

            -- 🌍 Apply ke semua container
            local containers = {
                workspace,
                lighting,
                rs,
                game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
            }
            for _, c in ipairs(containers) do
                applyLowGraphics(c)

                -- listen jika ada object baru masuk
                c.DescendantAdded:Connect(function(obj)
                    disableVFX(obj)
                    simplifyPart(obj)
                end)
            end
        else
        end
    end,
})

--[[
--// 🌊 Water Walk
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local waterPlatform
local runConn, charConn

-- Konfigurasi
local ORIGIN_RADIUS = 4
local NUM_AROUND = 6
local MAX_RAY_PASSES = 5
local SCAN_HEIGHT = 80
local SCAN_DEPTH = 400
local OFFSET_UP = 0.5
local TICK_SEC = 0.08
local PLATFORM_SIZE = Vector3.new(8, 0.8, 8)
local WATER_NAME_HINTS = { "water", "ocean", "sea", "lake", "river", "pond", "lagoon", "pool", "bay", "swamp" }

-- Deteksi apakah hit = air
local function isWaterHit(hitInst, material)
    if material == Enum.Material.Water then return true end
    if hitInst and hitInst:IsA("Terrain") and material == Enum.Material.Water then return true end
    if hitInst and hitInst:IsA("BasePart") then
        local ok, hasTag = pcall(function()
            return CollectionService:HasTag(hitInst, "Water") or CollectionService:HasTag(hitInst, "water")
        end)
        if ok and hasTag then return true end
        local n = hitInst.Name:lower()
        for _, k in ipairs(WATER_NAME_HINTS) do
            if string.find(n, k, 1, true) then return true end
        end
    end
    return false
end

-- Cari permukaan air terbaik di sekitar player
local function bestWaterSurfaceY(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local origins = { hrp.Position }
    for i = 1, NUM_AROUND do
        local angle = (i / NUM_AROUND) * math.pi * 2
        table.insert(origins, hrp.Position + Vector3.new(math.cos(angle) * ORIGIN_RADIUS, 0, math.sin(angle) * ORIGIN_RADIUS))
    end

    local bestY = nil
    for _, o in ipairs(origins) do
        local ignore = { character, waterPlatform }
        for _pass = 1, MAX_RAY_PASSES do
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = ignore

            local origin = o + Vector3.new(0, SCAN_HEIGHT, 0)
            local direction = Vector3.new(0, -SCAN_DEPTH, 0)
            local result = workspace:Raycast(origin, direction, params)
            if not result then break end

            if isWaterHit(result.Instance, result.Material) then
                local y = result.Position.Y
                if not bestY or y > bestY then bestY = y end
                break
            else
                table.insert(ignore, result.Instance)
            end
        end
    end
    return bestY
end

-- Aktifkan Water Walk
local function startWaterWalk(character)
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- cleanup lama
    if runConn then runConn:Disconnect(); runConn = nil end
    if waterPlatform and waterPlatform.Parent then waterPlatform:Destroy() end
    waterPlatform = nil

    -- buat platform
    waterPlatform = Instance.new("Part")
    waterPlatform.Name = "[RF]WaterWalk_" .. LocalPlayer.UserId
    waterPlatform.Size = PLATFORM_SIZE
    waterPlatform.Anchored = true
    waterPlatform.CanCollide = true
    waterPlatform.Transparency = 1
    waterPlatform.Material = Enum.Material.SmoothPlastic
    waterPlatform.Parent = workspace

    -- update platform posisi
    local acc = 0
    runConn = RunService.Heartbeat:Connect(function(dt)
        acc = acc + dt
        if acc < TICK_SEC then return end
        acc = 0

        if not hrp or not hrp.Parent then return end

        local y = bestWaterSurfaceY(character)
        if y then
            local p = hrp.Position
            waterPlatform.CFrame = CFrame.new(Vector3.new(p.X, y + OFFSET_UP, p.Z))
            waterPlatform.CanCollide = true
        else
            -- fallback kalau tidak ketemu air
            waterPlatform.CFrame = hrp.CFrame * CFrame.new(0, -6, 0)
            waterPlatform.CanCollide = false
        end
    end)
end

-- Toggle Water Walk
local Toggle = MainTab:CreateToggle({
    Name = "Water Walk",
    CurrentValue = false,
    Flag = "WaterWalkToggle",
    Callback = function(state)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

        if state then
            startWaterWalk(character)
        else
            if runConn then runConn:Disconnect(); runConn = nil end
            if waterPlatform and waterPlatform.Parent then waterPlatform:Destroy() end
            waterPlatform = nil
        end
    end,
})
]]

-- =========================================================
-- Trade Fish
local Section = AutoTab:CreateSection("Auto Trade")

-- Local
local remote = ReplicatedStorage.Packages["_Index"]["sleitnick_net@0.2.0"].net["RF/InitiateTrade"]

-- 🔁 State
local targetUserId = nil
local tradingActive = false
local skipFavorited = true
local skipEnchantStone = true

-- =========================================================
-- 🧠 Helper Functions
local function getPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        table.insert(names, plr.Name)
    end
    table.sort(names)
    return names
end

local function notify(title, content, icon)
    pcall(function()
        Rayfield:Notify({
            Title = title or "Info",
            Content = content or "",
            Duration = 3,
            Image = icon or "info"
        })
    end)
end

local function teleportNearTarget()
    local target = targetUserId and Players:GetPlayerByUserId(targetUserId)
    if not target then return end

    local tChar = target.Character
    local myChar = LocalPlayer.Character
    if not (tChar and myChar) then return end

    local tHRP = tChar:FindFirstChild("HumanoidRootPart")
    local mHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not (tHRP and mHRP) then return end

    mHRP.CFrame = tHRP.CFrame * CFrame.new(4, 0, 0)
end

local function getTargetName()
    if not targetUserId then return "N/A" end
    -- kalau target masih ada di server yang sama:
    local plr = Players:GetPlayerByUserId(targetUserId)
    if plr then return plr.Name end
    -- fallback ke API async:
    local ok, name = pcall(function()
        return Players:GetNameFromUserIdAsync(targetUserId)
    end)
    return ok and name or tostring(targetUserId)
end

local function getWeight(info)
	if not info then return "?" end
	local w = (info.Metadata and (info.Metadata.Weight or info.Metadata.weight))
	       or info.Weight or info.weight
	if typeof(w) == "number" then
		return string.format("%.2f", w)
	end
	return tostring(w or "?")
end

local function getMutation(info)
	if not info then return "-" end
	-- coba beberapa kemungkinan penamaan/struktur
	local m = info.VariantId or (info.Metadata and (info.Metadata.VariantId or info.Metadata.variantId or info.Metadata.VariantID))
	if typeof(m) == "table" then
		-- bila berupa list, gabungkan jadi teks
		local t = {}
		for k,v in pairs(m) do
			table.insert(t, tostring(v))
		end
		table.sort(t)
		return (#t > 0 and table.concat(t, ", ")) or "-"
	elseif m == nil then
		return "-"
	else
		return tostring(m)
	end
end

local function getFishMeta(info)
    if typeof(info) ~= "table" or not info.Id then return nil end
    local ok, meta = pcall(function()
        return ItemUtility.GetItemDataFromItemType("Fish", info.Id)
    end)
    if ok and meta and meta.Data and meta.Data.Type == "Fish" then
        return meta
    end
    return nil
end

local function isFavorited(info)
    if info and info.Metadata and info.Metadata.Favorited ~= nil then
        return info.Metadata.Favorited == true
    end
    return info and info.Favorited == true
end

local function countFishById(id, skipFav)
    local inv = Data and Data.Data and Data.Data.Inventory and Data.Data.Inventory.Items
    if not inv then return 0 end
    local c = 0
    for _, info in pairs(inv) do
        if info and info.Id == id then
            local meta = getFishMeta(info)
            if meta and (not skipFav or not isFavorited(info)) then
                c = c + 1
            end
        end
    end
    return c
end

-- ambil satu instance Fish (UUID) untuk Id tertentu
local function findOneFishInstance(id, skipFav)
	local inv = Data and Data.Data and Data.Data.Inventory and Data.Data.Inventory.Items
	if not inv then return nil end
	for _, info in pairs(inv) do
		if info and info.Id == id then
			local meta = getFishMeta(info)
			if meta and (not skipFav or not isFavorited(info)) then
				return {
					UUID     = info.UUID,
					Name     = meta.Data.Name or "Fish",
					Id       = id,
					Weight   = getWeight(info),
					Mutation = getMutation(info),
				}
			end
		end
	end
	return nil
end

-- bangun antrean SPESIES (unik per Id) + hitung total ikan unfavorit
local function buildSpeciesQueue(skipFav)
    local inv = Data and Data.Data and Data.Data.Inventory and Data.Data.Inventory.Items
    local seen, queue, totalCnt = {}, {}, 0
    if not inv then return queue, 0 end
    for _, info in pairs(inv) do
        if info and info.Id then
            local meta = getFishMeta(info)
            if meta and (not skipFav or not isFavorited(info)) then
                if not seen[info.Id] then
                    seen[info.Id] = true
                    table.insert(queue, { Id = info.Id, Name = meta.Data.Name or "Fish" })
                end
                totalCnt = totalCnt + 1
            end
        end
    end
    return queue, totalCnt
end

local function countAllEligibleFish(skipFav)
    local inv = Data and Data.Data and Data.Data.Inventory and Data.Data.Inventory.Items
    if not inv then return 0 end
    local total = 0
    for _, info in pairs(inv) do
        if info and info.Id then
            local meta = getFishMeta(info)
            if meta and (not skipFav or not isFavorited(info)) then
                total = total + 1
            end
        end
    end
    return total
end

--[[ === 🎣 Fish Inventory Overview (Live Full Rarity) ===

-- Mapping Tier -> Rarity
local RarityByTier = {
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "Secret",
}

-- helper ambil rarity dari meta fish
local function getFishRarityFromMeta(meta)
    if not (meta and meta.Data) then return nil end
    local tier = meta.Data.Tier or 1
    return RarityByTier[tier] or "Unknown"
end

-- helper opsional buat format angka
local function fmt(n)
    return tostring(n):reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,","")
end

-- urutan tampilan rarity
local rarityOrder = {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Secret"}

-- hitung semua rarity + unfavorited
local function countAllFishRarities()
    local inv = Data and Data.Data and Data.Data.Inventory and Data.Data.Inventory.Items
    if not inv then return {}, 0 end

    local counts = {
        Common = 0,
        Uncommon = 0,
        Rare = 0,
        Epic = 0,
        Legendary = 0,
        Mythic = 0,
        Secret = 0,
    }
    local unfavCount = 0

    for _, info in pairs(inv) do
        if info and info.Id then
            local meta = getFishMeta(info)
            if meta and meta.Data and meta.Data.Type == "Fish" then
                local rarity = getFishRarityFromMeta(meta)
                if counts[rarity] ~= nil then
                    counts[rarity] = counts[rarity] + 1
                end
                if not isFavorited(info) then
                    unfavCount = unfavCount + 1
                end
            end
        end
    end

    return counts, unfavCount
end

-- buat paragraf GUI
local fishPara = AutoTab:CreateParagraph({
    Title = "🎣 Fish Inventory Overview",
    Content = "Loading fish data...",
})

-- loop update tiap 2 detik
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local counts, unfav = countAllFishRarities()
            local lines = {}

            -- tampilkan HANYA rarity yang > 0
            for _, r in ipairs(rarityOrder) do
                local c = counts[r] or 0
                if c > 0 then
                    table.insert(lines, string.format("%s = %s", r, fmt(c)))
                end
            end

            -- baris tetap (selalu tampil)
            table.insert(lines, string.format("Unfavorited = %s", fmt(unfav)))
            table.insert(lines, "Price (Unfavorited) = —") -- isi nanti kalau sudah siap

            fishPara:Set({
                Title   = "🎣 Fish Inventory Overview",
                Content = table.concat(lines, "\n")
            })
        end)
    end
end)
]]

-- =========================================================
-- 🎛️ UI
local TradeDropdown = AutoTab:CreateDropdown({
    Name = "Select Trade Target",
    Options = getPlayerNames(),
    CurrentOption = {LocalPlayer.Name},
    Callback = function(selected)
        local name = selected and selected[1]
        local plr = name and Players:FindFirstChild(name)
        if plr then
            targetUserId = plr.UserId
            print("[Trade] Target set:", name, "(" .. targetUserId .. ")")
        else
            targetUserId = nil
            warn("[Trade] Invalid player selection")
        end
    end
})

local function refreshDropdown()
    local opts = getPlayerNames()
    pcall(function()
        TradeDropdown.Options = opts
        if TradeDropdown.Refresh then
            TradeDropdown:Refresh(opts, true)
        end
    end)
end

Players.PlayerAdded:Connect(refreshDropdown)
Players.PlayerRemoving:Connect(function(plr)
    if plr.UserId == targetUserId then
        targetUserId = nil
        notify("Target Left", "Your selected player left the server.", "triangle-alert")
    end
    refreshDropdown()
end)

AutoTab:CreateButton({
    Name = "🔄 Refresh Player List",
    Callback = refreshDropdown
})

AutoTab:CreateToggle({
    Name = "Skip Favorited Items",
    CurrentValue = true,
    Callback = function(state)
        skipFavorited = state
        print("[Trade] Skip Favorited Items:", state)
    end
})

-- =========================================================
-- 🚀 Main Auto Trade Toggle
AutoTab:CreateToggle({
    Name = "Auto Trade",
    CurrentValue = false,
    Callback = function(state)
        tradingActive = state
        if not tradingActive then
            notify("Info", "Auto Trade stopped", "circle-off")
            return
        end

        local target = targetUserId and Players:GetPlayerByUserId(targetUserId)
        if not target then
            tradingActive = false
            notify("Error", "Please select a valid target before starting!", "triangle-alert")
            return
        end

        -- 1) Scan: species unik + total ikan (respect skipFavorited)
        local speciesQueue, totalFish = buildSpeciesQueue(skipFavorited)
        if totalFish == 0 then
            tradingActive = false
            notify("Info", "Tidak ada Fish yang memenuhi kriteria.", "circle-help")
            return
        end

        Rayfield:Notify({
            Title = "Auto Trade",
            Content = ("Ditemukan " .. totalFish .. " Fish yang akan dikirim"
                .. (skipFavorited and " (skip favorit ON)" or " (skip favorit OFF)")),
            Duration = 4,
            Image = "fish"
        })

        notify("Starting", "Auto Trade started.", "arrow-right-left")

        local currentUUID = nil

        task.spawn(function()
            for si, spec in ipairs(speciesQueue) do
                if not tradingActive then break end

                while tradingActive do
                    -- 1) cek jumlah ikan eligible (semua spesies)
                    local remainingAll = countAllEligibleFish(skipFavorited)
                    if remainingAll <= 0 then
                        print("[TRADE] Tidak ada ikan tersisa.")
                        tradingActive = false
                        break
                    end

                    -- 2) kalau spesies ini sudah habis (respect skipFav), lanjut spesies berikutnya
                    local speciesRemain = countFishById(spec.Id, skipFavorited)
                    if speciesRemain <= 0 then
                        break
                    end

                    teleportNearTarget()

                    -- 3) pegang UUID yang sama sampai benar-benar hilang
                    local inst
                    if currentUUID and Data.Data.Inventory.Items[currentUUID] then
                        local info = Data.Data.Inventory.Items[currentUUID]
                        local meta = getFishMeta(info)
                        inst = {
                            UUID     = currentUUID,
                            Id       = info.Id,
                            Name     = (meta and meta.Data and meta.Data.Name) or "Fish",
                            Weight   = getWeight(info),
                            Mutation = getMutation(info),
                        }
                    else
                        inst = findOneFishInstance(spec.Id, skipFavorited)
                        if not inst then break end -- sisa spesies ini favorit semua
                        currentUUID = inst.UUID
                    end

                    -- 4) NOTIFY format baru: "Trading X Ikan Tersisa"
                    Rayfield:Notify({
                        Title   = ("Trading " .. tostring(remainingAll) .. " Ikan Tersisa"),
                        Content = string.format("%s | %s | %s | -> %s",
                            inst.Name or "Fish",
                            inst.Weight or "?",
                            inst.Mutation or "-",
                            getTargetName()
                        ),
                        Duration = 2,
                        Image = "arrow-right-left"
                    })

                    -- 5) kirim & konfirmasi: sukses hanya jika UUID hilang
                    local sendOk = pcall(function()
                        return remote:InvokeServer(targetUserId, inst.UUID)
                    end)

                    local confirmed = false
                    if sendOk then
                        local start = tick()
                        while true do
                            if Data.Data.Inventory.Items[inst.UUID] == nil then
                                confirmed = true
                                break
                            end
                            if tick() - start > 20 then
                                warn(("[TRADE] Timeout menunggu %s (UUID:%s) hilang; retry.")
                                    :format(inst.Name, inst.UUID))
                                break
                            end
                            task.wait(0.25)
                        end
                    else
                        warn("[TRADE] Gagal invoke:", inst.Name, inst.UUID)
                    end

                    -- 6) bila sukses, reset UUID dan (opsional) tampilkan notif sisa terbaru
                    if confirmed then
                        currentUUID = nil
                        local newRemain = countAllEligibleFish(skipFavorited)
                    end

                    task.wait(0.3)
                end
            end

            Rayfield:Notify({
                Title = "Success",
                Content = "Trading Selesai " .. totalFish .. " Ikan Sudah Terkirim",
                Duration = 5,
                Image = "circle-check-big"
            })
            tradingActive = false
        end)
    end
})

-- ==== Auto Accept Trade via PromptController (sesuai flow game) ====
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PromptController = require(ReplicatedStorage.Controllers.PromptController)

local originalDrawPrompt = PromptController.DrawPrompt  -- simpan aslinya sekali

AutoTab:CreateToggle({
    Name = "Auto Accept Trade",
    CurrentValue = false,
    Callback = function(state)
        if state then
            -- Override: auto-YES. Tetap hormati ConfirmAction (wajib nunggu ~3 detik).
            PromptController.DrawPrompt = function(self, action)
                -- action.TextPrompt, action.ConfirmAction (true untuk trade)
                if action and action.ConfirmAction then
                    -- Game asli pakai delay 3 detik sebelum YES kedua valid.
                    task.wait(3.1) -- sedikit lebih dari 3s biar aman
                    return true
                else
                    -- Prompt biasa (tanpa confirm 2x): langsung YES
                    return true
                end
            end
        else
            -- Balikkan ke perilaku asli (prompt normal)
            PromptController.DrawPrompt = originalDrawPrompt
        end
    end,
})

-- =========================================================
local Section = AutoTab:CreateSection("Auto Favorited Rarity")
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
local ItemsFolder = ReplicatedStorage:WaitForChild("Items")

-- Remote untuk favorite
local RemoteFavorite = ReplicatedStorage
    .Packages._Index["sleitnick_net@0.2.0"]
    .net["RE/FavoriteItem"]

-- Mapping Tier -> Rarity
local RarityByTier = {
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "Secret",
}

-- State
local autoFavEnabled = false
local selectedRarities = {}
local toFavoriteQueue = {}
local processing = false

-- Dropdown
AutoTab:CreateDropdown({
    Name = "Select Fish Rarities",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    MultipleOptions = true,
    CurrentOption = {},
    Flag = "FavRarities",
    Callback = function(opts)
        selectedRarities = opts
        print("🎯 Selected rarities:", table.concat(opts, ", "))
    end,
})

-- Toggle
AutoTab:CreateToggle({
    Name = "Enable Auto-Favorite",
    CurrentValue = false,
    Callback = function(value)
        autoFavEnabled = value
        print("Auto Favorite:", value)
    end,
})

-- =========================================================
-- 🧰 Helper Function: Refresh Queue
-- =========================================================
local function refreshQueue()
    table.clear(toFavoriteQueue)
    local items = Data.Data["Inventory"]["Items"]
    for _, info in pairs(items) do
        if typeof(info) == "table" and info.Id then
            local ok, meta = pcall(function()
                return ItemUtility.GetItemDataFromItemType("Fish", info.Id)
            end)

            if ok and meta and meta.Data and meta.Data.Type == "Fish" then
                local rarity = RarityByTier[meta.Data.Tier or 1]
                if rarity and table.find(selectedRarities, rarity) and not info.Favorited then
                    table.insert(toFavoriteQueue, {
                        UUID = info.UUID,
                        Name = meta.Data.Name or "Unknown",
                        Rarity = rarity,
                    })
                end
            end
        end
    end
end

-- =========================================================
-- 🔁 Worker Loop (1 per 0.1 detik)
-- =========================================================
task.spawn(function()
    while true do
        if autoFavEnabled then
            if not processing then
                processing = true
                refreshQueue()

                if #toFavoriteQueue > 0 then
                    print(string.format("🔍 Found %d fish to favorite...", #toFavoriteQueue))
					Rayfield:Notify({
						Title = "Auto Favorite",
						Content = (string.format("🔍 Found %d fish to favorite...", #toFavoriteQueue)),
						Image = "fish-off",
						Duration = 4
					})
                end

                for _, fish in ipairs(toFavoriteQueue) do
                    pcall(function()
                        RemoteFavorite:FireServer(fish.UUID)
                    end)
                    print(string.format("⭐ Favorited %s | %s | UUID: %s",
                        fish.Name, fish.Rarity, fish.UUID))
                    task.wait(0.1)
                end

                processing = false
            end
        end
        task.wait(0.5) -- cek ulang tiap 3 detik (bukan spam)
    end
end)

AutoTab:CreateButton({
    Name = "Unfavorite All Fishes",
    Callback = function()
        local items = Data.Data["Inventory"]["Items"]
        local unfavCount = 0

        for _, info in pairs(items) do
            if typeof(info) == "table" and info.Id and info.Favorited == true then
                local ok, meta = pcall(function()
                    return ItemUtility.GetItemDataFromItemType("Fish", info.Id)
                end)

                if ok and meta and meta.Data and meta.Data.Type == "Fish" then
                    -- toggle unfavorite
                    RemoteFavorite:FireServer(info.UUID)
                    unfavCount = unfavCount + 1
                end
            end
        end

        Rayfield:Notify({
            Title = "Unfavorite Complete",
            Content = "Successfully unfavorited " .. tostring(unfavCount) .. " fish.",
            Image = "fish-off",
            Duration = 4
        })
    end,
})

-- =========================================================
-- 🎯 Config: 4 Ikan Khusus
-- =========================================================
local SpecialFishIds = {
    [263] = false, --crocodile
    [283] = true, --laba laba
    [284] = false,
    [270] = false,
    [382] = true, --cute octopus
}

local autoFavSpecialEnabled = false

task.spawn(function()
    while true do
        if autoFavSpecialEnabled then
            local items = Data.Data.Inventory.Items
            
            for _, info in pairs(items) do
                if typeof(info) == "table" and info.Id and not info.Favorited then
                    local ok, meta = pcall(function()
                        return ItemUtility.GetItemDataFromItemType("Fish", info.Id)
                    end)

                    if ok and meta and SpecialFishIds[meta.Data.Id] then
                        RemoteFavorite:FireServer(info.UUID)
                        print("⭐ Auto-Favorited Special:", meta.Data.Name)
                        task.wait(0.1)
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

AutoTab:CreateToggle({
    Name = "Auto Favorite Laba Laba & Cute Octopus",
    Flag = "AutoFav4SpecialFish",
    CurrentValue = false,
    Callback = function(v)
        autoFavSpecialEnabled = v
    end,
})


--[[
-- =========================================================
local Section = AutoTab:CreateSection("Auto Equip Best")
-- Auto Best Rod

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetFolder = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net

-- priority list
local RodPriority = {
    ["Angler Rod"]    = 13,
    ["Ares Rod"]      = 12,
    ["Astral Rod"]    = 11, 
    ["Chrome Rod"]    = 10,
    ["Steampunk Rod"] = 9,
    ["Midnight Rod"]  = 8,
    ["Lucky Rod"]     = 7,
    ["Ice Rod"]       = 6,
    ["Demascus Rod"]  = 5,
    ["Grass Rod"]     = 4,
    ["Carbon Rod"]    = 3,
    ["Luck Rod"]      = 2,
    ["Starter Rod"]   = 1,
}

-- mapping Id → nama rod
local RodIdToName = {
    [1]   = "Starter Rod",
    [169] = "Angler Rod",
    [126] = "Ares Rod",
    [5]   = "Astral Rod",
    [76]  = "Carbon Rod",
    [7]   = "Chrome Rod",
    [77]  = "Demascus Rod",
    [85]  = "Grass Rod",
    [78]  = "Ice Rod",
    [79]  = "Luck Rod",
    [4]   = "Lucky Rod",
    [80]  = "Midnight Rod",
    [6]   = "Steampunk Rod",
}

-- ambil rod terbaik dari inventory
local function GetBestRodUUID()
    local rods = Data.Data["Inventory"]["Fishing Rods"]
    local bestRod, bestScore = nil, -math.huge
    for _, rod in pairs(rods) do
        local id = rod.Id
        local name = RodIdToName[id]
        local score = RodPriority[name] or 0
        if score > bestScore then
            bestScore = score
            bestRod = rod
        end
    end
    return bestRod and bestRod.UUID or nil, bestRod and RodIdToName[bestRod.Id] or "Unknown"
end

-- flag global
local AutoBestRod = false

-- toggle Rayfield
AutoTab:CreateToggle({
    Name = "Auto Equip Best Rod",
    CurrentValue = false,
    Callback = function(state)
        AutoBestRod = state
        if AutoBestRod then
            task.spawn(function()
                while AutoBestRod do
                    local uuid, name = GetBestRodUUID()
                    if uuid then
                        NetFolder["RE/EquipItem"]:FireServer(uuid, "Fishing Rods")
                    end
                    task.wait(0.05) -- cek tiap 10 detik
                end
            end)
        end
    end,
})

-- daftar bait urut murah → mahal
local BaitPriority = {
    [10] = {Name = "Topwater (100)", Rank = 1},
    [2]  = {Name = "Luck Bait (1K)", Rank = 2},
    [3]  = {Name = "Midnight Bait (3K)", Rank = 3},
    [17] = {Name = "Nature Bait (83.5K)", Rank = 4},
    [6]  = {Name = "Chroma Bait (290K)", Rank = 5},
    [8]  = {Name = "Dark Matter Bait (630K)", Rank = 6},
    [15] = {Name = "Corrupt Bait (1.15M)", Rank = 7},
    [16] = {Name = "Aether Bait (3.7M)", Rank = 8},
}

-- cari bait paling mahal dari inventory
local function GetBestBaitId()
    local baits = Data.Data["Inventory"]["Baits"]
    if not baits then
        return nil
    end

    local bestId, bestRank = nil, -1
    for uuid, baitData in pairs(baits) do
        local id = baitData.Id
        local info = BaitPriority[id]
        if info then
            if info.Rank > bestRank then
                bestRank = info.Rank
                bestId = id
            end
        end
    end
    return bestId
end

-- toggle
local AutoBestBait = false

AutoTab:CreateToggle({
    Name = "Auto Equip Best Bobber",
    CurrentValue = false,
    Callback = function(state)
        AutoBestBait = state
        if AutoBestBait then
            task.spawn(function()
                while AutoBestBait do
                    local bestId = GetBestBaitId()
                    if bestId then
                        NetFolder["RE/EquipBait"]:FireServer(bestId)
                    else
                        break
                    end
                    task.wait(0.05)
                end
            end)
        end
    end,
})
]]

-- =========================================================
-- Element Quest (GUI Labels + Redeemed TRUE/FALSE)

local Section = QuestTab:CreateSection("Element Quest")

local QuestInfoElement = QuestTab:CreateParagraph({
    Title = "Element Quest",
    Content = "Loading..."
})

-- References (GUI)
local QuestFolder = workspace["!!! DEPENDENCIES"]["QuestTrackers"]["Element Tracker"].Board.Gui.Content
local Header   = QuestFolder.Header
local Label1   = QuestFolder.Label1
local Label2   = QuestFolder.Label2
local Label3   = QuestFolder.Label3
local Label4   = QuestFolder.Label4
local ProgressLabel = QuestFolder.Progress.ProgressLabel

-- Data path: ElementJungle.Available.Forever.Quests
local function getQuests()
    local EJ = Data and Data.Data and Data.Data.ElementJungle
    local A = EJ and EJ.Available
    local F = A and A.Forever
    return F and F.Quests
end

local function redeemedText(Q, i)
    if not Q then return "..." end
    local q = Q[i] or Q[tostring(i)]
    local r = q and q.Redeemed
    if r == nil then return "..." end
    return tostring(r):upper() -- TRUE / FALSE
end

task.spawn(function()
    while true do
        if not QuestInfoElement then break end

        pcall(function()
            local Q = getQuests()
            QuestInfoElement:Set({
                Title = Header.Text,
                Content = string.format([[
%s = %s
%s = %s
%s = %s
%s = %s

%s
                ]],
                Label1.Text, redeemedText(Q, 1),
                Label2.Text, redeemedText(Q, 2),
                Label3.Text, redeemedText(Q, 3),
                Label4.Text, redeemedText(Q, 4),
                ProgressLabel.Text
                )
            })
        end)

        RunService.task.wait(0.1) -- update setiap frame (paling realtime)
    end
end)
-- =========================================================
-- Auto Quest Element

-- ===== ElementJungle quests path (FIX)
local function getElementQuests()
    local EJ = Data and Data.Data and Data.Data.ElementJungle
    local A  = EJ and EJ.Available
    local F  = A and A.Forever
    return F and F.Quests
end

local function getQuest(i)
    local Q = getElementQuests()
    if not Q then return nil end
    return Q[i] or Q[tostring(i)]
end

local function isRedeemed(i)
    local q = getQuest(i)
    if not q or q.Redeemed == nil then
        return nil -- data belum ready
    end
    return q.Redeemed == true
end

local function waitUntilRedeemed(i)
    while _G.AutoQuestElement do
        local r = isRedeemed(i)
        if r == true then return true end
        task.wait(0.1) -- realtime-ish
    end
    return false
end

local function hasGhostfinnRod()
    local rods = Data.Data["Inventory"]["Fishing Rods"]
    for _, r in pairs(rods) do
        if tonumber(r.id) == 169 then return true end
    end
    return false
end

local function forceRejoin()
    local ts = game:GetService("TeleportService")
    local plr = game.Players.LocalPlayer
    print("[Element Quest] Rejoining server...")
    ts:Teleport(game.PlaceId, plr)
end

-- Auto resume autofishing after respawn
local plr = game.Players.LocalPlayer
plr.CharacterAdded:Connect(function(newChar)
    print("[System] ♻️ Character respawn detected.")
    task.spawn(function()
        local hrp = newChar:WaitForChild("HumanoidRootPart", 10)
        if hrp then
            task.wait(2)
            if _G.AutoQuestElement then
                Rayfield.Flags["AutoFishing"]:Set(true)
                print("[System] ✅ AutoFishing resumed automatically after respawn.")
            end
        end
    end)
end)

-- =========================================================
-- Main Toggle

QuestTab:CreateToggle({
    Name = "⚡ Auto Quest (Element Quest)",
    CurrentValue = false,
    Flag = "AutoQuestElement",
    Callback = function(v)
        _G.AutoQuestElement = v

        if not v then
            if Rayfield.Flags["AutoFishing"].CurrentValue then
                Rayfield.Flags["AutoFishing"]:Set(false)
            end
            return
        end

        task.spawn(function()
            local step = 0

            while _G.AutoQuestElement do
                local r1 = isRedeemed(1)
                local r2 = isRedeemed(2)
                local r3 = isRedeemed(3)
                local r4 = isRedeemed(4)

                -- Data belum ready -> tunggu, lanjut loop
                if r1 == nil or r2 == nil or r3 == nil or r4 == nil then
                    task.wait(1)

                else
                    ---------------------------------------------------
                    -- Quest 1
                    if not r1 then
                        if step ~= 1 then
                            step = 1
                            print("[Element Quest] Quest 1 — Ghostfinn Rod (Redeemed = FALSE)")
                        end

                        if hasGhostfinnRod() then
                            print("[Element Quest] Rod found but quest not redeemed → rejoin.")
                            forceRejoin()
                            return
                        else
                            print("[Element Quest] Rod missing → start Deep Sea Quest.")
                            if not _G.AutoQuest then
                                Rayfield.Flags["AutoQuest"]:Set(true)
                            end
                        end

                    ---------------------------------------------------
                    -- Quest 2 — Artifact first, then Secret Fishing
                    elseif not r2 then
                        if step ~= 2 then
                            step = 2
                            print("[Element Quest] Quest 2 — Checking Temple Door and Artifact status before fishing...")

                            local function isTempleLocked()
                                local door = workspace:FindFirstChild("JUNGLE INTERACTIONS")
                                    and workspace["JUNGLE INTERACTIONS"].Doors
                                    and workspace["JUNGLE INTERACTIONS"].Doors:FindFirstChild("TempleDoor")
                                if door and door:FindFirstChild("DELETE_ME_AFTER_UNLOCK") then
                                    return true
                                end
                                return false
                            end

                            if isTempleLocked() then
                                print("[Element Quest] 🚪 Temple Door locked — starting Artifact Quest first...")

                                Rayfield.Flags["AutoQuestElement"]:Set(false)
                                _G.AutoQuestElement = false

                                Rayfield.Flags["AutoQuestArtifact"]:Set(true)
                                _G.AutoQuestArtifact = true

                                repeat task.wait(5) until not isTempleLocked()

                                print("[Element Quest] 🔓 Temple Door unlocked — switching back to Element Quest.")

                                Rayfield.Flags["AutoQuestArtifact"]:Set(false)
                                _G.AutoQuestArtifact = false

                                Rayfield.Flags["AutoQuestElement"]:Set(true)
                                _G.AutoQuestElement = true

                                return
                            end

                            print("[Element Quest] Quest 2 — Temple unlocked, fishing at Ancient Jungle...")
                            goToSpot(spotAncientJungle)
                            task.wait(3)
                            Rayfield.Flags["AutoFishing"]:Set(true)
                        end

                        if waitUntilRedeemed(2, 5) then
                            print("[Element Quest] ✅ Quest 2 redeemed! Proceeding to next quest...")
                        end

                    ---------------------------------------------------
                    -- Quest 3 — Sacred Temple Fishing
                    elseif not r3 then
                        if step ~= 3 then
                            step = 3
                            print("[Element Quest] Quest 3 — Checking Temple Door status before fishing...")

                            local function isTempleLocked()
                                local door = workspace:FindFirstChild("JUNGLE INTERACTIONS")
                                    and workspace["JUNGLE INTERACTIONS"].Doors
                                    and workspace["JUNGLE INTERACTIONS"].Doors:FindFirstChild("TempleDoor")
                                if door and door:FindFirstChild("DELETE_ME_AFTER_UNLOCK") then
                                    return true
                                end
                                return false
                            end

                            if isTempleLocked() then
                                print("[Element Quest] 🚪 Temple Door still locked — switching to Artifact Quest.")

                                Rayfield.Flags["AutoQuestElement"]:Set(false)
                                _G.AutoQuestElement = false

                                Rayfield.Flags["AutoQuestArtifact"]:Set(true)
                                _G.AutoQuestArtifact = true

                                repeat task.wait(5) until not isTempleLocked()

                                print("[Element Quest] 🔓 Temple Door unlocked — returning to Element Quest.")

                                Rayfield.Flags["AutoQuestArtifact"]:Set(false)
                                _G.AutoQuestArtifact = false

                                Rayfield.Flags["AutoQuestElement"]:Set(true)
                                _G.AutoQuestElement = true

                                return
                            end

                            print("[Element Quest] Temple Door unlocked — fishing at Sacred Temple...")
                            goToSpot(spotSacredTemple)
                            task.wait(3)
                            Rayfield.Flags["AutoFishing"]:Set(true)
                        end

                        if waitUntilRedeemed(3, 5) then
                            print("[Element Quest] ✅ Quest 3 redeemed! You can continue to Quest 4.")
                        end

                    ---------------------------------------------------
                    -- Quest 4 — Final behavior
                    else
                        if step ~= 4 then
                            step = 4
                            task.wait(3)
                            Rayfield.Flags["MegalodonHunt"]:Set(true)
                            Rayfield.Flags["AutoQuestElement"]:Set(false)
                            _G.AutoQuestElement = false
                            return
                        end
                    end
                end

                ---------------------------------------------------
                -- Safety: keep autofishing on while running
                if _G.AutoQuestElement and not Rayfield.Flags["AutoFishing"].CurrentValue then
                    Rayfield.Flags["AutoFishing"]:Set(true)
                end

                task.wait(2)
            end
        end)
    end
})

-- =========================================================
-- ⚙️ Auto Artifact Quest (Conditional Door Check)

QuestTab:CreateToggle({
    Name = "🔱 Auto Quest (Artifact Quest)",
    CurrentValue = false,
    Flag = "AutoQuestArtifact",
    Callback = function(state)
        _G.AutoQuestArtifact = state
        if not state then
            if Rayfield.Flags["AutoFishing"].CurrentValue then
                Rayfield.Flags["AutoFishing"]:Set(false)
            end
            return
        end

        -- ✅ Cek status pintu Sacred Temple
        local templeDoor = workspace:FindFirstChild("JUNGLE INTERACTIONS")
            and workspace["JUNGLE INTERACTIONS"].Doors
            and workspace["JUNGLE INTERACTIONS"].Doors:FindFirstChild("TempleDoor")

        if not (templeDoor and templeDoor:FindFirstChild("DELETE_ME_AFTER_UNLOCK")) then
            Rayfield:Notify({
                Title = "Info",
                Content = "Door Sacred Temple Opened.",
                Duration = 5,
                Image = "info"
            })
            Rayfield.Flags["AutoQuestArtifact"]:Set(false)
            _G.AutoQuestArtifact = false
            return
        end

        -- =========================================================
        task.spawn(function()
            local leverArtifacts = {
                {id = 266, name = "Crescent Artifact", cf = CFrame.lookAt(Vector3.new(1403.884,4.909,120.543), Vector3.new(1403.543,4.909,121.483))},
                {id = 265, name = "Arrow Artifact", cf = CFrame.lookAt(Vector3.new(877.822,3.976,-345.733), Vector3.new(876.827,3.976,-345.626))},
                {id = 271, name = "Hourglass Diamond Artifact", cf = CFrame.lookAt(Vector3.new(1478.453,3.935,-844.165), Vector3.new(1478.249,3.935,-843.186))},
                {id = 267, name = "Diamond Artifact", cf = CFrame.lookAt(Vector3.new(1838.371,5.282,-296.796), Vector3.new(1839.277,5.282,-297.220))}
            }

            local RemotePlaceLever = ReplicatedStorage
                .Packages._Index["sleitnick_net@0.2.0"]
                .net["RE/PlaceLeverItem"]

            local function hasArtifact(id)
                local items = Data.Data["Inventory"]["Items"]
                for _, item in pairs(items) do
                    if tonumber(item.Id or item.id) == id then
                        return true
                    end
                end
                return false
            end

            local function allArtifactsCollected()
                for _, art in ipairs(leverArtifacts) do
                    if not hasArtifact(art.id) then
                        return false
                    end
                end
                return true
            end

            while _G.AutoQuestArtifact do
                -- ❌ Jika pintu sudah terbuka di tengah jalan, hentikan
                local door = workspace:FindFirstChild("JUNGLE INTERACTIONS")
                    and workspace["JUNGLE INTERACTIONS"].Doors
                    and workspace["JUNGLE INTERACTIONS"].Doors:FindFirstChild("TempleDoor")
                if not (door and door:FindFirstChild("DELETE_ME_AFTER_UNLOCK")) then
                    Rayfield:Notify({
                        Title = "Info",
                        Content = "Pintu Sacred Temple sudah terbuka.",
                        Duration = 5,
                        Image = "info"
                    })
                    Rayfield.Flags["AutoQuestArtifact"]:Set(false)
                    _G.AutoQuestArtifact = false
                    break
                end

                if allArtifactsCollected() then
                    for _, art in ipairs(leverArtifacts) do
                        RemotePlaceLever:FireServer(art.name)
                        task.wait(3)
                    end
                    break
                end

                for _, art in ipairs(leverArtifacts) do
                    if not _G.AutoQuestArtifact then break end
                    if not hasArtifact(art.id) then
                        goToSpot(art.cf)
                        task.wait(2)
                        Rayfield.Flags["AutoFishing"]:Set(true)
                        repeat
                            task.wait(5)
                        until hasArtifact(art.id) or not _G.AutoQuestArtifact
                    end
                end
                task.wait(1)
            end
        end)
    end,
})

-- =========================================================
-- Quest Info (Deep Sea) - GUI + Data Redeemed

local Section = QuestTab:CreateSection("Deep Sea Quest")

local QuestInfo = QuestTab:CreateParagraph({
    Title = "Deep Sea Quest",
    Content = "Loading quest info..."
})

-- References (GUI)
local QuestFolder = workspace["!!! DEPENDENCIES"]["QuestTrackers"]["Deep Sea Tracker"].Board.Gui.Content
local Header = QuestFolder.Header
local Label1 = QuestFolder.Label1
local Label2 = QuestFolder.Label2
local Label3 = QuestFolder.Label3
local Label4 = QuestFolder.Label4
local ProgressLabel = QuestFolder.Progress.ProgressLabel

-- Helper: cari table Quests di Data.Data.DeepSea (fleksibel)
local function getDeepSeaQuests()
    local DS = Data and Data.Data and Data.Data.DeepSea
    if not DS then return nil end

    -- coba beberapa path yang paling umum
    local candidates = {
        DS.Available and DS.Available.Forever and DS.Available.Forever.Quests,
        DS.Available and DS.Available.Daily and DS.Available.Daily.Quests,
        DS.Available and DS.Available.Weekly and DS.Available.Weekly.Quests,
        DS.Quests,
    }

    for _, q in ipairs(candidates) do
        if q ~= nil then
            return q
        end
    end

    return nil
end

local function redeemedText(Q, i)
    if not Q then return "..." end
    local q = Q[i] or Q[tostring(i)]
    local r = q and q.Redeemed
    if r == nil then return "..." end
    return tostring(r):upper() -- TRUE / FALSE
end

task.spawn(function()
    while true do
        pcall(function()
            local Q = getDeepSeaQuests()

            QuestInfo:Set({
                Title = Header.Text,
                Content = string.format([[
%s = %s
%s = %s
%s = %s
%s = %s

%s
                ]],
                Label1.Text, redeemedText(Q, 1),
                Label2.Text, redeemedText(Q, 2),
                Label3.Text, redeemedText(Q, 3),
                Label4.Text, redeemedText(Q, 4),
                ProgressLabel.Text
                )
            })
        end)

        RunService.task.wait(0.1)
    end
end)

-- =========================================================
-- Auto Quest Deep Sea (Redeemed-based)

local bestSpotTreasure = CFrame.lookAt(
    Vector3.new(-3563.683349609375, -279.07421875, -1679.2740478515625),
    Vector3.new(-3563.683349609375, -279.07421875, -1679.2740478515625) + Vector3.new(-0.6082443, 0, 0.7937499)
)

local bestSpotSysyphus = CFrame.lookAt(
    Vector3.new(-3764.026, -135.074, -994.416),
    Vector3.new(-3764.026, -135.074, -994.416) + Vector3.new(0.694, 0, 0.720)
)

local function waitUntilDeepSeaRedeemed(i)
    while _G.AutoQuestDeepSea do
        local r = isDeepSeaRedeemed(i)
        if r == true then return true end
        task.wait(0.1) -- realtime-ish
    end
    return false
end

local function isDeepSeaRedeemed(i)
    local Q = getDeepSeaQuests()
    if not Q then return nil end
    local q = Q[i] or Q[tostring(i)]
    if not q or q.Redeemed == nil then return nil end
    return q.Redeemed == true
end

QuestTab:CreateToggle({
    Name = "⚡ Auto Quest (Deep Sea)",
    CurrentValue = false,
    Flag = "AutoQuestDeepSea",
    Callback = function(Value)
        _G.AutoQuestDeepSea = Value

        if not Value then
            if Rayfield.Flags["AutoFishing"].CurrentValue then
                Rayfield.Flags["AutoFishing"]:Set(false)
            end
            return
        end

        task.spawn(function()
            local currentStep = 0

            while _G.AutoQuestDeepSea do
                local r1 = isDeepSeaRedeemed(1)
                local r2 = isDeepSeaRedeemed(2)
                local r3 = isDeepSeaRedeemed(3)
                local r4 = isDeepSeaRedeemed(4)

                -- data belum ready
                if r1 == nil or r2 == nil or r3 == nil or r4 == nil then
                    task.wait(1)
                else
                    -- sama seperti logic lama p1/p2/p3 < 100,
                    -- tapi sekarang: kalau belum redeemed berarti belum selesai
                    if not r1 then
                        if currentStep ~= 1 then
                            currentStep = 1
                            goToSpot(bestSpotTreasure)
                        end

                    elseif not r2 then
                        if currentStep ~= 2 then
                            currentStep = 2
                            goToSpot(bestSpotSysyphus)
                        end

                    elseif not r3 then
                        if currentStep ~= 3 then
                            currentStep = 3
                            goToSpot(bestSpotSysyphus)
                        end

                    else
                        if currentStep ~= 4 then
                            currentStep = 4
                            goToSpot(bestSpotSysyphus)
                        end
                    end

                    task.wait(5)
                end
            end
        end)
    end
})

-- =========================================================
-- SHOP

local Section = ShopTab:CreateSection("Buy Rod")

--// Data Rods
local rods = {
    ["Bamboo Rod (12M)"] = 258,
    ["Angler Rod (8M)"] = 168,
    ["Ares Rod (3M)"] = 126,
    ["Astral Rod (1M)"] = 5,
    ["Carbon Rod (900)"] = 76,
    ["Chrome Rod (437K)"] = 7,
    ["Demascus Rod (3K)"] = 77,
    ["Grass Rod (1.5K)"] = 85,
    ["Ice Rod (5K)"] = 78,
    ["Luck Rod (350)"] = 79,
    ["Lucky Rod (15K)"] = 4,
    ["Midnight Rod (50K)"] = 80,
    ["Steampunk Rod (215K)"] = 6,
}

--// Referensi ke RemoteFunction dengan error handling
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local success, PurchaseFishingRod = pcall(function()
    return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseFishingRod")
end)
if not success then
    warn("Gagal menemukan RemoteFunction: " .. tostring(PurchaseFishingRod))
    return
end

--// Buat Dropdown untuk memilih rod
local Dropdown = ShopTab:CreateDropdown({
    Name = "Select Fishing Rod",
    Options = {
        "Bamboo Rod (12M)",
        "Angler Rod (8M)",
        "Ares Rod (3M)",
        "Astral Rod (1M)",
        "Carbon Rod (900)",
        "Chrome Rod (437K)",
        "Demascus Rod (3K)",
        "Grass Rod (1.5K)",
        "Ice Rod (5K)",
        "Luck Rod (350)",
        "Lucky Rod (15K)",
        "Midnight Rod (50K)",
        "Steampunk Rod (215K)",
    },
    CurrentOption = {"Bamboo Rod (12M)"}, -- Rayfield menggunakan array untuk CurrentOption
    Callback = function(selectedOption)
        local selectedRodName = selectedOption[1] -- Ambil string dari array
        local rodId = rods[selectedRodName]
        if rodId then
            print("Selected rod: " .. selectedRodName .. " with ID: " .. rodId)
        else
            print("Error: Rod not found for " .. tostring(selectedRodName))
        end
    end,
})

--// Buat Button untuk membeli rod
local Button = ShopTab:CreateButton({
    Name = "Buy Selected Rod",
    Callback = function()
        local selectedOption = Dropdown.CurrentOption -- CurrentOption adalah array
        local selectedRodName = selectedOption[1] -- Ambil string dari array
        local rodId = rods[selectedRodName]
        if rodId then
            local success, response = pcall(function()
                return PurchaseFishingRod:InvokeServer(rodId) -- Langsung kirim rodId, tanpa unpack
            end)
            if success then
                Rayfield:Notify({
                    Title = "Purchase Result",
                    Content = "Rod purchased successfully!",
                    Image = "shopping-cart",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "Purchase Failed",
                    Content = "Error: " .. tostring(response),
                    Image = "shopping-cart",
                    Duration = 3,
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No rod selected or invalid rod: " .. tostring(selectedRodName),
                Image = "shopping-cart",
                Duration = 3,
            })
        end
    end,
})

local Section = ShopTab:CreateSection("Buy Bobber")

--// Data Bobbers
local bobbers = {
    ["Floral Bait (4M)"] = 20,
    ["Aether Bait (3.7M)"] = 16,
    ["Chroma Bait (290K)"] = 6,
    ["Corrupt Bait (1.15M)"] = 15,
    ["Dark Matter Bait (630K)"] = 8,
    ["Luck Bait (1K)"] = 2,
    ["Midnight Bait (3K)"] = 3,
    ["Nature Bait (83.5K)"] = 17,
    ["Topwater (100)"] = 10,
}

--// Referensi ke RemoteFunction dengan error handling
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local success, PurchaseBobber = pcall(function()
    return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseBait")
end)
if not success then
    warn("Gagal menemukan RemoteFunction: " .. tostring(PurchaseBobber))
    return
end

--// Buat Dropdown untuk memilih bobber
local Dropdown = ShopTab:CreateDropdown({
    Name = "Select Bobber",
    Options = {
        "Floral Bait (4M)",
        "Aether Bait (3.7M)",
        "Chroma Bait (290K)",
        "Corrupt Bait (1.15M)",
        "Dark Matter Bait (630K)",
        "Luck Bait (1K)",
        "Midnight Bait (3K)",
        "Nature Bait (83.5K)",
        "Topwater (100)",
    },
    CurrentOption = {"Floral Bait (4M)"}, -- Rayfield menggunakan array untuk CurrentOption
    Callback = function(selectedOption)
        local selectedBobberName = selectedOption[1] -- Ambil string dari array
        local bobberId = bobbers[selectedBobberName]
        if bobberId then
            print("Selected bobber: " .. selectedBobberName .. " with ID: " .. bobberId)
        else
            print("Error: Bobber not found for " .. tostring(selectedBobberName))
        end
    end,
})

--// Buat Button untuk membeli bobber
local Button = ShopTab:CreateButton({
    Name = "Buy Selected Bobber",
    Callback = function()
        local selectedOption = Dropdown.CurrentOption -- CurrentOption adalah array
        local selectedBobberName = selectedOption[1] -- Ambil string dari array
        local bobberId = bobbers[selectedBobberName]
        if bobberId then
            local success, response = pcall(function()
                return PurchaseBobber:InvokeServer(bobberId) -- Langsung kirim bobberId, tanpa unpack
            end)
            if success then
                Rayfield:Notify({
                    Title = "Purchase Result",
                    Content = "Bobber purchased successfully!",
                    Image = "shopping-cart",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "Purchase Failed",
                    Content = "Error: " .. tostring(response),
                    Image = "shopping-cart",
                    Duration = 3,
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No bobber selected or invalid bobber: " .. tostring(selectedBobberName),
                Image = "shopping-cart",
                Duration = 3,
            })
        end
    end,
})

local Section = ShopTab:CreateSection("Buy Traveling Merchant")

local RF = game:GetService("ReplicatedStorage")
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
    :WaitForChild("RF/PurchaseMarketItem")

-- Mapping nama item -> ID server
local ItemPurchaseIds = {
    ["Mutation Totem"]      = 8,
    ["Shiny Totem"]         = 7,
    ["Luck Totem"]          = 5,
    ["Royal Bait"]          = 4,
    ["Singularity Bait"]    = 3,
    ["Hazmat Rod"]          = 2,
    ["Fluorescent Rod"]     = 1,
}

local selectedId = nil

-- Dropdown pilih item
ShopTab:CreateDropdown({
    Name = "Select Merchant Item",
    Options = {
        "Luck Totem",
        "Shiny Totem",
        "Mutation Totem",
        "Royal Bait ",
        "Singularity Bait",
        "Hazmat Rod",
        "Fluorescent Rod",
    },
    CurrentOption = { "Select item" },
    MultipleOptions = false,
    Callback = function(opt)
        local choice = type(opt) == "table" and opt[1] or opt
        selectedId = ItemPurchaseIds[choice]
    end,
})

-- Button buy item yang dipilih
ShopTab:CreateButton({
    Name = "Buy Selected Item",
    Callback = function()
        if not selectedId then
            Rayfield:Notify({
                Title = "Purchase Failed",
                Content = "Please select an item first.",
                Image = "circle-x",
                Duration = 3
            })
            return
        end

        local ok, res = pcall(function()
            return RF:InvokeServer(selectedId)
        end)

        if ok and res then
            Rayfield:Notify({
                Title = "Purchase Successful",
                Content = "You have successfully purchased the item.",
                Image = "shopping-cart",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Purchase Failed",
                Content = "Item is not available in merchant or you do not have enough currency.",
                Image = "circle-x",
                Duration = 4
            })
        end
    end,
})


local Section = ShopTab:CreateSection("Buy Boat")

--// Data Boats
local boats = {
    ["Fishing Boat (180K)"] = 6,
    ["Highfield Boat (25K)"] = 4,
    ["Jetski (7.5K)"] = 3,
    ["Kayak (1.1K)"] = 2,
    ["Mini Yacht (1.2M)"] = 14,
    ["Small Boat (300)"] = 1,
    ["Speed Boat (70K)"] = 5,
}

--// Referensi ke RemoteFunction dengan error handling
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local success, PurchaseBoat = pcall(function()
    return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseBoat")
end)
if not success then
    warn("Gagal menemukan RemoteFunction: " .. tostring(PurchaseBoat))
    return
end

--// Buat Dropdown untuk memilih boat
local Dropdown = ShopTab:CreateDropdown({
    Name = "Select Boat",
    Options = {
        "Fishing Boat (180K)",
        "Highfield Boat (25K)",
        "Jetski (7.5K)",
        "Kayak (1.1K)",
        "Mini Yacht (1.2M)",
        "Small Boat (300)",
        "Speed Boat (70K)",
    },
    CurrentOption = {"Fishing Boat (180K)"}, -- Rayfield menggunakan array untuk CurrentOption
    Callback = function(selectedOption)
        local selectedBoatName = selectedOption[1] -- Ambil string dari array
        local boatId = boats[selectedBoatName]
        if boatId then
            print("Selected boat: " .. selectedBoatName .. " with ID: " .. boatId)
        else
            print("Error: Boat not found for " .. tostring(selectedBoatName))
        end
    end,
})

--// Buat Button untuk membeli boat
local Button = ShopTab:CreateButton({
    Name = "Buy Selected Boat",
    Callback = function()
        local selectedOption = Dropdown.CurrentOption -- CurrentOption adalah array
        local selectedBoatName = selectedOption[1] -- Ambil string dari array
        local boatId = boats[selectedBoatName]
        if boatId then
            local success, response = pcall(function()
                return PurchaseBoat:InvokeServer(boatId) -- Langsung kirim boatId, sesuai dengan remote spy
            end)
            if success then
                Rayfield:Notify({
                    Title = "Purchase Result",
                    Content = "Boat purchased successfully!",
                    Image = "ship",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "Purchase Failed",
                    Content = "Error: " .. tostring(response),
                    Image = "ship",
                    Duration = 3,
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No boat selected or invalid boat: " .. tostring(selectedBoatName),
                Image = "ship",
                Duration = 3,
            })
        end
    end,
})

local Section = ShopTab:CreateSection("Buy Gear")

--// Data Gears
local gears = {
    ["Fishing Radar (3K)"] = 81,
    ["Diving Gear (75K)"] = 105,
}

--// Referensi ke RemoteFunction dengan error handling
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local success, PurchaseGear = pcall(function()
    return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseGear")
end)
if not success then
    warn("Gagal menemukan RemoteFunction: " .. tostring(PurchaseGear))
    return
end

--// Buat Dropdown untuk memilih gear
local Dropdown = ShopTab:CreateDropdown({
    Name = "Select Gear",
    Options = {
        "Fishing Radar (3K)",
        "Diving Gear (75K)",
    },
    CurrentOption = {"Fishing Radar (3K)"}, -- Rayfield menggunakan array untuk CurrentOption
    Callback = function(selectedOption)
        local selectedGearName = selectedOption[1] -- Ambil string dari array
        local gearId = gears[selectedGearName]
        if gearId then
            print("Selected gear: " .. selectedGearName .. " with ID: " .. gearId)
        else
            print("Error: Gear not found for " .. tostring(selectedGearName))
        end
    end,
})

--// Buat Button untuk membeli gear
local Button = ShopTab:CreateButton({
    Name = "Buy Selected Gear",
    Callback = function()
        local selectedOption = Dropdown.CurrentOption -- CurrentOption adalah array
        local selectedGearName = selectedOption[1] -- Ambil string dari array
        local gearId = gears[selectedGearName]
        if gearId then
            local success, response = pcall(function()
                return PurchaseGear:InvokeServer(gearId) -- Langsung kirim gearId
            end)
            if success then
                Rayfield:Notify({
                    Title = "Purchase Result",
                    Content = "Gear purchased successfully!",
                    Image = "shopping-cart",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "Purchase Failed",
                    Content = "Error: " .. tostring(response),
                    Image = "shopping-cart",
                    Duration = 3,
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No gear selected or invalid gear: " .. tostring(selectedGearName),
                Image = "shopping-cart",
                Duration = 3,
            })
        end
    end,
})
--[[
local Section = ShopTab:CreateSection("Buy Weather Event")

--// Data Weather Events
local weatherOptions = {
    "Wind",
    "Cloudy",
    "Snow",
    "Storm",
    "Radiant",
    "Shark Hunt"
}

--// Referensi ke RemoteFunction dengan error handling
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local success, PurchaseWeatherEvent = pcall(function()
    return ReplicatedStorage:WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net")
        :WaitForChild("RF/PurchaseWeatherEvent")
end)
if not success then
    warn("Gagal menemukan RemoteFunction: " .. tostring(PurchaseWeatherEvent))
    return
end

--// Variabel untuk mengontrol loop
local autoLoopRunning = false

--// Buat tiga Dropdown untuk memilih weather
local Dropdown1 = ShopTab:CreateDropdown({
    Name = "Weather 1",
    Options = weatherOptions,
    CurrentOption = nil,
    Callback = function(selectedOption)
        print("Selected Weather 1: " .. selectedOption[1])
    end,
})

local Dropdown2 = ShopTab:CreateDropdown({
    Name = "Weather 2",
    Options = weatherOptions,
    CurrentOption = nil,
    Callback = function(selectedOption)
        print("Selected Weather 2: " .. selectedOption[1])
    end,
})

local Dropdown3 = ShopTab:CreateDropdown({
    Name = "Weather 3",
    Options = weatherOptions,
    CurrentOption = nil,
    Callback = function(selectedOption)
        print("Selected Weather 3: " .. selectedOption[1])
    end,
})

--// Buat Textbox untuk interval looping (detik)
local TextBox = ShopTab:CreateInput({
    Name = "Loop Interval (Seconds)",
    PlaceholderText = "Default 5min",
    RemoveTextAfterFocusLost = false,
    Value = "300",
    Callback = function(value)
        local interval = tonumber(value)
        if not interval or interval <= 0 then
            TextBox:Set("300")
        end
    end,
})

--// Fungsi untuk mendapatkan opsi yang valid
local function getValidOptions()
    local selected1 = Dropdown1.CurrentOption[1]
    local selected2 = Dropdown2.CurrentOption[1]
    local selected3 = Dropdown3.CurrentOption[1]
    local validOptions = {}
    for _, option in pairs({selected1, selected2, selected3}) do
        if option and option ~= "" then
            table.insert(validOptions, option)
        end
    end
    return validOptions
end

--// Fungsi untuk membeli weather
local function buyWeather(validOptions)
    for _, weather in pairs(validOptions) do
        local success, response = pcall(function()
            return PurchaseWeatherEvent:InvokeServer(weather)
        end)
        if success then
            Rayfield:Notify({
                Title = "Auto Purchase Result",
                Content = weather .. " activated successfully!",
                Image = "cloudy",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "Auto Purchase Failed",
                Content = "Error for " .. weather .. ": " .. tostring(response),
                Image = "cloudy",
                Duration = 3,
            })
        end
    end
end

--// Buat Toggle untuk auto buy weather loop
local Toggle = ShopTab:CreateToggle({
    Name = "Auto Buy Weather Loop",
    CurrentValue = false,
    Flag = "AutoWeatherLoop",
    Callback = function(state)
        if state then
            autoLoopRunning = true
            spawn(function()
                while autoLoopRunning do
                    local validOptions = getValidOptions()
                    if #validOptions > 0 then
                        buyWeather(validOptions)
                    else
                        Rayfield:Notify({
                            Title = "Error",
                            Content = "No weather events selected.",
                            Duration = 3,
                        })
                        autoLoopRunning = false
                        Toggle:Set(false)
                        break
                    end

                    local interval = tonumber(TextBox.CurrentValue) or 300
                    wait(interval)
                end
            end)
        else
            autoLoopRunning = false
        end
    end,
})

--// Buat Button untuk membeli weather secara manual
local Button = ShopTab:CreateButton({
    Name = "Buy Selected Weather",
    Callback = function()
        local validOptions = getValidOptions()
        if #validOptions > 0 then
            buyWeather(validOptions)
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No weather events selected.",
                Duration = 3,
            })
        end
    end,
})
]]

-- =========================================================
-- Teleport to Islands
local Section = TeleportTab:CreateSection("Teleport to Islands")

--// Data Lokasi Teleport
local TeleportLocations = {
    ["Coral Reefs"] = {
        Pos = Vector3.new(-3021.346435546875, 2.5119528770446777, 2260.48095703125),
        Look = Vector3.new(0.10786788910627365, 2.4720577584957937e-08, -0.9941652417182922)
    },
    ["Crater Island"] = {
        Pos = Vector3.new(1010.010009765625, 22.573793411254883, 5078.451171875),
        Look = Vector3.new(3.020463924547495e-13, 7.394982048936072e-08, -1)
    },
    ["Estoric Island"] = {
        Pos = Vector3.new(2024.432373046875, 27.397220611572266, 1392.0283203125),
        Look = Vector3.new(0.986020141474762, -3.385313718240468e-08, -0.16662057836341858)
    },
    ["Estoric Depths"] = {
        Pos = Vector3.new(3193.617431640625, -1302.7548828125, 1419.4150390625),
        Look = Vector3.new(0.9179911071471908, -4.51204654361085e-08, -0.39660102128982544)
    },
    ["Kohana"] = {
        Pos = Vector3.new(-655.4415893554688, 16.03544807434082, 596.2943115234375),
        Look = Vector3.new(-0.9999969601631165, -2.061331549896249e-08, -0.002453863482340364)
    },
    ["Kohana Volcano"] = {
        Pos = Vector3.new(-594.9712524414062, 40.86043453216553, 149.10906982421875),
        Look = Vector3.new(-7.206466109934e-14, 7.847197336374734e-10, -1)
    },
    ["Tropical Grave"] = {
        Pos = Vector3.new(-2038.6060791015625, 6.2608160972595215, 3665.863037109375),
        Look = Vector3.new(-0.7323039779167175, 1.0251421400065321e-07, 0.6809488534927368)
    },
    ["Fisherman Island"] = {
        Pos = Vector3.new(14.251019477844238, 17.03352165222168, 2892.7509765625),
        Look = Vector3.new(-0.000957381154876023, 1.6343286723952133e-09, -0.9999995231628418)
    },
    ["Treasure Room"] = {
        Pos = Vector3.new(-3599.833251953125, -266.57421875, -1563.982421875),
        Look = Vector3.new(0.003540437202900648, 7.721693151552245e-08, -0.9999937415122986)
    },
    ["Sysyphus Statue"] = {
        Pos = Vector3.new(-3694.119384765625, -135.5744171142578, -1037.4427490234375),
        Look = Vector3.new(-0.25389963388442993, -5.699773452160393e-08, 0.9672305583953857)
    }
}

--// Buat Dropdown untuk memilih lokasi
local Dropdown = TeleportTab:CreateDropdown({
    Name = "Select Teleport Location",
    Options = {
        "Coral Reefs",
        "Crater Island",
        "Estoric Island",
        "Estoric Depths",
        "Kohana",
        "Kohana Volcano",
        "Tropical Grave",
        "Fisherman Island",
        "Treasure Room",
        "Sysyphus Statue",
    },
    CurrentOption = {"Fisherman Island"}, -- Rayfield menggunakan array untuk CurrentOption
    Callback = function(selectedOption)
        local selectedLocationName = selectedOption[1] -- Ambil string dari array
        local locationData = TeleportLocations[selectedLocationName]
    end,
})

--// Buat Button untuk teleportasi
local Button = TeleportTab:CreateButton({
    Name = "Teleport to Selected Location",
    Callback = function()
        local selectedOption = Dropdown.CurrentOption -- CurrentOption adalah array
        local selectedLocationName = selectedOption[1] -- Ambil string dari array
        local locationData = TeleportLocations[selectedLocationName]
        if locationData then
            local success, response = pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = character.HumanoidRootPart
                    rootPart.CFrame = CFrame.new(locationData.Pos, locationData.Pos + locationData.Look)
                else
                    error("Character or HumanoidRootPart not found")
                end
            end)
            if success then
                Rayfield:Notify({
                    Title = "Teleport Result",
                    Content = "Teleported to " .. selectedLocationName .. " successfully!",
                    Image = "tree-palm",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "Teleport Failed",
                    Content = "Error: " .. tostring(response),
                    Image = "tree-palm",
                    Duration = 3,
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No location selected or invalid location: " .. tostring(selectedLocationName),
                Image = "tree-palm",
                Duration = 3,
            })
        end
    end,
})

local Section = TeleportTab:CreateSection("Teleport to ???")

--// Referensi ke lokasi EnchantLocation
local enchantLocation = workspace:WaitForChild("! ENCHANTING ALTAR !"):WaitForChild("EnchantLocation")
if not enchantLocation then
    warn("EnchantLocation not found in workspace['! ENCHANTING ALTAR !']")
    return
end

--// Referensi ke lokasi EnchantLocation
local secondEnchant = workspace:WaitForChild("! SECOND ENCHANTING ALTAR !"):WaitForChild("EnchantLocation")
if not secondEnchant then
    warn("EnchantLocation not found in workspace['! SECOND ENCHANTING ALTAR !']")
    return
end

--// Buat Button untuk teleportasi
local Button = TeleportTab:CreateButton({
    Name = "Teleport to Enchant Altar",
    Callback = function()
        if enchantLocation then
            local success, response = pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = character.HumanoidRootPart
                    rootPart.CFrame = CFrame.new(enchantLocation.Position, enchantLocation.Position + rootPart.CFrame.LookVector) -- Gunakan arah hadap saat ini
                else
                    error("Character or HumanoidRootPart not found")
                end
            end)
            if success then
                Rayfield:Notify({
                    Title = "Teleport Result",
                    Content = "Teleported to Enchanting Altar successfully!",
                    Image = "map-pin",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "Teleport Failed",
                    Content = "Error: " .. tostring(response),
                    Image = "map-pin",
                    Duration = 3,
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Location not found: Enchanting Altar",
                Image = "map-pin",
                Duration = 3,
            })
        end
    end,
})

--// Buat Button untuk teleportasi
local Button = TeleportTab:CreateButton({
    Name = "Teleport to Second Enchant Altar",
    Callback = function()
        if secondEnchant then
            local success, response = pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = character.HumanoidRootPart
                    rootPart.CFrame = CFrame.new(secondEnchant.Position, secondEnchant.Position + rootPart.CFrame.LookVector) -- Gunakan arah hadap saat ini
                else
                    error("Character or HumanoidRootPart not found")
                end
            end)
            if success then
                Rayfield:Notify({
                    Title = "Teleport Result",
                    Content = "Teleported to Enchanting Altar successfully!",
                    Image = "map-pin",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "Teleport Failed",
                    Content = "Error: " .. tostring(response),
                    Image = "map-pin",
                    Duration = 3,
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Location not found: Enchanting Altar",
                Image = "map-pin",
                Duration = 3,
            })
        end
    end,
})

--======Traveling Merchant=======--
local NPCs = ReplicatedStorage:WaitForChild("NPC")

-- Ambil NPC Alien Merchant
local AlienMerchant = NPCs:WaitForChild("Alien Merchant")

-- kalau model, set PrimaryPart
if AlienMerchant:IsA("Model") and not AlienMerchant.PrimaryPart then
    AlienMerchant.PrimaryPart = AlienMerchant:FindFirstChildWhichIsA("BasePart")
end

-- // Button
TeleportTab:CreateButton({
    Name = "Teleport ke Alien Merchant",
    Callback = function()
        if not AlienMerchant then
            Rayfield:Notify({
                Title = "Error",
                Content = "NPC Alien Merchant tidak ditemukan!",
                Image = "map-pin",
                Duration = 3,
            })
            return
        end

        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")

        if not hrp then
            Rayfield:Notify({
                Title = "Teleport Failed",
                Content = "HumanoidRootPart tidak ditemukan!",
                Image = "map-pin",
                Duration = 3,
            })
            return
        end

        local success, err = pcall(function()
            local targetPos
            if AlienMerchant:IsA("Model") and AlienMerchant.PrimaryPart then
                targetPos = AlienMerchant.PrimaryPart.Position
            elseif AlienMerchant:IsA("BasePart") then
                targetPos = AlienMerchant.Position
            else
                error("Alien Merchant tidak punya BasePart untuk teleport")
            end

            -- teleport dengan mempertahankan arah hadap
            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 0, 0), targetPos + hrp.CFrame.LookVector)
        end)

        if success then
            Rayfield:Notify({
                Title = "Teleport Result",
                Content = "Berhasil teleport ke Alien Merchant!",
                Image = "map-pin",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "Teleport Failed",
                Content = tostring(err),
                Image = "map-pin",
                Duration = 3,
            })
        end
    end,
})
--[[
local Section = TeleportTab:CreateSection("Teleport to Machines")

--// Data Lokasi Mesin
local MachineLocations = {
    ["Spin Wheel"] = {
        Pos = Vector3.new(-139.68914794921875, 17.03361204956055, 2824.72314453125),
        Look = Vector3.new(-0.9993935227394104, -1.45441614307628e-08, 0.034821413457393646)
    },
    ["Luck Machine"] = {
        Pos = Vector3.new(13.64661979675293, 17.15852165222168, 2833.786376953125),
        Look = Vector3.new(0.01195607241243124, 4.777682249823556e-08, 0.9999285340309143)
    },
    ["Weather Machine"] = {
        Pos = Vector3.new(-1499.1246337890625, 6.499999523162842, 1892.8677978515625),
        Look = Vector3.new(0.4844721555709839, 8.364601459253548e-08, -0.8748067021369934)
    }
}

--// Buat Dropdown untuk memilih lokasi
local Dropdown = TeleportTab:CreateDropdown({
    Name = "Select Machine Location",
    Options = {
        "Spin Wheel",
        "Luck Machine",
        "Weather Machine",
    },
    CurrentOption = {"Spin Wheel"}, -- Rayfield menggunakan array untuk CurrentOption
    Callback = function(selectedOption)
        local selectedLocationName = selectedOption[1] -- Ambil string dari array
        local locationData = MachineLocations[selectedLocationName]
    end,
})

--// Buat Button untuk teleportasi
local Button = TeleportTab:CreateButton({
    Name = "Teleport to Selected Machine",
    Callback = function()
        local selectedOption = Dropdown.CurrentOption -- CurrentOption adalah array
        local selectedLocationName = selectedOption[1] -- Ambil string dari array
        local locationData = MachineLocations[selectedLocationName]
        if locationData then
            local success, response = pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = character.HumanoidRootPart
                    rootPart.CFrame = CFrame.new(locationData.Pos, locationData.Pos + locationData.Look)
                else
                    error("Character or HumanoidRootPart not found")
                end
            end)
            if success then
                Rayfield:Notify({
                    Title = "Teleport Result",
                    Content = "Teleported to " .. selectedLocationName .. " successfully!",
                    Image = "map-pinned",
                    Duration = 3,
                })
            else
                Rayfield:Notify({
                    Title = "Teleport Failed",
                    Content = "Error: " .. tostring(response),
                    Image = "map-pinned",
                    Duration = 3,
                })
            end
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No location selected or invalid location: " .. tostring(selectedLocationName),
                Image = "map-pinned",
                Duration = 3,
            })
        end
    end,
})
]]
-- =========================================================
-- Config
task.defer(function()
   Rayfield:LoadConfiguration()
   Rayfield:Notify({
       Title = "Config Loaded",
       Content = "Configuration has been automatically loaded for " .. LocalPlayer.Name,
       Duration = 3
   })
end)
