local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = true,     -- エイム自体の有効化
    autoFire = true,
    wallCheck = true,
    smooth = 0.4,      -- お気に入りの設定値を継承
    pcFov = 800,
    maxDistance = 500, -- 遠くは見せない
    menuOpen = false,
    hideUI = true      -- 最初は非表示
}

-- --- GUI (Harutoki Ultimate) ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate_Final"
gui.IgnoreGuiInset = true; gui.ResetOnSpawn = false; gui.DisplayOrder = 9999

for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name == "HarutokiUltimate_Final" and v ~= gui then v:Destroy() end
end

local function isEnemy(v)
    if not v or v == LP then return false end
    if LP.Team and v.Team then return LP.Team ~= v.Team end
    return true
end

-- --- 設定メニュー ---
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 350); menuFrame.Position = UDim2.new(0.5, -110, 0.5, -175)
menuFrame.BackgroundColor3 = Color3.new(0, 0, 0); menuFrame.Visible = false
Instance.new("UIStroke", menuFrame).Color = Color3.new(1, 1, 1); Instance.new("UICorner", menuFrame)

local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame); b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); b.TextColor3 = Color3.new(1, 1, 1); b.Text = txt; b.TextScaled = true; b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b); return b
end

local btns = {
    aim = createMenuBtn("AIM: ON", 50),
    fire = createMenuBtn("FIRE: ON", 95),
    wall = createMenuBtn("WALL FIL: ON", 140),
    hide = createMenuBtn("ESP: OFF", 185), -- 最初はOFF
    close = createMenuBtn("CLOSE", 230)
}

local function updateUI()
    menuFrame.Visible = config.menuOpen
    btns.aim.Text = "AIM: " .. (config.aimbot and "ON" or "OFF")
    btns.fire.Text = "FIRE: " .. (config.autoFire and "ON" or "OFF")
    btns.wall.Text = "WALL: " .. (config.wallCheck and "ON" or "OFF")
    btns.hide.Text = "ESP: " .. (config.hideUI and "OFF" or "ON")
end

btns.aim.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; updateUI() end)
btns.fire.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
btns.wall.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
btns.hide.MouseButton1Click:Connect(function() config.hideUI = not config.hideUI; updateUI() end)
btns.close.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)

U.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.RightShift then config.menuOpen = not config.menuOpen; updateUI()
    elseif i.KeyCode == Enum.KeyCode.M then config.hideUI = not config.hideUI; updateUI() end
end)

-- --- ESP ---
local pESP = {}
local function createESP(v)
    if v == LP then return nil end -- 自分には絶対につけない
    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false
    local mainFrame = Instance.new("Frame", container); mainFrame.Size = UDim2.new(1, 0, 1, 0); mainFrame.BackgroundTransparency = 1; local stroke = Instance.new("UIStroke", mainFrame); stroke.Thickness = 2
    local name = Instance.new("TextLabel", container); name.Size = UDim2.new(1, 0, 0, 15); name.Position = UDim2.new(0, 0, 0, -18)
    local healthNum = Instance.new("TextLabel", container); healthNum.Size = UDim2.new(0, 40, 0, 15); healthNum.Position = UDim2.new(0, -45, 0, -5)
    local barBG = Instance.new("Frame", container); barBG.Size = UDim2.new(0, 4, 1, 0); barBG.Position = UDim2.new(0, -8, 0, 0); barBG.BackgroundColor3 = Color3.new(0,0,0)
    local bar = Instance.new("Frame", barBG); bar.Size = UDim2.new(1, 0, 1, 0); bar.AnchorPoint = Vector2.new(0, 1); bar.Position = UDim2.new(0, 0, 1, 0)
    
    local function style(t)
        t.BackgroundTransparency, t.TextColor3, t.Font, t.TextScaled = 1, Color3.new(1, 1, 1), Enum.Font.RobotoMono, true
        Instance.new("UIStroke", t)
    end
    style(name); style(healthNum)
    pESP[v] = {Main = container, Name = name, HealthNum = healthNum, Bar = bar, Stroke = stroke}
    return pESP[v]
end

P.PlayerRemoving:Connect(function(p) if pESP[p] then pESP[p].Main:Destroy(); pESP[p] = nil end end)

-- --- メインエンジン ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local targetHead, nearestDist = nil, config.pcFov
    local fireAllowed = false

    for _, v in pairs(P:GetPlayers()) do
        if not isEnemy(v) then 
            if pESP[v] then pESP[v].Main.Visible = false end continue 
        end

        local char = v.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")

        if head and hum and hum.Health > 0 then
            local dist = (head.Position - C.CFrame.Position).Magnitude
            local pos, onScreen = C:WorldToViewportPoint(head.Position)
            
            -- 壁判定
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {LP.Character, char, C}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local result = workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position).Unit * dist, rayParams)
            local isVisible = not result

            -- 条件：画面内 & 距離以内 & (壁裏じゃない or フィルターOFF)
            local shouldShow = onScreen and dist <= config.maxDistance and (not config.hideUI) and isVisible
            
            if shouldShow then
                local esp = pESP[v] or createESP(v)
                if esp then
                    esp.Main.Visible = true
                    local h = math.clamp(1000/pos.Z, 10, 500); local w = h * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                    esp.Name.Text = v.DisplayName; esp.HealthNum.Text = math.floor(hum.Health)
                    esp.Stroke.Color = Color3.new(0, 1, 0)
                    esp.Bar.BackgroundColor3 = Color3.new(0, 1, 0)
                    esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)
                end
            elseif pESP[v] then pESP[v].Main.Visible = false end

            -- エイムターゲット選定 (壁裏は狙わない)
            if onScreen and isVisible and dist <= config.maxDistance then
                local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mouseDist < nearestDist then
                    targetHead = head
                    nearestDist = mouseDist
                end
                -- オートファイヤ判定
                if mouseDist < 100 then fireAllowed = true end
            end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    -- エイム実行 (右クリック中のみ吸い付き)
    if targetHead and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local pos, _ = C:WorldToViewportPoint(targetHead.Position)
        if mousemoverel then
            mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)
        end
    end

    -- 発射
    if config.autoFire and fireAllowed and mouse1press then
        mouse1press(); task.wait(0.01); mouse1release()
    end
end)

updateUI()
