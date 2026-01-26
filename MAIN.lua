local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = false,
    aimMode = "STICKY", 
    autoFire = false,
    wallCheck = true,
    espFilter = true,
    smooth = 0.8,      -- 1だと飛びすぎる場合があるので0.8で超高速化
    pcFov = 500,
    maxDist = 600,
    menuOpen = false,
    hideUI = true 
}

-- --- GUI ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.IgnoreGuiInset = true; gui.ResetOnSpawn = false

for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name == "HarutokiUltimate" and v ~= gui then v:Destroy() end
end

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
    mode = createMenuBtn("MODE: STICKY", 95),
    fire = createMenuBtn("FIRE: OFF", 140),
    wall = createMenuBtn("FILTER: ON", 185),
    esp = createMenuBtn("ESP FIL: ON", 230),
    hide = createMenuBtn("HIDE UI: ON", 275),
    close = createMenuBtn("CLOSE", 320)
}

local function updateUI()
    menuFrame.Visible = config.menuOpen
    btns.aim.Text = "AIM(J): " .. (config.aimbot and "ON" or "OFF")
    btns.mode.Text = "MODE(U): " .. config.aimMode
    btns.fire.Text = "FIRE(K): " .. (config.autoFire and "ON" or "OFF")
    btns.wall.Text = "WALL(L): " .. (config.wallCheck and "ON" or "OFF")
    btns.esp.Text = "ESP FIL(N): " .. (config.espFilter and "ON" or "OFF")
    btns.hide.Text = "HIDE(M): " .. (config.hideUI and "ON" or "OFF")
end

local actions = {
    aim = function() config.aimbot = not config.aimbot; updateUI() end,
    mode = function() config.aimMode = (config.aimMode == "LOCK" and "STICKY" or "LOCK"); updateUI() end,
    fire = function() config.autoFire = not config.autoFire; updateUI() end,
    wall = function() config.wallCheck = not config.wallCheck; updateUI() end,
    esp = function() config.espFilter = not config.espFilter; updateUI() end,
    hide = function() config.hideUI = not config.hideUI; updateUI() end,
    menu = function() config.menuOpen = not config.menuOpen; updateUI() end
}

for k, v in pairs(btns) do if k ~= "close" then v.MouseButton1Click:Connect(function() actions[k]() end) end end
btns.close.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)

U.InputBegan:Connect(function(input, processed)
    if processed then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.RightShift then actions.menu()
    elseif key == Enum.KeyCode.J then actions.aim()
    elseif key == Enum.KeyCode.K then actions.fire()
    elseif key == Enum.KeyCode.L then actions.wall()
    elseif key == Enum.KeyCode.U then actions.mode()
    elseif key == Enum.KeyCode.N then actions.esp()
    elseif key == Enum.KeyCode.M then actions.hide()
    end
end)

-- --- ESP (体力バー復活) ---
local pESP = {}
local function createESP(v)
    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false
    local box = Instance.new("Frame", container); box.Size = UDim2.new(1, 0, 1, 0); box.BackgroundTransparency = 1
    local stroke = Instance.new("UIStroke", box); stroke.Thickness = 2; stroke.Color = Color3.new(0, 1, 0)
    
    -- 左側の体力バー背景
    local barBG = Instance.new("Frame", container); barBG.Size = UDim2.new(0, 4, 1, 0); barBG.Position = UDim2.new(0, -6, 0, 0); barBG.BackgroundColor3 = Color3.new(0,0,0); barBG.BorderSizePixel = 0
    -- 体力バー
    local bar = Instance.new("Frame", barBG); bar.Size = UDim2.new(1, 0, 1, 0); bar.AnchorPoint = Vector2.new(0, 1); bar.Position = UDim2.new(0, 0, 1, 0); bar.BackgroundColor3 = Color3.new(0, 1, 0); bar.BorderSizePixel = 0
    -- 体力数値
    local hNum = Instance.new("TextLabel", container); hNum.Size = UDim2.new(0, 40, 0, 14); hNum.Position = UDim2.new(0, -48, 0.5, -7); hNum.BackgroundTransparency = 1; hNum.TextColor3 = Color3.new(1,1,1); hNum.Font = Enum.Font.RobotoMono; hNum.TextScaled = true; hNum.TextXAlignment = Enum.TextXAlignment.Right; Instance.new("UIStroke", hNum)
    -- 名前
    local name = Instance.new("TextLabel", container); name.Size = UDim2.new(1, 0, 0, 14); name.Position = UDim2.new(0, 0, 0, -16); name.BackgroundTransparency = 1; name.TextColor3 = Color3.new(1,1,1); name.Font = Enum.Font.RobotoMono; name.TextScaled = true; Instance.new("UIStroke", name)
    
    pESP[v] = {Main = container, Bar = bar, HealthNum = hNum, Name = name, Stroke = stroke}
    return pESP[v]
end

P.PlayerRemoving:Connect(function(p) if pESP[p] then pESP[p].Main:Destroy(); pESP[p] = nil end end)

-- --- メインエンジン ---
local stickyTarget = nil

R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local bestPart, near = nil, config.pcFov
    local isRightClick = U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

    for _, v in pairs(P:GetPlayers()) do
        if v == LP or (LP.Team and v.Team == LP.Team) then if pESP[v] then pESP[v].Main.Visible = false end continue end
        local ch = v.Character; local head = ch and ch:FindFirstChild("Head")
        local hum = ch and ch:FindFirstChildWhichIsA("Humanoid")
        
        if head and hum and hum.Health > 0 then
            local dist = (C.CFrame.Position - head.Position).Magnitude
            if dist > config.maxDist then if pESP[v] then pESP[v].Main.Visible = false end continue end

            local pos, vis = C:WorldToViewportPoint(head.Position)
            local canSee = vis
            if config.wallCheck then
                local res = workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position), RaycastParams.new())
                if res and not res.Instance:IsDescendantOf(ch) then canSee = false end
            end

            -- ESP表示
            if vis then
                local esp = pESP[v] or createESP(v)
                local show = (not config.hideUI) and (not config.espFilter or canSee)
                esp.Main.Visible = show
                if show then
                    local hS = 2300/dist; local wS = hS * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X - wS/2, 0, pos.Y - hS/2); esp.Main.Size = UDim2.new(0, wS, 0, hS)
                    esp.Name.Text = v.DisplayName
                    esp.HealthNum.Text = math.floor(hum.Health)
                    esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)
                    local col = canSee and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                    esp.Stroke.Color = col; esp.Bar.BackgroundColor3 = col
                end
                
                if canSee or (not config.wallCheck and vis) then
                    local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if d < near then bestPart = head; near = d end
                end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    -- --- エイム制御 ---
    if config.aimbot then
        local targetToAim = nil
        if config.aimMode == "STICKY" then
            -- ロック継続判定
            if stickyTarget then
                local h = stickyTarget.Parent:FindFirstChildWhichIsA("Humanoid")
                local _, vis = C:WorldToViewportPoint(stickyTarget.Position)
                if not h or h.Health <= 0 or not vis then stickyTarget = nil end
            end
            if not stickyTarget then stickyTarget = bestPart end
            targetToAim = stickyTarget
        else
            if isRightClick then targetToAim = bestPart end
        end

        if targetToAim and mousemoverel then
            local p, _ = C:WorldToViewportPoint(targetToAim.Position)
            -- 差分を滑らかに移動（これで明後日の方向を向くのを防ぐ）
            local moveX = (p.X - center.X) * config.smooth
            local moveY = (p.Y - center.Y) * config.smooth
            mousemoverel(moveX, moveY)
        end
    end

    -- オートファイヤ
    if config.autoFire and bestPart then
        local p, _ = C:WorldToViewportPoint(bestPart.Position)
        if (Vector2.new(p.X, p.Y) - center).Magnitude < 100 and mouse1press then
            mouse1press(); task.wait(0.01); mouse1release()
        end
    end
end)
updateUI()
