-- Rivals Script: Harutoki Ultimate (Final Auto-Fire Fix)
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
    fov = 150,
    pcFov = 800,
    maxDistance = 500,
    menuOpen = false
}

-- GUI初期化
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false

for _, v in pairs(LP.PlayerGui:GetChildren()) do
    if v.Name == "HarutokiUltimate" and v ~= gui then v:Destroy() end
end

-- --- チーム判定関数 ---
local function isEnemy(v)
    if not v or v == LP then return false end
    if LP.Team and v.Team then return LP.Team ~= v.Team end
    if v:FindFirstChild("TeamColor") and LP:FindFirstChild("TeamColor") then
        return v.TeamColor ~= LP.TeamColor
    end
    return true
end

-- --- FOV円 ---
local fovCircle = Instance.new("Frame", gui)
fovCircle.BackgroundColor3 = Color3.new(1, 1, 1); fovCircle.BackgroundTransparency = 0.95
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5); fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle); fovStroke.Color = Color3.new(1, 1, 1); fovStroke.Thickness = 1

-- --- 設定メニュー ---
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 300); menuFrame.Position = UDim2.new(0.5, -110, 0.5, -150)
menuFrame.BackgroundColor3 = Color3.new(0, 0, 0); menuFrame.Visible = false
Instance.new("UIStroke", menuFrame).Color = Color3.new(1, 1, 1); Instance.new("UICorner", menuFrame)

local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame); b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); b.TextColor3 = Color3.new(1, 1, 1); b.Text = txt; b.TextScaled = true; b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b); return b
end

local aimBtn = createMenuBtn("AIMBOT", 50); local fireBtn = createMenuBtn("AUTO FIRE", 95); local wallBtn = createMenuBtn("FILTER", 140); local fovSetBtn = createMenuBtn("FOV SET", 185); local closeBtn = createMenuBtn("CLOSE", 230)

local mobileMenuBtn = Instance.new("TextButton", gui)
mobileMenuBtn.Size = UDim2.new(0, 100, 0, 40); mobileMenuBtn.Position = UDim2.new(0.5, -50, 1, -100)
mobileMenuBtn.BackgroundColor3 = Color3.new(0, 0, 0); mobileMenuBtn.TextColor3 = Color3.new(1, 1, 1); mobileMenuBtn.Text = "MENU"; Instance.new("UIStroke", mobileMenuBtn); Instance.new("UICorner", mobileMenuBtn)

local modeToggle = Instance.new("TextButton", gui)
modeToggle.Size = UDim2.new(0, 120, 0, 30); modeToggle.Position = UDim2.new(0, 10, 0, 10)
modeToggle.BackgroundColor3 = Color3.new(0, 0, 0); modeToggle.TextColor3 = Color3.new(1, 1, 1); modeToggle.TextScaled = true; Instance.new("UIStroke", modeToggle)

local function updateUI()
    modeToggle.Text = "MODE: " .. (config.isPC and "PC" or "MOBILE")
    menuFrame.Visible = config.menuOpen; mobileMenuBtn.Visible = not config.isPC
    fovSetBtn.Visible = not config.isPC; fovCircle.Visible = (not config.isPC and config.aimbot)
    fovCircle.Size = UDim2.new(0, config.fov * 2, 0, config.fov * 2)
    aimBtn.Text = "AIM: " .. (config.aimbot and "ON" or "OFF"); fireBtn.Text = "FIRE: " .. (config.autoFire and "ON" or "OFF")
    wallBtn.Text = "FILTER: " .. (config.wallCheck and "ON" or "OFF"); fovSetBtn.Text = "FOV: " .. config.fov
end

modeToggle.MouseButton1Click:Connect(function() config.isPC = not config.isPC; config.menuOpen = false; updateUI() end)
mobileMenuBtn.MouseButton1Click:Connect(function() config.menuOpen = not config.menuOpen; updateUI() end)
closeBtn.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)
aimBtn.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; updateUI() end)
fireBtn.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
wallBtn.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
fovSetBtn.MouseButton1Click:Connect(function() config.fov = (config.fov >= 400) and 100 or config.fov + 50; updateUI() end)

U.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.RightShift and config.isPC then config.menuOpen = not config.menuOpen; updateUI()
    elseif not gpe and input.KeyCode == Enum.KeyCode.J then config.wallCheck = not config.wallCheck; updateUI() end
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
    local function style(t) t.BackgroundTransparency, t.TextColor3, t.Font, t.TextScaled = 1, Color3.new(1, 1, 1), Enum.Font.RobotoMono, true; Instance.new("UIStroke", t) end
    style(name); style(healthNum)
    return {Main = container, Name = name, HealthNum = healthNum, Ava = ava, Bar = bar}
end

P.PlayerRemoving:Connect(function(v) if pESP[v] then pESP[v].Main:Destroy(); pESP[v] = nil end end)

-- --- メインループ ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character or not LP.Character:FindFirstChild("PrimaryPart") then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local targetHead = nil
    local canShoot = false  -- オートファイア許可
    local nearestDist = (config.isPC and config.pcFov or config.fov)

    for _, v in pairs(P:GetPlayers()) do
        if not isEnemy(v) then 
            if pESP[v] then pESP[v].Main.Visible = false end
            continue 
        end

        local char = v.Character; local hum = char and char:FindFirstChild("Humanoid")
        local head = char and char:FindFirstChild("Head")

        if head and hum and hum.Health > 0 then
            local dist = (head.Position - LP.Character.PrimaryPart.Position).Magnitude
            if dist <= config.maxDistance then
                if not pESP[v] then pESP[v] = createESP(v) end
                local esp = pESP[v]
                local pos, onScreen = C:WorldToViewportPoint(head.Position)

                -- 【重要】発射用の視認性チェック (常に壁を判定する)
                local actuallyVisible = false
                if onScreen then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {LP.Character, char, workspace.CurrentCamera}
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    local result = workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position).Unit * dist, rayParams)
                    if not result then actuallyVisible = true end -- 何も遮るものがない
                end

                -- エイム用の視認性判定 (メニューのFilter設定に従う)
                local aimVisible = true
                if config.wallCheck and not actuallyVisible then aimVisible = false end

                if onScreen and aimVisible then
                    esp.Main.Visible = true
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mouseDist < nearestDist then
                        targetHead = head
                        nearestDist = mouseDist
                        -- 画面内にいて、かつ壁に遮られていない時だけ発射許可を出す
                        if actuallyVisible then canShoot = true end
                    end
                    
                    -- ESP更新
                    local h = math.clamp(1000/pos.Z, 20, 500); local w = h * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                    esp.Name.Text = v.DisplayName; esp.HealthNum.Text = math.floor(hum.Health)
                    local color = (hum.Health > 80 and Color3.new(0,1,0)) or (hum.Health > 50 and Color3.new(1,1,0)) or Color3.new(1,0,0)
                    esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0); esp.Bar.BackgroundColor3 = color; esp.HealthNum.TextColor3 = color
                    esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                else
                    if esp then esp.Main.Visible = false end
                end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    -- 5. エイムとオートファイアの実行
    if targetHead and config.aimbot then
        local isAiming = config.isPC and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or not config.isPC
        if isAiming then
            local pos, _ = C:WorldToViewportPoint(targetHead.Position)
            local targetPos = Vector2.new(pos.X, pos.Y)
            
            -- エイム吸い付き
            if config.isPC and mousemoverel then
                mousemoverel((targetPos.X - center.X) * config.smooth, (targetPos.Y - center.Y) * config.smooth)
            else
                C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, targetHead.Position), config.smooth * 0.2)
            end
            
            -- オートファイア (canShootがtrueの時のみ)
            if config.autoFire and canShoot and mouse1press then
                mouse1press(); task.wait(0.01); mouse1release()
            end
        end
    end
end)
updateUI()
