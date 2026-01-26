-- Rivals Script: Harutoki Ultimate (Fix: Input Logic & Cleanup)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = false,   -- 起動時はOFF
    aimMode = "LOCK", -- LOCK / STICKY
    autoFire = false, -- 起動時はOFF
    wallCheck = true,
    espFilter = true,
    smooth = 0.2,
    pcFov = 800,
    maxDistance = 1000,
    menuOpen = false,
    hideUI = true     -- 起動時はON
}

-- --- GUI作成 (エラー回避のためシンプルに構成) ---
local gui = Instance.new("ScreenGui")
gui.Name = "HarutokiUltimate"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui")

-- 古いGUIの消去
for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name == "HarutokiUltimate" and v ~= gui then v:Destroy() end
end

-- --- 設定メニュー ---
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 400); menuFrame.Position = UDim2.new(0.5, -110, 0.5, -200)
menuFrame.BackgroundColor3 = Color3.new(0, 0, 0); menuFrame.Visible = false
Instance.new("UIStroke", menuFrame).Color = Color3.new(1, 1, 1); Instance.new("UICorner", menuFrame)

local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame); b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); b.TextColor3 = Color3.new(1, 1, 1); b.Text = txt; b.TextScaled = true; b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b); return b
end

local aimBtn = createMenuBtn("AIM: OFF", 50)
local modeBtn = createMenuBtn("MODE: LOCK", 95)
local fireBtn = createMenuBtn("FIRE: OFF", 140)
local wallBtn = createMenuBtn("AIM FIL: ON", 185)
local eFilBtn = createMenuBtn("ESP FIL: ON", 230)
local hideBtn = createMenuBtn("HIDE UI: ON", 275)
local closeBtn = createMenuBtn("CLOSE", 320)

local function updateUI()
    menuFrame.Visible = config.menuOpen
    aimBtn.Text = "AIM: " .. (config.aimbot and "ON" or "OFF")
    modeBtn.Text = "MODE: " .. config.aimMode
    fireBtn.Text = "FIRE: " .. (config.autoFire and "ON" or "OFF")
    wallBtn.Text = "AIM FIL: " .. (config.wallCheck and "ON" or "OFF")
    eFilBtn.Text = "ESP FIL: " .. (config.espFilter and "ON" or "OFF")
    hideBtn.Text = "HIDE UI: " .. (config.hideUI and "ON" or "OFF")
end

-- --- キー入力処理 (InputBeganを確実に検知するように修正) ---
U.InputBegan:Connect(function(input, gpe)
    if gpe and input.KeyCode ~= Enum.KeyCode.RightShift then return end
    
    local code = input.KeyCode
    if code == Enum.KeyCode.RightShift then
        config.menuOpen = not config.menuOpen
    elseif code == Enum.KeyCode.J then
        config.aimbot = not config.aimbot
        if config.aimbot then config.aimMode = "LOCK" end
    elseif code == Enum.KeyCode.CloseBracket then -- "]"
        if config.aimbot then config.aimMode = (config.aimMode == "LOCK" and "STICKY" or "LOCK") end
    elseif code == Enum.KeyCode.K then
        config.autoFire = not config.autoFire
    elseif code == Enum.KeyCode.L then
        config.wallCheck = not config.wallCheck
    elseif code == Enum.KeyCode.QuotedPrintable or code == Enum.KeyCode.Colon then -- ":"
        config.espFilter = not config.espFilter
    elseif code == Enum.KeyCode.Semicolon then -- ";"
        config.hideUI = not config.hideUI
    end
    updateUI()
end)

-- ボタンクリックイベント
aimBtn.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; if config.aimbot then config.aimMode = "LOCK" end; updateUI() end)
modeBtn.MouseButton1Click:Connect(function() if config.aimbot then config.aimMode = (config.aimMode == "LOCK" and "STICKY" or "LOCK") end; updateUI() end)
fireBtn.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
wallBtn.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
eFilBtn.MouseButton1Click:Connect(function() config.espFilter = not config.espFilter; updateUI() end)
hideBtn.MouseButton1Click:Connect(function() config.hideUI = not config.hideUI; updateUI() end)
closeBtn.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)

-- --- ESP & Engine (ロジック維持) ---
local pESP = {}
local function isEnemy(v)
    if not v or v == LP then return false end
    if LP.Team and v.Team then return LP.Team ~= v.Team end
    return true
end

local function createESP(v)
    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false
    local mainFrame = Instance.new("Frame", container); mainFrame.Size = UDim2.new(1, 0, 1, 0); mainFrame.BackgroundTransparency = 1
    local stroke = Instance.new("UIStroke", mainFrame); stroke.Thickness = 2
    local name = Instance.new("TextLabel", container); name.Size = UDim2.new(1, 0, 0, 15); name.Position = UDim2.new(0, 0, 0, -18)
    name.BackgroundTransparency = 1; name.TextColor3 = Color3.new(1,1,1); name.TextScaled = true; Instance.new("UIStroke", name)
    pESP[v] = {Main = container, Stroke = stroke, Name = name}
    return pESP[v]
end

P.PlayerRemoving:Connect(function(v) if pESP[v] then pESP[v].Main:Destroy(); pESP[v] = nil end end)

R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local targetHead, nearestDist = nil, config.pcFov
    local fireAllowed = false

    for _, v in pairs(P:GetPlayers()) do
        if not isEnemy(v) then if pESP[v] then pESP[v].Main.Visible = false end continue end
        local char = v.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")

        if head and hum and hum.Health > 0 then
            local pos, onScreen = C:WorldToViewportPoint(head.Position)
            if onScreen then
                local esp = pESP[v] or createESP(v)
                local rayParams = RaycastParams.new(); rayParams.FilterDescendantsInstances = {LP.Character, char, C}; rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local isVisible = not workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position).Unit * 500, rayParams)

                esp.Main.Visible = (not config.hideUI) and ((not config.espFilter) or isVisible)
                if esp.Main.Visible then
                    local h = math.clamp(1000/pos.Z, 10, 500); local w = h * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                    esp.Stroke.Color = isVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                end

                if (not config.wallCheck) or isVisible then
                    local mDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mDist < nearestDist then targetHead = head; nearestDist = mDist end
                end
                if isVisible and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 100 then fireAllowed = true end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    if targetHead and config.aimbot then
        local am = config.aimMode
        if am == "STICKY" or (am == "LOCK" and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
            local pos, _ = C:WorldToViewportPoint(targetHead.Position)
            if mousemoverel then mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth) end
        end
    end

    if config.autoFire and fireAllowed and mouse1press then
        mouse1press(); task.wait(0.01); mouse1release()
    end
end)
