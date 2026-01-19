-- Rivals Script: Harutoki Ultimate (Design Perfection & Advanced Logic)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer
local Mouse = LP:GetMouse()

local config = {
    aimbot = true,
    autoFire = true,
    wallCheck = true, -- FILTER: ON(見える敵のみ描画・吸い付き)
    smooth = 0.3,
    pcFov = 600,
    maxDistance = 500, -- 500スタッド制限
    menuOpen = false
}

-- --- GUI 完全構築 ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate_Final"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 10000

-- --- チーム判定 (起点コード継承) ---
local function isEnemy(v)
    if not v or v == LP then return false end
    if LP.Team and v.Team then return LP.Team ~= v.Team end
    if v:FindFirstChild("TeamColor") and LP:FindFirstChild("TeamColor") then
        return v.TeamColor ~= LP.TeamColor
    end
    return true
end

-- --- ESPデザイン構築 (画像のデザインをミリ単位で再現) ---
local pESP = {}
local function createESP(v)
    local container = Instance.new("Frame", gui)
    container.BackgroundTransparency = 1
    container.Visible = false
    
    -- 四隅のコーナー枠 (画像にあるカギ括弧デザイン)
    local function addCorner(pos, size)
        local f = Instance.new("Frame", container)
        f.BackgroundColor3 = Color3.new(1, 1, 1)
        f.BorderSizePixel = 0
        f.Position = pos
        f.Size = size
        Instance.new("UIStroke", f).Thickness = 0.5
        return f
    end
    
    local t = 2 -- 太さ
    local l = 8 -- 長さ
    -- 左上
    addCorner(UDim2.new(0,0,0,0), UDim2.new(0,l,0,t)); addCorner(UDim2.new(0,0,0,0), UDim2.new(0,t,0,l))
    -- 右上
    addCorner(UDim2.new(1,-l,0,0), UDim2.new(0,l,0,t)); addCorner(UDim2.new(1,-t,0,0), UDim2.new(0,t,0,l))
    -- 左下
    addCorner(UDim2.new(0,0,1,-t), UDim2.new(0,l,0,t)); addCorner(UDim2.new(0,0,1,-l), UDim2.new(0,t,0,l))
    -- 右下
    addCorner(UDim2.new(1,-l,1,-t), UDim2.new(0,l,0,t)); addCorner(UDim2.new(1,-t,1,-l), UDim2.new(0,t,0,l))

    -- 1. 体力バー (左側・画像通りの太い緑)
    local barBG = Instance.new("Frame", container)
    barBG.Size = UDim2.new(0, 6, 1, 0); barBG.Position = UDim2.new(0, -15, 0, 0)
    barBG.BackgroundColor3 = Color3.new(0, 0, 0); barBG.BorderSizePixel = 0
    local bar = Instance.new("Frame", barBG)
    bar.Size = UDim2.new(1, 0, 1, 0); bar.Position = UDim2.new(0, 0, 1, 0); bar.AnchorPoint = Vector2.new(0, 1)
    bar.BackgroundColor3 = Color3.new(0, 1, 0); bar.BorderSizePixel = 0

    -- 2. 体力数値 (上部・大きく太字)
    local healthLabel = Instance.new("TextLabel", container)
    healthLabel.Size = UDim2.new(1, 0, 0, 24); healthLabel.Position = UDim2.new(0, 0, 0, -48)
    healthLabel.BackgroundTransparency = 1; healthLabel.TextColor3 = Color3.new(1, 1, 1)
    healthLabel.Font = Enum.Font.RobotoCondensedBold; healthLabel.TextScaled = true; healthLabel.TextXAlignment = Enum.TextXAlignment.Center
    local hStroke = Instance.new("UIStroke", healthLabel); hStroke.Thickness = 1.5

    -- 3. プレイヤー名 (体力数値の下)
    local nameLabel = Instance.new("TextLabel", container)
    nameLabel.Size = UDim2.new(1, 0, 0, 14); nameLabel.Position = UDim2.new(0, 0, 0, -22)
    nameLabel.BackgroundTransparency = 1; nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Font = Enum.Font.RobotoMono; nameLabel.TextScaled = true
    Instance.new("UIStroke", nameLabel)

    -- 4. アバターアイコン (右側・四角枠)
    local avatarImg = Instance.new("ImageLabel", container)
    avatarImg.Size = UDim2.new(0, 30, 0, 30); avatarImg.Position = UDim2.new(1, 10, 0, 0)
    avatarImg.BackgroundColor3 = Color3.new(0, 0, 0); avatarImg.BorderSizePixel = 1
    Instance.new("UIStroke", avatarImg).Color = Color3.new(1, 1, 1)

    pESP[v] = {Main = container, Bar = bar, HealthNum = healthLabel, Name = nameLabel, Ava = avatarImg}
    return pESP[v]
end

-- --- メインエンジン (高精度ループ) ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character then return end
    
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local targetHead, nearestDist = nil, config.pcFov
    local fireSignal = false

    for _, v in pairs(P:GetPlayers()) do
        if not isEnemy(v) then 
            if pESP[v] then pESP[v].Main.Visible = false end 
            continue 
        end

        local char = v.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")

        if head and hum and hum.Health > 0 then
            local pos, onScreen = C:WorldToViewportPoint(head.Position)
            local dist = (head.Position - C.CFrame.Position).Magnitude

            -- 厳格な壁判定 (Raycast)
            local isVisible = true
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {LP.Character, char, C}
            local result = workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position).Unit * dist, rayParams)
            if result then isVisible = false end

            -- 【リクエスト修正】FILTER ON時は壁越しを非表示、距離制限500を適用
            local shouldDraw = onScreen and dist <= config.maxDistance
            if config.wallCheck and not isVisible then shouldDraw = false end

            if shouldDraw then
                local esp = pESP[v] or createESP(v)
                esp.Main.Visible = true
                
                -- 動的スケーリング (距離に応じて枠サイズを変更)
                local sizeBase = math.clamp(1000/pos.Z, 15, 450)
                local w, h = sizeBase * 0.75, sizeBase
                esp.Main.Size = UDim2.new(0, w, 0, h)
                esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2)

                -- ステータス更新
                esp.Name.Text = v.DisplayName
                esp.HealthNum.Text = math.floor(hum.Health)
                esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)
                esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                
                -- 色の動的変化 (画像通り)
                local color = isVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                esp.Bar.BackgroundColor3 = color

                -- エイムターゲット選定 (FILTER ONなら壁越しは除外)
                if (not config.wallCheck) or isVisible then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mouseDist < nearestDist then
                        targetHead = head
                        nearestDist = mouseDist
                    end
                end

                -- 自動発射判定 (画面中央付近 & 視認可能のみ)
                if isVisible and (Vector2.new(pos.X, pos.Y) - center).Magnitude < 90 then
                    fireSignal = true
                end
            else
                if pESP[v] then pESP[v].Main.Visible = false end
            end
        elseif pESP[v] then
            pESP[v].Main.Visible = false
        end
    end

    -- --- アクション実行 ---
    if targetHead and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local pos, _ = C:WorldToViewportPoint(targetHead.Position)
        if mousemoverel then
            mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)
        else
            C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, targetHead.Position), 0.2)
        end
    end

    if config.autoFire and fireSignal and mouse1press then
        mouse1press(); task.wait(0.01); mouse1release()
    end
end)
