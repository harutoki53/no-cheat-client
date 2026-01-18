-- Rivals Script by harutoki53 (Aimbot + UI)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local C = workspace.CurrentCamera
local LP = P.LocalPlayer
local gui = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))

-- --- 設定 ---
local config = {
    showHistory = true,
    baseSize = Vector2.new(250, 150),
    aimbotEnabled = true,
    aimSmoothness = 0.2, -- 0に近いほど一瞬で吸い付く
    fov = 150 -- エイムが反応する範囲（ピクセル）
}

-- --- UI構築 ---
local F = Instance.new("Frame", gui)
F.AnchorPoint, F.Position, F.Size = Vector2.new(0.5, 0.5), UDim2.new(0.5, 150, 0.5, 0), UDim2.new(0, config.baseSize.X, 0, config.baseSize.Y)
F.BackgroundColor3, F.BackgroundTransparency, F.Visible = Color3.new(0,0,0), 0.4, false

local HB_BG = Instance.new("Frame", F)
HB_BG.Size, HB_BG.Position, HB_BG.BackgroundColor3 = UDim2.new(0,12,0.8,0), UDim2.new(0.05,0,0.1,0), Color3.fromRGB(30,30,30)
local Bar = Instance.new("Frame", HB_BG)
Bar.Size = UDim2.new(1,0,1,0)

local Name = Instance.new("TextLabel", F)
Name.Size, Name.Position, Name.BackgroundTransparency, Name.TextColor3, Name.TextScaled = UDim2.new(0.7,0,0.2,0), UDim2.new(0.25,0,0.05,0), 1, Color3.new(1,1,1), true

local Ava = Instance.new("ImageLabel", F)
Ava.Size, Ava.Position, Ava.BackgroundTransparency = UDim2.new(0.4,0,0.5,0), UDim2.new(0.4,0,0.25,0), 1

local Info = Instance.new("TextLabel", F)
Info.Size, Info.Position, Info.BackgroundTransparency, Info.TextColor3, Info.TextScaled = UDim2.new(0.9,0,0.2,0), UDim2.new(0.05,0,0.75,0), 1, Color3.new(1,1,1), true

-- クレジット
local Cr = Instance.new("TextLabel", gui)
Cr.Text, Cr.Size, Cr.Position, Cr.TextColor3, Cr.BackgroundTransparency = "create by harutoki53", UDim2.new(0,180,0,20), UDim2.new(1,-190,1,-30), Color3.new(1,1,1), 1
local Ic = Instance.new("ImageLabel", gui)
Ic.Image, Ic.Size, Ic.Position, Ic.BackgroundTransparency = "rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150", UDim2.new(0,40,0,40), UDim2.new(1,-50,1,-75), 1

-- 履歴ログ
local Log = Instance.new("ScrollingFrame", gui)
Log.Size, Log.Position, Log.Visible = UDim2.new(0,200,0,120), UDim2.new(0,10,1,-130), config.showHistory
Instance.new("UIListLayout", Log)

-- --- メインロジック ---
R.RenderStepped:Connect(function()
    local target, nearest = nil, config.fov
    local mousePos = U:GetMouseLocation()

    for _, v in pairs(P:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local root = v.Character.HumanoidRootPart
            local pos, onScreen = C:WorldToViewportPoint(root.Position)
            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
            
            if onScreen and dist < nearest then
                target, nearest = v, dist
            end
        end
    end

    if target then
        -- 1. UI更新
        local hum = target.Character.Humanoid
        local p = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
        F.Visible = true
        Name.Text = target.Name
        Bar.Size, Bar.BackgroundColor3 = UDim2.new(1,0,p,0), (p > 0.8 and Color3.new(0,1,0)) or (p > 0.5 and Color3.new(1,1,0)) or Color3.new(1,0,0)
        Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..target.UserId.."&w=150&h=150"
        local s = target:FindFirstChild("leaderstats")
        local lv = s and s:FindFirstChild("Level") and s.Level.Value or "?"
        local st = s and s:FindFirstChild("Streak") and s.Streak.Value or 0
        Info.Text = st > 0 and "Lv."..lv.." | "..st.."連勝" or "Lv."..lv

        -- 2. オートエイム (右クリックを押している間)
        if config.aimbotEnabled and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local aimPos = C:WorldToViewportPoint(target.Character.Head.Position)
            local move = (Vector2.new(aimPos.X, aimPos.Y) - mousePos) * config.aimSmoothness
            mousemoverel(move.X, move.Y) -- Xenoの標準マウス移動関数
        end
    else
        F.Visible = false
    end
end)

-- Lキーで履歴表示切替
U.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.L then Log.Visible = not Log.Visible end end)
