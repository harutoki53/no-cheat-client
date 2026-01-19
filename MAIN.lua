-- Rivals Script: Harutoki Ultimate (Advanced PC Edition)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = true,
    autoFire = true,
    wallCheck = true, -- FILTER 初期値
    smooth = 0.4,
    fov = 150,
    pcFov = 600,
    maxDistance = 800,
    menuOpen = false
}

-- --- GUI 構築 ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000

-- --- チーム判定 ---
local function isEnemy(v)
    if not v or v == LP then return false end
    if LP.Team and v.Team then return LP.Team ~= v.Team end
    return true
end

-- --- 設定メニュー (PC専用) ---
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 260); menuFrame.Position = UDim2.new(0.5, -110, 0.5, -130)
menuFrame.BackgroundColor3 = Color3.new(0, 0, 0); menuFrame.Visible = false
Instance.new("UIStroke", menuFrame).Color = Color3.new(1, 1, 1); Instance.new("UICorner", menuFrame)

local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame); b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); b.TextColor3 = Color3.new(1, 1, 1); b.Text = txt; b.TextScaled = true; b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b); return b
end

local aimBtn = createMenuBtn("AIMBOT", 50); local fireBtn = createMenuBtn("AUTO FIRE", 95); local wallBtn = createMenuBtn("FILTER", 140); local closeBtn = createMenuBtn("CLOSE", 185)

local function updateUI()
    menuFrame.Visible = config.menuOpen
    aimBtn.Text = "AIM: " .. (config.aimbot and "ON" or "OFF")
    fireBtn.Text = "FIRE: " .. (config.autoFire and "ON" or "OFF")
    wallBtn.Text = "FILTER: " .. (config.wallCheck and "ON" or "OFF")
end

aimBtn.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; updateUI() end)
fireBtn.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
wallBtn.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
closeBtn.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)

U.InputBegan:Connect(function(i, g) 
    if i.KeyCode == Enum.KeyCode.RightShift then config.menuOpen = not config.menuOpen; updateUI() end
end)

-- --- ESP 管理 ---
local pESP = {}
local function createESP(v)
    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false
    local mainFrame = Instance.new("Frame", container); mainFrame.Size = UDim2.new(1, 0, 1, 0); mainFrame.BackgroundTransparency = 1; local stroke = Instance.new("UIStroke", mainFrame); stroke.Thickness = 1.5
    local name = Instance.new("TextLabel", container); name.Size = UDim2.new(1, 0, 0, 15); name.Position = UDim2.new(0, 0, 0, -18)
    local healthNum = Instance.new("TextLabel", container); healthNum.Size = UDim2.new(0, 40, 0, 15); healthNum.Position = UDim2.new(0, -45, 0, -5)
    local barBG = Instance.new("Frame", container); barBG.Size = UDim2.new(0, 4, 1, 0); barBG.Position = UDim2.new(0, -8, 0, 0); barBG.BackgroundColor3 = Color3.new(0,0,0)
    local bar = Instance.new("Frame", barBG); bar.Size = UDim2.new(1, 0, 1, 0); bar.AnchorPoint = Vector2.new(0, 1); bar.Position = UDim2.new(0, 0, 1, 0)
    local function style(t) t.BackgroundTransparency, t.TextColor3, t.Font, t.TextScaled = 1, Color3.new(1, 1, 1), Enum.Font.RobotoMono, true; Instance.new("UIStroke", t) end
    style(name); style(healthNum)
    pESP[v] = {Main = container, Name = name, HealthNum = healthNum, Bar = bar, Stroke = stroke}
    return pESP[v]
end

-- --- メインエンジン ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character or not LP.Character:FindFirstChild("PrimaryPart") then return end
    
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local targetHead, nearestDist = nil, config.pcFov
    local shouldFire = false

    for _, v in pairs(P:GetPlayers()) do
        if not isEnemy(v) then if pESP[v] then pESP[v].Main.Visible = false end continue end

        local char = v.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart"))
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")

        if head and hum and hum.Health > 0 then
            local pos, onScreen = C:WorldToViewportPoint(head.Position)
            local dist = (head.Position - C.CFrame.Position).Magnitude

            if onScreen and dist <= config.maxDistance then
                local esp = pESP[v] or createESP(v)
                
                -- 壁判定 (Raycast)
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LP.Character, char, C}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position).Unit * dist, rayParams)
                local isVisible = not result -- 壁がなければtrue

                -- ESP更新
                esp.Main.Visible = true
                local h = math.clamp(1000/pos.Z, 15, 500); local w = h * 0.7
                esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                esp.Name.Text = v.DisplayName; esp.HealthNum.Text = math.floor(hum.Health)
                local hpColor = isVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0); esp.Bar.BackgroundColor3 = hpColor; esp.Stroke.Color = hpColor

                -- エイムターゲット選定
                -- FILTER ONなら「視認可能」のみ、OFFなら「すべて」
                local canLock = (not config.wallCheck) or isVisible
                if canLock then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mouseDist < nearestDist then
                        targetHead = head; nearestDist = mouseDist
                    end
                end

                -- 自動発射判定 (壁越しの時は絶対に撃たない)
                if isVisible and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 100 then
                    shouldFire = true
                end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    -- エイム・自動発射実行
    if targetHead and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local pos, _ = C:WorldToViewportPoint(targetHead.Position)
        if mousemoverel then
            mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)
        end
    end

    -- フィルターに関わらず、敵が視認可能なら発射
    if config.autoFire and shouldFire and mouse1press then
        mouse1press(); task.wait(0.01); mouse1release()
    end
end)
updateUI()
