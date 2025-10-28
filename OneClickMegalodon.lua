-- =========================================================
-- 🐟 OneClick Fish It v3
-- Auto Megalodon + Auto Fishing (Controller) + Auto Complete + Auto Sell + AntiAFK + RemoveGUI + LowGraphics
-- =========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

-- =========================================================
-- ⚙️ Remote References
local netRoot = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local EquipToolRemote = netRoot:WaitForChild("RE/EquipToolFromHotbar")
local SellAll = netRoot:WaitForChild("RF/SellAllItems")

-- =========================================================
-- Controller references
local RF_AutoFishing = require(ReplicatedStorage.Packages.Net):RemoteFunction("UpdateAutoFishingState")
local FishingController = require(ReplicatedStorage.Controllers:WaitForChild("FishingController"))

-- =========================================================
-- 🧭 Simple Teleport Function (no reset / respawn)
local function waitForCharacter()
    local plr = player
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
    while task.wait(1) do
        pcall(function()
            SellAll:InvokeServer()
        end)
    end
end)

-- =========================================================
-- 🎣 AUTO FISHING (pakai AutoFishingController bawaan game)
-- =========================================================
local function click(x, y)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function startAutoFishing()
	task.spawn(function()
		goToSpot(spotSacredTemple + Vector3.new(0, 5, 0))
		local _, hrp = waitForCharacter()
		if not hrp then return end

		task.wait(1)
		print("🎣 Equipping rod...")
		EquipToolRemote:FireServer(1)
		task.wait(0.5)

		print("⚙️ Enabling AutoFishingController...")
		RF_AutoFishing:InvokeServer(true)

		print("✅ AutoFishing aktif! Menunggu minigame...")

		task.spawn(function()
			while task.wait(0.05) do
				pcall(function()
					local fishingGui = player.PlayerGui:FindFirstChild("Fishing")
					if fishingGui and fishingGui.Main.Display.Minigame.Visible then
						local mover = fishingGui.Main.Display.Minigame:FindFirstChild("Mover")
						if mover then
							local pos = mover.AbsolutePosition + mover.AbsoluteSize / 2
							click(pos.X, pos.Y)
						end
					end
				end)
			end
		end)
	end)
end

-- =========================================================
-- 🦈 Auto Megalodon
local function getMegalodonProp()
    local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
    if not menuRings then return nil end

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

    return nil
end

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

local function startAutoMegalodon()
    if loopTask then return end

    goToSpot(spotSacredTemple + Vector3.new(0, 5, 0))
    activeMode = "BestSpot"

    loopTask = task.spawn(function()
        while task.wait(1) do
            pcall(function()
                local targetCFrame = getMegalodonProp()

                if targetCFrame then
                    if activeMode ~= "Megalodon" then
                        createPropsPlatform(targetCFrame)
                        goToSpot(propsPlatform.CFrame + Vector3.new(0, 100, 0))
                        activeMode = "Megalodon"
                        print("[Megalodon] 🦈 Found — teleporting high above spot!")
                    end
                else
                    if activeMode ~= "BestSpot" then
                        print("[Megalodon] 🌀 Megalodon gone → returning to BestSpot")
                        removePropsPlatform()
                        goToSpot(spotSacredTemple + Vector3.new(0, 5, 0))
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
-- 👻 Hide Random GUI Popups (!!! Daily Login & !!! Update Log)
task.spawn(function()
    while task.wait(600) do
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
    startAutoMegalodon()
    task.wait(3)
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
