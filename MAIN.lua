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

-- --- GUI ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.ResetOnSpawn = false

for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name == "HarutokiUltimate" and v ~= gui then v:Destroy() end
end

local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 400); menuFrame.Position = UDim2.new(0.5, -110, 0.5, -200)
menuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); menuFrame.Visible = false
Instance.new("UIStroke", menuFrame).Color = Color3.new(1, 1, 1); Instance.new("UICorner", menuFrame)

local function createBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame); b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.TextColor3 = Color3.new(1, 1, 1); b.Text = txt; b.TextSize = 14; b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b); return b
end

local btns = {
    aim = createBtn("AIM: OFF", 50), mode = createBtn("MODE: LOCK", 95), fire = createBtn("FIRE: OFF", 140),
    wall = createBtn("AIM FIL: ON", 185), esp = createBtn("ESP FIL: ON", 230), hide = createBtn("HIDE UI: ON", 275), close = createBtn("CLOSE", 320)
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

local actions = {
    aim = function() config.aimbot = not config.aimbot; if config.aimbot then config.aimMode = "LOCK" end end,
    mode = function() if config.aimbot then config.aimMode = (config.aimMode == "LOCK" and "STICKY" or "LOCK") end end,
    fire = function() config.autoFire = not config.autoFire end,
    wall = function() config.wallCheck = not config.wallCheck end,
    esp = function() config.espFilter = not config.espFilter end,
    hide = function() config.hideUI = not config.hideUI end,
    menu = function() config.menuOpen = not config.menuOpen end
}

for k, v in pairs(btns) do if k ~= "close" then v.MouseButton1Click:Connect(function() actions[k](); updateUI() end) end end
btns.close.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)

-- --- [判定の最速・最適化] ---
local function canSeePlayer(targetChar)
    if not targetChar then return false end
    local cam = workspace.CurrentCamera
    local parts = {targetChar:FindFirstChild("Head"), targetChar:FindFirstChild("UpperTorso")}
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LP.Character, targetChar, cam} -- 自分と敵とカメラを無視
    params.FilterType = Enum.RaycastFilterType.Exclude

    for _, p in pairs(parts) do
        if p then
            local res = workspace:Raycast(cam.CFrame.Position, (p.Position - cam.CFrame.Position), params)
            if not res then return true end -- 障害物なし
        end
    end
    return false
end

-- --- ESP ---
local pESP = {}
local function createESP(v)
    local c = Instance.new("Frame", gui); c.BackgroundTransparency = 1; c.Visible = false
    local m = Instance.new("Frame", c); m.Size = UDim2.new(1, 0, 1, 0); m.BackgroundTransparency = 1; local s = Instance.new("UIStroke", m); s.Thickness = 2
    local n = Instance.new("TextLabel", c); n.Size = UDim2.new(1, 0, 0, 15); n.Position = UDim2.new(0, 0, 0, -18); n.BackgroundTransparency = 1; n.TextColor3 = Color3.new(1,1,1); n.TextScaled = true; n.Font = Enum.Font.RobotoMono; Instance.new("UIStroke", n)
    pESP[v] = {Main = c, Stroke = s, Name = n}
    return pESP[v]
end

P.PlayerRemoving:Connect(function(v) if pESP[v] then pESP[v].Main:Destroy(); pESP[v] = nil end end)

-- --- MAIN ENGINE ---
local kState = {}
R.RenderStepped:Connect(function()
    if not U:GetFocusedTextBox() then
        local function h(k, a) if U:IsKeyDown(k) then if not kState[k] then a(); kState[k]=true; updateUI() end else kState[k]=false end end
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
                    esp.Name.Text = v.DisplayName; esp.Stroke.Color = canSee and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                end

                if (not config.wallCheck or canSee) then
                    local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if d < near then
                        target = (math.random(1, 100) <= 75) and head or ch:FindFirstChild("UpperTorso") or head
                        near = d 
                    end
                end
                if canSee and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 120 then fireOk = true end
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
