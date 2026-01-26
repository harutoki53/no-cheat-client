-- Rivals Script: Harutoki Ultimate (Final Stable & Realistic Build)
-- Keybinds: J, K, L, U, N, M | RightShift (Menu)

local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

-- --- [1] Configuration ---
local config = {
    aimbot = false,
    aimMode = "LOCK", -- LOCK (右クリ) / STICKY (常に)
    autoFire = false,
    wallCheck = true,
    espFilter = true,
    smooth = 0.18,
    pcFov = 800,
    menuOpen = false,
    hideUI = true -- 起動時はON (Mキーで解除)
}

-- --- [2] GUI System ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.ResetOnSpawn = false

-- 古いGUIを完全に削除
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

local function createBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame)
    b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = txt; b.TextSize = 14; b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b); return b
end

local btns = {
    aim = createBtn("AIM: OFF", 50),
    mode = createBtn("MODE: LOCK", 95),
    fire = createBtn("FIRE: OFF", 140),
    wall = createBtn("AIM FIL: ON", 185),
    esp = createBtn("ESP FIL: ON", 230),
    hide = createBtn("HIDE UI: ON", 275),
    close = createBtn("CLOSE", 320)
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

-- --- [3] Action Logic ---
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

-- --- [4] Detection Logic (判定の甘い改良版) ---
local function isTargetVisible(char)
    if not char then return false end
    local cam = workspace.CurrentCamera
    local partsToTest = {
        char:FindFirstChild("Head"),
        char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"),
        char:FindFirstChild("HumanoidRootPart")
    }
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LP.Character, char, cam}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    for _, part in pairs(partsToTest) do
        if part then
            local origin = cam.CFrame.Position
            local direction = (part.Position - origin)
            local result = workspace:Raycast(origin, direction, rayParams)
            
            -- 何も遮るものがない、または遮っているものが敵自身の体なら「可視」
            if not result or result.Instance:IsDescendantOf(char) then
                return true
            end
        end
    end
    return false
end

-- --- [5] ESP System ---
local pESP = {}
local function createESP(v)
    local c = Instance.new("Frame", gui); c.BackgroundTransparency = 1; c.Visible = false
    local m = Instance.new("Frame", c); m.Size = UDim2.new(1, 0, 1, 0); m.BackgroundTransparency = 1; local s = Instance.new("UIStroke", m); s.Thickness = 2
    local n = Instance.new("TextLabel", c); n.Size = UDim2.new(1, 0, 0, 15); n.Position = UDim2.new(0, 0, 0, -18); n.BackgroundTransparency = 1; n.TextColor3 = Color3.new(1,1,1); n.TextScaled = true; n.Font = Enum.Font.RobotoMono; Instance.new("UIStroke", n)
    pESP[v] = {Main = c, Stroke = s, Name = n}
    return pESP[v]
end

P.PlayerRemoving:Connect(function(v) if pESP[v] then pESP[v].Main:Destroy(); pESP[v] = nil end end)

-- --- [6] Main Engine ---
local keyState = {}
R.RenderStepped:Connect(function()
    -- キー判定 (超低遅延)
    if not U:GetFocusedTextBox() then
        local function h(k, a) if U:IsKeyDown(k) then if not keyState[k] then a(); keyState[k]=true; updateUI() end else keyState[k]=false end end
        h(Enum.KeyCode.RightShift, actions.menu); h(Enum.KeyCode.J, actions.aim); h(Enum.KeyCode.K, actions.fire)
        h(Enum.KeyCode.L, actions.wall); h(Enum.KeyCode.U, actions.mode); h(Enum.KeyCode.N, actions.esp); h(Enum.KeyCode.M, actions.hide)
    end

    local C = workspace.CurrentCamera; if not C or not LP.Character then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local target, near = nil, config.pcFov; local fireOk = false

    for _, v in pairs(P:GetPlayers()) do
        if v == LP or (LP.Team and v.Team == LP.Team) then if pESP[v] then pESP[v].Main.Visible = false end continue end
        local ch = v.Character; local hum = ch and ch:FindFirstChildWhichIsA("Humanoid")
        local head = ch and ch:FindFirstChild("Head")
        
        if head and hum and hum.Health > 0 then
            local pos, onScreen = C:WorldToViewportPoint(head.Position)
            local canSee = isTargetVisible(ch)
            
            if onScreen then
                local esp = pESP[v] or createESP(v)
                local show = (not config.hideUI) and ((not config.espFilter) or canSee)
                esp.Main.Visible = show
                if show then
                    local hSize = math.clamp(1000/pos.Z, 10, 500); local wSize = hSize * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X - wSize/2, 0, pos.Y - hSize/2); esp.Main.Size = UDim2.new(0, wSize, 0, hSize)
                    esp.Name.Text = v.DisplayName; esp.Stroke.Color = canSee and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                end

                if (not config.wallCheck or canSee) then
                    local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if d < near then
                        -- 【リアリティ】75%頭、25%胴体をランダムでターゲット
                        target = (math.random(1, 100) <= 75) and head or ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso") or head
                        near = d 
                    end
                end
                if canSee and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 120 then fireOk = true end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    -- エイムボット実行
    if target and config.aimbot then
        local isPressed = U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if config.aimMode == "STICKY" or isPressed then
            local p = C:WorldToViewportPoint(target.Position)
            if mousemoverel then
                mousemoverel((p.X - center.X) * config.smooth, (p.Y - center.Y) * config.smooth)
            end
        end
    end

    -- オート射撃
    if config.autoFire and fireOk and mouse1press then
        mouse1press(); task.wait(0.01); mouse1release()
    end
end)

updateUI()
print("Harutoki Ultimate: THE FINAL COMPLETE EDITION Loaded.")
