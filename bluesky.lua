local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

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


local MainTab = Window:CreateTab("Main", "home")
local AutoTab = Window:CreateTab ("Auto", "repeat")
local QuestTab = Window:CreateTab("Quest", "list-checks")
local ShopTab = Window:CreateTab("Shop", "shopping-cart")
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
local ConfigTab = Window:CreateTab("Config", "cog")

--// ⚡ Remote references
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
local UnequipToolRemote     = netRoot:WaitForChild("RE/UnequipToolFromHotbar")

--// UI Section
local Section = MainTab:CreateSection("🎣 Auto Fishing")

--// Fungsi utama
local function equipRod()
    EquipToolRemote:FireServer(1) -- slot 1
end

local function unequipRod()
    UnequipToolRemote:FireServer()
end

local function startFishing()
    ChargeRodRemote:InvokeServer(tick())
    RequestMiniGameRemote:InvokeServer(40, 1)
end

-- State
local spamThread
local autoFishConn
local safetyThread
local lastCatch = tick()

--// Toggle
MainTab:CreateToggle({
    Name = "Auto Fishing",
    CurrentValue = false,
    Flag = "AutoFishing",
    Callback = function(Value)
        _G.AutoFish = Value

        if not Value then
            -- 🔴 Stop semua
            if spamThread then task.cancel(spamThread) spamThread = nil end
            if autoFishConn then autoFishConn:Disconnect() autoFishConn = nil end
            if safetyThread then task.cancel(safetyThread) safetyThread = nil end
            return
        end

        -- ✅ Step 1: Equip & mulai fishing
        equipRod()
        task.wait(0.3)
        startFishing()
        lastCatch = tick()

        -- ✅ Step 2: Spam FishingCompleted
        spamThread = task.spawn(function()
            while _G.AutoFish do
                pcall(function()
                    FishingCompleteRemote:FireServer()
                end)
                task.wait(0.1)
            end
        end)

        -- ✅ Step 3: Saat dapat ikan → ulang siklus
        autoFishConn = FishCaughtRemote.OnClientEvent:Connect(function()
            if not _G.AutoFish then return end
            lastCatch = tick()

            task.spawn(function()
                -- urutan aman
                unequipRod()
                task.wait(0.1) -- biar server sempet proses unequip
                equipRod()
                task.wait(0.1) -- biar rod benar-benar ke-equip
                startFishing()
                lastCatch = tick()
            end)
        end)

        -- ✅ Step 4: Safety loop (jaga kalau stuck)
        safetyThread = task.spawn(function()
            while _G.AutoFish do
                if tick() - lastCatch > 10 then
                    -- restart fishing kalau lama gak dapat ikan
                    unequipRod()
                    task.wait(0.1)
                    equipRod()
                    task.wait(0.1)
                    startFishing()
                    lastCatch = tick()
                end
                task.wait(1)
            end
        end)
    end
})

-- =========================================================
-- Reset Character

MainTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        Rayfield.Flags["AutoFishing"]:Set(false)
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
        task.wait(0.5) -- kasih delay kecil biar loading char selesai
        newHrp.CFrame = lastPos
    end
})

MainTab:CreateButton({
    Name = "Reset Fishing",
    Callback = function()
        Rayfield.Flags["AutoFishing"]:Set(false)
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
        task.wait(0.5) -- kasih delay kecil biar loading char selesai
        newHrp.CFrame = lastPos
        task.wait(1)
        Rayfield.Flags["AutoFishing"]:Set(true)
    end
})

local Section = MainTab:CreateSection("Auto Events Megalodon, Ghost Worm, Wormhole, Ghost Shark Hunt, Shark Hunt")

--// 📍 Best Spot lokasi default
local bestSpotCFrame = CFrame.lookAt(
    Vector3.new(-3764.026, -135.074, -994.416),
    Vector3.new(-3764.026, -135.074, -994.416) + Vector3.new(0.694, -8.57e-08, 0.720)
)

local player = game.Players.LocalPlayer

--// 🔎 Cari Props apapun
local function getAnyProp()
    local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
    if not menuRings then return nil end
    local props = menuRings:FindFirstChild("Props")
    if not props then return nil end

    for _, child in ipairs(props:GetChildren()) do
        local part = child:FindFirstChildWhichIsA("BasePart", true)
        if part then
            return part.CFrame
        end
    end

    return nil -- ❌ ga ada Props
end

--// 🪵 Platform Props
local propsPlatform
local activeMode = "BestSpot"
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

local function safeTeleport(cframeTarget)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cframeTarget + Vector3.new(0, 25, 0)
    end
end

--// 🌀 Start / Stop Loop
local function startAutoProps()
    if loopTask then return end -- biar ga dobel

    -- 📍 Action pertama: selalu ke BestSpot dulu
    safeTeleport(bestSpotCFrame)
    activeMode = "BestSpot"

    loopTask = task.spawn(function()
        while task.wait(1) do
            pcall(function()
                local targetCFrame = getAnyProp()

                if targetCFrame then
                    -- kalau ada Props → teleport ke Props
                    if activeMode ~= "Props" then
                        createPropsPlatform(targetCFrame)
                        safeTeleport(propsPlatform.CFrame)
                        activeMode = "Props"
                    else
                        -- kalau sudah di Props → cek jarak
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            local dist = (hrp.Position - propsPlatform.Position).Magnitude
                            if dist > 25 then
                                safeTeleport(propsPlatform.CFrame)
                            end
                        end
                    end
                else
                    -- kalau Props hilang → balik ke BestSpot
                    if activeMode ~= "BestSpot" then
                        removePropsPlatform()
                        safeTeleport(bestSpotCFrame)
                        activeMode = "BestSpot"
                    end
                end
            end)
        end
    end)
end

local function stopAutoProps()
    if loopTask then
        task.cancel(loopTask)
        loopTask = nil
    end
    removePropsPlatform()
    activeMode = "BestSpot"
end

--// 🟢 Toggle di Rayfield
MainTab:CreateToggle({
    Name = "Auto Events",
    Flag = "AutoProps",
    CurrentValue = false,
    Callback = function(state)
        if state then
            -- ✅ Nyalakan Auto Props
            startAutoProps()

            task.wait(5)

            -- ✅ Paksa toggle Auto Fishing ikut nyala
            if not Rayfield.Flags["AutoFishing"].CurrentValue then
                Rayfield.Flags["AutoFishing"]:Set(true)
            end
        else
            -- 🔴 Matikan Auto Props
            stopAutoProps()

            -- 🔴 Matikan Auto Fishing juga
            if Rayfield.Flags["AutoFishing"].CurrentValue then
                Rayfield.Flags["AutoFishing"]:Set(false)
            end
        end
    end,
})

--// 📍 Best Spot lokasi default
local bestSpotCFrame = CFrame.lookAt(
    Vector3.new(-3764.026, -135.074, -994.416),
    Vector3.new(-3764.026, -135.074, -994.416) + Vector3.new(0.694, -8.57e-08, 0.720)
)

local player = game.Players.LocalPlayer

--// 🎯 Fokus hanya ke Megalodon Hunt
local function getMegalodonProp()
    local menuRings = workspace:FindFirstChild("!!! MENU RINGS") 
    if not menuRings then 
        return nil 
    end

    -- 🔹 Cek jalur Props langsung
    local props = menuRings:FindFirstChild("Props")
    if props then
        local target = props:FindFirstChild("Megalodon Hunt")
        if target then
            local part = target:FindFirstChildWhichIsA("BasePart", true)
            if part then
                return part.CFrame
            end
        end
    end

    -- 🔹 Fallback ke children index 19
    local child19 = menuRings:GetChildren()[19]
    if child19 then
        local target = child19:FindFirstChild("Megalodon Hunt")
        if target then
            local part = target:FindFirstChildWhichIsA("BasePart", true)
            if part then
                return part.CFrame
            end
        end
    end

    return nil -- ❌ Tidak ada Megalodon Hunt
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

local function safeTeleport(cframeTarget)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cframeTarget + Vector3.new(0, 15, 0)
    end
end

--// 🌀 Start / Stop Loop
local function startAutoMegalodon()
    if loopTask then return end -- biar ga dobel

    safeTeleport(bestSpotCFrame)
    activeMode = "BestSpot"

    loopTask = task.spawn(function()
        while task.wait(1) do
            pcall(function()
                local targetCFrame = getMegalodonProp()

                if targetCFrame then
                    if activeMode ~= "Megalodon" then
                        createPropsPlatform(targetCFrame)
                        safeTeleport(propsPlatform.CFrame)
                        activeMode = "Megalodon"
                    else
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            local dist = (hrp.Position - propsPlatform.Position).Magnitude
                            if dist > 5 then
                                safeTeleport(propsPlatform.CFrame)
                            end
                        end
                    end
                else
                    if activeMode ~= "BestSpot" then
                        print("📍 Megalodon hilang → teleport ke BestSpot")
                        removePropsPlatform()
                        safeTeleport(bestSpotCFrame)
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
    Name = "Auto Megalodon Hunt",
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


--// 🎯 Ambil Model dari MENU RINGS
local function getMenuRingsModel()
    local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
    if not menuRings then return nil end

    -- 🔹 Coba jalur Props.Model
    local props = menuRings:FindFirstChild("Props")
    if props and props:FindFirstChild("Model") then
        local part = props.Model:FindFirstChildWhichIsA("BasePart", true)
        if part then
            return part.CFrame
        end
    end

    -- 🔹 Coba jalur GetChildren()[20].Model
    local child20 = menuRings:GetChildren()[20]
    if child20 and child20:FindFirstChild("Model") then
        local part = child20.Model:FindFirstChildWhichIsA("BasePart", true)
        if part then
            return part.CFrame
        end
    end

    return nil -- ❌ Model tidak ditemukan
end

--// 🪵 Platform Props
local modelPlatform
local activeModelMode = "BestSpot"
local loopModelTask

local function createModelPlatform(cframeTarget)
    if modelPlatform and modelPlatform.Parent then
        modelPlatform:Destroy()
    end
    modelPlatform = Instance.new("Part")
    modelPlatform.Size = Vector3.new(12, 1, 12)
    modelPlatform.Anchored = true
    modelPlatform.CanCollide = true
    modelPlatform.Transparency = 1
    modelPlatform.Name = "[RF]ModelPlatform"
    modelPlatform.CFrame = cframeTarget + Vector3.new(0, 5, 0)
    modelPlatform.Parent = workspace
end

local function removeModelPlatform()
    if modelPlatform and modelPlatform.Parent then
        modelPlatform:Destroy()
    end
    modelPlatform = nil
end

local function safeTeleportModel(cframeTarget)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cframeTarget + Vector3.new(0, 20, 0)
    end
end

--// 🌀 Start / Stop Loop
local function startAutoModel()
    if loopModelTask then return end -- biar ga dobel

    safeTeleportModel(bestSpotCFrame)
    activeModelMode = "BestSpot"

    loopModelTask = task.spawn(function()
        while task.wait(1) do
            pcall(function()
                local targetCFrame = getMenuRingsModel()

                if targetCFrame then
                    if activeModelMode ~= "Model" then
                        createModelPlatform(targetCFrame)
                        safeTeleportModel(modelPlatform.CFrame)
                        activeModelMode = "Model"
                    else
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            local dist = (hrp.Position - modelPlatform.Position).Magnitude
                            if dist > 20 then
                                safeTeleportModel(modelPlatform.CFrame)
                            end
                        end
                    end
                else
                    if activeModelMode ~= "BestSpot" then
                        removeModelPlatform()
                        safeTeleportModel(bestSpotCFrame)
                        activeModelMode = "BestSpot"
                    end
                end
            end)
        end
    end)
end

local function stopAutoModel()
    if loopModelTask then
        task.cancel(loopModelTask)
        loopModelTask = nil
    end
    removeModelPlatform()
    activeModelMode = "BestSpot"
end

--// 🟢 Toggle di Rayfield
MainTab:CreateToggle({
    Name = "Auto Worm Ghost or Wormhole Hunt",
    CurrentValue = false,
    Flag = "MenuRingsModel",
    Callback = function(state)
        if state then
            startAutoModel()

            task.wait(5)

            -- ✅ Paksa toggle Auto Fishing ikut nyala
            if not Rayfield.Flags["AutoFishing"].CurrentValue then
                Rayfield.Flags["AutoFishing"]:Set(true)
            end
        else
            stopAutoModel()
            -- 🔴 Matikan Auto Fishing juga
            if Rayfield.Flags["AutoFishing"].CurrentValue then
                Rayfield.Flags["AutoFishing"]:Set(false)
            end
        end
    end,
})

-- =========================================================
-- Auto Sell

local Section = MainTab:CreateSection("Auto Sell")

MainTab:CreateButton({
    Name = "Sell All Items",
    Callback = function()
        local netRoot = game:GetService("ReplicatedStorage")
            :WaitForChild("Packages")
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0")
            :WaitForChild("net")

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
local autoSellDelay = 1 -- default 1 seconds

-- // TextBox to change delay
MainTab:CreateInput({
    Name = "Auto Sell Delay (seconds)",
    PlaceholderText = "Enter seconds (default 1s)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num > 0 then
            autoSellDelay = num
        end
    end,
})

-- // Toggle Auto Sell
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
            local netRoot = game:GetService("ReplicatedStorage")
                :WaitForChild("Packages")
                :WaitForChild("_Index")
                :WaitForChild("sleitnick_net@0.2.0")
                :WaitForChild("net")

            local SellAll = netRoot:WaitForChild("RF/SellAllItems")

            while _G.AutoSell do
                pcall(function()
                    SellAll:InvokeServer()
                end)
                task.wait(autoSellDelay)
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
        local netRoot = game:GetService("ReplicatedStorage")
            :WaitForChild("Packages")
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0")
            :WaitForChild("net")

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
        local netRoot = game:GetService("ReplicatedStorage")
            :WaitForChild("Packages")
            :WaitForChild("_Index")
            :WaitForChild("sleitnick_net@0.2.0")
            :WaitForChild("net")

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
MainTab:CreateToggle({
   Name = "Remove Popup",
   CurrentValue = false,
   Flag = "RemoveGUI",
   Callback = function(Value)
       if Value then
           local player = game:GetService("Players").LocalPlayer
           local playerGui = player:WaitForChild("PlayerGui")

           local smallNotif = playerGui:FindFirstChild("Small Notification")
           if smallNotif then smallNotif:Destroy() end

           local textNotif = playerGui:FindFirstChild("Text Notifications")
           if textNotif then textNotif:Destroy() end
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


--// 🌊 Water Walk
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer

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

-- =========================================================
-- Trade Fish
local Section = AutoTab:CreateSection("Auto Trade")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Local
local LocalPlayer = Players.LocalPlayer
local Client = require(ReplicatedStorage.Packages.Replion).Client
local Data = Client:WaitReplion("Data")
local remote = ReplicatedStorage.Packages["_Index"]["sleitnick_net@0.2.0"].net["RF/InitiateTrade"]

local targetUserId = nil
local tradingActive = false
local skipFavorited = true
local skipEnchantStone = true

-- Get player names
local function getPlayerNames()
    local names = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        table.insert(names, plr.Name)
    end
    return names
end

-- Dropdown: select target
local TradeDropdown = AutoTab:CreateDropdown({
    Name = "Select Trade Target",
    Options = getPlayerNames(),
    CurrentOption = {LocalPlayer.Name},
    Callback = function(selectedName)
        local chosen = selectedName[1]
        local targetPlayer = Players:FindFirstChild(chosen)
        if targetPlayer then
            targetUserId = targetPlayer.UserId
            print("Target set to:", chosen, "(" .. targetUserId .. ")")
        else
            warn("Player not found:", chosen)
        end
    end,
})

-- Button: refresh dropdown
AutoTab:CreateButton({
    Name = "🔄 Refresh Player List",
    Callback = function()
        TradeDropdown.Options = getPlayerNames()
    end,
})

-- Toggle: skip favorited
AutoTab:CreateToggle({
    Name = "Skip Favorited Items",
    CurrentValue = true,
    Callback = function(state)
        skipFavorited = state
    end,
})

-- Toggle: skip enchant stone
AutoTab:CreateToggle({
    Name = "Skip Enchant Stone",
    CurrentValue = true,
    Callback = function(state)
        skipEnchantStone = state
        print("Skip Enchant Stone:", state)
    end,
})

-- Toggle: auto trade
AutoTab:CreateToggle({
    Name = "Auto Trade",
    CurrentValue = false,
    Callback = function(state)
        tradingActive = state

        if tradingActive then
            if not targetUserId then
                warn("Select a target before starting!")
                tradingActive = false
                -- Notify with Rayfield
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Please select a target before starting Auto Trade!",
                    Duration = 3,
                    Image = "triangle-alert"
                })
                return
            end

            -- Teleport to target player
            local targetPlayer = Players:GetPlayerByUserId(targetUserId)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(3, 0, 0)
                end
            end

            task.spawn(function()
                while tradingActive do
                    local rods = Data.Data["Inventory"]["Items"]
                    local tradedSomething = false

                    for _, rodData in pairs(rods) do
                        if not tradingActive then break end

                        if rodData.UUID then
                            -- Debug struktur data
                            local favoritedValue = rodData.Favorited
                            if rodData.Metadata and rodData.Metadata.Favorited ~= nil then
                                favoritedValue = rodData.Metadata.Favorited
                            end

                            -- Logika trade berdasarkan toggle dan skip Id 105, 81
                            local shouldTrade = rodData.UUID and 
                                (not skipFavorited or (favoritedValue == nil or favoritedValue == false)) and 
                                (not skipEnchantStone or (rodData.Id ~= 10 and rodData.Id ~= 125)) and 
                                (rodData.Id ~= 105 and rodData.Id ~= 81)
                            if shouldTrade then
                                local uuid = rodData.UUID
                                remote:InvokeServer(targetUserId, uuid)
                                tradedSomething = true
                                task.wait(0.1)
                                Rayfield:Notify({
                                    Title = "Loading",
                                    Content = "Processing...",
                                    Duration = 3,
                                    Image = "arrow-right-left"
                                })
                            end
                        end
                    end

                    if not tradedSomething then
                        Rayfield:Notify({
                            Title = "Success",
                            Content = "Trading Done",
                            Duration = 3,
                            Image = "circle-check-big"
                        })
                        tradingActive = false
                        break
                    end

                    task.wait(2)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Info",
                Content = "Auto Trade has been stopped",
                Duration = 3,
                Image = "circle-off"
            })
        end
    end,
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
local RS = game:GetService("ReplicatedStorage")
local Client = require(RS.Packages.Replion).Client
local Data = Client:WaitReplion("Data")
local ItemUtility = require(RS.Shared.ItemUtility)

-- Remote untuk favorite
local RemoteFavorite = RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/FavoriteItem"]

-- Mapping Tier -> Rarity (1-7)
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

-- Dropdown Rayfield
AutoTab:CreateDropdown({
    Name = "Select Fish Rarities",
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    CurrentOption = {"Mythic", "Secret"},
    Flag = "FavRarities",
    MultipleOptions = true,
    Callback = function(opts)
        selectedRarities = opts
    end,
})

-- Toggle Rayfield
AutoTab:CreateToggle({
    Name = "Enable Auto-Favorite",
    CurrentValue = false,
    Flag = "AutoFavToggle",
    Callback = function(value)
        autoFavEnabled = value
    end,
})

AutoTab:CreateButton({
    Name = "Unfavorite All Fishes",
    Callback = function()
        local items = Data.Data["Inventory"]["Items"]
        local unfavCount = 0

        for _, info in pairs(items) do
            if typeof(info) == "table" and info.Id and info.Favorited == true then
                local ok, meta = pcall(function()
                    return ItemUtility.GetItemDataFromItemType("Fishes", info.Id)
                end)

                if ok and meta and meta.Data and meta.Data.Type == "Fishes" then
                    -- toggle unfavorite
                    RemoteFavorite:FireServer(info.UUID)
                    unfavCount = unfavCount + 1
                end
            end
        end

        Rayfield:Notify({
            Title = "Unfavorite Complete",
            Content = "Successfully unfavorited " .. tostring(unfavCount) .. " fishes.",
            Image = "fish-off",
            Duration = 4
        })
    end,
})


-- Loop cek inventory
task.spawn(function()
    while true do
        if autoFavEnabled then
            local items = Data.Data["Inventory"]["Items"]

            for _, info in pairs(items) do
                if typeof(info) == "table" and info.Id then
                    local ok, meta = pcall(function()
                        return ItemUtility.GetItemDataFromItemType("Fishes", info.Id)
                    end)

                    if ok and meta and meta.Data and meta.Data.Type == "Fishes" then
                        local rarity = RarityByTier[meta.Data.Tier or 1] or "Unknown"

                        -- hanya favoritkan kalau rarity cocok DAN belum favorit
                        if table.find(selectedRarities, rarity) and not info.Favorited then
                            RemoteFavorite:FireServer(info.UUID)
                            print("Favorited:", meta.Data.Name, rarity, "UUID:", info.UUID)
                        end
                    end
                end
            end
        end
        task.wait(0.1) -- cek tiap 1 detik
    end
end)


-- =========================================================
local Section = AutoTab:CreateSection("Auto Equip Best")
-- Auto Best Rod

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetFolder = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local Client = require(ReplicatedStorage.Packages.Replion).Client
local Data = Client:WaitReplion("Data")

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


-- =========================================================
-- Quest Info

local Section = QuestTab:CreateSection("Deep Sea Quest")

local QuestInfo = QuestTab:CreateParagraph({
    Title = "Deep Sea Quest",
    Content = "Loading quest info..."
})

-- References
local QuestFolder = workspace["!!! MENU RINGS"]["Deep Sea Tracker"].Board.Gui.Content
local Header = QuestFolder.Header
local Label1 = QuestFolder.Label1
local Label2 = QuestFolder.Label2
local Label3 = QuestFolder.Label3
local Label4 = QuestFolder.Label4
local Progress = QuestFolder.Progress.ProgressLabel

-- Auto update loop
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            QuestInfo:Set({
                Title = Header.Text,
                Content = string.format([[ 
%s
%s
%s
%s

%s
                ]],
                Label1.Text,
                Label2.Text,
                Label3.Text,
                Label4.Text,
                Progress.Text
            )})
        end)
    end
end)

-- =========================================================
-- Auto Quest Deep Sea

-- safe percent parsing helper
local function parsePercentFromText(txt)
    if not txt then return 0 end
    local num = txt:match("([%d%.]+)%%")
    return tonumber(num) or 0
end

-- coordinates
local bestSpotTreasure = CFrame.lookAt(
    Vector3.new(-3563.683349609375, -279.07421875, -1679.2740478515625),
    Vector3.new(-3563.683349609375, -279.07421875, -1679.2740478515625) + Vector3.new(-0.6082443, 0, 0.7937499)
)

local bestSpotSysyphus = CFrame.lookAt(
    Vector3.new(-3764.026, -135.074, -994.416),
    Vector3.new(-3764.026, -135.074, -994.416) + Vector3.new(0.694, 0, 0.720)
)

-- helper to teleport ke spot
local function goToSpot(cf)
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        hrp.CFrame = cf
        task.wait(1) -- buffer agar posisi stabil
    end

    -- equip rod (slot 1)
    EquipToolRemote:FireServer(1)

    -- tunggu rod benar-benar muncul
    local timeout = tick() + 3
    repeat
        task.wait(0.2)
    until (plr.Character and plr.Character:FindFirstChild("!!!EQUIPPED_TOOL!!!")) or tick() > timeout
end

-- Auto Quest toggle
QuestTab:CreateToggle({
    Name = "⚡ Auto Quest (Deep Sea)",
    CurrentValue = false,
    Flag = "AutoQuest",
    Callback = function(Value)
        _G.AutoQuest = Value

        if not Value then
            -- matikan AutoFishing juga lewat toggle utama
            if Rayfield.Flags["AutoFishing"].CurrentValue then
                Rayfield.Flags["AutoFishing"]:Set(false)
            end
            return
        end
        
        task.spawn(function()
            local currentStep = 0
            while _G.AutoQuest do
                local p1 = parsePercentFromText(Label1.Text)
                local p2 = parsePercentFromText(Label2.Text)
                local p3 = parsePercentFromText(Label3.Text)
                local overall = parsePercentFromText(Progress.Text)

                if p1 < 100 then
                    if currentStep ~= 1 then
                        currentStep = 1
                        print("[Quest] Catch 300 Rare/Epic (Treasure Room) — " .. tostring(p1) .. "%")
                    end
                    goToSpot(bestSpotTreasure)

                elseif p2 < 100 then
                    if currentStep ~= 2 then
                        currentStep = 2
                        print("[Quest] Catch 3 Mythic (Sisyphus Statue) — " .. tostring(p2) .. "%")
                    end
                    goToSpot(bestSpotSysyphus)

                elseif p3 < 100 then
                    if currentStep ~= 3 then
                        currentStep = 3
                        print("[Quest] Catch 1 SECRET (Sisyphus Statue) — " .. tostring(p3) .. "%")
                    end
                    goToSpot(bestSpotSysyphus)

                else
                    if currentStep ~= 4 then
                        currentStep = 4
                        print("[Quest] ✅ All Deep Sea quests completed (overall " .. tostring(overall) .. "%). Staying at Sisyphus.")
                    end
                    goToSpot(bestSpotSysyphus)
                end

                -- pastikan AutoFishing ON lewat toggle utama
                if not Rayfield.Flags["AutoFishing"].CurrentValue then
                    Rayfield.Flags["AutoFishing"]:Set(true)
                    print("[Quest] Auto Fishing enabled from Main Tab.")
                end

                task.wait(5)
            end
        end)
    end
})


-- =========================================================
-- SHOP

local Section = ShopTab:CreateSection("Buy Rod")

--// Data Rods
local rods = {
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
    CurrentOption = {"Angler Rod (8M)"}, -- Rayfield menggunakan array untuk CurrentOption
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
        "Aether Bait (3.7M)",
        "Chroma Bait (290K)",
        "Corrupt Bait (1.15M)",
        "Dark Matter Bait (630K)",
        "Luck Bait (1K)",
        "Midnight Bait (3K)",
        "Nature Bait (83.5K)",
        "Topwater (100)",
    },
    CurrentOption = {"Aether Bait (3.7M)"}, -- Rayfield menggunakan array untuk CurrentOption
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
    ["Luck Totem 2M Coins"]       = 5,
    ["Royal Bait 425K Coins"]     = 4,
    ["Singularity Bait 8.2M Coins"] = 3,
    ["Hazmat Rod 1.38M Coins"]    = 2,
    ["Fluorescent Rod 685K Coins"]= 1,
}

local selectedId = nil

-- Dropdown pilih item
ShopTab:CreateDropdown({
    Name = "Select Merchant Item",
    Options = {
        "Luck Totem 2M Coins",
        "Royal Bait 425K Coins",
        "Singularity Bait 8.2M Coins",
        "Hazmat Rod 1.38M Coins",
        "Fluorescent Rod 685K Coins"
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

-- =========================================================
-- Teleport to Islands

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
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
