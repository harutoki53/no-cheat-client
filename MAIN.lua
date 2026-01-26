-- Rivals Script: Harutoki Ultimate (Final Stable Build)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

-- --- 初期設定 ---
local config = {
    aimbot = false,   -- 起動時はOFF
    aimMode = "LOCK", -- LOCK (右クリ) / STICKY (自動)
    autoFire = false, -- 起動時はOFF
    wallCheck = true,
    espFilter = true,
    smooth = 0.22,    -- 滑らかさを最適化
    pcFov = 800,
    maxDistance = 1000,
    menuOpen = false,
    hideUI = true     -- [リクエスト] 起動時はON
}

-- --- GUI作成 (エラー回避・クリーンアップ) ---
local gui = Instance.new("ScreenGui")
gui.Name = "HarutokiUltimate"
gui.ResetOnSpawn = false
gui.DisplayOrder = 9999
gui.Parent = LP:WaitForChild("PlayerGui")

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

-- --- キー入力ロジック (Value判定でエラーを防止) ---
U.InputBegan:Connect(function(input, gpe)
    if gpe and input.KeyCode ~= Enum.KeyCode.RightShift then return end
    local k = input.KeyCode.Value

    if k == 306 or k == 1306 then -- RightShift
        config.menuOpen = not config.menuOpen
    elseif k == 106 then -- J: AIM
        config.aimbot = not config.aimbot
        if config.aimbot then config.aimMode = "LOCK" end
    elseif k == 107 then -- K: FIRE
        config.autoFire = not config.autoFire
    elseif k == 108 then -- L: AIM FILTER
        config.wallCheck = not config.wallCheck
    elseif k == 93 then -- ]: MODE SWITCH
        if config.aimbot then config.aimMode = (config.aimMode == "LOCK" and "STICKY" or "LOCK") end
    elseif k == 58 or k == 44 then -- : (Colon / Keypad Period)
        config.espFilter = not config.espFilter
    elseif k == 59 then -- ;: HIDE UI
        config.hideUI = not config.hideUI
    end
    updateUI()
end)

-- ボタン操作
btns.aim.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; if config.aimbot then config.aimMode = "LOCK" end; updateUI() end)
btns.mode.MouseButton1Click:Connect(function() if config.aimbot then config.aimMode = (config.aimMode == "LOCK" and "STICKY" or "LOCK") end; updateUI() end)
btns.fire.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
btns.wall.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
btns.esp.MouseButton1Click:Connect(function() config.espFilter = not config.espFilter; updateUI() end)
btns.hide.MouseButton1Click:Connect(function() config.hideUI = not config.hideUI; updateUI() end)
btns.close.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)

-- --- ESP & Engine ---
local pESP = {}
local function createESP(v)
    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false
    local mainFrame = Instance.new("Frame", container); mainFrame.Size = UDim2.new(1, 0, 1, 0); mainFrame.BackgroundTransparency = 1
    local stroke = Instance.new("UIStroke", mainFrame); stroke.Thickness = 2
    local name = Instance.new("TextLabel", container); name.Size = UDim2.new(1, 0, 0, 15); name.Position = UDim2.new(0, 0, 0, -18)
    name.BackgroundTransparency = 1; name.TextColor3 = Color3.new(1,1,1); name.TextScaled = true; Instance.new("UIStroke", name)
    local ava = Instance.new("ImageLabel", container); ava.Size = UDim2.new(0.6, 0, 0.6, 0); ava.Position = UDim2.new(0.2, 0, 0.2, 0); ava.BackgroundTransparency = 1
    local barBG = Instance.new("Frame", container); barBG.Size = UDim2.new(0, 4, 1, 0); barBG.Position = UDim2.new(0, -8, 0, 0); barBG.BackgroundColor3 = Color3.new(0,0,0)
    local bar = Instance.new("Frame", barBG); bar.Size = UDim2.new(1, 0, 1, 0); bar.AnchorPoint = Vector2.new(0, 1); bar.Position = UDim2.new(0, 0, 1, 0)
    
    pESP[v] = {Main = container, Stroke = stroke, Name = name, Ava = ava, Bar = bar}
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
        if v == LP or (LP.Team and v.Team == LP.Team) then 
            if pESP[v] then pESP[v].Main.Visible = false end continue 
        end
        local char = v.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")

        if head and hum and hum.Health > 0 then
            local pos, onScreen = C:WorldToViewportPoint(head.Position)
            if onScreen then
                local esp = pESP[v] or createESP(v)
                local rayParams = RaycastParams.new(); rayParams.FilterDescendantsInstances = {LP.Character, char, C}; rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local isVisible = not workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position).Unit * 500, rayParams)

                local show = (not config.hideUI) and ((not config.espFilter) or isVisible)
                esp.Main.Visible = show
                if show then
                    local h = math.clamp(1000/pos.Z, 10, 500); local w = h * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                    esp.Name.Text = v.DisplayName; esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                    local col = isVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                    esp.Stroke.Color = col; esp.Bar.BackgroundColor3 = col
                    esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)
                end

                if (not config.wallCheck or isVisible) then
                    local mDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mDist < nearestDist then targetHead = head; nearestDist = mDist end
                end
                if isVisible and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 100 then fireAllowed = true end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    if targetHead and config.aimbot then
        if config.aimMode == "STICKY" or U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local pos = C:WorldToViewportPoint(targetHead.Position)
            if mousemoverel then mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth) end
        end
    end

    if config.autoFire and fireAllowed and mouse1press then
        mouse1press(); task.wait(0.01); mouse1release()
    end
end)

updateUI()
print("Harutoki Ultimate: All Systems Ready.")
