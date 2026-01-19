-- Rivals Script: Harutoki Ultimate (Full Restore & ESP Fix)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = true,
    autoFire = true,
    wallCheck = true,
    isPC = true,
    smooth = 0.4,
    fov = 150,
    pcFov = 800,
    maxDistance = 600,
    menuOpen = false
}

-- --- GUI 強制リセット & 初期化 ---
local function initGUI()
    local existing = LP.PlayerGui:FindFirstChild("HarutokiUltimate")
    if existing then existing:Destroy() end
    
    local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
    gui.Name = "HarutokiUltimate"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    return gui
end
local gui = initGUI()

-- --- チーム判定 (より厳密に) ---
local function isEnemy(v)
    if not v or v == LP then return false end
    if LP.Team and v.Team then return LP.Team ~= v.Team end
    if v:FindFirstChild("TeamColor") and LP:FindFirstChild("TeamColor") then
        return v.TeamColor ~= LP.TeamColor
    end
    -- チーム設定がないゲームでは自分以外全員敵とする
    return true
end

-- --- FOV円 ---
local fovCircle = Instance.new("Frame", gui)
fovCircle.BackgroundColor3 = Color3.new(1, 1, 1); fovCircle.BackgroundTransparency = 0.95
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5); fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle); fovStroke.Color = Color3.new(1, 1, 1); fovStroke.Thickness = 1

-- --- 設定メニュー (あなたのデザインを維持) ---
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 300); menuFrame.Position = UDim2.new(0.5, -110, 0.5, -150)
menuFrame.BackgroundColor3 = Color3.new(0, 0, 0); menuFrame.Visible = false
Instance.new("UIStroke", menuFrame).Color = Color3.new(1, 1, 1); Instance.new("UICorner", menuFrame)

local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame); b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); b.TextColor3 = Color3.new(1, 1, 1); b.Text = txt; b.TextScaled = true; b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b); return b
end

local aimBtn = createMenuBtn("AIMBOT", 50); local fireBtn = createMenuBtn("AUTO FIRE", 95); local wallBtn = createMenuBtn("FILTER", 140); local fovSetBtn = createMenuBtn("FOV SET", 185); local closeBtn = createMenuBtn("CLOSE", 230)
local modeToggle = Instance.new("TextButton", gui)
modeToggle.Size = UDim2.new(0, 120, 0, 30); modeToggle.Position = UDim2.new(0, 10, 0, 10); modeToggle.BackgroundColor3 = Color3.new(0, 0, 0); modeToggle.TextColor3 = Color3.new(1, 1, 1); modeToggle.TextScaled = true; Instance.new("UIStroke", modeToggle)

local function updateUI()
    modeToggle.Text = "MODE: " .. (config.isPC and "PC" or "MOBILE")
    menuFrame.Visible = config.menuOpen; fovCircle.Visible = (not config.isPC and config.aimbot)
    fovCircle.Size = UDim2.new(0, config.fov * 2, 0, config.fov * 2)
    aimBtn.Text = "AIM: " .. (config.aimbot and "ON" or "OFF"); fireBtn.Text = "FIRE: " .. (config.autoFire and "ON" or "OFF")
    wallBtn.Text = "FILTER: " .. (config.wallCheck and "ON" or "OFF"); fovSetBtn.Text = "FOV: " .. config.fov
end

modeToggle.MouseButton1Click:Connect(function() config.isPC = not config.isPC; updateUI() end)
aimBtn.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; updateUI() end)
fireBtn.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
wallBtn.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
fovSetBtn.MouseButton1Click:Connect(function() config.fov = (config.fov >= 400) and 100 or config.fov + 50; updateUI() end)
closeBtn.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)

U.InputBegan:Connect(function(i, g) if i.KeyCode == Enum.KeyCode.RightShift then config.menuOpen = not config.menuOpen; updateUI() end end)

-- --- ESPオブジェクト作成 (確実に描画されるように修正) ---
local pESP = {}
local function createESP(v)
    local c = Instance.new("Frame", gui); c.BackgroundTransparency = 1; c.Visible = false
    local m = Instance.new("Frame", c); m.Size = UDim2.new(1, 0, 1, 0); m.BackgroundTransparency = 1; local s = Instance.new("UIStroke", m); s.Color = Color3.new(1,1,1)
    local n = Instance.new("TextLabel", c); n.Size = UDim2.new(1, 0, 0, 15); n.Position = UDim2.new(0, 0, 0, -18)
    local hN = Instance.new("TextLabel", c); hN.Size = UDim2.new(0, 40, 0, 15); hN.Position = UDim2.new(0, -45, 0, -5)
    local av = Instance.new("ImageLabel", c); av.Size = UDim2.new(0.6, 0, 0.6, 0); av.Position = UDim2.new(0.2, 0, 0.2, 0); av.BackgroundTransparency = 1
    local bG = Instance.new("Frame", c); bG.Size = UDim2.new(0, 4, 1, 0); bG.Position = UDim2.new(0, -8, 0, 0); bG.BackgroundColor3 = Color3.new(0,0,0)
    local b = Instance.new("Frame", bG); b.Size = UDim2.new(1, 0, 1, 0); b.AnchorPoint = Vector2.new(0, 1); b.Position = UDim2.new(0, 0, 1, 0)
    
    local function style(t) t.BackgroundTransparency, t.TextColor3, t.Font, t.TextScaled = 1, Color3.new(1, 1, 1), Enum.Font.RobotoMono, true; Instance.new("UIStroke", t) end
    style(n); style(hN)
    
    pESP[v] = {Main = c, Name = n, HealthNum = hN, Ava = av, Bar = b, Stroke = s}
    return pESP[v]
end

-- --- メインループ (ESP強制更新) ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character or not LP.Character:FindFirstChild("PrimaryPart") then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local targetHead = nil
    local canShoot = false
    local nearestDist = (config.isPC and config.pcFov or config.fov)

    for _, v in pairs(P:GetPlayers()) do
        if not isEnemy(v) then 
            if pESP[v] then pESP[v].Main.Visible = false end
            continue 
        end

        local char = v.Character
        local hum = char and char:FindFirstChild("Humanoid")
        -- Headがない場合に備えてRootPartも候補に入れる
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))

        if head and hum and hum.Health > 0 then
            local pos, onScreen = C:WorldToViewportPoint(head.Position)
            local dist = (head.Position - LP.Character.PrimaryPart.Position).Magnitude

            if dist <= config.maxDistance then
                local esp = pESP[v] or createESP(v)
                
                -- 壁越し判定 (Raycast)
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LP.Character, char, C}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position).Unit * dist, rayParams)
                local isVisible = not result

                -- 表示判定
                local aimAllowed = (not config.wallCheck) or isVisible

                if onScreen and aimAllowed then
                    esp.Main.Visible = true
                    local h = math.clamp(1000/pos.Z, 20, 500); local w = h * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                    esp.Name.Text = v.DisplayName; esp.HealthNum.Text = math.floor(hum.Health)
                    
                    local hpColor = (hum.Health > 80 and Color3.new(0,1,0)) or (hum.Health > 50 and Color3.new(1,1,0)) or Color3.new(1,0,0)
                    esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0); esp.Bar.BackgroundColor3 = hpColor; esp.HealthNum.TextColor3 = hpColor
                    esp.Stroke.Color = isVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                    esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"

                    -- ターゲット選定
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mouseDist < nearestDist then
                        targetHead = head
                        nearestDist = mouseDist
                        if isVisible then canShoot = true end
                    end
                else
                    esp.Main.Visible = false
                end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    -- --- エイム & 発射実行 ---
    if targetHead and config.aimbot then
        local isAim = (config.isPC and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) or not config.isPC
        if isAim then
            local pos, _ = C:WorldToViewportPoint(targetHead.Position)
            if config.isPC and mousemoverel then
                mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)
            else
                C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, targetHead.Position), config.smooth * 0.25)
            end
            if config.autoFire and canShoot and mouse1press then
                mouse1press(); task.wait(0.01); mouse1release()
            end
        end
    end
end)
updateUI()
