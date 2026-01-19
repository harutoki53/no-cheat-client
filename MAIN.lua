--[[
    Harutoki Ultimate - High Density Edition
    - デザイン: 画像の「コーナー枠」「左体力バー」「上数値」「右アバター」をミリ単位で再現
    - フィルターON: 視認不可または500スタッド以上を「完全に非表示・演算除外」
    - フィルターOFF: 壁越しでも表示・吸い付きを行うが、射撃のみロック
    - 自動発射: 壁越しはON/OFF問わず絶対に撃たない
    - 設定画面: LeftShift / RightShift 両対応 (※管理者設定は完全に排除)
--]]

local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer
local Camera = workspace.CurrentCamera

-- --- 内部データ構造 (省略なし) ---
local config = {
    aimbot = true,
    autoFire = true,
    filter = true,       -- これが「フィルター」機能
    smooth = 0.32,
    pcFov = 650,
    maxDist = 500,       -- 500スタッド制限
    menuOpen = false,
    themeColor = Color3.fromRGB(255, 255, 255),
    visibleEnemyColor = Color3.fromRGB(0, 255, 0),
    hiddenEnemyColor = Color3.fromRGB(255, 0, 0)
}

-- --- GUI 完全構築レイヤー ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate_V5"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 10000

-- --- 設定画面UI (管理者機能を一切排除した純粋版) ---
local menu = Instance.new("Frame", gui)
menu.Size = UDim2.new(0, 320, 0, 250)
menu.Position = UDim2.new(0.5, -160, 0.5, -125)
menu.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
menu.BorderSizePixel = 0
menu.Visible = false
local mStroke = Instance.new("UIStroke", menu); mStroke.Color = Color3.new(1,1,1); mStroke.Thickness = 2
local mCorner = Instance.new("UICorner", menu); mCorner.CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", menu)
title.Size = UDim2.new(1, 0, 0, 50); title.Text = "HARUTOKI SETTINGS"; title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1; title.Font = Enum.Font.SourceSansBold; title.TextSize = 22

local function createToggle(name, pos, configKey)
    local btn = Instance.new("TextButton", menu)
    btn.Size = UDim2.new(0.8, 0, 0, 40); btn.Position = UDim2.new(0.1, 0, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 16
    Instance.new("UICorner", btn)
    
    local function updateText()
        btn.Text = name .. ": " .. (config[configKey] and "ON" or "OFF")
        btn.TextColor3 = config[configKey] and Color3.new(0,1,0) or Color3.new(1,0,0)
    end
    
    btn.MouseButton1Click:Connect(function()
        config[configKey] = not config[configKey]
        updateText()
    end)
    updateText()
end

createToggle("AIMBOT", 70, "aimbot")
createToggle("AUTO FIRE", 120, "autoFire")
createToggle("FILTER (WALLS)", 170, "filter")

-- --- チーム検証ロジック ---
local function isEnemy(target)
    if not target or target == LP then return false end
    if LP.Team and target.Team then return LP.Team ~= target.Team end
    return true
end

-- --- 精密ESP描画ロジック (画像のデザインをドット単位でシミュレート) ---
local pESP = {}
local function createESP(v)
    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false
    
    local function drawLine(pos, size)
        local f = Instance.new("Frame", container); f.BackgroundColor3 = config.themeColor; f.BorderSizePixel = 0; f.Position = pos; f.Size = size; return f
    end
    local t, l = 2.5, 12
    drawLine(UDim2.new(0,0,0,0), UDim2.new(0,l,0,t)); drawLine(UDim2.new(0,0,0,0), UDim2.new(0,t,0,l))
    drawLine(UDim2.new(1,-l,0,0), UDim2.new(0,l,0,t)); drawLine(UDim2.new(1,-t,0,0), UDim2.new(0,t,0,l))
    drawLine(UDim2.new(0,0,1,-t), UDim2.new(0,l,0,t)); drawLine(UDim2.new(0,0,1,-l), UDim2.new(0,t,0,l))
    drawLine(UDim2.new(1,-l,1,-t), UDim2.new(0,l,0,t)); drawLine(UDim2.new(1,-t,1,-l), UDim2.new(0,t,0,l))

    local barBG = Instance.new("Frame", container); barBG.Size = UDim2.new(0, 6, 1, 0); barBG.Position = UDim2.new(0, -15, 0, 0); barBG.BackgroundColor3 = Color3.new(0,0,0); barBG.BorderSizePixel = 0
    local bar = Instance.new("Frame", barBG); bar.Size = UDim2.new(1, 0, 1, 0); bar.Position = UDim2.new(0, 0, 1, 0); bar.AnchorPoint = Vector2.new(0, 1); bar.BackgroundColor3 = config.visibleEnemyColor; bar.BorderSizePixel = 0
    local hNum = Instance.new("TextLabel", container); hNum.Size = UDim2.new(1, 0, 0, 26); hNum.Position = UDim2.new(0, 0, 0, -52); hNum.BackgroundTransparency = 1; hNum.TextColor3 = Color3.new(1,1,1); hNum.Font = Enum.Font.SourceSansBold; hNum.TextScaled = true; Instance.new("UIStroke", hNum).Thickness = 1.8
    local nL = Instance.new("TextLabel", container); nL.Size = UDim2.new(1, 0, 0, 14); nL.Position = UDim2.new(0, 0, 0, -24); nL.BackgroundTransparency = 1; nL.TextColor3 = Color3.new(1,1,1); nL.Font = Enum.Font.SourceSans; nL.TextScaled = true; Instance.new("UIStroke", nL)
    local ava = Instance.new("ImageLabel", container); ava.Size = UDim2.new(0, 32, 0, 32); ava.Position = UDim2.new(1, 12, 0, 0); ava.BackgroundColor3 = Color3.new(0,0,0); Instance.new("UIStroke", ava).Color = Color3.new(1,1,1)
    
    pESP[v] = {Main = container, Bar = bar, HealthNum = hNum, Name = nL, Ava = ava}
    return pESP[v]
end

-- --- メイン演算エンジン ---
R.RenderStepped:Connect(function()
    if not Camera or not LP.Character then return end
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local targetUnit, nearestDist = nil, config.pcFov
    local canFire = false

    for _, v in pairs(P:GetPlayers()) do
        if not isEnemy(v) then if pESP[v] then pESP[v].Main.Visible = false end continue end
        local char = v.Character; local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")

        if head and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            local dist = (head.Position - Camera.CFrame.Position).Magnitude
            
            -- 壁判定の実施
            local rayParams = RaycastParams.new(); rayParams.FilterDescendantsInstances = {LP.Character, char, Camera}
            local isVisible = not workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * dist, rayParams)

            -- 【厳格フィルター】
            local display = onScreen and dist <= config.maxDist
            if config.filter and not isVisible then display = false end

            if display then
                local esp = pESP[v] or createESP(v)
                esp.Main.Visible = true
                local s = math.clamp(1000/pos.Z, 12, 450); local w = s * 0.75
                esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - s/2); esp.Main.Size = UDim2.new(0, w, 0, s)
                esp.Name.Text = v.DisplayName; esp.HealthNum.Text = math.floor(hum.Health); esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)
                esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                esp.Bar.BackgroundColor3 = isVisible and config.visibleEnemyColor or config.hiddenEnemyColor

                -- エイム判定
                if (not config.filter) or isVisible then
                    local mDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mDist < nearestDist then targetUnit = head; nearestDist = mDist end
                end
                -- 自動発射判定
                if isVisible and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 100 then canFire = true end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    if targetUnit and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local p = Camera:WorldToViewportPoint(targetUnit.Position)
        if mousemoverel then mousemoverel((p.X - center.X) * config.smooth, (p.Y - center.Y) * config.smooth) end
    end
    if config.autoFire and canFire and mouse1press then
        mouse1press(); task.wait(0.01); mouse1release()
    end
end)

-- --- キー入力 (左右Shift両対応) ---
U.InputBegan:Connect(function(i, g)
    if not g then
        if i.KeyCode == Enum.KeyCode.LeftShift or i.KeyCode == Enum.KeyCode.RightShift then
            config.menuOpen = not config.menuOpen
            menu.Visible = config.menuOpen
        end
    end
end)
