-- Rivals Script: Harutoki Ultimate (Error Fixed)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = true,
    autoFire = true,
    wallCheck = true,
    smooth = 0.4,
    pcFov = 800,
    maxDistance = 1000,
    menuOpen = false
}

-- --- GUI作成 (エラーの出た行を修正) ---
local gui = Instance.new("ScreenGui")
-- エラー対策: 親を後から設定し、問題のプロパティを削除
gui.Name = "HarutokiUltimate"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 9999
-- gui.DisplayOnAppWindow = false  <-- これがエラーの原因だったので削除しました

-- 実行環境によっては CoreGui に入れることで OBS に映らなくなる場合があります
local success, parent = pcall(function() return game:GetService("CoreGui") end)
gui.Parent = success and parent or LP:WaitForChild("PlayerGui")

-- 古いUIのクリーンアップ
for _, v in pairs(gui.Parent:GetChildren()) do
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

local aimBtn = createMenuBtn("AIMBOT", 50)
local fireBtn = createMenuBtn("AUTO FIRE", 95)
local wallBtn = createMenuBtn("FILTER", 140)
local closeBtn = createMenuBtn("CLOSE", 185)

local function updateUI()
    menuFrame.Visible = config.menuOpen
    aimBtn.Text = "AIM: " .. (config.aimbot and "ON" or "OFF")
    fireBtn.Text = "FIRE: " .. (config.autoFire and "ON" or "OFF")
    wallBtn.Text = "FILTER: " .. (config.wallCheck and "ON" or "OFF")
end

aimBtn.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; updateUI() end)
fireBtn.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
wallBtn.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
closeBtn.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)

U.InputBegan:Connect(function(i, gpe)
    if not gpe and i.KeyCode == Enum.KeyCode.RightShift then
        config.menuOpen = not config.menuOpen; updateUI()
    end
end)

-- --- ESPオブジェクト管理 ---
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

-- --- メインエンジン ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character then return end
    
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local targetHead, nearestDist = nil, config.pcFov
    local fireAllowed = false

    for _, v in pairs(P:GetPlayers()) do
        if not isEnemy(v) then 
            if pESP[v] then pESP[v].Main.Visible = false end
            continue 
        end

        local char = v.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart", true))
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")

        if head and hum and hum.Health > 0 then
            local pos, onScreen = C:WorldToViewportPoint(head.Position)
            local dist = (head.Position - C.CFrame.Position).Magnitude

            if onScreen and dist <= config.maxDistance then
                local esp = pESP[v] or createESP(v)
                
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LP.Character, char, C}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position).Unit * dist, rayParams)
                local isVisible = not result

                esp.Main.Visible = true
                local h = math.clamp(1000/pos.Z, 10, 500); local w = h * 0.7
                esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                esp.Name.Text = v.DisplayName; esp.HealthNum.Text = math.floor(hum.Health)
                esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                
                local color = isVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                esp.Stroke.Color = color
                esp.Bar.BackgroundColor3 = color
                esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)

                if (not config.wallCheck) or isVisible then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mouseDist < nearestDist then
                        targetHead = head
                        nearestDist = mouseDist
                    end
                end

                if isVisible and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 100 then
                    fireAllowed = true
                end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    if targetHead and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local pos, _ = C:WorldToViewportPoint(targetHead.Position)
        if mousemoverel then
            mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)
        end
    end

    if config.autoFire and fireAllowed and mouse1press then
        mouse1press(); task.wait(0.01); mouse1release()
    end
end)

updateUI()
print("Harutoki Ultimate: Fixed & Running")
