-- Rivals Script by harutoki53 (Overhead ESP Version)
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

-- 設定
local config = { aimbot = true, wallCheck = true, smooth = 0.2, fov = 150 }

-- --- 各プレイヤーの頭上UIを作成・管理する ---
local function createOverheadUI(player)
    if player == LP then return end
    
    local folder = Instance.new("Folder")
    folder.Name = "ESP_" .. player.Name
    folder.Parent = ParentGui

    local bg = Instance.new("BillboardGui", folder)
    bg.Adornee = nil
    bg.Size = UDim2.new(0, 200, 0, 120)
    bg.StudsOffset = Vector3.new(3, 2, 0) -- キャラクターの横に浮かせる
    bg.AlwaysOnTop = true

    local frame = Instance.new("Frame", bg)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1 -- 背景の四角は消す

    -- 1. 体力数値（バーの上）
    local HealthNum = Instance.new("TextLabel", frame)
    HealthNum.Size, HealthNum.Position = UDim2.new(0, 40, 0, 20), UDim2.new(0.05, 0, 0, 0)
    HealthNum.BackgroundTransparency, HealthNum.TextColor3, HealthNum.TextScaled = 1, Color3.new(1,1,1), true

    -- 2. 体力バー背景
    local HB_BG = Instance.new("Frame", frame)
    HB_BG.Size, HB_BG.Position, HB_BG.BackgroundColor3 = UDim2.new(0, 12, 0.7, 0), UDim2.new(0.05, 0, 0.2, 0), Color3.fromRGB(30,30,30)

    -- 3. 体力バー中身（上から下に減る）
    local Bar = Instance.new("Frame", HB_BG)
    Bar.Size, Bar.Position, Bar.BorderSizePixel = UDim2.new(1, 0, 1, 0), UDim2.new(0,0,0,0), 0

    -- 4. 名前
    local Name = Instance.new("TextLabel", frame)
    Name.Size, Name.Position = UDim2.new(0.6, 0, 0.2, 0), UDim2.new(0.3, 0, 0.1, 0)
    Name.BackgroundTransparency, Name.TextColor3, Name.TextScaled = 1, Color3.new(1,1,1), true
    Name.TextXAlignment = Enum.TextXAlignment.Left

    -- 5. アバター
    local Ava = Instance.new("ImageLabel", frame)
    Ava.Size, Ava.Position = UDim2.new(0.4, 0, 0.4, 0), UDim2.new(0.35, 0, 0.35, 0)
    Ava.BackgroundTransparency = 1

    -- 6. レベル・連勝
    local Info = Instance.new("TextLabel", frame)
    Info.Size, Info.Position = UDim2.new(0.6, 0, 0.2, 0), UDim2.new(0.3, 0, 0.75, 0)
    Info.BackgroundTransparency, Info.TextColor3, Info.TextScaled = 1, Color3.new(1,1,1), true

    return folder, bg, Bar, HealthNum, Name, Ava, Info
end

local activeUIs = {}

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
    local mousePos = U:GetMouseLocation()
    local currentTarget, nearest = nil, config.fov

    for _, v in pairs(P:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                -- UIの管理
                if not activeUIs[v] then
                    activeUIs[v] = {createOverheadUI(v)}
                end
                
                local folder, bg, bar, hpNum, name, ava, info = unpack(activeUIs[v])
                bg.Adornee = v.Character.HumanoidRootPart
                
                -- ステータス更新
                local p = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                hpNum.Text = tostring(math.floor(hum.Health))
                name.Text = v.DisplayName or v.Name
                bar.Size, bar.BackgroundColor3 = UDim2.new(1, 0, p, 0), getHealthColor(p * 100)
                ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                
                local s = v:FindFirstChild("leaderstats")
                local lv = s and s:FindFirstChild("Level") and s.Level.Value or "?"
                local st = s and s:FindFirstChild("Streak") and s.Streak.Value or 0
                info.Text = st > 0 and "Lv."..lv.." | "..st.."連勝" or "Lv."..lv
                
                -- エイムターゲット選定
                local pos, onScreen = C:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if onScreen and dist < nearest and isVisible(v.Character.HumanoidRootPart) then
                    currentTarget, nearest = v, dist
                end
            else
                if activeUIs[v] then activeUIs[v][1].Visible = false end
            end
        end
    end

    -- オートエイム
    if currentTarget and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local head = currentTarget.Character:FindFirstChild("Head")
        if head then
            local headPos = C:WorldToViewportPoint(head.Position)
            local move = (Vector2.new(headPos.X, headPos.Y) - mousePos) * config.smooth
            if mousemoverel then mousemoverel(move.X, move.Y) end
        end
    end
end)

-- キー切替
U.InputBegan:Connect(function(i, g)
    if not g then
        if i.KeyCode == Enum.KeyCode.K then config.aimbot = not config.aimbot
        elseif i.KeyCode == Enum.KeyCode.J then config.wallCheck = not config.wallCheck end
    end
end)
