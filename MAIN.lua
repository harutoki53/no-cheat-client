-- Rivals Script by harutoki53 (UI Design Update)
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
gui.Name = "HarutokiDesignFinal"

-- 初期設定
local config = { aimbot = true, wallCheck = true, smooth = 0.2, fov = 150 }

-- --- UI構築（設計図の再現） ---
local F = Instance.new("Frame", gui)
F.AnchorPoint, F.Position, F.Size = Vector2.new(0.5, 0.5), UDim2.new(0.5, 150, 0.5, 0), UDim2.new(0, 250, 0, 150)
F.BackgroundColor3, F.BackgroundTransparency, F.Visible = Color3.new(0,0,0), 0.4, false

-- 1. 敵の体力（数字で表示）：バーの真上に配置
local HealthNum = Instance.new("TextLabel", F)
HealthNum.Size, HealthNum.Position = UDim2.new(0, 40, 0, 20), UDim2.new(0.05, 0, -0.05, 0)
HealthNum.BackgroundTransparency, HealthNum.TextColor3, HealthNum.TextScaled = 1, Color3.new(1,1,1), true
HealthNum.Text = "100"

-- 2. 体力バー（背景）
local HB_BG = Instance.new("Frame", F)
HB_BG.Size, HB_BG.Position, HB_BG.BackgroundColor3 = UDim2.new(0, 15, 0.8, 0), UDim2.new(0.05, 0, 0.1, 0), Color3.fromRGB(30, 30, 30)

-- 3. 体力バー（中身：上から下に減る設定）
local Bar = Instance.new("Frame", HB_BG)
Bar.Size = UDim2.new(1, 0, 1, 0)
Bar.Position = UDim2.new(0, 0, 0, 0) -- 上固定
Bar.BorderSizePixel = 0

-- 4. 敵の名前：右上に配置
local Name = Instance.new("TextLabel", F)
Name.Size, Name.Position = UDim2.new(0.6, 0, 0.2, 0), UDim2.new(0.3, 0, 0.05, 0)
Name.BackgroundTransparency, Name.TextColor3, Name.TextScaled = 1, Color3.new(1,1,1), true
Name.TextXAlignment = Enum.TextXAlignment.Left

-- 5. 敵のアバター：中央右
local Ava = Instance.new("ImageLabel", F)
Ava.Size, Ava.Position = UDim2.new(0.45, 0, 0.45, 0), UDim2.new(0.35, 0, 0.28, 0)
Ava.BackgroundTransparency = 1

-- 6. 敵のレベルと連勝：右下に配置
local Info = Instance.new("TextLabel", F)
Info.Size, Info.Position = UDim2.new(0.6, 0, 0.2, 0), UDim2.new(0.3, 0, 0.75, 0)
Info.BackgroundTransparency, Info.TextColor3, Info.TextScaled = 1, Color3.new(1,1,1), true
Info.TextXAlignment = Enum.TextXAlignment.Right

-- クレジット
local Cr = Instance.new("TextLabel", gui)
Cr.Text, Cr.Size, Cr.Position = "create by harutoki53", UDim2.new(0,180,0,20), UDim2.new(1,-190,1,-30)
Cr.TextColor3, Cr.BackgroundTransparency = Color3.new(1,1,1), 1
local Ic = Instance.new("ImageLabel", gui)
Ic.Image = "rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150"
Ic.Size, Ic.Position, Ic.BackgroundTransparency = UDim2.new(0,40,0,40), UDim2.new(1,-50,1,-75), 1

-- --- 色判定ロジック（指示通り） ---
local function getHealthColor(p)
    if p >= 80 then return Color3.new(0, 1, 0)      -- 80~100: 緑
    elseif p >= 50 then return Color3.new(1, 1, 0)  -- 50~80: 黄色
    elseif p >= 25 then return Color3.fromRGB(255, 165, 0) -- 25~50: オレンジ
    else return Color3.new(1, 0, 0)                 -- 0~25: 赤
    end
end

-- --- 壁越し判定 ---
local function isVisible(part)
    if not config.wallCheck then return true end
    C = workspace.CurrentCamera
    if not C then return false end
    local cast = C:GetPartsObscuringTarget({part.Position}, {LP.Character, part.Parent})
    return #cast == 0
end

-- --- メイン処理 ---
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

    if target then
        local hum = target.Character:FindFirstChildOfClass("Humanoid")
        local hp = math.floor(hum.Health)
        local p = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
        
        F.Visible = true
        HealthNum.Text = tostring(hp)
        Name.Text = target.DisplayName or target.Name
        Bar.Size = UDim2.new(1, 0, p, 0)
        Bar.BackgroundColor3 = getHealthColor(p * 100)
        Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..target.UserId.."&w=150&h=150"
        
        -- レベルと連勝（連勝なしの場合は書かない）
        local s = target:FindFirstChild("leaderstats")
        local lv = s and s:FindFirstChild("Level") and s.Level.Value or "?"
        local st = s and s:FindFirstChild("Streak") and s.Streak.Value or 0
        if st > 0 then
            Info.Text = "Lv."..lv.." | "..st.."連勝"
        else
            Info.Text = "Lv."..lv
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

-- キー入力による設定変更
U.InputBegan:Connect(function(i, g)
    if not g then
        if i.KeyCode == Enum.KeyCode.K then config.aimbot = not config.aimbot
        elseif i.KeyCode == Enum.KeyCode.J then config.wallCheck = not config.wallCheck end
    end
end)
