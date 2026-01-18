-- Rivals Script by harutoki53 (Name Fix Version)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local C = workspace.CurrentCamera
local LP = P.LocalPlayer
local gui = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))

local config = {
    aimbotEnabled = true,
    wallCheck = true,
    aimSmoothness = 0.2,
    fov = 150,
    showHistory = true
}

-- --- UI構築 ---
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

-- クレジット（指示通り右下に配置）
local Cr = Instance.new("TextLabel", gui)
Cr.Text, Cr.Size, Cr.Position, Cr.TextColor3, Cr.BackgroundTransparency = "create by harutoki53", UDim2.new(0,180,0,20), UDim2.new(1,-190,1,-30), Color3.new(1,1,1), 1
local Ic = Instance.new("ImageLabel", gui)
Ic.Image, Ic.Size, Ic.Position, Ic.BackgroundTransparency = "rbxthumb://type=AvatarHeadShot&id="..LP.UserId.."&w=150&h=150", UDim2.new(0,40,0,40), UDim2.new(1,-50,1,-75), 1

-- --- 名前・データの取得関数（強化版） ---
local function getEnemyData(enemyPlayer, character)
    local name = "Unknown"
    local id = 0
    
    if enemyPlayer then
        -- プレイヤーが存在する場合
        name = enemyPlayer.DisplayName or enemyPlayer.Name
        id = enemyPlayer.UserId
    elseif character then
        -- プレイヤーが見つからないがキャラはいる場合（NPCや特殊エンティティ）
        name = character.Name
        -- キャラクターにIDが紐づいていないか探す
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum and hum.DisplayName ~= "" then name = hum.DisplayName end
    end
    
    return name, id
end

-- --- 壁越し判定 ---
local function isVisible(targetPart)
    if not config.wallCheck then return true end
    local castPoints = {C.CFrame.Position, targetPart.Position}
    local ignoreList = {LP.Character, targetPart.Parent}
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = ignoreList
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(castPoints[1], castPoints[2] - castPoints[1], params)
    return result == nil
end

-- --- メインループ ---
R.RenderStepped:Connect(function()
    local target, nearest = nil, config.fov
    local mousePos = U:GetMouseLocation()

    for _, v in pairs(P:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local pos, onScreen = C:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if onScreen and dist < nearest and isVisible(v.Character.HumanoidRootPart) then
                    target, nearest = v, dist
                end
            end
        end
    end

    if target then
        local hum = target.Character:FindFirstChildOfClass("Humanoid")
        local p = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
        
        -- 名前とアバターIDを取得
        local enemyName, enemyId = getEnemyData(target, target.Character)
        
        F.Visible = true
        Name.Text = enemyName
        Bar.Size, Bar.BackgroundColor3 = UDim2.new(1,0,p,0), (p > 0.8 and Color3.new(0,1,0)) or (p > 0.5 and Color3.new(1,1,0)) or Color3.new(1,0,0)
        
        if enemyId > 0 then
            Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..enemyId.."&w=150&h=150"
        end
        
        local s = target:FindFirstChild("leaderstats")
        local lv = s and s:FindFirstChild("Level") and s.Level.Value or "?"
        local st = s and s:FindFirstChild("Streak") and s.Streak.Value or 0
        Info.Text = st > 0 and "Lv."..lv.." | "..st.."連勝" or "Lv."..lv

        -- オートエイム
        if config.aimbotEnabled and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local aimPos = C:WorldToViewportPoint(head.Position)
                local move = (Vector2.new(aimPos.X, aimPos.Y) - mousePos) * config.aimSmoothness
                if mousemoverel then mousemoverel(move.X, move.Y) end
            end
        end
    else
        F.Visible = false
    end
end)
