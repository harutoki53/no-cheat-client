-- Rivals Script by harutoki53 (Error Fixed Version)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

-- カメラを確実に見つけるための待機ループ
local C = workspace.CurrentCamera
while not C do
    task.wait()
    C = workspace.CurrentCamera
end

-- UIの親設定（Executor用）
local ParentGui = (gethui and gethui()) or game:GetService("CoreGui")
local gui = Instance.new("ScreenGui", ParentGui)
gui.Name = "HarutokiFinal"

-- 初期設定
local config = {
    aimbot = true,
    wallCheck = true,
    smooth = 0.2,
    fov = 150
}

-- --- UI構築（指示通りのレイアウト） ---
local F = Instance.new("Frame", gui)
F.AnchorPoint, F.Position, F.Size = Vector2.new(0.5, 0.5), UDim2.new(0.5, 150, 0.5, 0), UDim2.new(0, 250, 0, 150)
F.BackgroundColor3, F.BackgroundTransparency, F.Visible = Color3.new(0,0,0), 0.4, false

-- 体力数値
local HealthNum = Instance.new("TextLabel", F)
HealthNum.Size, HealthNum.Position = UDim2.new(0.2,0,0.1,0), UDim2.new(0.05,0,0,0)
HealthNum.BackgroundTransparency, HealthNum.TextColor3, HealthNum.TextScaled = 1, Color3.new(1,1,1), true
HealthNum.Text = "100"

-- 体力バー（背景）
local HB_BG = Instance.new("Frame", F)
HB_BG.Size, HB_BG.Position, HB_BG.BackgroundColor3 = UDim2.new(0,12,0.8,0), UDim2.new(0.05,0,0.1,0), Color3.fromRGB(30,30,30)

-- 体力バー（中身：上から下に減るようにAnchorPointを調整）
local Bar = Instance.new("Frame", HB_BG)
Bar.Size = UDim2.new(1,0,1,0)
Bar.AnchorPoint = Vector2.new(0, 0)
Bar.Position = UDim2.new(0, 0, 0, 0)

local Name = Instance.new("TextLabel", F)
Name.Size, Name.Position, Name.BackgroundTransparency, Name.TextColor3, Name.TextScaled = UDim2.new(0.7,0,0.2,0), UDim2.new(0.25,0,0.05,0), 1, Color3.new(1,1,1), true

local Ava = Instance.new("ImageLabel", F)
Ava.Size, Ava.Position, Ava.BackgroundTransparency = UDim2.new(0.4,0,0.5,0), UDim2.new(0.4,0,0.25,0), 1

local Info = Instance.new("TextLabel", F)
Info.Size, Info.Position, Info.BackgroundTransparency, Info.TextColor3, Info.TextScaled = UDim2.new(0.9,0,0.2,0), UDim2.new(0.05,0,0.75,0), 1, Color3.new(1,1,1), true

-- 右下クレジット
local Cr = Instance.new("TextLabel", gui)
Cr.Text, Cr.Size, Cr.Position, Cr.TextColor3, Cr.BackgroundTransparency = "create by harutoki53", UDim2.new(0,180,0,20), UDim2.new(1,-190,1,-30), Color3.new(1,1,1), 1
local Ic = Instance.new("ImageLabel", gui)
Ic.Image = "rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150"
Ic.Size, Ic.Position, Ic.BackgroundTransparency = UDim2.new(0,40,0,40), UDim2.new(1,-50,1,-75), 1

-- --- 体力の色判定ロジック ---
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
    local cast = C:GetPartsObscuringTarget({part.Position}, {LP.Character, part.Parent})
    return #cast == 0
end

-- --- メイン処理 ---
R.RenderStepped:Connect(function()
    C = workspace.CurrentCamera -- 毎フレーム再取得してnilエラーを防止
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
                
                if onScreen and dist < nearest then
                    if isVisible(root) then
                        target, nearest = v, dist
                    end
                end
            end
        end
    end

    if target then
        local hum = target.Character:FindFirstChildOfClass("Humanoid")
        local hp = math.floor(hum.Health)
        local p = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
        
        F.Visible = true
        HealthNum.Text = tostring(hp) -- 数値で表示
        Name.Text = target.DisplayName or target.Name
        Bar.Size = UDim2.new(1, 0, p, 0) -- 体力バーは上から下に減る
        Bar.BackgroundColor3 = getHealthColor(p * 100) -- 色変化
        Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..target.UserId.."&w=150&h=150"
        
        -- レベル・連勝表示
        local s = target:FindFirstChild("leaderstats")
        local lv = s and s:FindFirstChild("Level") and s.Level.Value or "?"
        local st = s and s:FindFirstChild("Streak") and s.Streak.Value or 0
        Info.Text = st > 0 and "Lv."..lv.." | "..st.."連勝" or "Lv."..lv -- 連勝なしは書かない

        -- オートエイム (右クリック)
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

-- --- 設定切り替えキー ---
U.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.K then
        config.aimbot = not config.aimbot -- Kキーでオートエイム切替
    elseif i.KeyCode == Enum.KeyCode.J then
        config.wallCheck = not config.wallCheck -- Jキーで壁越し判定切替
    end
end)
