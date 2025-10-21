-- =========================================================
-- 🎃 OneClick Halloween Auto Fish
-- Auto Fishing + Auto Complete + Auto Sell + AntiAFK + RemoveGUI + LowGraphics

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
-- 🧭 Simple Teleport Function
local function waitForCharacter()
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    return char, hrp
end

local function goToSpot(cf)
    local _, hrp = waitForCharacter()
    if hrp then
        hrp.CFrame = cf
        print(string.format("[System] 📍 Teleported to (%.1f, %.1f, %.1f)", cf.Position.X, cf.Position.Y, cf.Position.Z))
    end
end

-- =========================================================
-- 🎃 Lokasi Halloween
local spotHalloween = CFrame.lookAt(
    Vector3.new(2105.46630859375, 81.03092956542969, 3295.840087890625),
    Vector3.new(2105.46630859375, 81.03092956542969, 3295.840087890625)
        + Vector3.new(0.9843165278434753, -4.2261455446279683e-10, 0.17641150951385498)
)

-- =========================================================
-- 💤 Anti AFK
task.spawn(function()
    player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- =========================================================
-- 💰 Auto Sell
task.spawn(function()
    while task.wait(10) do
        pcall(function()
            SellAll:InvokeServer()
        end)
    end
end)

-- =========================================================
-- ⚡ Auto Complete Fishing
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            FishingCompleteRemote:FireServer()
        end)
    end
end)

-- =========================================================
-- 🎣 Auto Fishing
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

local function resetCharacter()
    local char = player.Character
    if not char then return end

    -- Bunuh karakter untuk trigger respawn
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end

    -- Tunggu karakter baru spawn
    local newChar = player.CharacterAdded:Wait()
    local newHrp = newChar:WaitForChild("HumanoidRootPart", 10)
    if not newHrp then return end

    -- Teleport balik ke lokasi Halloween
    task.wait(0.5)
    newHrp.CFrame = spotHalloween + Vector3.new(0, 2, 0) -- tambahkan sedikit ketinggian biar aman
    print("[System] 🎃 Respawned & teleported back to Halloween spot!")

    -- Equip rod dan mulai mancing lagi
    task.wait(0.3)
    pcall(function()
        equipRod()
        task.wait(0.2)
        startFishing()
    end)
end


local function startAutoFishing()
    task.spawn(function()
        goToSpot(spotHalloween + Vector3.new(0, 2, 0))
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
                    resetCharacter(spotHalloween + Vector3.new(0, 2, 0))
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
    local s = playerGui:FindFirstChild("Small Notification")
    if s then s:Destroy() end
    local t = playerGui:FindFirstChild("Text Notifications")
    if t then t:Destroy() end
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
-- 👻 Hide Random GUI Popups (!!! Daily Login & !!! Update Log)
task.spawn(function()
    while task.wait(600) do -- tiap 10 menit
        pcall(function()
            local gui = player:WaitForChild("PlayerGui")
            local daily = gui:FindFirstChild("!!! Daily Login")
            local update = gui:FindFirstChild("!!! Update Log")
            if daily then daily.Enabled = false end
            if update then update.Enabled = false end
        end)
    end
end)

-- =========================================================
-- 🚀 Start Everything
task.spawn(function()
    removeGUI()
    enableLowGraphics()
    task.wait(1)
    startAutoFishing()
end)


-- =========================================================
-- 🧠 Handle Respawn: rebuild UI after CharacterAdded

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Client = require(ReplicatedStorage.Packages.Replion).Client
local Data = Client:WaitReplion("Data")

local netRoot = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local FishCaughtRemote = netRoot:WaitForChild("RE/FishCaught")

local function buildOverlay()
	-- Hapus overlay lama jika ada
	local old = PlayerGui:FindFirstChild("FishingOverlay")
	if old then old:Destroy() end

	-- Ambil avatar player
	local thumbType = Enum.ThumbnailType.HeadShot
	local thumbSize = Enum.ThumbnailSize.Size420x420
	local thumbUrl, _ = Players:GetUserThumbnailAsync(Player.UserId, thumbType, thumbSize)

	-- GUI setup
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "FishingOverlay"
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = PlayerGui

	-- 🔘 Toggle button (ALWAYS visible)
	local ToggleButton = Instance.new("TextButton")
	ToggleButton.Size = UDim2.new(0, 100, 0, 100)
	ToggleButton.Position = UDim2.new(0, 20, 0, 400)
	ToggleButton.Text = "💩"
	ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	ToggleButton.BackgroundTransparency = 1
	ToggleButton.TextScaled = true
	ToggleButton.TextColor3 = Color3.new(1, 1, 1)
	ToggleButton.Parent = ScreenGui
	ToggleButton.ZIndex = 50
	local togCorner = Instance.new("UICorner", ToggleButton)
	togCorner.CornerRadius = UDim.new(1, 0)

	-- 🌌 Background
	local DarkBg = Instance.new("Frame")
	DarkBg.Size = UDim2.new(1, 0, 1, 0)
	DarkBg.BackgroundColor3 = Color3.new(0, 0, 0)
	DarkBg.BackgroundTransparency = 0
	DarkBg.Parent = ScreenGui

	-- 📦 Container for center info
	local Center = Instance.new("Frame")
	Center.AnchorPoint = Vector2.new(0.5, 0.5)
	Center.Position = UDim2.new(0.5, 0, 0.5, 0)
	Center.Size = UDim2.new(0, 400, 0, 450)
	Center.BackgroundTransparency = 1
	Center.Parent = DarkBg

	-- Avatar image
	local Avatar = Instance.new("ImageLabel")
	Avatar.Size = UDim2.new(0, 120, 0, 120)
	Avatar.AnchorPoint = Vector2.new(0.5, 0)
	Avatar.Position = UDim2.new(0.5, 0, 0, 0)
	Avatar.BackgroundTransparency = 1
	Avatar.Image = thumbUrl
	Avatar.Parent = Center

	-- Text factory
    local function makeLabel(text, yOffset, textColor)
        local lbl = Instance.new("TextLabel")
        lbl.AnchorPoint = Vector2.new(0.5, 0)
        lbl.Position = UDim2.new(0.5, 0, 0, yOffset)
        lbl.Size = UDim2.new(1, 0, 0, 35)
        lbl.Text = text
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextScaled = true
        lbl.TextColor3 = textColor or Color3.new(1, 1, 1) -- ⬅️ gunakan warna custom kalau ada
        lbl.Parent = Center
        return lbl
    end

    -- Contoh pemakaian:
    local Username = makeLabel(Player.Name, 130, Color3.fromRGB(255, 255, 255))
    local Level = makeLabel("Level: ?", 170, Color3.fromRGB(152, 238, 204))
    local FishCaught = makeLabel("Fish Caught: 0", 210, Color3.fromRGB(255, 255, 255))
    local Rod = makeLabel("Rod: ?", 250, Color3.fromRGB(255, 0, 0))
    local Bait = makeLabel("Bait: ?", 290, Color3.fromRGB(255, 0, 0))
    local Coins = makeLabel("Coins: ?", 330, Color3.fromRGB(255, 255, 0))
    local Credit = makeLabel("by: bluesky", 450, Color3.fromRGB(100, 200, 255))

	-- 🔴 Indicator circle (fishing status)
	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0, 100, 0, 100)
	Indicator.Position = UDim2.new(0, 20, 1, -500)
	Indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	Indicator.BorderSizePixel = 0
	Indicator.BackgroundTransparency = 0.1
	Indicator.ZIndex = 50
	Indicator.Parent = ScreenGui
	local indCorner = Instance.new("UICorner", Indicator)
	indCorner.CornerRadius = UDim.new(1, 0)

	-- 💤 Indicator logic + FishCaught counter
	local lastCatch = tick()
	local totalCaught = 0

	FishCaughtRemote.OnClientEvent:Connect(function()
		lastCatch = tick()
		totalCaught = totalCaught + 1
		FishCaught.Text = "Fish Caught: " .. tostring(totalCaught)
		Indicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
	end)

	task.spawn(function()
        local waitingReset = false
        while task.wait(1) do
            local elapsed = tick() - lastCatch

            if elapsed > 15 and not waitingReset then
                Indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                warn("[AutoFishing] ❌ Tidak ada ikan >15s → reset karakter.")
                
                waitingReset = true
                resetCharacter()

                -- tunggu 10 detik untuk monitor apakah sudah hijau lagi
                task.spawn(function()
                    local startCheck = tick()
                    while tick() - startCheck < 30 do
                        if tick() - lastCatch < 5 then
                            -- sudah hijau (ikan tertangkap)
                            waitingReset = false
                            print("[AutoFishing] ✅ Ikan tertangkap, batalkan reset lanjutan.")
                            break
                        end
                        task.wait(1)
                    end

                    -- jika setelah 10 detik masih tidak dapat ikan
                    if waitingReset then
                        print("[AutoFishing] ⚠️ Masih macet setelah 10s, reset ulang.")
                        resetCharacter()
                        waitingReset = false
                    end
                end)
            elseif elapsed <= 15 then
                Indicator.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            end
        end
    end)

	-- 🎣 Data updates
	task.spawn(function()
		while task.wait(1) do
			pcall(function()
				if Data.Data.Level then
					Level.Text = "Level: " .. tostring(Data.Data.Level)
				end
				if Data.Data.Coins then
					Coins.Text = "Coins: " .. tostring(Data.Data.Coins)
				end

				local rods = Data.Data.Inventory["Fishing Rods"]
				local eq = Data.Data.EquippedItems and Data.Data.EquippedItems[1]
				local rodName = "?"
				if eq then
					for _, rod in pairs(rods) do
						if rod.UUID == eq then
							local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
							if itemsFolder then
								for _, item in ipairs(itemsFolder:GetChildren()) do
									local info = require(item)
									if info.Data and info.Data.Id == rod.Id then
										rodName = info.Data.Name
										break
									end
								end
							end
						end
					end
				end
				Rod.Text = "Rod: " .. rodName

				local baitName = "?"
				local baitId = Data.Data.EquippedBaitId
				if baitId then
					local baitFolder = ReplicatedStorage:FindFirstChild("Baits")
					if baitFolder then
						for _, b in ipairs(baitFolder:GetChildren()) do
							local info = require(b)
							if info.Data and info.Data.Id == baitId then
								baitName = info.Data.Name
								break
							end
						end
					end
				end
				Bait.Text = "Bait: " .. baitName
			end)
		end
	end)

	-- 🧭 Toggle visibility
	local visible = true
	ToggleButton.MouseButton1Click:Connect(function()
		visible = not visible
		DarkBg.Visible = visible
	end)
end

-- ✅ Pertama kali jalankan overlay
pcall(buildOverlay)

-- 🔁 Rebuild otomatis setelah respawn
Player.CharacterAdded:Connect(function()
	task.wait(1) -- tunggu karakter muncul
	pcall(buildOverlay)
	print("[UI] 🔁 Overlay rebuilt after respawn.")
end)


print("[ONECLICK] ✅ Fish It v3 Loaded: Megalodon, AutoFishing, AutoComplete, AutoSell, AntiAFK, RemoveGUI, LowGraphics active.")