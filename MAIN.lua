-- Harutoki Ultimate: Full Restore & Elite ESP Edition
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
    smooth = 0.18,
    pcFov = 800,
    menuOpen = false,
    hideUI = true 
}

-- --- GUI Parent ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 9999

for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name == "HarutokiUltimate" and v ~= gui then v:Destroy() end
end

-- --- 設定メニュー (復元デザイン) ---
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
    aim = createMenuBtn("AIMBOT", 50),
    mode = createMenuBtn("MODE: LOCK", 95),
    fire = createMenuBtn("AUTO FIRE", 140),
    wall = createMenuBtn("FILTER", 185),
    esp = createMenuBtn("ESP FIL", 230),
    hide = createMenuBtn("HIDE UI", 275),
    close = createMenuBtn("CLOSE", 320)
}

local function updateUI()
    menuFrame.Visible = config.menuOpen
    btns.aim.Text = "AIM: " .. (config.aimbot and "ON" or "OFF")
    btns.mode.Text = "MODE: " .. config.aimMode
    btns.fire.Text = "FIRE: " .. (config.autoFire and "ON" or "OFF")
    btns.wall.Text = "FILTER: " .. (config.wallCheck and "ON" or "OFF")
    btns.esp.Text = "ESP FIL: " .. (config.espFilter and "ON" or "OFF")
    btns.hide.Text = "HIDE UI: " .. (config.hideUI and "ON" or "OFF")
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

-- --- [判定ロジック] ---
local function canSeePlayer(targetChar)
    if not targetChar then return false end
    local cam = workspace.CurrentCamera
    local parts = {targetChar:FindFirstChild("Head"), targetChar:FindFirstChild("UpperTorso")}
    local params = RaycastParams.new(); params.FilterDescendantsInstances = {LP.Character, targetChar, cam}; params.FilterType = Enum.RaycastFilterType.Exclude
    for _, p in pairs(parts) do
        if p then
            local res = workspace:Raycast(cam.CFrame.Position, (p.Position - cam.CFrame.Position), params)
            if not res then return true end
        end
    end
    return false
end

-- --- ESP完全復元デザイン ---
local pESP = {}
local function createESP(v)
    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false
    local mainFrame = Instance.new("Frame", container); mainFrame.Size = UDim2.new(1, 0, 1, 0); mainFrame.BackgroundTransparency = 1; local stroke = Instance.new("UIStroke", mainFrame); stroke.Thickness = 2
    local name = Instance.new("TextLabel", container); name.Size = UDim2.new(1, 0, 0, 15); name.Position = UDim2.new(0, 0, 0, -18)
    local healthNum = Instance.new("TextLabel", container); healthNum.Size = UDim2.new(0, 40, 0, 15); healthNum.Position = UDim2.new(0, -45, 0, -5)
    local ava = Instance.new("ImageLabel", container); ava.Size = UDim2.new(0.6, 0, 0.6, 0); ava.Position = UDim2.new(0.2, 0, 0.2, 0); ava.BackgroundTransparency = 1
    local barBG = Instance.new("Frame", container); barBG.Size = UDim2.new(0, 4, 1, 0); barBG.Position = UDim2.new(0, -8, 0, 0); barBG.BackgroundColor3 = Color3.new(0,0,0)
    local bar = Instance.new("Frame", barBG); bar.Size = UDim2.new(1, 0, 1, 0); bar.AnchorPoint = Vector2.new(0, 1); bar.Position = UDim2.new(0, 0, 1, 0)
    
    local function style(t)
        t.BackgroundTransparency, t.TextColor3, t.Font, t.TextScaled = 1, Color3.new(1, 1, 1), Enum.Font.RobotoMono, true
        Instance.new("UIStroke", t)
    end
    style(name); style(healthNum)
    
    pESP[v] = {Main = container, Name = name, HealthNum = healthNum, Ava = ava, Bar = bar, Stroke = stroke}
    return pESP[v]
end

P.PlayerRemoving:Connect(function(v) if pESP[v] then pESP[v].Main:Destroy(); pESP[v] = nil end end)

-- --- MAIN ENGINE ---
local kState = {}
R.RenderStepped:Connect(function()
    if not U:GetFocusedTextBox() then
        local function h(k, a) if U:IsKeyDown(k) then if not kState[k] then a(); kState[k]=true; end else kState[k]=false end end
        h(Enum.KeyCode.RightShift, actions.menu); h(Enum.KeyCode.J, actions.aim); h(Enum.KeyCode.K, actions.fire)
        h(Enum.KeyCode.L, actions.wall); h(Enum.KeyCode.U, actions.mode); h(Enum.KeyCode.N, actions.esp); h(Enum.KeyCode.M, actions.hide)
    end

    local C = workspace.CurrentCamera; if not C or not LP.Character then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local target, near = nil, config.pcFov; local fireOk = false

    for _, v in pairs(P:GetPlayers()) do
        if v == LP or (LP.Team and v.Team == LP.Team) then if pESP[v] then pESP[v].Main.Visible = false end continue end
        local ch = v.Character; local head = ch and ch:FindFirstChild("Head")
        local hum = ch and ch:FindFirstChildWhichIsA("Humanoid")
        
        if head and hum and hum.Health > 0 then
            local pos, vis = C:WorldToViewportPoint(head.Position)
            local canSee = canSeePlayer(ch)
            
            if vis then
                local esp = pESP[v] or createESP(v)
                local show = (not config.hideUI) and ((not config.espFilter) or canSee)
                esp.Main.Visible = show
                if show then
                    local hS = math.clamp(1000/pos.Z, 10, 500); local wS = hS * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X - wS/2, 0, pos.Y - hS/2); esp.Main.Size = UDim2.new(0, wS, 0, hS)
                    esp.Name.Text = v.DisplayName; esp.HealthNum.Text = math.floor(hum.Health)
                    esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                    
                    local color = canSee and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                    esp.Stroke.Color = color
                    esp.Bar.BackgroundColor3 = color
                    esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)
                end

                if (not config.wallCheck or canSee) then
                    local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if d < near then
                        target = (math.random(1, 100) <= 75) and head or ch:FindFirstChild("UpperTorso") or head
                        near = d 
                    end
                end
                if canSee and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 100 then fireOk = true end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    if target and config.aimbot then
        if config.aimMode == "STICKY" or U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local p = C:WorldToViewportPoint(target.Position)
            if mousemoverel then mousemoverel((p.X - center.X) * config.smooth, (p.Y - center.Y) * config.smooth) end
        end
    end
    if config.autoFire and fireOk and mouse1press then mouse1press(); task.wait(0.01); mouse1release() end
end)
updateUI()
