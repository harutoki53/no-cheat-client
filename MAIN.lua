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
    smooth = 0.15,      -- 吸いつきを少し強化
    pcFov = 400,
    maxDist = 500,     -- 遠くの敵を無視（値を調整可能）
    menuOpen = false,
    hideUI = true
}

-- --- GUI ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate_Final_Complete"
gui.IgnoreGuiInset = true; gui.ResetOnSpawn = false

for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name:find("HarutokiUltimate") and v ~= gui then v:Destroy() end
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
    wall = createMenuBtn("WALL FIL: ON", 185),
    esp = createMenuBtn("DIST FIL: ON", 230),
    hide = createMenuBtn("HIDE UI: ON", 275),
    close = createMenuBtn("CLOSE", 320)
}

local function updateUI()
    menuFrame.Visible = config.menuOpen
    btns.aim.Text = "AIM(J): " .. (config.aimbot and "ON" or "OFF")
    btns.mode.Text = "MODE(U): " .. config.aimMode
    btns.fire.Text = "FIRE(K): " .. (config.autoFire and "ON" or "OFF")
    btns.wall.Text = "WALL(L): " .. (config.wallCheck and "ON" or "OFF")
    btns.esp.Text = "DIST(N): " .. (config.espFilter and "ON" or "OFF")
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
    elseif key == Enum.KeyCode.N then actions.esp()
    elseif key == Enum.KeyCode.M then actions.hide()
    end
end)

-- --- ESP ---
local pESP = {}
local function createESP(v)
    if v == LP then return nil end 
    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false
    local box = Instance.new("Frame", container); box.Size = UDim2.new(1, 0, 1, 0); box.BackgroundTransparency = 1
    local stroke = Instance.new("UIStroke", box); stroke.Thickness = 2; stroke.Color = Color3.new(0, 1, 0)
    local barBG = Instance.new("Frame", container); barBG.Size = UDim2.new(0, 4, 1, 0); barBG.Position = UDim2.new(0, -7, 0, 0); barBG.BackgroundColor3 = Color3.new(0,0,0); barBG.BorderSizePixel = 0
    local bar = Instance.new("Frame", barBG); bar.Size = UDim2.new(1, 0, 1, 0); bar.AnchorPoint = Vector2.new(0, 1); bar.Position = UDim2.new(0, 0, 1, 0); bar.BackgroundColor3 = Color3.new(0, 1, 0); bar.BorderSizePixel = 0
    local hNum = Instance.new("TextLabel", container); hNum.Size = UDim2.new(0, 40, 0, 14); hNum.Position = UDim2.new(0, -50, 0.5, -7); hNum.BackgroundTransparency = 1; hNum.TextColor3 = Color3.new(1,1,1); hNum.Font = Enum.Font.RobotoMono; hNum.TextScaled = true; hNum.TextXAlignment = Enum.TextXAlignment.Right; Instance.new("UIStroke", hNum)
    pESP[v] = {Main = container, Bar = bar, HealthNum = hNum, Stroke = stroke}
    return pESP[v]
end

P.PlayerRemoving:Connect(function(p)
    if pESP[p] then pESP[p].Main:Destroy(); pESP[p] = nil end
end)

-- 壁チェック関数
local function isVisible(targetPart)
    if not config.wallCheck then return true end
    local C = workspace.CurrentCamera
    local char = targetPart.Parent
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LP.Character, C}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(C.CFrame.Position, (targetPart.Position - C.CFrame.Position), rayParams)
    return result == nil or result.Instance:IsDescendantOf(char)
end

local function getBestTarget()
    local target, near = nil, config.pcFov
    local C = workspace.CurrentCamera
    for _, v in pairs(P:GetPlayers()) do
        if v == LP or (v.Team ~= nil and LP.Team ~= nil and v.Team == LP.Team) then continue end
        local head = v.Character and v.Character:FindFirstChild("Head")
        local hum = v.Character and v.Character:FindFirstChildWhichIsA("Humanoid")
        if head and hum and hum.Health > 0 then
            local dist = (C.CFrame.Position - head.Position).Magnitude
            if dist > config.maxDist then continue end -- 遠すぎたら無視
            
            local pos, vis = C:WorldToViewportPoint(head.Position)
            if vis and isVisible(head) then
                local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)).Magnitude
                if d < near then near = d; target = head end
            end
        end
    end
    return target
end

local stickyTarget = nil

R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C then return end
    
    -- ESP Loop
    for _, v in pairs(P:GetPlayers()) do
        if v == LP or (v.Team ~= nil and LP.Team ~= nil and v.Team == LP.Team) then 
            if pESP[v] then pESP[v].Main.Visible = false end continue 
        end

        local head = v.Character and v.Character:FindFirstChild("Head")
        local hum = v.Character and v.Character:FindFirstChildWhichIsA("Humanoid")
        
        if head and hum and hum.Health > 0 then
            local dist = (C.CFrame.Position - head.Position).Magnitude
            local pos, vis = C:WorldToViewportPoint(head.Position)
            
            -- 距離フィルター & 壁チェック & 画面内
            local canShow = (not config.hideUI) and (dist <= config.maxDist) and vis and isVisible(head)
            
            if canShow then
                local esp = pESP[v] or createESP(v)
                if esp then
                    esp.Main.Visible = true
                    local hS = 2300/dist; local wS = hS * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X - wS/2, 0, pos.Y - hS/2); esp.Main.Size = UDim2.new(0, wS, 0, hS)
                    esp.HealthNum.Text = math.floor(hum.Health)
                    esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)
                end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    -- Aim & Fire
    local currentTarget = nil
    if config.aimbot then
        if config.aimMode == "STICKY" then
            if not stickyTarget or not stickyTarget.Parent or stickyTarget.Parent:FindFirstChildWhichIsA("Humanoid").Health <= 0 or (C.CFrame.Position - stickyTarget.Position).Magnitude > config.maxDist or not isVisible(stickyTarget) then
                stickyTarget = getBestTarget()
            end
            currentTarget = stickyTarget
        else
            stickyTarget = nil
            if U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then currentTarget = getBestTarget() end
        end

        if currentTarget then
            C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, currentTarget.Position), config.smooth)
        end
    else
        stickyTarget = nil
    end

    if config.autoFire and currentTarget then
        local p, vis = C:WorldToViewportPoint(currentTarget.Position)
        if vis and (Vector2.new(p.X, p.Y) - Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)).Magnitude < 30 then
            if mouse1press then mouse1press(); task.wait(0.01); mouse1release() end
        end
    end
end)

updateUI()
