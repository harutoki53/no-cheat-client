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
    smooth = 0.2,
    pcFov = 500,
    menuOpen = false,
    hideUI = false 
}

-- --- GUI ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.IgnoreGuiInset = true; gui.ResetOnSpawn = false; gui.DisplayOrder = 9999

for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name == "HarutokiUltimate" and v ~= gui then v:Destroy() end
end

local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 420); menuFrame.Position = UDim2.new(0.5, -110, 0.5, -210)
menuFrame.BackgroundColor3 = Color3.new(0, 0, 0); menuFrame.Visible = false
Instance.new("UIStroke", menuFrame).Color = Color3.new(1, 1, 1); Instance.new("UICorner", menuFrame)

local credits = Instance.new("TextLabel", menuFrame)
credits.Size = UDim2.new(1, 0, 0, 20); credits.Position = UDim2.new(0, 0, 1, 5)
credits.BackgroundTransparency = 1; credits.TextColor3 = Color3.new(1, 1, 1); credits.Font = Enum.Font.RobotoMono
credits.Text = "create by harutoki53"; credits.TextSize = 12

local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame); b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); b.TextColor3 = Color3.new(1, 1, 1); b.Text = txt; b.TextScaled = true; b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b); return b
end

local btns = {
    aim = createMenuBtn("AIM: OFF", 50),
    mode = createMenuBtn("MODE: LOCK", 95),
    fire = createMenuBtn("FIRE: OFF", 140),
    wall = createMenuBtn("FILTER: ON", 185),
    esp = createMenuBtn("ESP FIL: ON", 230),
    hide = createMenuBtn("HIDE: OFF", 275),
    close = createMenuBtn("CLOSE", 320)
}

local function updateUI()
    menuFrame.Visible = config.menuOpen
    btns.aim.Text = "AIM(J): " .. (config.aimbot and "ON" or "OFF")
    btns.mode.Text = "MODE(U): " .. config.aimMode
    btns.fire.Text = "FIRE(K): " .. (config.autoFire and "ON" or "OFF")
    btns.wall.Text = "WALL(L): " .. (config.wallCheck and "ON" or "OFF")
    btns.esp.Text = "ESP(N): " .. (config.espFilter and "ON" or "OFF")
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

-- --- キー入力判定 (InputBeganで確実に検知) ---
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

-- --- ESP ---
local pESP = {}
local function createESP(v)
    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false; container.AnchorPoint = Vector2.new(0.5, 0.5)
    local stroke = Instance.new("UIStroke", Instance.new("Frame", container)); stroke.Thickness = 2; stroke.Color = Color3.new(0, 1, 0); stroke.Parent.Size = UDim2.new(1,0,1,0); stroke.Parent.BackgroundTransparency = 1
    local ava = Instance.new("ImageLabel", container); ava.Size = UDim2.new(0.6, 0, 0.6, 0); ava.Position = UDim2.new(0.2, 0, 0.2, 0); ava.BackgroundTransparency = 1; ava.ImageTransparency = 0.3
    local barBG = Instance.new("Frame", container); barBG.Size = UDim2.new(0, 4, 1, 0); barBG.Position = UDim2.new(0, -7, 0, 0); barBG.BackgroundColor3 = Color3.new(0,0,0)
    local bar = Instance.new("Frame", barBG); bar.Size = UDim2.new(1, 0, 1, 0); bar.AnchorPoint = Vector2.new(0, 1); bar.Position = UDim2.new(0, 0, 1, 0); bar.BorderSizePixel = 0
    local hNum = Instance.new("TextLabel", container); hNum.Size = UDim2.new(0, 40, 0, 15); hNum.Position = UDim2.new(0, -50, 0.5, -7); hNum.BackgroundTransparency = 1; hNum.TextColor3 = Color3.new(1,1,1); hNum.Font = Enum.Font.RobotoMono; hNum.TextScaled = true; Instance.new("UIStroke", hNum)
    local name = Instance.new("TextLabel", container); name.Size = UDim2.new(1, 0, 0, 15); name.Position = UDim2.new(0, 0, 0, -20); name.BackgroundTransparency = 1; name.TextColor3 = Color3.new(1,1,1); name.Font = Enum.Font.RobotoMono; name.TextScaled = true; Instance.new("UIStroke", name)
    pESP[v] = {Main = container, Name = name, HealthNum = hNum, Bar = bar, Stroke = stroke, Ava = ava}
    return pESP[v]
end

-- --- Main Loop ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local target, near = nil, config.pcFov
    local fireOk = false

    for _, v in pairs(P:GetPlayers()) do
        if v == LP or (LP.Team and v.Team == LP.Team) then if pESP[v] then pESP[v].Main.Visible = false end continue end
        local ch = v.Character; local root = ch and ch:FindFirstChild("HumanoidRootPart")
        local hum = ch and ch:FindFirstChildWhichIsA("Humanoid")
        
        if root and hum and hum.Health > 0 then
            local pos, vis = C:WorldToViewportPoint(root.Position)
            local canSee = vis
            if config.wallCheck then
                local res = workspace:Raycast(C.CFrame.Position, (root.Position - C.CFrame.Position), RaycastParams.new())
                if res and not res.Instance:IsDescendantOf(ch) then canSee = false end
            end

            if vis then
                local esp = pESP[v] or createESP(v)
                local show = (not config.hideUI) and ((not config.espFilter) or canSee)
                esp.Main.Visible = show
                if show then
                    local dist = (C.CFrame.Position - root.Position).Magnitude
                    local hS = math.clamp(2300/dist, 15, 800); local wS = hS * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X, 0, pos.Y); esp.Main.Size = UDim2.new(0, wS, 0, hS)
                    esp.Name.Text = v.DisplayName; esp.HealthNum.Text = math.floor(hum.Health)
                    esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                    local col = canSee and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                    esp.Stroke.Color = col; esp.Bar.BackgroundColor3 = col; esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0); esp.HealthNum.TextColor3 = col
                end
                if canSee and (Vector2.new(pos.X, pos.Y) - center).Magnitude < near then target = ch:FindFirstChild("Head") or root; near = (Vector2.new(pos.X, pos.Y) - center).Magnitude end
                if canSee and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 120 then fireOk = true end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    if config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and target then
        local p, vis = C:WorldToViewportPoint(target.Position)
        if vis and mousemoverel then mousemoverel((p.X - center.X) * config.smooth, (p.Y - center.Y) * config.smooth) end
    end
    if config.autoFire and fireOk and mouse1press then mouse1press(); task.wait(0.01); mouse1release() end
end)
updateUI()
