-- Rivals Script: Harutoki Ultimate (Ultra-Low Latency Build)
-- Keybinds: J, K, L, U, I, O | RightShift (Instant Response)

local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = false,
    aimMode = "LOCK",
    autoFire = false,
    wallCheck = true,
    espFilter = true,
    smooth = 0.2, -- 反応速度を上げるため少し数値を調整
    pcFov = 800,
    maxDistance = 1000,
    menuOpen = false,
    hideUI = true
}

-- --- GUI System ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.ResetOnSpawn = false

for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name == "HarutokiUltimate" and v ~= gui then v:Destroy() end
end

local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 400)
menuFrame.Position = UDim2.new(0.5, -110, 0.5, -200)
menuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menuFrame.Visible = false
Instance.new("UIStroke", menuFrame).Color = Color3.new(1, 1, 1)
Instance.new("UICorner", menuFrame)

local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame)
    b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = txt; b.TextSize = 14; b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b); return b
end

local btns = {
    aim = createMenuBtn("AIM: OFF", 50),
    mode = createMenuBtn("MODE: LOCK", 95),
    fire = createMenuBtn("FIRE: OFF", 140),
    wall = createMenuBtn("AIM FIL: ON", 185),
    esp = createMenuBtn("ESP FIL: ON", 230),
    hide = createMenuBtn("HIDE UI: ON", 275),
    close = createMenuBtn("CLOSE", 320)
}

local function updateUI()
    menuFrame.Visible = config.menuOpen
    btns.aim.Text = "AIM: " .. (config.aimbot and "ON" or "OFF")
    btns.mode.Text = "MODE: " .. config.aimMode
    btns.fire.Text = "FIRE: " .. (config.autoFire and "ON" or "OFF")
    btns.wall.Text = "AIM FIL: " .. (config.wallCheck and "ON" or "OFF")
    btns.esp.Text = "ESP FIL: " .. (config.espFilter and "ON" or "OFF")
    btns.hide.Text = "HIDE UI: " .. (config.hideUI and "ON" or "OFF")
end

-- --- ESP System ---
local pESP = {}
local function createESP(v)
    local c = Instance.new("Frame", gui); c.BackgroundTransparency = 1; c.Visible = false
    local m = Instance.new("Frame", c); m.Size = UDim2.new(1, 0, 1, 0); m.BackgroundTransparency = 1
    local s = Instance.new("UIStroke", m); s.Thickness = 2
    local n = Instance.new("TextLabel", c); n.Size = UDim2.new(1, 0, 0, 15); n.Position = UDim2.new(0, 0, 0, -18)
    n.BackgroundTransparency = 1; n.TextColor3 = Color3.new(1, 1, 1); n.TextScaled = true; n.Font = Enum.Font.RobotoMono
    Instance.new("UIStroke", n)
    pESP[v] = {Main = c, Stroke = s, Name = n}
    return pESP[v]
end

P.PlayerRemoving:Connect(function(v) if pESP[v] then pESP[v].Main:Destroy(); pESP[v] = nil end end)

-- --- 超高速入力検知ロジック ---
local keyState = {}
local function isKeyDown(k)
    return U:IsKeyDown(k)
end

local function toggle(key, action)
    if isKeyDown(key) then
        if not keyState[key] then
            action()
            keyState[key] = true
            updateUI()
        end
    else
        keyState[key] = false
    end
end

-- --- メインエンジン (低遅延ループ) ---
R.RenderStepped:Connect(function()
    -- キー判定を毎フレーム最初に行う (イベント待ちをしない)
    toggle(Enum.KeyCode.RightShift, function() config.menuOpen = not config.menuOpen end)
    toggle(Enum.KeyCode.J, function() 
        config.aimbot = not config.aimbot 
        if config.aimbot then config.aimMode = "LOCK" end 
    end)
    toggle(Enum.KeyCode.K, function() config.autoFire = not config.autoFire end)
    toggle(Enum.KeyCode.L, function() config.wallCheck = not config.wallCheck end)
    toggle(Enum.KeyCode.U, function() 
        if config.aimbot then config.aimMode = (config.aimMode == "LOCK" and "STICKY" or "LOCK") end 
    end)
    toggle(Enum.KeyCode.I, function() config.espFilter = not config.espFilter end)
    toggle(Enum.KeyCode.O, function() config.hideUI = not config.hideUI end)

    local C = workspace.CurrentCamera
    if not C or not LP.Character then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local target, near = nil, config.pcFov
    local fireAllowed = false

    for _, v in pairs(P:GetPlayers()) do
        if v == LP or (LP.Team and v.Team == LP.Team) then 
            if pESP[v] then pESP[v].Main.Visible = false end continue 
        end

        local char = v.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")

        if head and hum and hum.Health > 0 then
            local pos, vis = C:WorldToViewportPoint(head.Position)
            if vis then
                local esp = pESP[v] or createESP(v)
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LP.Character, char, C}
                local ray = workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position).Unit * 1000, rayParams)
                local canSee = not ray

                local showESP = (not config.hideUI) and ((not config.espFilter) or canSee)
                esp.Main.Visible = showESP

                if showESP then
                    local h = math.clamp(1000/pos.Z, 10, 500); local w = h * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                    esp.Name.Text = v.DisplayName
                    esp.Stroke.Color = canSee and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                end

                if (not config.wallCheck or canSee) then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < near then target = head; near = dist end
                end
                if canSee and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 100 then fireAllowed = true end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    -- エイム
    if target and config.aimbot then
        local shouldAim = (config.aimMode == "STICKY") or (U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
        if shouldAim then
            local p = C:WorldToViewportPoint(target.Position)
            if mousemoverel then
                mousemoverel((p.X - center.X) * config.smooth, (p.Y - center.Y) * config.smooth)
            end
        end
    end

    -- オート射撃
    if config.autoFire and fireAllowed and mouse1press then
        mouse1press(); task.wait(0.01); mouse1release()
    end
end)

-- ボタンクリックも維持
btns.close.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)
updateUI()
