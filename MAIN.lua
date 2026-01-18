-- Rivals Script by harutoki53 (Corner Box ESP + Aimbot)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer
local C = workspace.CurrentCamera

-- 設定
local config = {
    aimbot = true,
    wallCheck = true,
    smooth = 0.15,
    fov = 150
}

local ParentGui = (gethui and gethui()) or game:GetService("CoreGui")
local gui = Instance.new("ScreenGui", ParentGui)
gui.Name = "HarutokiCornerESP"

-- --- コーナーボックスの作成関数 ---
local function createCornerBox(parent)
    local lines = {}
    for i = 1, 8 do
        local line = Instance.new("Frame", parent)
        line.BackgroundColor3 = Color3.new(1, 1, 1)
        line.BorderSizePixel = 0
        lines[i] = line
    end
    return lines
end

local function updateCornerBox(lines, x, y, w, h)
    local t = 2 -- 線の太さ
    local l = w * 0.2 -- 角の線の長さ
    -- 左上
    lines[1].Position, lines[1].Size = UDim2.new(0, x, 0, y), UDim2.new(0, l, 0, t)
    lines[2].Position, lines[2].Size = UDim2.new(0, x, 0, y), UDim2.new(0, t, 0, l)
    -- 右上
    lines[3].Position, lines[3].Size = UDim2.new(0, x + w - l, 0, y), UDim2.new(0, l, 0, t)
    lines[4].Position, lines[4].Size = UDim2.new(0, x + w - t, 0, y), UDim2.new(0, t, 0, l)
    -- 左下
    lines[5].Position, lines[5].Size = UDim2.new(0, x, 0, y + h - t), UDim2.new(0, l, 0, t)
    lines[6].Position, lines[6].Size = UDim2.new(0, x, 0, y + h - l), UDim2.new(0, t, 0, l)
    -- 右下
    lines[7].Position, lines[7].Size = UDim2.new(0, x + w - l, 0, y + h - t), UDim2.new(0, l, 0, t)
    lines[8].Position, lines[8].Size = UDim2.new(0, x + w - t, 0, y + h - l), UDim2.new(0, t, 0, l)
end

-- --- ESP要素の作成 ---
local function createESP(player)
    local obj = Instance.new("Frame", gui)
    obj.BackgroundTransparency = 1
    obj.Visible = false

    local esp = {
        Main = obj,
        Corners = createCornerBox(obj),
        HealthNum = Instance.new("TextLabel", obj),
        BarBG = Instance.new("Frame", obj),
        Bar = nil,
        Name = Instance.new("TextLabel", obj),
        Ava = Instance.new("ImageLabel", obj),
        Info = Instance.new("TextLabel", obj)
    }

    -- 体力数値
    esp.HealthNum.Size, esp.HealthNum.Position = UDim2.new(0, 40, 0, 15), UDim2.new(0, -45, 0, -15)
    esp.HealthNum.BackgroundTransparency, esp.HealthNum.TextColor3, esp.HealthNum.TextScaled = 1, Color3.new(1,1,1), true
    
    -- バー
    esp.BarBG.BackgroundColor3, esp.BarBG.BorderSizePixel = Color3.new(0,0,0), 0
    esp.Bar = Instance.new("Frame", esp.BarBG)
    esp.Bar.Size, esp.Bar.BorderSizePixel = UDim2.new(1,0,1,0), 0

    -- 名前
    esp.Name.Size, esp.Name.Position = UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, -25)
    esp.Name.BackgroundTransparency, esp.Name.TextColor3, esp.Name.TextScaled = 1, Color3.new(1,1,1), true

    -- アバターとレベル
    esp.Ava.Size, esp.Ava.Position, esp.Ava.BackgroundTransparency = UDim2.new(0, 50, 0, 50), UDim2.new(1, 10, 0, 0), 1
    esp.Info.Size, esp.Info.Position = UDim2.new(0, 80, 0, 20), UDim2.new(1, 10, 0, 55)
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

-- --- メインループ ---
R.RenderStepped:Connect(function()
    local mousePos = U:GetMouseLocation()
    local target, nearest = nil, config.fov

    for _, v in pairs(P:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if not playerESP[v] then playerESP[v] = createESP(v) end
                local esp = playerESP[v]
                local root = v.Character.HumanoidRootPart
                local pos, onScreen = C:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local headPos = C:WorldToViewportPoint(v.Character.Head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = C:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local h = math.abs(headPos.Y - legPos.Y)
                    local w = h * 0.6
                    local x, y = pos.X - w/2, pos.Y - h/2
                    
                    esp.Main.Visible = true
                    updateCornerBox(esp.Corners, x, y, w, h)
                    
                    -- 情報配置
                    local p = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                    esp.HealthNum.Text = tostring(math.floor(hum.Health))
                    esp.HealthNum.Position = UDim2.new(0, x - 45, 0, y - 15)
                    esp.BarBG.Size, esp.BarBG.Position = UDim2.new(0, 5, 0, h), UDim2.new(0, x - 10, 0, y)
                    esp.Bar.Size, esp.Bar.BackgroundColor3 = UDim2.new(1, 0, p, 0), getHealthColor(p * 100)
                    
                    esp.Name.Text = v.DisplayName or v.Name
                    esp.Name.Position = UDim2.new(0, x, 0, y - 25)
                    esp.Name.Size = UDim2.new(0, w, 0, 20)
                    
                    esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                    esp.Ava.Position = UDim2.new(0, x + w + 10, 0, y)
                    esp.Info.Position = UDim2.new(0, x + w + 10, 0, y + 55)
                    
                    local s = v:FindFirstChild("leaderstats")
                    local lv = s and s:FindFirstChild("Level") and s.Level.Value or "?"
                    local st = s and s:FindFirstChild("Streak") and s.Streak.Value or 0
                    esp.Info.Text = st > 0 and "Lv."..lv.."\n"..st.."連勝" or "Lv."..lv

                    -- エイムターゲット
                    if not config.wallCheck or #C:GetPartsObscuringTarget({v.Character.Head.Position}, {LP.Character, v.Character}) == 0 then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if dist < nearest then target, nearest = v, dist end
                    end
                else esp.Main.Visible = false end
            elseif playerESP[v] then playerESP[v].Main.Visible = false end
        end
    end

    -- オートエイム
    if target and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local headPos = C:WorldToViewportPoint(target.Character.Head.Position)
        local move = (Vector2.new(headPos.X, headPos.Y) - mousePos) * config.smooth
        if mousemoverel then mousemoverel(move.X, move.Y) end
    end
end)

-- キー切替
U.InputBegan:Connect(function(i, g)
    if not g then
        if i.KeyCode == Enum.KeyCode.K then config.aimbot = not config.aimbot
        elseif i.KeyCode == Enum.KeyCode.J then config.wallCheck = not config.wallCheck end
    end
end)
