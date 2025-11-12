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

local TradeTab = Window:CreateTab ("Trade", "repeat")
local FavoritTab = Window:CreateTab ("Favorite", "star")
local UtilityTab = Window:CreateTab ("Utility", "settings")

-- =========================================================
-- ⚙️ Remote References
local netRoot = game:GetService("ReplicatedStorage")
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

    -- =========================================================
-- Trade Fish
local Section = TradeTab:CreateSection("Auto Trade")

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

    mHRP.CFrame = tHRP.CFrame * CFrame.new(3, 0, 0)
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

-- === 🎣 Fish Inventory Overview (Live Full Rarity) ===

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
local fishPara = TradeTab:CreateParagraph({
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

-- =========================================================
-- 🎛️ UI
local TradeDropdown = TradeTab:CreateDropdown({
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

TradeTab:CreateButton({
    Name = "🔄 Refresh Player List",
    Callback = refreshDropdown
})

TradeTab:CreateToggle({
    Name = "Skip Favorited Items",
    CurrentValue = true,
    Callback = function(state)
        skipFavorited = state
        print("[Trade] Skip Favorited Items:", state)
    end
})

-- =========================================================
-- 🚀 Main Auto Trade Toggle
TradeTab:CreateToggle({
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


-- ==== Auto Accept Trade via PromptController (sesuai flow game) ====\
local PromptController = require(ReplicatedStorage.Controllers.PromptController)
local originalDrawPrompt = PromptController.DrawPrompt  -- simpan aslinya sekali

TradeTab:CreateToggle({
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

local Section = TradeTab:CreateSection("Auto Trade Enchant Stone")

-- === Enchant Stones Live Counter ===
-- ID yang kamu sebut:
local ENCHANT_IDS = {
    Enchant      = 10,
    Super        = 125,
    Transcended  = 246,
}

-- Hitung jumlah batu di tas (scan langsung dari Inventory)
local function countEnchantStones()
    local inv = Data and Data.Data and Data.Data.Inventory and Data.Data.Inventory.Items
    if not inv then
        return 0, 0, 0, 0
    end
    local c1, c2, c3 = 0, 0, 0
    for _, info in pairs(inv) do
        local id = info and info.Id
        if id == ENCHANT_IDS.Enchant then
            c1 = c1 + 1
        elseif id == ENCHANT_IDS.Super then
            c2 = c2 + 1
        elseif id == ENCHANT_IDS.Transcended then
            c3 = c3 + 1
        end
        -- kalau mau super aman hanya untuk item Type "Enchant Stones", uncomment:
        if id and (id == ENCHANT_IDS.Enchant or id == ENCHANT_IDS.Super or id == ENCHANT_IDS.Transcended) then
            local ok, meta = pcall(function()
                return ItemUtility.GetItemDataFromItemType("Enchant Stones", id)
            end)
            if not (ok and meta and meta.Data and meta.Data.Type == "Enchant Stones") then
                 -- skip kalau bukan Enchant Stones
            end
        end
    end
    return c1, c2, c3, (c1 + c2 + c3)
end

-- Buat paragraf di tab mana pun (contoh: TradeTab)
local stonesPara = TradeTab:CreateParagraph({
    Title = "Enchant Stones",
    Content = "Loading...",
})

-- Loop update tampilan setiap 1 detik
task.spawn(function()
    while task.wait(1) do
        local c1, c2, c3, total = countEnchantStones()
        -- format bebas, ini contoh yang kamu minta
        stonesPara:Set({
            Title = "Enchant Stones",
            Content = string.format(
                "Enchant Stone = %d\nSuper Enchant Stone = %d\nTranscended Stone = %d\nTotal = %d",
                c1, c2, c3, total
            )
        })
    end
end)

-- =========================================================
local Section = FavoritTab:CreateSection("Auto Favorited Rarity")


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
FavoritTab:CreateDropdown({
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
FavoritTab:CreateToggle({
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
        task.wait(0.5)
    end
end)

FavoritTab:CreateButton({
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
-- Anti AFK

local Section = UtilityTab:CreateSection("ANTI AFK")

--// Global flag
_G.AntiAFK = false
local antiAFKConn = nil

--// Toggle di MainTab
UtilityTab:CreateToggle({
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