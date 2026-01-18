-- Rivals Script by harutoki53 (Aimbot + WallCheck Toggle)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local C = workspace.CurrentCamera
local LP = P.LocalPlayer
local gui = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))

-- --- 初期設定 ---
local config = {
    aimbotEnabled = true,
    wallCheck = true,
    aimSmoothness = 0.2,
    fov = 150,
    showHistory = true
}

-- --- 通知用関数 (設定が変わったことを知らせる) ---
local function notify(text)
    local n = Instance.new("TextLabel", gui)
    n.Size = UDim2.new(0, 200, 0, 30)
    n.Position = UDim2.new(0.5, -100, 0.2, 0)
    n.Text = text
    n.TextColor3 = Color3.new(1, 1, 1)
    n.BackgroundColor3 = Color3.new(0, 0, 0)
    n.BackgroundTransparency = 0.3
    game:GetService("TweenService"):Create(n, TweenInfo.new(1), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    task.delay(1, function() n:Destroy() end)
end

-- --- UI構築 (ステータス画面) ---
local F = Instance.new("Frame", gui)
F.AnchorPoint, F.Position, F.Size = Vector2.new(0.5, 0.5), UDim2.new(0.5, 150, 0.5, 0), UDim2.new(0, 250, 0, 150)
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

-- 右下クレジット
local Cr = Instance.new("TextLabel", gui)
Cr.Text, Cr.Size, Cr.Position, Cr.TextColor3, Cr.BackgroundTransparency = "create by harutoki53", UDim2.new(0,180,0,20), UDim2.new(1,-190,1,-30), Color3.new(1,1,1), 1
local Ic = Instance.new("ImageLabel", gui)
Ic.Image, Ic.Size, Ic.Position, Ic.BackgroundTransparency = "rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150", UDim2.new(0,40,0,40), UDim2.new(1,-50,1,-75), 1

-- 履歴ログ
local Log = Instance.new("ScrollingFrame", gui)
Log.Size, Log.Position, Log.Visible = UDim2.new(0,200,0,120), UDim2.new(0,10,1,-130), config.showHistory
Instance.new("UIListLayout", Log)

-- --- メインロジック ---
local function isVisible(part)
    if not config.wallCheck then return true end
    local res = Camera:GetPartsObscuringTarget({part.Position}, {LP.Character, part.Parent})
    return #res == 0
end

R.RenderStepped:Connect(function()
    local target, nearest = nil, config.fov
    local mousePos = U:GetMouseLocation()

    for _, v in pairs(P:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
            if onScreen and dist < nearest and isVisible(v.Character.HumanoidRootPart) then
                target, nearest = v, dist
            end
        end
    end

    if target then
        local hum = target.Character.Humanoid
        local p = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
        F.Visible = true
        Name.Text = target.DisplayName or target.Name
        Bar.Size, Bar.BackgroundColor3 = UDim2.new(1,0,p,0), (p > 0.8 and Color3.new(0,1,0)) or (p > 0.5 and Color3.new(1,1,0)) or Color3.new(1,0,0)
        Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..target.UserId.."&w=150&h=150"
        
        if config.aimbotEnabled and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local aimPos = Camera:WorldToViewportPoint(head.Position)
                local move = (Vector2.new(aimPos.X, aimPos.Y) - mousePos) * config.aimSmoothness
                if mousemoverel then mousemoverel(move.X, move.Y) end
            end
        end
    else
        F.Visible = false
    end
end)

-- --- キー入力による設定切り替え ---
U.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.K then
        config.aimbotEnabled = not config.aimbotEnabled
        notify("Aimbot: " .. (config.aimbotEnabled and "ON" or "OFF"))
    elseif i.KeyCode == Enum.KeyCode.J then
        config.wallCheck = not config.wallCheck
        notify("Wall Check: " .. (config.wallCheck and "ON" or "OFF"))
    elseif i.KeyCode == Enum.KeyCode.L then
        Log.Visible = not Log.Visible
    end
end)
