-- Rivals Script: Harutoki Ultimate (Full Fix & Visual)
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
    pcFov = 800,      -- PC用固定
    maxDistance = 1000,
    menuOpen = false
}

-- GUI初期化
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

-- 古いUIの削除
for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name == "HarutokiUltimate" and v ~= gui then v:Destroy() end
end

-- --- FOV円 (スマホでしっかり見えるように修正) ---
local fovCircle = Instance.new("Frame", gui)
fovCircle.BackgroundColor3 = Color3.new(1, 1, 1); fovCircle.BackgroundTransparency = 0.95
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5); fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Visible = false
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle); fovStroke.Color = Color3.new(1, 1, 1); fovStroke.Thickness = 1

-- --- 設定メニュー ---
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 300); menuFrame.Position = UDim2.new(0.5, -110, 0.5, -150)
menuFrame.BackgroundColor3 = Color3.new(0, 0, 0); menuFrame.Visible = false; Instance.new("UIStroke", menuFrame).Color = Color3.new(1, 1, 1)

local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame); b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); b.TextColor3 = Color3.new(1, 1, 1); b.Text = txt; b.TextScaled = true; b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b); return b
end

local aimBtn = createMenuBtn("AIMBOT", 50); local fireBtn = createMenuBtn("AUTO FIRE", 95); local wallBtn = createMenuBtn("FILTER", 140); local fovSetBtn = createMenuBtn("FOV SET", 185); local closeBtn = createMenuBtn("CLOSE", 230)

-- --- スマホ用メニューボタン (画面下部中央) ---
local mobileMenuBtn = Instance.new("TextButton", gui)
mobileMenuBtn.Size = UDim2.new(0, 100, 0, 40); mobileMenuBtn.Position = UDim2.new(0.5, -50, 1, -60)
mobileMenuBtn.BackgroundColor3 = Color3.new(0, 0, 0); mobileMenuBtn.TextColor3 = Color3.new(1, 1, 1); mobileMenuBtn.Text = "MENU"; mobileMenuBtn.Visible = false; Instance.new("UIStroke", mobileMenuBtn)

-- --- PC/スマホ切替ボタン ---
local modeToggle = Instance.new("TextButton", gui)
modeToggle.Size = UDim2.new(0, 120, 0, 30); modeToggle.Position = UDim2.new(0, 10, 0, 10)
modeToggle.BackgroundColor3 = Color3.new(0, 0, 0); modeToggle.TextColor3 = Color3.new(1, 1, 1); modeToggle.TextScaled = true

local function updateUI()
    modeToggle.Text = "MODE: " .. (config.isPC and "PC" or "MOBILE")
    menuFrame.Visible = config.menuOpen
    mobileMenuBtn.Visible = not config.isPC
    fovSetBtn.Visible = not config.isPC -- PCは800固定なので非表示
    fovCircle.Visible = (not config.isPC and config.aimbot)
    fovCircle.Size = UDim2.new(0, config.fov * 2, 0, config.fov * 2)
    aimBtn.Text = "AIM: " .. (config.aimbot and "ON" or "OFF")
    fireBtn.Text = "FIRE: " .. (config.autoFire and "ON" or "OFF")
    wallBtn.Text = "FILTER: " .. (config.wallCheck and "ON" or "OFF")
    fovSetBtn.Text = "FOV: " .. config.fov
end

modeToggle.MouseButton1Click:Connect(function() config.isPC = not config.isPC; config.menuOpen = false; updateUI() end)
mobileMenuBtn.MouseButton1Click:Connect(function() config.menuOpen = not config.menuOpen; updateUI() end)
closeBtn.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)
aimBtn.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; updateUI() end)
fireBtn.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
wallBtn.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
fovSetBtn.MouseButton1Click:Connect(function() config.fov = (config.fov >= 400) and 100 or config.fov + 50; updateUI() end)

-- キー入力 (PC Shift & J)
U.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.RightShift then -- PC用: 右Shiftでメニュー
        config.menuOpen = not config.menuOpen; updateUI()
    elseif not gpe and input.KeyCode == Enum.KeyCode.J then -- Jキーでフィルター
        config.wallCheck = not config.wallCheck; updateUI()
    end
end)

-- --- ESPオブジェクト管理 ---
local pESP = {}
local function createESP(v)
    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false
    local mainFrame = Instance.new("Frame", container); mainFrame.Size = UDim2.new(1, 0, 1, 0); mainFrame.BackgroundTransparency = 1; Instance.new("UIStroke", mainFrame).Color = Color3.new(1,1,1)
    
    local name = Instance.new("TextLabel", container); name.Size = UDim2.new(1, 0, 0, 15); name.Position = UDim2.new(0, 0, 0, -18)
    local healthNum = Instance.new("TextLabel", container); healthNum.Size = UDim2.new(0, 40, 0, 15); healthNum.Position = UDim2.new(0, -45, 0, -5)
    local ava = Instance.new("ImageLabel", container); ava.Size = UDim2.new(0.6, 0, 0.6, 0); ava.Position = UDim2.new(0.2, 0, 0.2, 0); ava.BackgroundTransparency = 1
    local barBG = Instance.new("Frame", container); barBG.Size = UDim2.new(0, 4, 1, 0); barBG.Position = UDim2.new(0, -8, 0, 0); barBG.BackgroundColor3 = Color3.new(0,0,0)
    local bar = Instance.new("Frame", barBG); bar.Size = UDim2.new(1, 0, 1, 0); bar.AnchorPoint = Vector2.new(0, 1); bar.Position = UDim2.new(0, 0, 1, 0)
    local stats = Instance.new("TextLabel", container); stats.Size = UDim2.new(1, 100, 0, 15); stats.Position = UDim2.new(1, 5, 1, -5)

    local function style(t) t.BackgroundTransparency, t.TextColor3, t.Font, t.TextScaled = 1, Color3.new(1, 1, 1), Enum.Font.RobotoMono, true; Instance.new("UIStroke", t) end
    style(name); style(healthNum); style(stats)

    return {Main = container, Name = name, HealthNum = healthNum, Ava = ava, Bar = bar, Stats = stats}
end

-- 抜けたプレイヤーを消す処理
P.PlayerRemoving:Connect(function(v) if pESP[v] then pESP[v].Main:Destroy(); pESP[v] = nil end end)

-- --- メインループ ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local target, nearest = nil, (config.isPC and config.pcFov or config.fov)

    for _, v in pairs(P:GetPlayers()) do
        if v ~= LP then
            local char = v.Character; local hum = char and char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and (not v.Team or v.Team ~= LP.Team) then
                if not pESP[v] then pESP[v] = createESP(v) end
                local esp = pESP[v]; local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos, onScreen = C:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local hPos = C:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 1, 0))
                        local fPos = C:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        local h = math.abs(hPos.Y - fPos.Y); local w = h * 0.7
                        
                        esp.Main.Visible = true; esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                        esp.Name.Text = v.DisplayName; esp.HealthNum.Text = math.floor(hum.Health)
                        
                        local color = Color3.new(1, 0, 0)
                        if hum.Health > 80 then color = Color3.new(0, 1, 0) elseif hum.Health > 50 then color = Color3.new(1, 1, 0) elseif hum.Health > 25 then color = Color3.new(1, 0.5, 0) end
                        esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0); esp.Bar.BackgroundColor3 = color; esp.HealthNum.TextColor3 = color
                        esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                        
                        local lv = v:FindFirstChild("leaderstats") and v.leaderstats:FindFirstChild("Level") and v.leaderstats.Level.Value or 0
                        esp.Stats.Text = "Lv: "..lv

                        local isVisible = #C:GetPartsObscuringTarget({char.Head.Position}, {char, LP.Character}) == 0
                        if (not config.wallCheck) or isVisible then
                            local dC = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if dC < nearest then target = char.Head; nearest = dC end
                        end
                    else esp.Main.Visible = false end
                end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        end
    end

    -- エイム
    if target and config.aimbot then
        local isAim = config.isPC and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or not config.isPC
        if isAim then
            local pos = C:WorldToViewportPoint(target.Position)
            if config.isPC and mousemoverel then
                mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)
            else
                C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, target.Position), config.smooth * 0.4)
            end
            if config.autoFire and mouse1press then mouse1press(); task.wait(0.01); mouse1release() end
        end
    end
end)
updateUI()
