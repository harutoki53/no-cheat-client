-- Rivals Script: Final Polished Version
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer
local C = workspace.CurrentCamera

local config = {
    aimbot = true,
    wallCheck = true,
    smooth = 0.12,
    fov = 150,
    maxSize = 420 -- 至近距離での巨大化防止
}

local ParentGui = (gethui and gethui()) or game:GetService("CoreGui")
local gui = Instance.new("ScreenGui", ParentGui)
gui.Name = "HarutokiUltimateESP"

-- コーナーボックス作成（二重構造）
local function createCornerBox(parent)
    local lines = {}
    for i = 1, 16 do
        local line = Instance.new("Frame", parent)
        line.BackgroundColor3 = (i <= 8) and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
        line.BorderSizePixel = 0
        line.ZIndex = (i <= 8) and 1 or 2
        lines[i] = line
    end
    return lines
end

local function updateCornerBox(lines, x, y, w, h)
    local t, l = 1.5, w * 0.25
    local ot = t + 2
    local function setPosSize(i, px, py, sx, sy)
        lines[i].Position, lines[i].Size = UDim2.new(0, px, 0, py), UDim2.new(0, sx, 0, sy)
        lines[i+8].Position, lines[i+8].Size = UDim2.new(0, px+1, 0, py+1), UDim2.new(0, sx-2, 0, sy-2)
    end
    setPosSize(1, x, y, l, ot) -- 左上
    setPosSize(2, x, y, ot, l)
    setPosSize(3, x + w - l, y, l, ot) -- 右上
    setPosSize(4, x + w - ot, y, ot, l)
    setPosSize(5, x, y + h - ot, l, ot) -- 左下
    setPosSize(6, x, y + h - l, ot, l)
    setPosSize(7, x + w - l, y + h - ot, l, ot) -- 右下
    setPosSize(8, x + w - ot, y + h - l, ot, l)
end

local function createESP(player)
    local f = Instance.new("Frame", gui)
    f.BackgroundTransparency = 1
    f.Visible = false
    local esp = {
        Main = f, Corners = createCornerBox(f),
        HealthNum = Instance.new("TextLabel", f),
        BarBG = Instance.new("Frame", f), Bar = nil,
        Name = Instance.new("TextLabel", f),
        Ava = Instance.new("ImageLabel", f),
        Info = Instance.new("TextLabel", f)
    }
    local function style(l)
        l.BackgroundTransparency, l.TextColor3, l.TextScaled = 1, Color3.new(1,1,1), true
        l.Font = Enum.Font.RobotoMono
        local s = Instance.new("UIStroke", l)
        s.Thickness = 1
    end
    style(esp.HealthNum); style(esp.Name); style(esp.Info)
    esp.BarBG.BackgroundColor3, esp.BarBG.BorderSizePixel = Color3.new(0,0,0), 0
    esp.Bar = Instance.new("Frame", esp.BarBG); esp.Bar.BorderSizePixel = 0
    esp.Ava.BackgroundTransparency = 1; Instance.new("UIStroke", esp.Ava).Thickness = 1
    return esp
end

local playerESP = {}

local function getHealthColor(p)
    if p >= 80 then return Color3.new(0, 1, 0)
    elseif p >= 50 then return Color3.new(1, 1, 0)
    elseif p >= 25 then return Color3.fromRGB(255, 165, 0)
    else return Color3.new(1, 0, 0) end
end

local function isTarget(v)
    if v == LP or not v.Team or v.Team == LP.Team then return false end
    local lobby = game:GetService("Teams"):FindFirstChild("Lobby")
    return v.Team ~= lobby
end

R.RenderStepped:Connect(function()
    C = workspace.CurrentCamera
    if not C then return end
    local mousePos = U:GetMouseLocation()
    local target, nearest = nil, config.fov

    for _, v in pairs(P:GetPlayers()) do
        local char = v.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if root and head and hum and hum.Health > 0 and isTarget(v) then
            if not playerESP[v] then playerESP[v] = createESP(v) end
            local esp = playerESP[v]
            local pos, onScreen = C:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local hPos = C:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
                local lPos = C:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local h = math.clamp(math.abs(hPos.Y - lPos.Y), 40, config.maxSize)
                local w = h * 0.6
                local x, y = pos.X - w/2, pos.Y - h/2
                
                esp.Main.Visible = true
                updateCornerBox(esp.Corners, x, y, w, h)
                
                local p = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                esp.HealthNum.Text = tostring(math.floor(hum.Health))
                esp.HealthNum.Position, esp.HealthNum.Size = UDim2.new(0, x - 40, 0, y - 18), UDim2.new(0, 35, 0, 15)
                esp.BarBG.Position, esp.BarBG.Size = UDim2.new(0, x - 8, 0, y), UDim2.new(0, 4, 0, h)
                esp.Bar.Size, esp.Bar.BackgroundColor3 = UDim2.new(1, 0, p, 0), getHealthColor(p * 100)
                esp.Name.Text = v.DisplayName
                esp.Name.Position, esp.Name.Size = UDim2.new(0, x, 0, y - 20), UDim2.new(0, w, 0, 18)
                esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                esp.Ava.Position, esp.Ava.Size = UDim2.new(0, x + w + 5, 0, y), UDim2.new(0, h*0.3, 0, h*0.3)
                
                local s = v:FindFirstChild("leaderstats")
                local lv = s and s:FindFirstChild("Level") and s.Level.Value or "?"
                local st = s and s:FindFirstChild("Streak") and s.Streak.Value or 0
                esp.Info.Text = (st > 0) and "Lv."..lv.."\n"..st.." STREAK" or "Lv."..lv
                esp.Info.Position, esp.Info.Size = UDim2.new(0, x + w + 5, 0, y + h*0.3 + 5), UDim2.new(0, 60, 0, 25)

                if not config.wallCheck or #C:GetPartsObscuringTarget({head.Position}, {LP.Character, char}) == 0 then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < nearest then target, nearest = v, dist end
                end
            else esp.Main.Visible = false end
        elseif playerESP[v] then playerESP[v].Main.Visible = false end
    end

    if target and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local head = target.Character:FindFirstChild("Head")
        if head then
            local headPos = C:WorldToViewportPoint(head.Position)
            local move = (Vector2.new(headPos.X, headPos.Y) - mousePos) * config.smooth
            if mousemoverel then mousemoverel(move.X, move.Y) end
        end
    end
end)
