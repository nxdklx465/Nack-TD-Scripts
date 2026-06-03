-- ====================================================================
--  NACK TD HUB - OFFICIAL SOURCE (ULTIMATE BYPASS & BUILT-IN FALLBACK)
-- ====================================================================
-- GitHub URL: https://raw.githubusercontent.com/nxdklx465/Nack-TD-Scripts/refs/heads/main/source.lua

if not game:IsLoaded() then 
    game.Loaded:Wait() 
end
task.wait(0.5)

-- 1. ระบบค้นหาลิงก์ UI สำรองอัตโนมัติ
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
    
    if loadSuccess and typeof(result) == "table" and result.MakeWindow then
        OrionLib = result
        print("[Nack Hub] โหลดอินเตอร์เฟสสำเร็จจากคลังสำรองที่: " .. tostring(i))
        break
    else
        warn("[Nack Hub Warning] ลิงก์ที่ " .. tostring(i) .. " มีปัญหา กำลังข้ามไปลิงก์ถัดไป...")
    end
end

-- 📌 [SUPER FIXED] ถ้าระบบออนไลน์ล่มหมด (ตามรูป image_f51c83.png) ให้เปิดระบบสร้าง UI เองในตัวทันที!
if not OrionLib then
    warn("[Nack Hub] ลิงก์ล่มทั้งหมด! เปิดใช้งานระบบ Built-in Safe UI (รันได้ 100% ไม่พึ่งเน็ตนอก)...")
    OrionLib = {}
    
    function OrionLib:MakeWindow(config)
        local CoreGui = game:GetService("CoreGui")
        local ParentUI = CoreGui:FindFirstChild("RobloxGui") or CoreGui
        
        if ParentUI:FindFirstChild("NackHubFallback") then
            ParentUI["NackHubFallback"]:Destroy()
        end
        
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "NackHubFallback"
        ScreenGui.Parent = ParentUI
        ScreenGui.ResetOnSpawn = false
        
        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(0, 520, 0, 320)
        MainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
        MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        MainFrame.BorderSizePixel = 0
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Parent = ScreenGui
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = MainFrame
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0, 40)
        Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Title.Text = "  " .. (config.Name or "Nack TD Hub (Safe Mode)")
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 16
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Font = Enum.Font.SourceSansBold
        Title.Parent = MainFrame
        
        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 40, 0, 40)
        CloseBtn.Position = UDim2.new(1, -40, 0, 0)
        CloseBtn.BackgroundTransparency = 1
        CloseBtn.Text = "X"
        CloseBtn.TextColor3 = Color3.fromRGB(255, 85, 85)
        CloseBtn.TextSize = 18
        CloseBtn.Font = Enum.Font.SourceSansBold
        CloseBtn.Parent = MainFrame
        CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
        
        local TabFrame = Instance.new("Frame")
        TabFrame.Size = UDim2.new(0, 130, 1, -40)
        TabFrame.Position = UDim2.new(0, 0, 0, 40)
        TabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabFrame.BorderSizePixel = 0
        TabFrame.Parent = MainFrame
        
        local ContentFrame = Instance.new("Frame")
        ContentFrame.Size = UDim2.new(1, -130, 1, -40)
        ContentFrame.Position = UDim2.new(0, 130, 0, 40)
        ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        ContentFrame.BorderSizePixel = 0
        ContentFrame.Parent = MainFrame
        
        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Parent = TabFrame
        tabLayout.Padding = UDim.new(0, 2)
        
        local windowObj = {}
        local isFirstTab = true
        
        function windowObj:MakeTab(tabConfig)
            local TabBtn = Instance.new("TextButton")
            TabBtn.Size = UDim2.new(1, 0, 0, 35)
            TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            TabBtn.Text = tabConfig.Name
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabBtn.Font = Enum.Font.SourceSans
            TabBtn.TextSize = 14
            TabBtn.Parent = TabFrame
            
            local Page = Instance.new("ScrollingFrame")
            Page.Size = UDim2.new(1, -10, 1, -10)
            Page.Position = UDim2.new(0, 5, 0, 5)
            Page.BackgroundTransparency = 1
            Page.CanvasSize = UDim2.new(0, 0, 0, 800)
            Page.ScrollBarThickness = 4
            Page.Visible = isFirstTab
            Page.Parent = ContentFrame
            isFirstTab = false
            
            local pageLayout = Instance.new("UIListLayout")
            pageLayout.Parent = Page
            pageLayout.Padding = UDim.new(0, 6)
            
            TabBtn.MouseButton1Click:Connect(function()
                for _, p in pairs(ContentFrame:GetChildren()) do
                    if p:IsA("ScrollingFrame") then p.Visible = false end
                end
                Page.Visible = true
            end)
            
            local tabObj = {}
            
            function tabObj:AddToggle(toggleConfig)
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
                ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                ToggleFrame.Parent = Page
                
                local tCorner = Instance.new("UICorner")
                tCorner.CornerRadius = UDim.new(0, 4)
                tCorner.Parent = ToggleFrame
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.7, 0, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Text = toggleConfig.Name
                Label.TextColor3 = Color3.fromRGB(240, 240, 240)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Font = Enum.Font.SourceSans
                Label.TextSize = 14
                Label.Parent = ToggleFrame
                
                local StatusBtn = Instance.new("TextButton")
                StatusBtn.Size = UDim2.new(0, 55, 0, 24)
                StatusBtn.Position = UDim2.new(1, -65, 0.5, -12)
                StatusBtn.BackgroundColor3 = toggleConfig.Default and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
                StatusBtn.Text = toggleConfig.Default and "ON" or "OFF"
                StatusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                StatusBtn.Font = Enum.Font.SourceSansBold
                StatusBtn.TextSize = 12
                StatusBtn.Parent = ToggleFrame
                
                local state = toggleConfig.Default or false
                StatusBtn.MouseButton1Click:Connect(function()
                    state = not state
                    StatusBtn.Text = state and "ON" or "OFF"
                    StatusBtn.BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
                    toggleConfig.Callback(state)
                end)
            end
            
            function tabObj:AddParagraph(pTitle, pDesc)
                local ParaFrame = Instance.new("Frame")
                ParaFrame.Size = UDim2.new(1, 0, 0, 75)
                ParaFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                ParaFrame.Parent = Page
                
                local pCorner = Instance.new("UICorner")
                pCorner.CornerRadius = UDim.new(0, 4)
                pCorner.Parent = ParaFrame
                
                local Txt = Instance.new("TextLabel")
                Txt.Size = UDim2.new(1, -20, 1, -10)
                Txt.Position = UDim2.new(0, 10, 0, 5)
                Txt.BackgroundTransparency = 1
                Txt.Text = pTitle .. "\n" .. pDesc
                Txt.TextColor3 = Color3.fromRGB(200, 200, 200)
                Txt.TextWrapped = true
                Txt.TextXAlignment = Enum.TextXAlignment.Left
                Txt.TextYAlignment = Enum.TextYAlignment.Top
                Txt.Font = Enum.Font.SourceSans
                Txt.TextSize = 13
                Txt.Parent = ParaFrame
                
                local paraObj = {}
                function paraObj:Set(newText)
                    Txt.Text = pTitle .. "\n" .. tostring(newText)
                end
                return paraObj
            end
            
            function tabObj:AddButton(btnConfig)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 35)
                Btn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
                Btn.Text = btnConfig.Name
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                Btn.Font = Enum.Font.SourceSansBold
                Btn.TextSize = 14
                Btn.Parent = Page
                
                local bCorner = Instance.new("UICorner")
                bCorner.CornerRadius = UDim.new(0, 4)
                bCorner.Parent = Btn
                
                Btn.MouseButton1Click:Connect(btnConfig.Callback)
            end
            
            return tabObj
        end
        
        function windowObj:Init() print("[Nack Hub] Built-in Safe UI Activated!") end
        return windowObj
    end
end

-- 2. สร้างหน้าต่างเมนูหลัก (รองรับโครงสร้างแบบคู่ขนานทั้ง Orion และ Built-in UI)
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
        end
    end
})

OrionLib:Init()
