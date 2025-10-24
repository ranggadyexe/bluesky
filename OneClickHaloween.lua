-- =========================================================
-- 🎃 OneClick Halloween Auto Fish (Final Stable)
-- Auto Fishing + Auto Complete + Auto Sell + AntiAFK + RemoveGUI + LowGraphics + Webhook

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
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
-- 🧭 Character Utilities
local function waitForCharacter()
	local plr = game.Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart", 10)
	return char, hrp
end

local function goToSpot(cf)
	local _, hrp = waitForCharacter()
	if hrp then
		task.wait(0.3)
		hrp.CFrame = cf
		print(string.format("[System] 📍 Teleported to (%.1f, %.1f, %.1f)", cf.Position.X, cf.Position.Y, cf.Position.Z))
	end
end

-- =========================================================
-- 📏 Hitung jarak antar posisi
local function getDistance(pos1, pos2)
	return (pos1 - pos2).Magnitude
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
	while task.wait(15) do
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
-- 🎣 Auto Fishing Core
local function equipRod() EquipToolRemote:FireServer(1) end
local function unequipRod() UnequipToolRemote:FireServer() end
local function startFishing()
	ChargeRodRemote:InvokeServer(tick())
	RequestMiniGameRemote:InvokeServer(50, 1)
end

local function resetCharacter()
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then hum.Health = 0 end

	local newChar = player.CharacterAdded:Wait()
	local newHrp = newChar:WaitForChild("HumanoidRootPart", 10)
	if not newHrp then return end

	task.wait(0.5)
	newHrp.CFrame = spotHalloween + Vector3.new(0, 2, 0)
	print("[System] 🎃 Respawned & teleported back to Halloween spot!")

	task.wait(0.3)
	pcall(function()
		equipRod()
		task.wait(0.2)
		startFishing()
	end)
end

-- =========================================================
-- 🧱 Data Setup
local Client = require(ReplicatedStorage.Packages.Replion).Client
local Data = Client:WaitReplion("Data")
local ItemsFolder = ReplicatedStorage:WaitForChild("Items")

local knownUUIDs = {}
local TIER_NAMES = {
	[1] = "Common",
	[2] = "Uncommon",
	[3] = "Rare",
	[4] = "Epic",
	[5] = "Legendary",
	[6] = "Mythic",
	[7] = "SECRET"
}

local function getItemDataById(itemId)
	for _, module in pairs(ItemsFolder:GetChildren()) do
		local success, data = pcall(require, module)
		if success and type(data) == "table" and data.Data and tonumber(data.Data.Id) == tonumber(itemId) then
			return data
		end
	end
	return nil
end


-- =========================================================
-- 💬 Webhook Configuration

local WEBHOOK_ENABLED = _G.WebhookEnabled ~= false  -- default aktif
local WEBHOOK_URL = _G.Webhook or ""
local RARITY_FILTER = _G.RarityFilter or ""
local WEBHOOK_PING = _G.Ping or false
local playerName = game:GetService("Players").LocalPlayer.Name

-- =========================================================
-- 🎨 Warna Embed per Rarity
local EMBED_COLORS = {
	SECRET = 16711935,    -- ungu
	Mythic = 16753920,    -- oranye
	Legendary = 16766720, -- emas
	Epic = 65280,         -- hijau
	Rare = 255,           -- biru
	Uncommon = 11184810,  -- abu
	Common = 16777215     -- putih
}

-- =========================================================
-- 📤 Kirim ke Webhook
local function sendToWebhook(name, rarity, weight, shiny, variant)
	if not WEBHOOK_ENABLED or WEBHOOK_URL == "" then return end

	local color = EMBED_COLORS[rarity] or 16777215
	local shinyText = shiny and "✨ Yes" or "No"
	local variantText = variant ~= "None" and variant or "-"
	local content = ""

	if WEBHOOK_PING and type(WEBHOOK_PING) == "string" and WEBHOOK_PING ~= "" then
		content = WEBHOOK_PING -- bisa @everyone atau <@id>
	end

	local data = {
		username = "🎣 Bluesky AutoFish",
		content = content,
		embeds = { {
			title = string.format("🐟 %s", name),
			description = string.format(
				"**Player:** %s\n**Rarity:** %s\n**Weight:** `%.2f`\n**Shiny:** %s\n**Variant:** %s",
				playerName, rarity, weight, shinyText, variantText
			),
			color = color,
			footer = { text = "AutoFishing Notifier by Bluesky" },
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
		} }
	}

	pcall(function()
		local req = (syn and syn.request) or (http and http.request) or http_request
		if not req then
			warn("[Webhook] ❌ Executor tidak mendukung HTTP request.")
			return
		end

		req({
			Url = WEBHOOK_URL,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode(data)
		})

		print(string.format("[Webhook] ✅ %s (%s) | %.2f | shiny=%s | variant=%s | player=%s",
			name, rarity, weight, tostring(shiny), variant, playerName))
	end)
end

-- =========================================================
-- 🔍 Deteksi Ikan Baru (FIXED)
task.spawn(function()
    -- ✅ Abaikan semua ikan yang sudah ada sebelum mulai
    local initialItems = Data.Data["Inventory"]["Items"]
    for uuid in pairs(initialItems) do
        knownUUIDs[uuid] = true
    end
    print("[Webhook] ✅ Initialized inventory, now tracking new catches only.")

	while task.wait(0.5) do
		local items = Data.Data["Inventory"]["Items"]
		for uuid, item in pairs(items) do
			if not knownUUIDs[uuid] then
				knownUUIDs[uuid] = true
				local id = item.Id or 0
				local metadata = item.Metadata or {}
				local weight = metadata.Weight or 0
				local shiny = metadata.Shiny or false
				local variant = metadata.VariantId or "None"

				local itemInfo = getItemDataById(id)
				local name = (itemInfo and itemInfo.Data and itemInfo.Data.Name) or "Unknown Fish"
				local tier = (itemInfo and itemInfo.Data and itemInfo.Data.Tier) or 1
				local rarity = TIER_NAMES[tier] or "Unknown"
                rarity = string.lower(rarity)

				for _, filter in ipairs(RARITY_FILTER) do
                    if string.lower(filter) == rarity then
                        sendToWebhook(name, rarity, weight, shiny, variant)
                        break
                    end
                end
			end
		end
	end
end)


-- =========================================================
-- 🎣 Auto Fishing Loop
local function startAutoFishing()
	task.spawn(function()
        -- 🚀 Teleport awal
        goToSpot(spotHalloween + Vector3.new(0, 2, 0))
		local _, hrp = waitForCharacter()
		if not hrp then return end

        -- 🧠 Start auto fishing
        equipRod()
        task.wait(1)
        startFishing()
        local lastCatch = tick()

        -- 🧭 Penjaga posisi (kalau keluar area >5 stud, teleport balik)
		task.spawn(function()
			while task.wait(2) do
				pcall(function()
					local dist = (hrp.Position - spotHalloween.Position).Magnitude
					if dist > 5 then
						print(string.format("[AutoGuard] ⚠️ Keluar area (%.1f stud), teleport balik!", dist))
						hrp.CFrame = spotHalloween + Vector3.new(0, 2, 0)
					end
				end)
			end
		end)

		FishCaughtRemote.OnClientEvent:Connect(function(fishName)
			lastCatch = tick()
			print("[AutoFishing] 🎣 Ikan tertangkap:", fishName)

			-- 🔍 Ambil ikan terbaru dari inventory
			local newest
            for _, item in pairs(Data.Data["Inventory"]["Items"]) do
                newest = item
            end

			if not newest then return end
			local id = newest.Id or 0
			local metadata = newest.Metadata or {}
			local weight = metadata.Weight or 0
			local shiny = metadata.Shiny or false
			local variant = metadata.VariantId or "None"

			local itemInfo = getItemDataById(id)
			local name = (itemInfo and itemInfo.Data and itemInfo.Data.Name) or fishName or "Unknown Fish"
			local tier = (itemInfo and itemInfo.Data and itemInfo.Data.Tier) or 1
			local rarity = TIER_NAMES[tier] or "Unknown"

			print(string.format("🎣 %s | Tier %d (%s) | Weight: %.2f | Shiny: %s | Variant: %s",
				name, tier, rarity, weight, tostring(shiny), variant))

			-- 🎯 Kirim webhook realtime hanya jika sesuai filter
			for _, filter in ipairs(RARITY_FILTER) do
				if string.lower(filter) == string.lower(rarity) then
					sendToWebhook(name, rarity, weight, shiny, variant)
					break
				end
			end

			-- Lanjutkan auto-fishing
			task.wait(0.1)
			unequipRod()
			task.wait(0.1)
			equipRod()
			task.wait(0.2)
			startFishing()
		end)

		-- ⏱ Failsafe jika event tidak terpicu
		while task.wait(1) do
			local elapsed = tick() - lastCatch
			if elapsed > 30 then
				warn("[AutoFishing] ❌ Stuck >15s, reset karakter.")
				resetCharacter(spotHalloween + Vector3.new(0, 2, 0))
				lastCatch = tick()
			elseif elapsed > 10 then
				print("[AutoFishing] ⚠️ No catch in 10s, restart rod...")
				unequipRod()
				task.wait(0.1)
				equipRod()
				task.wait(0.2)
				startFishing()
				lastCatch = tick()
			end
		end
	end)
end

-- =========================================================
-- 🧹 GUI & Graphics Optimizer
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
-- 👻 Hide GUI Popups (!!! Daily Login & !!! Update Log)
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

            if elapsed > 30 and not waitingReset then
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