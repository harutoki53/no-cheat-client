-- Rivals Script: Harutoki Ultimate (ESP RELOADED)
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
    maxDistance = 1000, -- 距離を伸ばして検証しやすくしました
    menuOpen = false
}

-- --- GUI初期化 (最前面に強制表示) ---
local gui = LP:WaitForChild("PlayerGui"):FindFirstChild("HarutokiUltimate")
if gui then gui:Destroy() end

gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "HarutokiUltimate"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 999 -- 他のUIより手前に表示

-- --- チーム判定 (継承) ---
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

-- --- 設定メニュー (起点デザイン) ---
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

local function updateUI()
    menuFrame.Visible = config.menuOpen
    fovCircle.Visible = (not config.isPC and config.aimbot)
    fovCircle.Size = UDim2.new(0, config.fov * 2, 0, config.fov * 2)
    aimBtn.Text = "AIM: " .. (config.aimbot and "ON" or "OFF")
    fireBtn.Text = "FIRE: " .. (config.autoFire and "ON" or "OFF")
    wallBtn.Text = "FILTER: " .. (config.wallCheck and "ON" or "OFF")
    fovSetBtn.Text = "FOV: " .. config.fov
end

aimBtn.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; updateUI() end)
fireBtn.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
wallBtn.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
closeBtn.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)
U.InputBegan:Connect(function(i, g) if i.KeyCode == Enum.KeyCode.RightShift then config.menuOpen = not config.menuOpen; updateUI() end end)

-- --- ESPオブジェクト作成 ---
local pESP = {}
local function createESP(v)
    local c = Instance.new("Frame", gui); c.BackgroundTransparency = 1; c.Visible = false
    local m = Instance.new("Frame", c); m.Size = UDim2.new(1, 0, 1, 0); m.BackgroundTransparency = 1; local s = Instance.new("UIStroke", m); s.Thickness = 1.5
    local n = Instance.new("TextLabel", c); n.Size = UDim2.new(1, 0, 0, 15); n.Position = UDim2.new(0, 0, 0, -18)
    local hN = Instance.new("TextLabel", c); hN.Size = UDim2.new(0, 40, 0, 15); hN.Position = UDim2.new(0, -45, 0, -5)
    local bG = Instance.new("Frame", c); bG.Size = UDim2.new(0, 4, 1, 0); bG.Position = UDim2.new(0, -8, 0, 0); bG.BackgroundColor3 = Color3.new(0,0,0)
    local b = Instance.new("Frame", bG); b.Size = UDim2.new(1, 0, 1, 0); b.AnchorPoint = Vector2.new(0, 1); b.Position = UDim2.new(0, 0, 1, 0)
    
    local function style(t) t.BackgroundTransparency, t.TextColor3, t.Font, t.TextScaled = 1, Color3.new(1, 1, 1), Enum.Font.RobotoMono, true; Instance.new("UIStroke", t) end
    style(n); style(hN)
    
    pESP[v] = {Main = c, Name = n, HealthNum = hN, Bar = b, Stroke = s}
    return pESP[v]
end

-- --- メインループ ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local targetHead = nil
    local nearestDist = (config.isPC and config.pcFov or config.fov)

    for _, v in pairs(P:GetPlayers()) do
        if not isEnemy(v) then 
            if pESP[v] then pESP[v].Main.Visible = false end
            continue 
        end

        local char = v.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        local hum = char and char:FindFirstChild("Humanoid")

        if head and hum and hum.Health > 0 then
            local pos, onScreen = C:WorldToViewportPoint(head.Position)
            local dist = (head.Position - C.CFrame.Position).Magnitude

            if onScreen and dist <= config.maxDistance then
                local esp = pESP[v] or createESP(v)
                
                -- 壁越し判定
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LP.Character, char, C}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position).Unit * dist, rayParams)
                local isVisible = not result

                -- ESP更新 (ここが重要)
                esp.Main.Visible = true
                local h = math.clamp(1000/pos.Z, 10, 500); local w = h * 0.7
                esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                esp.Name.Text = v.Name; esp.HealthNum.Text = math.floor(hum.Health)
                esp.Stroke.Color = isVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)
                esp.Bar.BackgroundColor3 = isVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)

                -- エイム判定 (FILTER設定を考慮)
                if (not config.wallCheck) or isVisible then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mouseDist < nearestDist then
                        targetHead = head
                        nearestDist = mouseDist
                    end
                end
            else
                if pESP[v] then pESP[v].Main.Visible = false end
            end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    -- エイム
    if targetHead and config.aimbot then
        local isAim = config.isPC and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or not config.isPC
        if isAim then
            local pos, _ = C:WorldToViewportPoint(targetHead.Position)
            if config.isPC and mousemoverel then
                mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)
            else
                C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, targetHead.Position), config.smooth * 0.25)
            end
            if config.autoFire and mouse1press then
                mouse1press(); task.wait(0.01); mouse1release()
            end
        end
    end
end)
updateUI()
