local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Window = Rayfield:CreateWindow({
   Name = "bluesky | Plant vs Brainrot",
   Icon = 0,
   LoadingTitle = "bluesky | Plant vs Brainrot",
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
local SeedsTab = Window:CreateTab("Seeds Shop", "store")
local GearsTab = Window:CreateTab("Gears Shop", "wrench")
local AutoTab = Window:CreateTab("Auto", "skull")

local Section = MainTab:CreateSection("Brainrots")


-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local AttackRemote = RS:WaitForChild("Remotes"):WaitForChild("AttacksServer"):WaitForChild("WeaponAttack")

local player = Players.LocalPlayer
local hrp
local noclipConn
local AutoFarm = false

-- // Helpers
local function getBrainrotsFolder()
    local sm = workspace:FindFirstChild("ScriptedMap")
    if not sm then return nil end
    return sm:FindFirstChild("Brainrots")
end

local function getUUID(model)
    return model.Name -- nama model = uuid
end

local function getNearestBrainrot()
    local brFolder = getBrainrotsFolder()
    if not brFolder or not hrp then return nil end

    local nearest, dist = nil, math.huge
    for _, m in ipairs(brFolder:GetChildren()) do
        if m:FindFirstChild("RootPart") then
            -- Hanya ambil Brainrot dekat player (misalnya radius 100 stud)
            local d = (m.RootPart.Position - hrp.Position).Magnitude
            if d < dist and d < 100 then
                nearest, dist = m, d
            end
        end
    end
    return nearest
end

-- Smooth follow + attack
local function followAndAttack(target)
    local uuid = getUUID(target)
    if not uuid then return end

    task.spawn(function()
        while AutoFarm and target.Parent == getBrainrotsFolder() do
            if hrp and target:FindFirstChild("RootPart") then
                local targetPos = target.RootPart.Position + (target.RootPart.CFrame.LookVector * -0.1)
                hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(targetPos, target.RootPart.Position), 0.15)
            end

            local args = { { uuid } }
            pcall(function()
                AttackRemote:FireServer(unpack(args))
            end)

            task.wait(0.05)
        end
    end)
end

-- Main loop
local function startAutoFarm()
    noclipConn = RunService.Stepped:Connect(function()
        if AutoFarm and player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)

    task.spawn(function()
        while AutoFarm do
            local char = player.Character or player.CharacterAdded:Wait()
            hrp = char:WaitForChild("HumanoidRootPart")

            local target = getNearestBrainrot()
            if target then
                followAndAttack(target)
                while AutoFarm and target.Parent == getBrainrotsFolder() do
                    task.wait(0.2)
                end
            else
                task.wait(0.5)
            end
        end
    end)
end

local function stopAutoFarm()
    AutoFarm = false
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
end

-- Toggle
MainTab:CreateToggle({
    Name = "Auto Farm Brainrots (hold Bat)",
    CurrentValue = false,
    Flag = "AutoBrainrot",
    Callback = function(v)
        AutoFarm = v
        if v then
            startAutoFarm()
        else
            stopAutoFarm()
        end
    end
})

--======================================================================================




--======================================================================================
local Section = MainTab:CreateSection("Auto Equip Best Brainrots")

-- Services
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("Remotes")
local equipBest = Remotes:WaitForChild("EquipBest")
local sellAll = Remotes:WaitForChild("ItemSell")

-- State
local AutoBest = false
local AutoSell = false
local IntervalMinutes = 5

-- Slider (1–60 menit)
MainTab:CreateSlider({
    Name = "Interval (Minutes)",
    Range = {1, 60},
    Increment = 1,
    Suffix = "min",
    CurrentValue = 5,
    Flag = "IntervalSlider",
    Callback = function(val)
        IntervalMinutes = val
    end
})

-- Loop Auto Best
local function bestLoop()
    task.spawn(function()
        while AutoBest do
            pcall(function()
                equipBest:Fire()
                print("✅ Equip Best Fired")
            end)

            local delayTime = IntervalMinutes * 60
            for i = 1, delayTime do
                if not AutoBest then break end
                task.wait(1)
            end
        end
    end)
end

-- Loop Auto Sell
local function sellLoop()
    task.spawn(function()
        while AutoSell do
            pcall(function()
                sellAll:FireServer()
                print("💰 Sell All Fired")
            end)

            local delayTime = IntervalMinutes * 60
            for i = 1, delayTime do
                if not AutoSell then break end
                task.wait(1)
            end
        end
    end)
end

-- Toggle Auto Best
MainTab:CreateToggle({
    Name = "Auto Best Brainrots",
    CurrentValue = false,
    Flag = "AutoBestBrainrots",
    Callback = function(v)
        AutoBest = v
        if v then bestLoop() end
    end
})

-- Toggle Auto Sell
MainTab:CreateToggle({
    Name = "Auto Sell Brainrots",
    CurrentValue = false,
    Flag = "AutoSellBrainrots",
    Callback = function(v)
        AutoSell = v
        if v then sellLoop() end
    end
})

--======================================================================================

local Section = MainTab:CreateSection("Utility")

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local AntiAFKEnabled = false
local conn

MainTab:CreateToggle({
    Name = "🛡️ Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(v)
        AntiAFKEnabled = v
        if v then
            print("✅ Anti-AFK Enabled")
            conn = Players.LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                print("💤 AFK prevented")
            end)
        else
            print("❌ Anti-AFK Disabled")
            if conn then
                conn:Disconnect()
                conn = nil
            end
        end
    end
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

--======================================================================================

-- Services
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("Remotes")
local BuyItem = Remotes:WaitForChild("BuyItem")

local Player = Players.LocalPlayer
local SeedsUI = Player.PlayerGui.Main.Seeds.Frame.ScrollingFrame

-- State
local AutoSeed = {}

-- List seeds + emoji
local SeedList = {
    "🌵 Cactus Seed",
    "🍓 Strawberry Seed",
    "🎃 Pumpkin Seed",
    "🌻 Sunflower Seed",
    "🐉 Dragon Fruit Seed",
    "🍆 Eggplant Seed",
    "🍉 Watermelon Seed",
    "🍇 Grape Seed",
    "🥥 Cocotank Seed",
    "🪴 Carnivorous Plant Seed",
    "🥕 Mr Carrot Seed",
    "🍅 Tomatrio Seed",
    "🍄 Shroombino Seed",
    "🥭 Mango Seed",
    "🍋 King Limone Seed",
}

-- Hapus emoji (ambil teks setelah spasi pertama)
local function cleanName(nameWithEmoji)
    return nameWithEmoji:match("%s(.+)$") or nameWithEmoji
end

-- Loop auto buy per seed
local function startAutoBuy(seedNameWithEmoji)
    task.spawn(function()
        local clean = cleanName(seedNameWithEmoji)
        while AutoSeed[clean] do
            local uiSeed = SeedsUI:FindFirstChild(clean)
            if uiSeed and uiSeed:FindFirstChild("Stock") then
                local stock = tonumber(uiSeed.Stock.Text:match("%d+")) or 0
                if stock > 0 then
                    -- Remote benar
                    BuyItem:FireServer(clean)
                    print("🌱 Bought:", clean, "Stock:", stock)
                end
            end
            task.wait(1) -- delay cek stock
        end
    end)
end

-- Buat toggle per seed
for _, seedName in ipairs(SeedList) do
    local clean = cleanName(seedName)
    SeedsTab:CreateToggle({
        Name = "Auto Buy " .. seedName,
        CurrentValue = false,
        Flag = "AutoBuy_" .. clean,
        Callback = function(v)
            AutoSeed[clean] = v
            if v then
                startAutoBuy(seedName)
            end
        end
    })
end


--======================================================================================

-- Services
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("Remotes")
local BuyGear = Remotes:WaitForChild("BuyGear")

local Player = Players.LocalPlayer
local GearsUI = Player.PlayerGui.Main.Gears.Frame.ScrollingFrame

-- State
local AutoGear = {}

-- List gears dengan emoji
local GearList = {
    "🍌 Banana Gun",
    "🥕 Carrot Launcher",
    "❄️ Frost Blower",
    "🧊 Frost Grenade",
    "💧 Water Bucket"
}

-- Hapus emoji dari nama (ambil teks setelah spasi pertama)
local function cleanName(nameWithEmoji)
    return nameWithEmoji:match("%s(.+)$") or nameWithEmoji
end

-- Loop auto buy per gear
local function startAutoBuyGear(gearNameWithEmoji)
    task.spawn(function()
        local clean = cleanName(gearNameWithEmoji)
        while AutoGear[clean] do
            local uiGear = GearsUI:FindFirstChild(clean)
            if uiGear and uiGear:FindFirstChild("Stock") then
                local stock = tonumber(uiGear.Stock.Text:match("%d+")) or 0
                if stock > 0 then
                    -- Remote yang benar
                    BuyGear:FireServer(clean)
                    print("⚙️ Bought Gear:", clean, "Stock:", stock)
                end
            end
            task.wait(1) -- delay cek stock
        end
    end)
end

-- Buat toggle otomatis di GearsTab
for _, gearName in ipairs(GearList) do
    local clean = cleanName(gearName)
    GearsTab:CreateToggle({
        Name = "Auto Buy " .. gearName,
        CurrentValue = false,
        Flag = "AutoBuyGear_" .. clean,
        Callback = function(v)
            AutoGear[clean] = v
            if v then
                startAutoBuyGear(gearName)
            end
        end
    })
end


--======================================================================================

local Player = game:GetService("Players").LocalPlayer
local Backpack = Player:WaitForChild("Backpack")

local SeedOptions = {}
local SeedDropdown -- reference ke dropdown

-- fungsi rebuild seed list
local function rebuildSeedOptions()
    table.clear(SeedOptions)

    for _, item in ipairs(Backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name:find("Seed") then
            -- hapus [xN] di depan
            local clean = item.Name:gsub("^%b[]%s*", "")
            -- hapus " Tool" di belakang
            clean = clean:gsub("%s*Tool$", "")
            table.insert(SeedOptions, clean)
        end
    end

    print("🔄 Seed list auto-refreshed:", table.concat(SeedOptions, ", "))

    -- update dropdown kalau UI lib support :Set()
    if SeedDropdown and SeedDropdown.Set then
        SeedDropdown:Set(SeedOptions)
    end
end

-- buat dropdown pertama kali
rebuildSeedOptions()
SeedDropdown = AutoTab:CreateDropdown({
    Name = "🌱 Choose Seed",
    Options = SeedOptions,
    CurrentOption = SeedOptions[1],
    Flag = "SeedDropdown",
    Callback = function(opt)
        print("👉 Selected:", opt)
    end
})

-- pasang listener auto-refresh
Backpack.ChildAdded:Connect(function(item)
    if item:IsA("Tool") and item.Name:find("Seed") then
        rebuildSeedOptions()
    end
end)

Backpack.ChildRemoved:Connect(function(item)
    if item:IsA("Tool") and item.Name:find("Seed") then
        rebuildSeedOptions()
    end
end)

--======================================================================================