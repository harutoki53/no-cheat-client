-- [[ Not Cheat Client v1.0 - FINAL REPAIR ]] --
-- Created by harutoki53

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local Player = Services.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = Services.RunService
local CoreGui = Services.CoreGui
local OWNER_ID = 4666377774

-- [ 1. データの初期化 ]
if not _G.NCC_Data then
    _G.NCC_Data = {
        Settings = {HUD = true, Inventory = true, AntiCheat = true, Fullbright = false, ESP = true},
        History = {}
    }
end
local startTime = os.time()

-- [ 2. UIの土台作成 ]
local ScreenGui = CoreGui:FindFirstChild("NCC_UI") or Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "NCC_UI"
ScreenGui:ClearAllChildren()

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 300)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false -- 最初は非表示
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "NCC v1.0 - harutoki53"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

-- [ 3. ボタン作成関数（ここが重要） ]
local function addBtn(text, configKey, yPos)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btn)

    local function updateVisuals()
        local isOn = _G.NCC_Data.Settings[configKey]
        btn.Text = text .. ": " .. (isOn and "ON" or "OFF")
        btn.BackgroundColor3 = isOn and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    end

    btn.MouseButton1Click:Connect(function()
        _G.NCC_Data.Settings[configKey] = not _G.NCC_Data.Settings[configKey]
        updateVisuals()
    end)
    updateVisuals()
end

-- ボタンを配置
addBtn("Status HUD", "HUD", 60)
addBtn("Anti-Cheat", "AntiCheat", 110)
addBtn("ESP System", "ESP", 160)
addBtn("Fullbright", "Fullbright", 210)

-- [ 4. HUD表示用ラベル ]
local infoFrame = Instance.new("Frame", ScreenGui)
infoFrame.Size = UDim2.new(0, 200, 0, 100)
infoFrame.Position = UDim2.new(0, 10, 0.5, -50)
infoFrame.BackgroundColor3 = Color3.new(0,0,0)
infoFrame.BackgroundTransparency = 0.5
Instance.new("UICorner", infoFrame)

local statsLabel = Instance.new("TextLabel", infoFrame)
statsLabel.Size = UDim2.new(1, -10, 1, -10)
statsLabel.Position = UDim2.new(0, 5, 0, 5)
statsLabel.TextColor3 = Color3.new(1,1,1)
statsLabel.BackgroundTransparency = 1
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Font = Enum.Font.Code
statsLabel.TextSize = 13

-- [ 5. 実行ループ ]
RunService.RenderStepped:Connect(function()
    infoFrame.Visible = _G.NCC_Data.Settings.HUD
    if _G.NCC_Data.Settings.HUD then
        local ping = math.floor(Player:GetNetworkPing() * 1000)
        statsLabel.Text = string.format("PING: %dms\nTIME: %ds\nUSER: %s", ping, os.time()-startTime, Player.Name)
    end
    if _G.NCC_Data.Settings.Fullbright then
        Services.Lighting.Brightness = 2
        Services.Lighting.ClockTime = 14
    end
end)

-- キー入力の設定
Services.UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

warn("NCC System Fully Initialized.")
-- ==========================================
-- 6. 高度なステータス HUD (リアルタイム監視)
-- ==========================================
local infoFrame = Instance.new("Frame", ScreenGui)
infoFrame.Size = UDim2.new(0, 220, 0, 140)
infoFrame.Position = UDim2.new(0, 10, 0.5, -70)
infoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
infoFrame.BackgroundTransparency = 0.5
Instance.new("UICorner", infoFrame)

local statsLabel = Instance.new("TextLabel", infoFrame)
statsLabel.Size = UDim2.new(1, -10, 1, -10)
statsLabel.Position = UDim2.new(0, 5, 0, 5)
statsLabel.BackgroundTransparency = 1
statsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Font = Enum.Font.Code
statsLabel.TextSize = 13

-- ==========================================
-- 7. 豪華インベントリ HUD (常時表示)
-- ==========================================
local invHud = Instance.new("Frame", ScreenGui)
invHud.Size = UDim2.new(0, 450, 0, 60)
invHud.Position = UDim2.new(0.5, -225, 1, -100)
invHud.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
invHud.BackgroundTransparency = 0.4
Instance.new("UICorner", invHud)

local function refreshInv()
    invHud:ClearAllChildren()
    Instance.new("UICorner", invHud)
    local items = Player.Backpack:GetChildren()
    if Player.Character then
        for _, v in ipairs(Player.Character:GetChildren()) do if v:IsA("Tool") then table.insert(items, v) end end
    end
    for i, item in ipairs(items) do
        local b = Instance.new("TextLabel", invHud)
        b.Size = UDim2.new(0, 45, 0, 45)
        b.Position = UDim2.new(0, (i-1)*50 + 5, 0, 5)
        b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        b.Text = item.Name:sub(1,3)
        b.TextColor3 = Color3.new(1,1,1)
        b.TextSize = 10
        Instance.new("UICorner", b)
    end
end

-- ==========================================
-- 8. ターゲット解析 (Insertキー) & 管理者機能
-- ==========================================
Services.UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    -- Insertでターゲット詳細
    if input.KeyCode == Enum.KeyCode.Insert then
        local target = Mouse.Target
        local char = target and target:FindFirstAncestorOfClass("Model")
        local tp = char and Services.Players:GetPlayerFromCharacter(char)
        if tp then
            print("--- NCC TARGET ANALYSIS ---")
            print("Name: " .. tp.Name)
            print("Account Age: " .. tp.AccountAge .. " days")
            print("Speed Detect: " .. (_G.NCC_Data.History[tp.UserId] or "CLEAN"))
        end
    end
end)

-- ==========================================
-- 9. メインレンダーループ (秒間60回以上の更新)
-- ==========================================
RunService.RenderStepped:Connect(function()
    -- ステータスHUD更新
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local ping = math.floor(Player:GetNetworkPing() * 1000)
    local speed = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and math.floor(Player.Character.HumanoidRootPart.Velocity.Magnitude) or 0
    local playtime = os.time() - startTime
    
    statsLabel.Text = string.format(
        "FPS: %d\nPING: %d ms\nSPEED: %d studs/s\nTIME: %dm %ds\nJOB: %s",
        fps, ping, speed, math.floor(playtime/60), playtime%60, game.JobId:sub(1,10)
    )
    
    -- インベントリ更新
    refreshInv()
    
    -- フルブライト
    if _G.NCC_Data.Settings.Fullbright then
        Services.Lighting.Brightness = 2
        Services.Lighting.ClockTime = 14
    end
end)
-- ==========================================
-- 10. 起動演出：ハッカー風スプラッシュスクリーン
-- ==========================================
local function playIntro()
    local introGui = Instance.new("ScreenGui", CoreGui)
    local background = Instance.new("Frame", introGui)
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.ZIndex = 100
    
    local logo = Instance.new("TextLabel", background)
    logo.Size = UDim2.new(1, 0, 0, 100)
    logo.Position = UDim2.new(0, 0, 0.4, 0)
    logo.Text = "NOT CHEAT CLIENT v1.0"
    logo.TextColor3 = Color3.fromRGB(0, 255, 150)
    logo.Font = Enum.Font.Code
    logo.TextSize = 40
    logo.TextTransparency = 1
    
    local sub = Instance.new("TextLabel", background)
    sub.Size = UDim2.new(1, 0, 0, 50)
    sub.Position = UDim2.new(0, 0, 0.5, 0)
    sub.Text = "Developed by harutoki53"
    sub.TextColor3 = Color3.fromRGB(200, 200, 200)
    sub.Font = Enum.Font.Code
    sub.TextSize = 18
    sub.TextTransparency = 1
    
    -- フェードイン演出
    local TweenService = Services.TweenService
    TweenService:Create(logo, TweenInfo.new(1.5), {TextTransparency = 0}):Play()
    task.wait(1)
    TweenService:Create(sub, TweenInfo.new(1.5), {TextTransparency = 0}):Play()
    task.wait(3)
    
    -- ローディング・ログ風演出
    local logLabel = Instance.new("TextLabel", background)
    logLabel.Size = UDim2.new(1, 0, 0, 20)
    logLabel.Position = UDim2.new(0, 20, 0.9, 0)
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    logLabel.Font = Enum.Font.Code
    logLabel.TextSize = 14
    
    local logs = {"[INFO] Loading Core...", "[INFO] Bypassing Security...", "[INFO] Injecting Anti-Cheat...", "[SUCCESS] NCC Ready."}
    for _, msg in ipairs(logs) do
        logLabel.Text = msg
        task.wait(0.5)
    end
    
    TweenService:Create(background, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
    TweenService:Create(logo, TweenInfo.new(1), {TextTransparency = 1}):Play()
    TweenService:Create(sub, TweenInfo.new(1), {TextTransparency = 1}):Play()
    task.wait(1)
    introGui:Destroy()
end

-- ==========================================
-- 11. 管理者専用：サーバーホップ & 通報ログ
-- ==========================================
local function executeServerHop()
    if Player.UserId ~= OWNER_ID then return end
    print("[NCC] Finding a clean server...")
    local success, result = pcall(function()
        local servers = Services.HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                break
            end
        end
    end)
    if not success then warn("Server Hop Failed: " .. tostring(result)) end
end

-- 管理者コマンド (コンソール用)
_G.NCC_Admin = {
    Hop = executeServerHop,
    ClearHistory = function() _G.NCC_Data.History = {} end
}

-- ==========================================
-- 12. 最終セットアップ
-- ==========================================
task.spawn(playIntro)
warn("Not Cheat Client: Full Deployment Complete. Press RightShift for Menu.")
-- ==========================================
-- 13. 高度なスケルトン ESP (骨格可視化)
-- ==========================================
-- プレイヤーの関節を線で結び、姿勢を完璧に把握する機能
local function createSkeleton(char)
    local p = Services.Players:GetPlayerFromCharacter(char)
    if not p then return end

    local folder = Instance.new("Folder", CoreGui)
    folder.Name = "Skeleton_" .. p.Name

    local function createLine()
        local l = Instance.new("Frame", folder)
        l.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        l.BorderSizePixel = 0
        l.AnchorPoint = Vector2.new(0.5, 0.5)
        return l
    end

    -- 結ぶ関節のリスト
    local connections = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    }

    RunService.RenderStepped:Connect(function()
        if not char:Parent() or not _G.NCC_Data.Settings.ESP then
            folder:ClearAllChildren()
            return
        end

        folder:ClearAllChildren()
        for _, pair in ipairs(connections) do
            local p1, p2 = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
            if p1 and p2 then
                local pos1, vis1 = workspace.CurrentCamera:WorldToViewportPoint(p1.Position)
                local pos2, vis2 = workspace.CurrentCamera:WorldToViewportPoint(p2.Position)

                if vis1 and vis2 then
                    local line = createLine()
                    local dist = Vector2.new(pos1.X - pos2.X, pos1.Y - pos2.Y)
                    line.Size = UDim2.new(0, dist.Magnitude, 0, 1)
                    line.Position = UDim2.new(0, (pos1.X + pos2.X)/2, 0, (pos1.Y + pos2.Y)/2)
                    line.Rotation = math.atan2(dist.Y, dist.X) * (180 / math.pi)
                end
            end
        end
    end)
end

-- ==========================================
-- 14. 軌道予測：移動トレーサー (Movement Tracer)
-- ==========================================
-- プレイヤーが数秒後にどこにいるかを予測するドットを表示
local function createTracer(p)
    RunService.RenderStepped:Connect(function()
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and _G.NCC_Data.Settings.AntiCheat then
            local hrp = p.Character.HumanoidRootPart
            local velocity = hrp.Velocity
            if velocity.Magnitude > 5 then
                local predictedPos = hrp.Position + (velocity * 0.5) -- 0.5秒後の位置予測
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(predictedPos)
                
                if onScreen then
                    local dot = Instance.new("Frame", CoreGui)
                    dot.Size = UDim2.new(0, 4, 0, 4)
                    dot.Position = UDim2.new(0, screenPos.X - 2, 0, screenPos.Y - 2)
                    dot.BackgroundColor3 = Color3.new(1, 0.8, 0)
                    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                    Services.Debris:AddItem(dot, 0.05)
                end
            end
        end
    end)
end

-- 初期適用
for _, p in ipairs(Services.Players:GetPlayers()) do
    if p ~= Player then
        if p.Character then createSkeleton(p.Character) end
        p.CharacterAdded:Connect(createSkeleton)
        createTracer(p)
    end
end
Services.Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(createSkeleton)
    createTracer(p)
end)

-- ==========================================
-- 15. 究極の最終警告システム
-- ==========================================
print("Not Cheat Client: Skeleton ESP & Prediction Engine - DEPLOYED.")
warn("Current Total Lines: Approaching Massive Scale. Build by harutoki53.")
