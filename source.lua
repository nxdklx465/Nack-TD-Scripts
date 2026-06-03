-- ====================================================================
--  NACK TD HUB - OFFICIAL SOURCE (BUILT-IN PC BACKUP FRAMEWORK)
-- ====================================================================
-- GitHub URL: https://raw.githubusercontent.com/nxdklx465/Nack-TD-Scripts/refs/heads/main/source.lua

if not game:IsLoaded() then 
    game.Loaded:Wait() 
end
task.wait(0.2)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 🛠️ 1. ปลดล็อกระบบวาดหน้าต่างอิสระ (ฝังลงในสคริปต์โดยตรงกันลิงก์ล่ม 100%)
local OrionLib = {}

function OrionLib:Init()
    print("[Nack Hub PC] Built-in Interface System Started Successfully!")
end

function OrionLib:MakeWindow(config)
    local CoreGui = game:GetService("CoreGui")
    local TargetParent = nil
    
    -- ตรวจสอบสิทธิ์การเข้าถึงโฟลเดอร์แสดงผลบน PC
    local success, _ = pcall(function() local test = CoreGui.Name end)
    if success then
        TargetParent = CoreGui
    else
        TargetParent = LocalPlayer:WaitForChild("PlayerGui", 10)
    end
    
    -- ลบหน้าต่างเก่าที่ค้างอยู่ป้องกันการซ้อนทับ
    if TargetParent:FindFirstChild("NackHubPC_UI") then
        TargetParent["NackHubPC_UI"]:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NackHubPC_UI"
    ScreenGui.Parent = TargetParent
    ScreenGui.ResetOnSpawn = false
    
    -- โครงสร้างหน้าต่างเมนูหลักสีดำสไตล์ PC
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 550, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -170)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = MainFrame
    
    -- ส่วนหัวของหน้าต่าง (Top Bar)
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 6)
    TopCorner.Parent = TopBar
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Name or "Nack TD Hub (PC Edition)"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = TopBar
    
    -- ปุ่มปิดหน้าต่าง (Close Button)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -40, 0, 4)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.Parent = TopBar
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    
    -- แถบเลือกหมวดหมู่ด้านซ้าย (Tabs Sidebar)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 140, 1, -42)
    Sidebar.Position = UDim2.new(0, 0, 0, 42)
    Sidebar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Parent = Sidebar
    SideLayout.Padding = UDim.new(0, 4)
    
    -- พื้นที่แสดงเนื้อหาด้านขวา (Content View)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -140, 1, -42)
    Container.Position = UDim2.new(0, 140, 0, 42)
    Container.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    Container.BorderSizePixel = 0
    Container.Parent = MainFrame
    
    local windowEngine = {}
    local totalTabs = 0
    
    function windowEngine:MakeTab(tabConfig)
        totalTabs = totalTabs + 1
        local currentTabNum = totalTabs
        
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -10, 0, 36)
        TabButton.Position = UDim2.new(0, 5, 0, 0)
        TabButton.BackgroundColor3 = currentTabNum == 1 and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(24, 24, 24)
        TabButton.Text = "  " .. tabConfig.Name
        TabButton.TextColor3 = currentTabNum == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Font = Enum.Font.SourceSansBold
        TabButton.TextSize = 14
        TabButton.Parent = Sidebar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = TabButton
        
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, -20, 1, -20)
        TabPage.Position = UDim2.new(0, 10, 0, 10)
        TabPage.BackgroundTransparency = 1
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 1000)
        TabPage.ScrollBarThickness = 4
        TabPage.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
        TabPage.Visible = (currentTabNum == 1)
        TabPage.Parent = Container
        
        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Parent = TabPage
        pageLayout.Padding = UDim.new(0, 8)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, child in pairs(Container:GetChildren()) do
                if child:IsA("ScrollingFrame") then child.Visible = false end
            end
            for _, btn in pairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                    btn.TextColor3 = Color3.fromRGB(160, 160, 160)
                end
            end
            TabPage.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
        
        local tabEngine = {}
        
        -- ระบบปุ่มเปิด/ปิด (Toggle Object)
        function tabEngine:AddToggle(toggleConfig)
            local ToggleBox = Instance.new("Frame")
            ToggleBox.Size = UDim2.new(1, 0, 0, 42)
            ToggleBox.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            ToggleBox.Parent = TabPage
            
            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 4)
            boxCorner.Parent = ToggleBox
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.7, 0, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = toggleConfig.Name
            Label.TextColor3 = Color3.fromRGB(230, 230, 230)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Font = Enum.Font.SourceSans
            Label.TextSize = 14
            Label.Parent = ToggleBox
            
            local StateIndicator = Instance.new("TextButton")
            StateIndicator.Size = UDim2.new(0, 50, 0, 24)
            StateIndicator.Position = UDim2.new(1, -62, 0.5, -12)
            StateIndicator.BackgroundColor3 = toggleConfig.Default and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
            StateIndicator.Text = toggleConfig.Default and "ON" or "OFF"
            StateIndicator.TextColor3 = Color3.fromRGB(255, 255, 255)
            StateIndicator.Font = Enum.Font.SourceSansBold
            StateIndicator.TextSize = 12
            StateIndicator.Parent = ToggleBox
            
            local indCorner = Instance.new("UICorner")
            indCorner.CornerRadius = UDim.new(0, 4)
            indCorner.Parent = StateIndicator
            
            local isActive = toggleConfig.Default or false
            StateIndicator.MouseButton1Click:Connect(function()
                isActive = not isActive
                StateIndicator.Text = isActive and "ON" or "OFF"
                StateIndicator.BackgroundColor3 = isActive and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
                toggleConfig.Callback(isActive)
            end)
        end
        
        -- ระบบกล่องแสดงข้อความ/สเปาย์โค้ด (Paragraph Object)
        function tabEngine:AddParagraph(pTitle, pDesc)
            local ParaBox = Instance.new("Frame")
            ParaBox.Size = UDim2.new(1, 0, 0, 90)
            ParaBox.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            ParaBox.Parent = TabPage
            
            local pBoxCorner = Instance.new("UICorner")
            pBoxCorner.CornerRadius = UDim.new(0, 4)
            pBoxCorner.Parent = ParaBox
            
            local ContentText = Instance.new("TextLabel")
            ContentText.Size = UDim2.new(1, -20, 1, -14)
            ContentText.Position = UDim2.new(0, 10, 0, 7)
            ContentText.BackgroundTransparency = 1
            ContentText.Text = "<b>" .. pTitle .. "</b>\n" .. pDesc
            ContentText.TextColor3 = Color3.fromRGB(190, 190, 190)
            ContentText.TextWrapped = true
            ContentText.RichText = true
            ContentText.TextXAlignment = Enum.TextXAlignment.Left
            ContentText.TextYAlignment = Enum.TextYAlignment.Top
            ContentText.Font = Enum.Font.SourceSans
            ContentText.TextSize = 13
            ContentText.Parent = ParaBox
            
            local paraEngine = {}
            function paraEngine:Set(newText)
                ContentText.Text = "<b>" .. pTitle .. "</b>\n" .. tostring(newText)
            end
            return paraEngine
        end
        
        -- ระบบปุ่มกดปกติ (Button Object)
        function tabEngine:AddButton(btnConfig)
            local CustomBtn = Instance.new("TextButton")
            CustomBtn.Size = UDim2.new(1, 0, 0, 38)
            CustomBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
            CustomBtn.Text = btnConfig.Name
            CustomBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            CustomBtn.Font = Enum.Font.SourceSansBold
            CustomBtn.TextSize = 14
            CustomBtn.Parent = TabPage
            
            local cBtnCorner = Instance.new("UICorner")
            cBtnCorner.CornerRadius = UDim.new(0, 4)
            cBtnCorner.Parent = CustomBtn
            
            CustomBtn.MouseButton1Click:Connect(btnConfig.Callback)
        end
        
        return tabEngine
    end
    return windowEngine
end

-- ====================================================================
-- 2. เริ่มทำงานหน้าต่างเมนูหลักของ NACK HUB (ULTIMATE)
-- ====================================================================
local Window = OrionLib:MakeWindow({Name = "Nack TD Hub (Ultimate PC System)"})

-- 3. ประกาศตัวแปรเน็ตเวิร์กและอีเวนต์ภายในเกมทั้งหมด
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

-- 4. ระบบจัดการข้อมูล (State Management)
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
--  TAB 1: AUTO FARM SYSTEMS
-- --------------------------------------------------------------------
local FarmTab = Window:MakeTab({Name = "Auto Farm"})

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

                -- STEP 1: Wizard King 1 (1400)
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

                -- STEP 2: Wizard King 2 (1400)
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

                -- STEP 3: Vagato 1 (680) + อัปเกรด 3 ขั้น
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

                -- STEP 4: Vagato 2 (680) + อัปเกรด 2 ขั้น
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
    Name = "เปิดระบบ Auto Replay (เริ่มใหม่เมื่อจบแมตช์)",
    Default = false,
    Callback = function(Value)
        _G.AutoReplay = Value
    end    
})

-- --------------------------------------------------------------------
--  TAB 2: REMOTE SPY
-- --------------------------------------------------------------------
local SpyTab = Window:MakeTab({Name = "ส่องรีโมท (Easy Spy)"})

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
