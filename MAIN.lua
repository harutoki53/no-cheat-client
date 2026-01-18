-- Rivals Script: Ultimate Hybrid Edition (Harutoki Custom)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = true,
    autoFire = true,
    wallCheck = true,
    isPC = true,
    smooth = 0.4,
    fov = 150,        -- スマホ用初期値
    pcFov = 800,      -- PC用固定値
    maxDistance = 500,
    menuOpen = false
}

-- 既存のGUIを削除
local old = LP:WaitForChild("PlayerGui"):FindFirstChild("HarutokiUltimate")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.IgnoreGuiInset = true

-- --- FOV円 (スマホのみ) ---
local fovCircle = Instance.new("Frame", gui)
fovCircle.BackgroundColor3 = Color3.new(1, 1, 1); fovCircle.BackgroundTransparency = 0.9
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5); fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle); fovStroke.Color = Color3.new(1, 1, 1)

-- --- 設定メニュー ---
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 280); menuFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
menuFrame.BackgroundColor3 = Color3.new(0, 0, 0); menuFrame.BackgroundTransparency = 0.1; menuFrame.Visible = false
Instance.new("UICorner", menuFrame); Instance.new("UIStroke", menuFrame).Color = Color3.new(1, 1, 1)

local title = Instance.new("TextLabel", menuFrame)
title.Size = UDim2.new(1, 0, 0, 40); title.Text = "HARUTOKI SETTINGS"; title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1; title.TextScaled = true; title.Font = Enum.Font.RobotoMono

-- --- 常時表示: PC/スマホ切替 ---
local modeToggle = Instance.new("TextButton", gui)
modeToggle.Size = UDim2.new(0, 160, 0, 35); modeToggle.Position = UDim2.new(0, 10, 0, 10)
modeToggle.BackgroundColor3 = Color3.new(0, 0, 0); modeToggle.BackgroundTransparency = 0.5
modeToggle.TextColor3 = Color3.new(1, 1, 1); modeToggle.TextScaled = true; modeToggle.Font = Enum.Font.RobotoMono
Instance.new("UIStroke", modeToggle)

-- --- スマホ用メニューボタン ---
local mobileMenuBtn = Instance.new("TextButton", gui)
mobileMenuBtn.Size = UDim2.new(0, 100, 0, 35); mobileMenuBtn.Position = UDim2.new(0, 10, 0, 50)
mobileMenuBtn.Text = "MENU"; mobileMenuBtn.BackgroundColor3 = Color3.new(0, 0, 0); mobileMenuBtn.TextColor3 = Color3.new(1, 1, 0); mobileMenuBtn.Visible = false
Instance.new("UIStroke", mobileMenuBtn)

-- --- メニュー内ボタン ---
local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame)
    b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = txt; b.TextScaled = true; b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b); return b
end

local aimBtn = createMenuBtn("AIMBOT", 50)
local fireBtn = createMenuBtn("AUTO FIRE", 95)
local wallBtn = createMenuBtn("FILTER", 140)
local fovBtn = createMenuBtn("MOBILE FOV", 185) -- PCでは消す
local closeBtn = createMenuBtn("CLOSE", 230); closeBtn.BackgroundColor3 = Color3.new(0.4, 0.1, 0.1)

local function updateUI()
    modeToggle.Text = "MODE: " .. (config.isPC and "PC" or "MOBILE")
    mobileMenuBtn.Visible = not config.isPC
    menuFrame.Visible = config.menuOpen
    
    -- PCならFOVボタンを隠す
    fovBtn.Visible = not config.isPC
    fovCircle.Visible = (not config.isPC and config.aimbot)
    fovCircle.Size = UDim2.new(0, config.fov * 2, 0, config.fov * 2)
    
    aimBtn.Text = "AIMBOT: " .. (config.aimbot and "ON [K]" or "OFF [K]")
    aimBtn.TextColor3 = config.aimbot and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    fireBtn.Text = "AUTO FIRE: " .. (config.autoFire and "ON [L]" or "OFF [L]")
    fireBtn.TextColor3 = config.autoFire and Color3.new(1, 0.8, 0) or Color3.new(1, 0, 0)
    wallBtn.Text = "FILTER: " .. (config.wallCheck and "ON [J]" or "OFF [J]")
    wallBtn.TextColor3 = config.wallCheck and Color3.new(0, 1, 1) or Color3.new(1, 0.5, 0)
    fovBtn.Text = "MOBILE FOV: " .. config.fov
end

-- --- インタラクション ---
modeToggle.MouseButton1Click:Connect(function() config.isPC = not config.isPC; config.menuOpen = false; updateUI() end)
mobileMenuBtn.MouseButton1Click:Connect(function() config.menuOpen = not config.menuOpen; updateUI() end)
closeBtn.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)
aimBtn.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; updateUI() end)
fireBtn.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
wallBtn.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
fovBtn.MouseButton1Click:Connect(function() config.fov = (config.fov >= 450) and 100 or config.fov + 50; updateUI() end)

U.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift and config.isPC then config.menuOpen = not config.menuOpen; updateUI()
    elseif input.KeyCode == Enum.KeyCode.K then config.aimbot = not config.aimbot; updateUI()
    elseif input.KeyCode == Enum.KeyCode.L then config.autoFire = not config.autoFire; updateUI()
    elseif input.KeyCode == Enum.KeyCode.J then config.wallCheck = not config.wallCheck; updateUI() end
end)

-- --- ESP描写関数 ---
local function createESP(v)
    local f = Instance.new("Frame", gui); f.BackgroundTransparency = 1; f.Visible = false
    local esp = {
        Main = f,
        Name = Instance.new("TextLabel", f),
        HealthBarBG = Instance.new("Frame", f),
        HealthBar = Instance.new("Frame", f),
        Distance = Instance.new("TextLabel", f)
    }
    local function style(l) l.BackgroundTransparency, l.TextColor3, l.TextScaled, l.Font = 1, Color3.new(1,1,1), true, Enum.Font.RobotoMono; Instance.new("UIStroke", l) end
    style(esp.Name); style(esp.Distance); esp.HealthBarBG.BackgroundColor3 = Color3.new(0,0,0)
    esp.HealthBar.BorderSizePixel = 0; esp.HealthBar.Parent = esp.HealthBarBG
    return esp
end
local pESP = {}

-- --- メインループ ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C then return end
    local mousePos = U:GetMouseLocation()
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local target, nearest = nil, (config.isPC and config.pcFov or config.fov)

    for _, v in pairs(P:GetPlayers()) do
        local char = v.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")

        if v ~= LP and hum and root and head and hum.Health > 0 then
            if not pESP[v] then pESP[v] = createESP(v) end
            local esp = pESP[v]
            local pos, onScreen = C:WorldToViewportPoint(head.Position)

            if onScreen then
                local dist = (root.Position - C.CFrame.Position).Magnitude
                local isVisible = #C:GetPartsObscuringTarget({head.Position}, {char, LP.Character}) == 0
                
                -- ESP表示
                esp.Main.Visible = true
                esp.Name.Text = v.DisplayName; esp.Name.Position = UDim2.new(0, pos.X-50, 0, pos.Y-40); esp.Name.Size = UDim2.new(0, 100, 0, 15)
                esp.Distance.Text = math.floor(dist).."m"; esp.Distance.Position = UDim2.new(0, pos.X-50, 0, pos.Y+20); esp.Distance.Size = UDim2.new(0, 100, 0, 12)
                esp.HealthBarBG.Position = UDim2.new(0, pos.X-25, 0, pos.Y-20); esp.HealthBarBG.Size = UDim2.new(0, 50, 0, 3)
                esp.HealthBar.Size = UDim2.new(hum.Health/hum.MaxHealth, 0, 1, 0); esp.HealthBar.BackgroundColor3 = (hum.Health/hum.MaxHealth > 0.5) and Color3.new(0,1,0) or Color3.new(1,0,0)

                -- エイム判定 (FILTER連動)
                if (not config.wallCheck) or isVisible then
                    local distCenter = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if distCenter < nearest then target = head; nearest = distCenter end
                end
            else esp.Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    -- 実行
    if target and config.aimbot then
        local isAim = config.isPC and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or not config.isPC
        if isAim then
            local pos = C:WorldToViewportPoint(target.Position)
            if config.isPC and mousemoverel then
                mousemoverel((pos.X - mousePos.X) * config.smooth, (pos.Y - mousePos.Y) * config.smooth)
            else
                C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, target.Position), config.smooth * 0.4)
            end
            if config.autoFire and mouse1press then mouse1press(); task.wait(0.01); mouse1release() end
        end
    end
end)
updateUI()
