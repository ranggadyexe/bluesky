-- =========================================================
-- 🐟 OneClick Fish It v3
-- Auto Megalodon + Auto Fishing + Auto Complete + Auto Sell + AntiAFK + RemoveGUI + LowGraphics

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- =========================================================
-- ⚙️ Remote References
local netRoot = ReplicatedStorage
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
local SellAll               = netRoot:WaitForChild("RF/SellAllItems")

-- =========================================================
-- 🧭 Simple Teleport Function (no reset / respawn)
local function waitForCharacter()
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hrp then
        warn("[System] ⚠️ Character not found.")
        return nil, nil
    end
    return char, hrp
end

local function goToSpot(cf)
    local _, hrp = waitForCharacter()
    if not hrp then return end

    hrp.CFrame = cf
    print(string.format("[System] 📍 Teleported to spot (%.1f, %.1f, %.1f)", cf.Position.X, cf.Position.Y, cf.Position.Z))
end

-- =========================================================
-- Coordinates Sacred Temple
local spotSacredTemple = CFrame.lookAt(
    Vector3.new(1479.1177978515625, -22.125001907348633, -666.4100341796875),
    Vector3.new(1479.1177978515625, -22.125001907348633, -666.4100341796875)
        + Vector3.new(0.993732750415802, 4.227080196983479e-08, -0.11178195476531982)
)

-- =========================================================
-- 💤 Anti AFK (always on)
task.spawn(function()
    player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- =========================================================
-- 💰 Auto Sell (loop tiap 10 detik)
task.spawn(function()
    while task.wait(10) do
        pcall(function()
            SellAll:InvokeServer()
        end)
    end
end)

-- =========================================================
-- ⚡ Auto Complete Fishing (always on)
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            FishingCompleteRemote:FireServer()
        end)
    end
end)

-- =========================================================
-- 🎣 Auto Fishing (with reset if stuck)
local function equipRod()
    EquipToolRemote:FireServer(1)
end
local function unequipRod()
    UnequipToolRemote:FireServer()
end
local function startFishing()
    ChargeRodRemote:InvokeServer(tick())
    RequestMiniGameRemote:InvokeServer(50, 1)
end

local function resetCharacter(targetCFrame)
    local char = player.Character
    if not char then return end

    -- tentukan posisi terakhir (target dari Megalodon / SacredTemple)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local lastPos = targetCFrame or (hrp and hrp.CFrame) or spotSacredTemple

    -- bunuh karakter (trigger respawn)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end

    -- tunggu respawn dan teleport balik
    local newChar = player.CharacterAdded:Wait()
    local newHrp = newChar:WaitForChild("HumanoidRootPart", 10)
    if not newHrp then return end

    task.wait(0.5)
    newHrp.CFrame = lastPos  -- ⬅️ balik ke posisi terakhir

    -- lanjut equip dan start fishing lagi
    task.wait(0.3)
    pcall(function()
        equipRod()
        task.wait(0.2)
        startFishing()
    end)
end


-- =========================================================
-- 🦈 Auto Megalodon (integrated with goToSpot)
local function getMegalodonProp()
    local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
    if not menuRings then return nil end

    -- 🔹 Cek langsung di Props
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

    -- 🔹 Fallback ke children index ke-19
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

-- =========================================================
-- 🪵 Platform Props
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
    propsPlatform.CFrame = cframeTarget + Vector3.new(0, 100, 0)
    propsPlatform.Parent = workspace
end

local function removePropsPlatform()
    if propsPlatform and propsPlatform.Parent then
        propsPlatform:Destroy()
    end
    propsPlatform = nil
end

-- =========================================================
-- 🌀 Start / Stop Loop
local function startAutoMegalodon()
    if loopTask then return end -- hindari dobel loop

    goToSpot(spotSacredTemple + Vector3.new(0, 2, 0))
    activeMode = "BestSpot"

    loopTask = task.spawn(function()
        while task.wait(1) do
            pcall(function()
                local targetCFrame = getMegalodonProp()

                if targetCFrame then
                    -- Megalodon terdeteksi
                    if activeMode ~= "Megalodon" then
                        createPropsPlatform(targetCFrame)
                        goToSpot(propsPlatform.CFrame + Vector3.new(0, 100, 0))
                        activeMode = "Megalodon"
                        print("[Megalodon] 🦈 Found — teleporting high above spot!")
                    end
                else
                    -- Megalodon hilang
                    if activeMode ~= "BestSpot" then
                        print("[Megalodon] 🌀 Megalodon gone → returning to BestSpot")
                        removePropsPlatform()
                        goToSpot(spotSacredTemple + Vector3.new(0, 2, 0))
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


-- =========================================================
-- 🎣 Start AutoFishing Loop
local function startAutoFishing()
    task.spawn(function()
        equipRod()
        task.wait(0.3)
        startFishing()
        local lastCatch = tick()

        FishCaughtRemote.OnClientEvent:Connect(function()
            unequipRod()
            task.wait(0.1)
            equipRod()
            task.wait(0.1)
            startFishing()
            lastCatch = tick()
        end)

        while task.wait(1) do
            local elapsed = tick() - lastCatch
            if elapsed > 10 then
                if elapsed > 15 then
                    warn("[AutoFishing] ❌ Stuck >15s, resetting...")
                    local cf = (propsPlatform and propsPlatform.CFrame + Vector3.new(0, 100, 0)) or spotSacredTemple
                    resetCharacter(cf)
                    lastCatch = tick()
                else
                    unequipRod()
                    task.wait(0.1)
                    equipRod()
                    task.wait(0.1)
                    startFishing()
                    lastCatch = tick()
                end
            end
        end
    end)
end

-- =========================================================
-- 🧹 Remove Popup + Low Graphics
local function removeGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    local smallNotif = playerGui:FindFirstChild("Small Notification")
    if smallNotif then smallNotif:Destroy() end
    local textNotif = playerGui:FindFirstChild("Text Notifications")
    if textNotif then textNotif:Destroy() end
end

local function disableVFX(obj)
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
    or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
        obj.Enabled = false
    end
end

local function simplifyPart(obj)
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
    end
end

local function applyLowGraphics(container)
    for _, obj in ipairs(container:GetDescendants()) do
        disableVFX(obj)
        simplifyPart(obj)
    end
end

local function enableLowGraphics()
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
    Lighting.FogEnd = 1e6
    Lighting.EnvironmentSpecularScale = 0
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)

    if ReplicatedStorage:FindFirstChild("VFX") then
        ReplicatedStorage.VFX:ClearAllChildren()
    end

    local containers = {workspace, Lighting, ReplicatedStorage, player:WaitForChild("PlayerGui")}
    for _, c in ipairs(containers) do
        applyLowGraphics(c)
        c.DescendantAdded:Connect(function(obj)
            disableVFX(obj)
            simplifyPart(obj)
        end)
    end
end

-- =========================================================
-- 🚀 Start Everything
task.spawn(function()
    removeGUI()
    enableLowGraphics()
    startAutoMegalodon()
    task.wait(3)
    startAutoFishing()
end)

print("[ONECLICK] ✅ Fish It v3 Loaded: Megalodon, AutoFishing, AutoComplete, AutoSell, AntiAFK, RemoveGUI, LowGraphics active.")
