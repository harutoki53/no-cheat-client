--[[
    Harutoki Ultimate - The Absolute Sovereign
    - デザイン: 画像デザインをドット単位でシミュレート（四隅カギ括弧、左バー、上数値、右アイコン）
    - フィルターON: 視認不可または500スタッド以上の敵を「完全に演算から除外・非表示」
    - フィルターOFF: 壁越しでも表示・吸い付きを行うが、射撃のみロック
    - 自動発射: エイム状態に関わらず、敵が「視認可能」な時のみトリガーを引く
--]]

local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer
local Camera = workspace.CurrentCamera

local config = {
    aimbot = true,
    autoFire = true,
    filter = true,       -- リクエストの「フィルター」機能
    smooth = 0.35,       -- 滑らかさ
    pcFov = 650,         -- エイム範囲
    maxDist = 500,       -- 500スタッド制限
    fireFov = 90         -- 自動発射が反応する中心範囲
}

-- --- GUIレイヤー構築 ---
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate_Sovereign"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 10000

-- --- チーム検証 (高度な判定) ---
local function isEnemy(target)
    if not target or target == LP then return false end
    if LP.Team and target.Team then return LP.Team ~= target.Team end
    local char = target.Character
    if char and char:FindFirstChild("Highlight") then return true end -- Rivals特有の判定補助
    return true
end

-- --- 精密デザインESP構築 (画像再現) ---
local pESP = {}
local function createESP(v)
    local container = Instance.new("Frame", gui)
    container.BackgroundTransparency = 1
    container.Visible = false
    
    -- 1. 画像の「コーナーカギ括弧」の精密描画
    local function drawBracket(pos, size)
        local f = Instance.new("Frame", container)
        f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        f.BorderSizePixel = 0; f.Position = pos; f.Size = size
        return f
    end
    local t, l = 2.5, 12 -- 太さと長さ
    -- 左上
    drawBracket(UDim2.new(0,0,0,0), UDim2.new(0,l,0,t)); drawBracket(UDim2.new(0,0,0,0), UDim2.new(0,t,0,l))
    -- 右上
    drawBracket(UDim2.new(1,-l,0,0), UDim2.new(0,l,0,t)); drawBracket(UDim2.new(1,-t,0,0), UDim2.new(0,t,0,l))
    -- 左下
    drawBracket(UDim2.new(0,0,1,-t), UDim2.new(0,l,0,t)); drawBracket(UDim2.new(0,0,1,-l), UDim2.new(0,t,0,l))
    -- 右下
    drawBracket(UDim2.new(1,-l,1,-t), UDim2.new(0,l,0,t)); drawBracket(UDim2.new(1,-t,1,-l), UDim2.new(0,t,0,l))

    -- 2. 体力バー (画像の通り左側に厚めに配置)
    local barBG = Instance.new("Frame", container)
    barBG.Size = UDim2.new(0, 6, 1, 0); barBG.Position = UDim2.new(0, -15, 0, 0)
    barBG.BackgroundColor3 = Color3.new(0, 0, 0); barBG.BorderSizePixel = 0
    local bar = Instance.new("Frame", barBG)
    bar.Size = UDim2.new(1, 0, 1, 0); bar.Position = UDim2.new(0, 0, 1, 0); bar.AnchorPoint = Vector2.new(0, 1)
    bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0); bar.BorderSizePixel = 0

    -- 3. 体力数値 (上部に大きく配置)
    local hNum = Instance.new("TextLabel", container)
    hNum.Size = UDim2.new(1, 0, 0, 26); hNum.Position = UDim2.new(0, 0, 0, -52)
    hNum.BackgroundTransparency = 1; hNum.TextColor3 = Color3.new(1, 1, 1)
    hNum.Font = Enum.Font.SourceSansBold; hNum.TextScaled = true
    Instance.new("UIStroke", hNum).Thickness = 1.8

    -- 4. プレイヤー名 (数値の直下)
    local nameL = Instance.new("TextLabel", container)
    nameL.Size = UDim2.new(1, 0, 0, 14); nameL.Position = UDim2.new(0, 0, 0, -24)
    nameL.BackgroundTransparency = 1; nameL.TextColor3 = Color3.new(1, 1, 1); nameL.Font = Enum.Font.SourceSans
    nameL.TextScaled = true; Instance.new("UIStroke", nameL)

    -- 5. アバターアイコン (右側に白枠付きで配置)
    local ava = Instance.new("ImageLabel", container)
    ava.Size = UDim2.new(0, 32, 0, 32); ava.Position = UDim2.new(1, 12, 0, 0)
    ava.BackgroundColor3 = Color3.new(0, 0, 0); ava.BorderSizePixel = 1
    Instance.new("UIStroke", ava).Color = Color3.new(1, 1, 1)

    pESP[v] = {Main = container, Bar = bar, HealthNum = hNum, Name = nameL, Ava = ava}
    return pESP[v]
end

-- --- メインレンダリング & ロジックエンジン ---
R.RenderStepped:Connect(function()
    if not Camera or not LP.Character then return end
    
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local targetUnit, nearestDist = nil, config.pcFov
    local canAutoFire = false

    for _, v in pairs(P:GetPlayers()) do
        if not isEnemy(v) then 
            if pESP[v] then pESP[v].Main.Visible = false end 
            continue 
        end

        local char = v.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")

        if head and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            local dist = (head.Position - Camera.CFrame.Position).Magnitude

            -- レイキャストによる「視認可能判定」 (Rivalsの壁抜き対策)
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {LP.Character, char, Camera}
            local result = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * dist, rayParams)
            local isVisible = not result

            -- 【核心ロジック】フィルターと距離の厳密な判定
            local displayStatus = onScreen and dist <= config.maxDist
            if config.filter and not isVisible then 
                displayStatus = false -- フィルターON時は壁越しを完全に消去
            end

            if displayStatus then
                local esp = pESP[v] or createESP(v)
                esp.Main.Visible = true
                
                -- 距離に応じた動的なサイズ調整
                local size = math.clamp(1000/pos.Z, 12, 450)
                local w, h = size * 0.75, size
                esp.Main.Size = UDim2.new(0, w, 0, h)
                esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2)

                -- 情報の流し込み
                esp.Name.Text = v.DisplayName
                esp.HealthNum.Text = math.floor(hum.Health)
                esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)
                esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                
                -- 色の同期 (視認できる時は緑、できない時は赤)
                local statusColor = isVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                esp.Bar.BackgroundColor3 = statusColor

                -- エイム判定 (フィルター設定を反映)
                if (not config.filter) or isVisible then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mouseDist < nearestDist then
                        targetUnit = head; nearestDist = mouseDist
                    end
                end

                -- 自動発射判定 (壁越しの時はフィルターに関わらず絶対にTrueにしない)
                if isVisible and (Vector2.new(pos.X, pos.Y) - center).Magnitude < config.fireFov then
                    canAutoFire = true
                end
            else
                if pESP[v] then pESP[v].Main.Visible = false end
            end
        elseif pESP[v] then
            pESP[v].Main.Visible = false
        end
    end

    -- --- オートエイム・射撃実行 ---
    if targetUnit and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local p, _ = Camera:WorldToViewportPoint(targetUnit.Position)
        if mousemoverel then
            mousemoverel((p.X - center.X) * config.smooth, (p.Y - center.Y) * config.smooth)
        end
    end

    if config.autoFire and canAutoFire and mouse1press then
        mouse1press(); task.wait(0.01); mouse1release()
    end
end)

-- F2キー: フィルターの切り替えショートカット
U.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.F2 then
        config.filter = not config.filter
        print("FILTER MODIFIED: " .. tostring(config.filter))
    end
end)
