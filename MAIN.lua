-- Rivals Script by harutoki53 (Target Tracking UI)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

-- カメラ準備待ち
local function getCamera()
    local cam = workspace.CurrentCamera
    while not cam do task.wait() cam = workspace.CurrentCamera end
    return cam
end
local C = getCamera()

local ParentGui = (gethui and gethui()) or game:GetService("CoreGui")
local gui = Instance.new("ScreenGui", ParentGui)
gui.Name = "HarutokiTrackingFinal"

-- 設定
local config = { aimbot = true, wallCheck = true, smooth = 0.2, fov = 150 }

-- --- 追従UIの構築 ---
local F = Instance.new("Frame", gui)
F.Size = UDim2.new(0, 200, 0, 100) -- 少しコンパクトに
F.BackgroundColor3, F.BackgroundTransparency, F.Visible = Color3.new(0,0,0), 0.4, false

-- 体力数値
local HealthNum = Instance.new("TextLabel", F)
HealthNum.Size, HealthNum.Position = UDim2.new(0.3,0,0.2,0), UDim2.new(0.05,0,-0.2,0)
HealthNum.BackgroundTransparency, HealthNum.TextColor3, HealthNum.TextScaled = 1, Color3.new(1,1,1), true

-- 体力バー背景
local HB_BG = Instance.new("Frame", F)
HB_BG.Size, HB_BG.Position, HB_BG.BackgroundColor3 = UDim2.new(0, 10, 0.8, 0), UDim2.new(0.05, 0, 0.1, 0), Color3.fromRGB(30, 30, 30)

-- 体力バー中身
local Bar = Instance.new("Frame", HB_BG)
Bar.Size, Bar.Position, Bar.BorderSizePixel = UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 0

-- 名前
local Name = Instance.new("TextLabel", F)
Name.Size, Name.Position = UDim2.new(0.6, 0, 0.2, 0), UDim2.new(0.3, 0, 0.05, 0)
Name.BackgroundTransparency, Name.TextColor3, Name.TextScaled = 1, Color3.new(1,1,1), true
Name.TextXAlignment = Enum.TextXAlignment.Left

-- アバター
local Ava = Instance.new("ImageLabel", F)
Ava.Size, Ava.Position = UDim2.new(0.4, 0, 0.4, 0), UDim2.new(0.35, 0, 0.3, 0)
Ava.BackgroundTransparency = 1

-- レベル・連勝
local Info = Instance.new("TextLabel", F)
Info.Size, Info.Position = UDim2.new(0.6, 0, 0.2, 0), UDim2.new(0.3, 0, 0.75, 0)
Info.BackgroundTransparency, Info.TextColor3, Info.TextScaled = 1, Color3.new(1,1,1), true

-- 右下クレジット（これは画面固定）
local Cr = Instance.new("TextLabel", gui)
Cr.Text, Cr.Size, Cr.Position = "create by harutoki53", UDim2.new(0,180,0,20), UDim2.new(1,-190,1,-30)
Cr.TextColor3, Cr.BackgroundTransparency = Color3.new(1,1,1), 1
local Ic = Instance.new("ImageLabel", gui)
Ic.Image = "rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150"
Ic.Size, Ic.Position, Ic.BackgroundTransparency = UDim2.new(0,40,0,40), UDim2.new(1,-50,1,-75), 1

-- 色判定
local function getHealthColor(p)
    if p >= 80 then return Color3.new(0, 1, 0)
    elseif p >= 50 then return Color3.new(1, 1, 0)
    elseif p >= 25 then return Color3.fromRGB(255, 165, 0)
    else return Color3.new(1, 0, 0)
    end
end

-- 壁越し
local function isVisible(part)
    if not config.wallCheck then return true end
    C = workspace.CurrentCamera
    local cast = C:GetPartsObscuringTarget({part.Position}, {LP.Character, part.Parent})
    return #cast == 0
end

-- メインループ
R.RenderStepped:Connect(function()
    C = workspace.CurrentCamera
    if not C then return end

    local target, nearest = nil, config.fov
    local mousePos = U:GetMouseLocation()

    for _, v in pairs(P:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local root = v.Character.HumanoidRootPart
                local pos, onScreen = C:WorldToViewportPoint(root.Position)
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if onScreen and dist < nearest and isVisible(root) then
                    target, nearest = v, dist
                end
            end
        end
    end

    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hum = target.Character:FindFirstChildOfClass("Humanoid")
        local root = target.Character.HumanoidRootPart
        
        -- 【重要】敵の位置を画面座標に変換してUIを移動させる
        local screenPos, onScreen = C:WorldToViewportPoint(root.Position + Vector3.new(3, 2, 0)) -- 敵の少し右上
        
        if onScreen then
            F.Visible = true
            F.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
            
            local hp = math.floor(hum.Health)
            local p = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
            HealthNum.Text = tostring(hp)
            Name.Text = target.DisplayName or target.Name
            Bar.Size, Bar.BackgroundColor3 = UDim2.new(1, 0, p, 0), getHealthColor(p * 100)
            Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..target.UserId.."&w=150&h=150"
            
            local s = target:FindFirstChild("leaderstats")
            local lv = s and s:FindFirstChild("Level") and s.Level.Value or "?"
            local st = s and s:FindFirstChild("Streak") and s.Streak.Value or 0
            Info.Text = st > 0 and "Lv."..lv.." | "..st.."連勝" or "Lv."..lv
        else
            F.Visible = false
        end

        -- オートエイム
        if config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local headPos = C:WorldToViewportPoint(head.Position)
                local move = (Vector2.new(headPos.X, headPos.Y) - mousePos) * config.smooth
                if mousemoverel then mousemoverel(move.X, move.Y) end
            end
        end
    else
        F.Visible = false
    end
end)

-- キー切替
U.InputBegan:Connect(function(i, g)
    if not g then
        if i.KeyCode == Enum.KeyCode.K then config.aimbot = not config.aimbot
        elseif i.KeyCode == Enum.KeyCode.J then config.wallCheck = not config.wallCheck end
    end
end)
