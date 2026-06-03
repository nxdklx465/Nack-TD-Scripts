-- ====================================================================
--  NACK TD HUB - OFFICIAL SOURCE (POTASSIUM COMPATIBLE FIXED)
-- ====================================================================
-- GitHub: https://raw.githubusercontent.com/nxdklx465/Nack-TD-Scripts/refs/heads/main/source.lua

-- 1. ระบบค้นหาลิงก์ UI สำรองอัตโนมัติ 4 ชั้น (Multi-Link Bypass)
local OrionLib = nil
local UI_URLs = {
    "https://raw.githubusercontent.com/shlexware/Orion/main/source",
    "https://raw.githubusercontent.com/jensonhirst/OSM/main/TonguriHub/Source/Orion.lua",
    "https://raw.githubusercontent.com/bloodball/-Aimbot-v2/main/orion.lua",
    "https://raw.githubusercontent.com/oyunfirmasi/Roblox/main/Orion.lua"
}

for i, url in ipairs(UI_URLs) do
    local loadSuccess, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if loadSuccess and result then
        OrionLib = result
        print("[Nack Hub] โหลดอินเตอร์เฟสสำเร็จจากคลังสำรองที่: " .. tostring(i))
        break
    else
        warn("[Nack Hub Warning] ลิงก์ที่ " .. tostring(i) .. " ขัดข้อง กำลังลองลิงก์ถัดไป...")
    end
    task.wait(0.1)
end

-- ป้องกันสคริปต์หลุดทำงานถ้าเน็ตเวิร์กหลุดจริง ๆ
if not OrionLib then
    return warn("[Nack Hub Error] ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ UI ได้ กรุณาลองใหม่อีกครั้งใน Potassium")
end

-- 2. สร้างหน้าต่างเมนูหลัก (บรรทัดที่ 18 เดิม ปลอดภัย 100% แล้ว)
local Window = OrionLib:MakeWindow({
    Name = "Nack TD Hub (Ultimate Edition)", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "NackTD_Ultimate"
})

-- 3. การประกาศตัวแปรระบบและเน็ตเวิร์กของเกม
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GamePlayEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Remote"):WaitForChild("GamePlay")
local RemoteFunctionFolder = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunction")
local FunctionRemoteFolder = ReplicatedStorage:WaitForChild("Functions"):WaitForChild("Remote")

local VotePlayAgain = GamePlayEvents:WaitForChild("RequestVotePlayAgain")
local VoteStart = GamePlayEvents:WaitForChild("Vote_StartGame")
local CheckHotbar = FunctionRemoteFolder:WaitForChild("CheckHotbarUnlocks")
local SelectSlot = GamePlayEvents:WaitForChild("RequestSelectSlot")
local DeselectSlot = GamePlayEvents:WaitForChild("RequestDeselectSlot")
local PlaceUnit = GamePlayEvents:WaitForChild("RequestPlaceUnit")
local UpgradeUnit = GamePlayEvents:WaitForChild("RequestUpgradeUnit")
local GetUnitData = RemoteFunctionFolder:WaitForChild("GetUnitData")

-- 4. สวิตช์และฟังก์ชันการดักจับข้อมูล (State Management)
_G.UltimateFarm = false
_G.AutoReplay = false
_G.SpyEnabled = true
local LastCapturedCode = "-- ยังไม่มีการยิงรีโมทในเกม --"
local LastPlacedUUID = nil

-- ดักจับ UUID ยูนิตที่วางล่าสุด
local WorkspaceUnits = game.Workspace:WaitForChild("Units", 5) or game.Workspace
WorkspaceUnits.ChildAdded:Connect(function(child)
    if _G.UltimateFarm then
        task.wait(0.3)
        pcall(function()
            if child:FindFirstChild("Owner") and child.Owner.Value == LocalPlayer.Name then
                if child.Name:match("%-") then
                    LastPlacedUUID = child.Name
                end
            end
        end)
    end
end)

-- ฟังก์ชันเช็คเงินสดในเกม
local function getMyCash()
    local GamePlayClient = LocalPlayer:FindFirstChild("GamePlayClient")
    if GamePlayClient then
        for _, v in pairs(GamePlayClient:GetChildren()) do
            if v.Name == "Cash" or v.Name == "Money" or v.Name == "Gold" or v.Name == "Coins" or v:IsA("IntValue") or v:IsA("NumberValue") then
                return v.Value
            end
        end
    end
    return 0
end

-- ฟังก์ชันแปลงอาร์กิวเมนต์ของระบบ Easy Spy
local function formatArgsToLua(args)
    local str = "local args = {\n"
    for i, v in ipairs(args) do
        if typeof(v) == "Vector3" then
            str = str .. string.format("    [%d] = Vector3.new(%.3f, %.3f, %.3f),\n", i, v.X, v.Y, v.Z)
        elseif typeof(v) == "string" then
            str = str .. string.format("    [%d] = \"%s\",\n", i, v)
        else
            str = str .. string.format("    [%d] = %s,\n", i, tostring(v))
        end
    end
    str = str .. "}\n"
    return str
end

-- ระบบ Hook ดักจับรีโมทหลังบ้านสำหรับ Easy Spy
local OldNamecall; OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if _G.SpyEnabled and (Method == "FireServer" or Method == "InvokeServer") then
        if self:IsDescendantOf(GamePlayEvents) or self.Name:match("GamePlay") or self.Name:match("Unit") then
            local formattedArgs = formatArgsToLua(Args)
            LastCapturedCode = formattedArgs .. string.format("game:%s:%s(unpack(args))", self:GetFullName(), Method)
            pcall(function()
                if _G.CodeParagraph then
                    _G.CodeParagraph:Set(LastCapturedCode)
                end
            end)
        end
    end
    return OldNamecall(self, ...)
end)

-- สแกนหน้าจอเมื่อจบเกมเพื่อกด Replay อัตโนมัติ
task.spawn(function()
    while task.wait(3) do
        if _G.AutoReplay then
            pcall(function()
                local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                local isMatchOver = false
                
                if PlayerGui then
                    for _, v in pairs(PlayerGui:GetDescendants()) do
                        if v:IsA("TextLabel") and v.Visible then
                            local txt = v.Text:upper()
                            if txt:match("DEFEAT") or txt:match("VICTORY") or txt:match("GAME OVER") or txt:match("REWARD") then
                                isMatchOver = true
                                break
                            end
                        end
                    end
                end
                
                if isMatchOver and VotePlayAgain then
                    VotePlayAgain:FireServer()
                end
            end)
        end
    end
end)

-- --------------------------------------------------------------------
--  TAB 1: AUTO FARM & UTILITIES
-- --------------------------------------------------------------------
local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

FarmTab:AddToggle({
    Name = "เปิดใช้งานระบบฟาร์มตามไทม์ไลน์",
    Default = false,
    Callback = function(Value)
        _G.UltimateFarm = Value
        
        if _G.UltimateFarm then
            task.spawn(function()
                print("[บอท] เริ่มระบบออโต้ฟาร์ม...")
                LastPlacedUUID = nil
                
                if VotePlayAgain then VotePlayAgain:FireServer() end
                task.wait(0.2)
                if CheckHotbar then CheckHotbar:InvokeServer() end
                task.wait(0.5)
                if VoteStart then VoteStart:FireServer() end
                task.wait(0.2)
                if CheckHotbar then CheckHotbar:InvokeServer() end
                
                task.wait(3)
                
                task.spawn(function()
                    while _G.UltimateFarm do
                        local SkipRemote = GamePlayEvents:FindFirstChild("RequestSkipWave") or GamePlayEvents:FindFirstChild("SkipWave")
                        if SkipRemote then SkipRemote:FireServer() end
                        task.wait(2)
                    end
                end)

                -- STEP 1: วาง Wizard King ตัวที่ 1 (1400)
                if not _G.UltimateFarm then return end
                repeat task.wait(0.5) until getMyCash() >= 1400 or not _G.UltimateFarm
                if _G.UltimateFarm then
                    SelectSlot:FireServer("Unit1")
                    task.wait(0.1)
                    LastPlacedUUID = nil
                    PlaceUnit:FireServer("Wizard King_1", Vector3.new(-428.727, 172.588, -68.281), "Unit1", 0)
                    task.wait(0.1)
                    DeselectSlot:FireServer()
                    repeat task.wait(0.1) until LastPlacedUUID or not _G.UltimateFarm
                    if LastPlacedUUID and GetUnitData then GetUnitData:InvokeServer(LastPlacedUUID) end
                end

                -- STEP 2: วาง Wizard King ตัวที่ 2 (1400)
                if not _G.UltimateFarm then return end
                repeat task.wait(0.5) until getMyCash() >= 1400 or not _G.UltimateFarm
                if _G.UltimateFarm then
                    SelectSlot:FireServer("Unit1")
                    task.wait(0.1)
                    LastPlacedUUID = nil
                    PlaceUnit:FireServer("Wizard King_1", Vector3.new(-427.816, 172.588, -124.560), "Unit1", 0)
                    task.wait(0.1)
                    DeselectSlot:FireServer()
                    repeat task.wait(0.1) until LastPlacedUUID or not _G.UltimateFarm
                    if LastPlacedUUID and GetUnitData then GetUnitData:InvokeServer(LastPlacedUUID) end
                end

                -- STEP 3: วาง Vagato ตัวที่ 1 (680) + อัปเกรดรวดเดียว 3 ขั้น
                if not _G.UltimateFarm then return end
                repeat task.wait(0.5) until getMyCash() >= 680 or not _G.UltimateFarm
                local Vagato1_UUID = nil
                if _G.UltimateFarm then
                    SelectSlot:FireServer("Unit2")
                    task.wait(0.1)
                    LastPlacedUUID = nil
                    PlaceUnit:FireServer("Vagato_1", Vector3.new(-388.847, 178.081, -62.696), "Unit2", 0)
                    task.wait(0.1)
                    DeselectSlot:FireServer()
                    repeat task.wait(0.1) until LastPlacedUUID or not _G.UltimateFarm
                    Vagato1_UUID = LastPlacedUUID
                    if Vagato1_UUID and GetUnitData then GetUnitData:InvokeServer(Vagato1_UUID) end
                end

                -- อัปเกรด Vagato ตัวที่ 1 ขั้น 1-3
                local costs = {420, 520, 640}
                for i, cost in ipairs(costs) do
                    if not _G.UltimateFarm or not Vagato1_UUID then break end
                    repeat task.wait(0.3) until getMyCash() >= cost or not _G.UltimateFarm
                    if _G.UltimateFarm then
                        if GetUnitData then GetUnitData:InvokeServer(Vagato1_UUID) end
                        task.wait(0.1)
                        UpgradeUnit:FireServer(Vagato1_UUID)
                    end
                end

                -- STEP 4: วาง Vagato ตัวที่ 2 (680) + อัปเกรดรวดเดียว 2 ขั้น
                if not _G.UltimateFarm then return end
                repeat task.wait(0.5) until getMyCash() >= 680 or not _G.UltimateFarm
                local Vagato2_UUID = nil
                if _G.UltimateFarm then
                    SelectSlot:FireServer("Unit2")
                    task.wait(0.1)
                    LastPlacedUUID = nil
                    PlaceUnit:FireServer("Vagato_1", Vector3.new(-379.511, 178.093, -62.681), "Unit2", 0)
                    task.wait(0.1)
                    DeselectSlot:FireServer()
                    repeat task.wait(0.1) until LastPlacedUUID or not _G.UltimateFarm
                    Vagato2_UUID = LastPlacedUUID
                    if Vagato2_UUID and GetUnitData then GetUnitData:InvokeServer(Vagato2_UUID) end
                end

                -- อัปเกรด Vagato ตัวที่ 2 ขั้น 1-2
                local costs2 = {420, 520}
                for i, cost in ipairs(costs2) do
                    if not _G.UltimateFarm or not Vagato2_UUID then break end
                    repeat task.wait(0.3) until getMyCash() >= cost or not _G.UltimateFarm
                    if _G.UltimateFarm then
                        if GetUnitData then GetUnitData:InvokeServer(Vagato2_UUID) end
                        task.wait(0.1)
                        UpgradeUnit:FireServer(Vagato2_UUID)
                    end
                end
                print("[บอท] ทำงานเสร็จสิ้นตามกระบวนการฟาร์มทั้งหมดแล้วครับแน็ค!")
            end)
        end
    end    
})

FarmTab:AddToggle({
    Name = "เปิดระบบ Auto Replay (เริ่มเกมใหม่เมื่อจบแมตช์)",
    Default = false,
    Callback = function(Value)
        _G.AutoReplay = Value
    end    
})

-- --------------------------------------------------------------------
--  TAB 2: EASY SPY
-- --------------------------------------------------------------------
local SpyTab = Window:MakeTab({
    Name = "ส่องรีโมท (Easy Spy)",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SpyTab:AddToggle({
    Name = "เปิดระบบดักฟัง Remote",
    Default = true,
    Callback = function(Value)
        _G.SpyEnabled = Value
    end    
})

_G.CodeParagraph = SpyTab:AddParagraph("สคริปต์ที่สกัดได้ล่าสุด:", LastCapturedCode)

SpyTab:AddButton({
    Name = "📋 กดคัดลอกโค้ดนี้ไปใช้งาน (Copy to Clipboard)",
    Callback = function()
        if setclipboard then
            setclipboard(LastCapturedCode)
            OrionLib:MakeNotification({
                Name = "Nack TD Spy",
                Content = "คัดลอกโค้ดลง Clipboard เรียบร้อยแล้ว!",
                Time = 2
            })
        end
    end
})

OrionLib:Init()
