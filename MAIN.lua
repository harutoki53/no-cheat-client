-- Rivals Script: Harutoki Ultimate (New Key Mapping)
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
    smooth = 0.22,
    pcFov = 800,
    maxDistance = 1000,
    menuOpen = false,
    hideUI = true -- 起動時はON
}

-- --- GUI作成 ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.ResetOnSpawn = false

local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 400); menuFrame.Position = UDim2.new(0.5, -110, 0.5, -200)
menuFrame.BackgroundColor3 = Color3.new(0, 0, 0); menuFrame.Visible = false
Instance.new("UIStroke", menuFrame).Color = Color3.new(1, 1, 1); Instance.new("UICorner", menuFrame)

local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame); b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); b.TextColor3 = Color3.new(1, 1, 1); b.Text = txt; b.TextScaled = true; b.Font = Enum.Font.RobotoMono
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

-- --- 修正版キー入力ロジック ---
U.InputBegan:Connect(function(input, gpe)
    if gpe and input.KeyCode ~= Enum.KeyCode.RightShift then return end
    
    local k = input.KeyCode
    if k == Enum.KeyCode.RightShift then
        config.menuOpen = not config.menuOpen
    elseif k == Enum.KeyCode.J then
        config.aimbot = not config.aimbot
        if config.aimbot then config.aimMode = "LOCK" end
    elseif k == Enum.KeyCode.K then
        config.autoFire = not config.autoFire
    elseif k == Enum.KeyCode.L then
        config.wallCheck = not config.wallCheck
    elseif k == Enum.KeyCode.U then -- MODE切替
        if config.aimbot then config.aimMode = (config.aimMode == "LOCK" and "STICKY" or "LOCK") end
    elseif k == Enum.KeyCode.I then -- ESP壁判定
        config.espFilter = not config.espFilter
    elseif k == Enum.KeyCode.O then -- HIDE UI
        config.hideUI = not config.hideUI
    end
    updateUI()
end)

-- --- ボタン操作 ---
btns.aim.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; if config.aimbot then config.aimMode = "LOCK" end; updateUI() end)
btns.mode.MouseButton1Click:Connect(function() if config.aimbot then config.aimMode = (config.aimMode == "LOCK" and "STICKY" or "LOCK") end; updateUI() end)
btns.fire.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
btns.wall.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
btns.esp.MouseButton1Click:Connect(function() config.espFilter = not config.espFilter; updateUI() end)
btns.hide.MouseButton1Click:Connect(function() config.hideUI = not config.hideUI; updateUI() end)
btns.close.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)

-- --- エンジン部分 (以前の高品質ESP & スムーズエイムを継承) ---
local pESP = {}
local function createESP(v)
    local c = Instance.new("Frame", gui); c.BackgroundTransparency = 1; c.Visible = false
    local m = Instance.new("Frame", c); m.Size = UDim2.new(1, 0, 1, 0); m.BackgroundTransparency = 1; local s = Instance.new("UIStroke", m); s.Thickness = 2
    local n = Instance.new("TextLabel", c); n.Size = UDim2.new(1, 0, 0, 15); n.Position = UDim2.new(0, 0, 0, -18); n.BackgroundTransparency = 1; n.TextColor3 = Color3.new(1,1,1); n.TextScaled = true; Instance.new("UIStroke", n)
    pESP[v] = {Main = c, Stroke = s, Name = n}
    return pESP[v]
end

P.PlayerRemoving:Connect(function(v) if pESP[v] then pESP[v].Main:Destroy(); pESP[v] = nil end end)

R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local target, near = nil, config.pcFov
    local fire = false

    for _, v in pairs(P:GetPlayers()) do
        if v == LP or (LP.Team and v.Team == LP.Team) then if pESP[v] then pESP[v].Main.Visible = false end continue end
        local ch = v.Character
        local head = ch and (ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart"))
        local hum = ch and ch:FindFirstChildWhichIsA("Humanoid")

        if head and hum and hum.Health > 0 then
            local pos, vis = C:WorldToViewportPoint(head.Position)
            if vis then
                local esp = pESP[v] or createESP(v)
                local ray = workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position).Unit * 1000, RaycastParams.new())
                local canSee = not ray or ray.Instance:IsDescendantOf(ch)

                local show = (not config.hideUI) and ((not config.espFilter) or canSee)
                esp.Main.Visible = show
                if show then
                    local h = math.clamp(1000/pos.Z, 10, 500); local w = h * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                    esp.Name.Text = v.DisplayName
                    esp.Stroke.Color = canSee and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                end

                if (not config.wallCheck or canSee) then
                    local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if d < near then target = head; near = d end
                end
                if canSee and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 100 then fire = true end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    if target and config.aimbot then
        if config.aimMode == "STICKY" or U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local p = C:WorldToViewportPoint(target.Position)
            if mousemoverel then mousemoverel((p.X - center.X) * config.smooth, (p.Y - center.Y) * config.smooth) end
        end
    end
    if config.autoFire and fire and mouse1press then mouse1press(); task.wait(0.01); mouse1release() end
end)

updateUI()
