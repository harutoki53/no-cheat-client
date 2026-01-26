-- Rivals Script: Harutoki Ultimate (Final Complete Version)
-- Keybinds: J, K, L (Main) | U, I, O (Utility) | RightShift (Menu)

local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

-- --- [1] Configuration (初期設定) ---
local config = {
    aimbot = false,
    aimMode = "LOCK", -- LOCK (右クリ) / STICKY (常に)
    autoFire = false,
    wallCheck = true,
    espFilter = true, -- 壁越しのESPを隠す
    smooth = 0.22,
    pcFov = 800,
    maxDistance = 1000,
    menuOpen = false,
    hideUI = true -- [リクエスト] 起動時はON (Oキーで解除)
}

-- --- [2] GUI System (UI構築) ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- 重複削除
for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name == "HarutokiUltimate" and v ~= gui then v:Destroy() end
end

local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 400)
menuFrame.Position = UDim2.new(0.5, -110, 0.5, -200)
menuFrame.BackgroundColor3 = Color3.new(0, 0, 0)
menuFrame.Visible = false
Instance.new("UIStroke", menuFrame).Color = Color3.new(1, 1, 1)
Instance.new("UICorner", menuFrame)

local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = txt
    b.TextSize = 14
    b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b)
    return b
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

-- --- [3] Input System (キー入力判定) ---
U.InputBegan:Connect(function(input, gpe)
    if gpe and input.KeyCode ~= Enum.KeyCode.RightShift then return end
    
    local k = input.KeyCode
    if k == Enum.KeyCode.RightShift then
        config.menuOpen = not config.menuOpen
    elseif k == Enum.KeyCode.J then -- AIM ON/OFF
        config.aimbot = not config.aimbot
        if config.aimbot then config.aimMode = "LOCK" end
    elseif k == Enum.KeyCode.K then -- FIRE ON/OFF
        config.autoFire = not config.autoFire
    elseif k == Enum.KeyCode.L then -- AIM FILTER
        config.wallCheck = not config.wallCheck
    elseif k == Enum.KeyCode.U then -- MODE SWITCH
        if config.aimbot then config.aimMode = (config.aimMode == "LOCK" and "STICKY" or "LOCK") end
    elseif k == Enum.KeyCode.I then -- ESP FILTER
        config.espFilter = not config.espFilter
    elseif k == Enum.KeyCode.O then -- HIDE UI
        config.hideUI = not config.hideUI
    end
    updateUI()
end)

-- ボタンクリック
btns.aim.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; if config.aimbot then config.aimMode = "LOCK" end; updateUI() end)
btns.mode.MouseButton1Click:Connect(function() if config.aimbot then config.aimMode = (config.aimMode == "LOCK" and "STICKY" or "LOCK") end; updateUI() end)
btns.fire.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
btns.wall.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
btns.esp.MouseButton1Click:Connect(function() config.espFilter = not config.espFilter; updateUI() end)
btns.hide.MouseButton1Click:Connect(function() config.hideUI = not config.hideUI; updateUI() end)
btns.close.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)

-- --- [4] ESP System (描画と削除) ---
local pESP = {}
local function createESP(v)
    local c = Instance.new("Frame", gui); c.BackgroundTransparency = 1; c.Visible = false
    local m = Instance.new("Frame", c); m.Size = UDim2.new(1, 0, 1, 0); m.BackgroundTransparency = 1
    local s = Instance.new("UIStroke", m); s.Thickness = 2
    local n = Instance.new("TextLabel", c); n.Size = UDim2.new(1, 0, 0, 15); n.Position = UDim2.new(0, 0, 0, -18)
    n.BackgroundTransparency = 1; n.TextColor3 = Color3.new(1, 1, 1); n.TextScaled = true; n.Font = Enum.Font.RobotoMono
    Instance.new("UIStroke", n)
    local barBG = Instance.new("Frame", c); barBG.Size = UDim2.new(0, 4, 1, 0); barBG.Position = UDim2.new(0, -8, 0, 0); barBG.BackgroundColor3 = Color3.new(0,0,0)
    local bar = Instance.new("Frame", barBG); bar.Size = UDim2.new(1, 0, 1, 0); bar.AnchorPoint = Vector2.new(0, 1); bar.Position = UDim2.new(0, 0, 1, 0)
    
    pESP[v] = {Main = c, Stroke = s, Name = n, Bar = bar}
    return pESP[v]
end

-- 退出時にESPを破棄
P.PlayerRemoving:Connect(function(v)
    if pESP[v] then
        pESP[v].Main:Destroy()
        pESP[v] = nil
    end
end)

-- --- [5] Main Engine (RenderStepped) ---
R.RenderStepped:Connect(function()
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

                -- ESP表示ロジック
                local showESP = (not config.hideUI) and ((not config.espFilter) or canSee)
                esp.Main.Visible = showESP

                if showESP then
                    local h = math.clamp(1000/pos.Z, 10, 500); local w = h * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                    esp.Name.Text = v.DisplayName
                    local col = canSee and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                    esp.Stroke.Color = col; esp.Bar.BackgroundColor3 = col
                    esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)
                end

                -- AIM判定
                if (not config.wallCheck or canSee) then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < near then target = head; near = dist end
                end
                
                -- AUTOFIRE判定
                if canSee and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 100 then fireAllowed = true end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    -- エイム実行
    if target and config.aimbot then
        local shouldAim = (config.aimMode == "STICKY") or (U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2))
        if shouldAim then
            local p = C:WorldToViewportPoint(target.Position)
            if mousemoverel then
                mousemoverel((p.X - center.X) * config.smooth, (p.Y - center.Y) * config.smooth)
            end
        end
    end

    -- オート射撃実行
    if config.autoFire and fireAllowed and mouse1press then
        mouse1press(); task.wait(0.01); mouse1release()
    end
end)

updateUI()
print("Harutoki Ultimate: FULL VERSION LOADED.")
