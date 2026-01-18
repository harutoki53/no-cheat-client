-- Rivals Script by harutoki53 (Box ESP + Aimbot + Toggle Indicators)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer
local C = workspace.CurrentCamera

-- 設定（初期状態）
local config = {
    aimbot = true,
    wallCheck = true,
    smooth = 0.2,
    fov = 150
}

local ParentGui = (gethui and gethui()) or game:GetService("CoreGui")
local gui = Instance.new("ScreenGui", ParentGui)

-- --- オンオフ状態の表示（画面左上） ---
local Indicators = Instance.new("Frame", gui)
Indicators.Size = UDim2.new(0, 150, 0, 50)
Indicators.Position = UDim2.new(0, 10, 0, 10)
Indicators.BackgroundTransparency = 1

local function createText(name, pos, text)
    local l = Instance.new("TextLabel", Indicators)
    l.Name = name
    l.Size = UDim2.new(1, 0, 0.5, 0)
    l.Position = pos
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1, 1, 1)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextScaled = true
    return l
end

local AimStatus = createText("AimStatus", UDim2.new(0,0,0,0), "Aimbot: ON [K]")
local WallStatus = createText("WallStatus", UDim2.new(0,0,0.5,0), "WallCheck: ON [J]")

local function updateIndicators()
    AimStatus.Text = "Aimbot: " .. (config.aimbot and "ON" or "OFF") .. " [K]"
    AimStatus.TextColor3 = config.aimbot and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    WallStatus.Text = "WallCheck: " .. (config.wallCheck and "ON" or "OFF") .. " [J]"
    WallStatus.TextColor3 = config.wallCheck and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
end
updateIndicators()

-- --- ESP要素の作成 ---
local function createESP(player)
    local esp = {Box = Instance.new("Frame", gui)}
    esp.Box.BackgroundTransparency, esp.Box.BorderSizePixel, esp.Box.Visible = 1, 1, false
    esp.Box.BorderColor3 = Color3.new(1,1,1)

    esp.HealthNum = Instance.new("TextLabel", esp.Box)
    esp.HealthNum.Size, esp.HealthNum.Position = UDim2.new(0,30,0,15), UDim2.new(0,-35,0,-15)
    esp.HealthNum.BackgroundTransparency, esp.HealthNum.TextColor3, esp.HealthNum.TextScaled = 1, Color3.new(1,1,1), true

    esp.BarBG = Instance.new("Frame", esp.Box)
    esp.BarBG.Size, esp.BarBG.Position, esp.BarBG.BackgroundColor3 = UDim2.new(0,4,1,0), UDim2.new(0,-8,0,0), Color3.new(0,0,0)

    esp.Bar = Instance.new("Frame", esp.BarBG)
    esp.Bar.Size, esp.Bar.Position, esp.Bar.BorderSizePixel = UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 0

    esp.Name = Instance.new("TextLabel", esp.Box)
    esp.Name.Size, esp.Name.Position = UDim2.new(1,0,0,15), UDim2.new(0,0,0,-18)
    esp.Name.BackgroundTransparency, esp.Name.TextColor3, esp.Name.TextScaled = 1, Color3.new(1,1,1), true

    esp.Ava = Instance.new("ImageLabel", esp.Box)
    esp.Ava.Size, esp.Ava.Position, esp.Ava.BackgroundTransparency = UDim2.new(0,40,0,40), UDim2.new(1,5,0,0), 1

    esp.Info = Instance.new("TextLabel", esp.Box)
    esp.Info.Size, esp.Info.Position = UDim2.new(0,80,0,20), UDim2.new(1,5,0,45)
    esp.Info.BackgroundTransparency, esp.Info.TextColor3, esp.Info.TextScaled = 1, Color3.new(1,1,1), true
    esp.Info.TextXAlignment = Enum.TextXAlignment.Left

    return esp
end

local playerESP = {}

local function getHealthColor(p)
    if p >= 80 then return Color3.new(0, 1, 0)
    elseif p >= 50 then return Color3.new(1, 1, 0)
    elseif p >= 25 then return Color3.fromRGB(255, 165, 0)
    else return Color3.new(1, 0, 0)
    end
end

R.RenderStepped:Connect(function()
    local mousePos = U:GetMouseLocation()
    local target, nearest = nil, config.fov

    for _, v in pairs(P:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if not playerESP[v] then playerESP[v] = createESP(v) end
                local esp = playerESP[v]
                local pos, onScreen = C:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                
                if onScreen then
                    local headPos = C:WorldToViewportPoint(v.Character.Head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = C:WorldToViewportPoint(v.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0))
                    local h = math.abs(headPos.Y - legPos.Y)
                    local w = h * 0.6
                    
                    esp.Box.Visible = true
                    esp.Box.Size = UDim2.new(0, w, 0, h)
                    esp.Box.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2)
                    
                    local p = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                    esp.HealthNum.Text = tostring(math.floor(hum.Health))
                    esp.Bar.Size, esp.Bar.BackgroundColor3 = UDim2.new(1, 0, p, 0), getHealthColor(p * 100)
                    esp.Name.Text = v.DisplayName or v.Name
                    esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                    
                    local s = v:FindFirstChild("leaderstats")
                    local lv = s and s:FindFirstChild("Level") and s.Level.Value or "?"
                    local st = s and s:FindFirstChild("Streak") and s.Streak.Value or 0
                    esp.Info.Text = st > 0 and "Lv."..lv.."\n"..st.."連勝" or "Lv."..lv

                    if (not config.wallCheck or #C:GetPartsObscuringTarget({v.Character.Head.Position}, {LP.Character, v.Character}) == 0) then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if dist < nearest then target, nearest = v, dist end
                    end
                else esp.Box.Visible = false end
            elseif playerESP[v] then playerESP[v].Box.Visible = false end
        end
    end

    if target and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local headPos = C:WorldToViewportPoint(target.Character.Head.Position)
        local move = (Vector2.new(headPos.X, headPos.Y) - mousePos) * config.smooth
        if mousemoverel then mousemoverel(move.X, move.Y) end
    end
end)

U.InputBegan:Connect(function(i, g)
    if not g then
        if i.KeyCode == Enum.KeyCode.K then
            config.aimbot = not config.aimbot
            updateIndicators()
        elseif i.KeyCode == Enum.KeyCode.J then
            config.wallCheck = not config.wallCheck
            updateIndicators()
        end
    end
end)
