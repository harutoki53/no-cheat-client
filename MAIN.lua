-- Rivals Script: Fixed Version
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = true,
    wallCheck = true,
    smooth = 0.1,
    fov = 150,
    maxSize = 400
}

-- UIの親を確実に取得
local ParentGui = (gethui and gethui()) or game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name = "HarutokiUltimate"
gui.IgnoreGuiInset = true
gui.Parent = ParentGui

-- コーナー作成
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
        if not lines[i] or not lines[i+8] then return end
        lines[i].Position, lines[i].Size = UDim2.new(0, px, 0, py), UDim2.new(0, sx, 0, sy)
        lines[i+8].Position, lines[i+8].Size = UDim2.new(0, px+1, 0, py+1), UDim2.new(0, sx-2, 0, sy-2)
    end
    setPosSize(1, x, y, l, ot); setPosSize(2, x, y, ot, l)
    setPosSize(3, x+w-l, y, l, ot); setPosSize(4, x+w-ot, y, ot, l)
    setPosSize(5, x, y+h-ot, l, ot); setPosSize(6, x, y+h-l, ot, l)
    setPosSize(7, x+w-l, y+h-ot, l, ot); setPosSize(8, x+w-ot, y+h-l, ot, l)
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
    esp.BarBG.BackgroundColor3 = Color3.new(0,0,0)
    esp.Bar = Instance.new("Frame", esp.BarBG); esp.Bar.BorderSizePixel = 0
    esp.Ava.BackgroundTransparency = 1; Instance.new("UIStroke", esp.Ava).Thickness = 1
    return esp
end

local playerESP = {}

-- 試合中の敵判定（ロビー以外）
local function isTarget(v)
    if v == LP then return false end
    local char = v.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    -- Rivalsのチーム判定
    if v.Team and LP.Team and v.Team == LP.Team then return false end
    if v.Team and v.Team.Name == "Lobby" then return false end
    return true
end

R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C then return end
    local mousePos = U:GetMouseLocation()
    local target, nearest = nil, config.fov

    for _, v in pairs(P:GetPlayers()) do
        local char = v.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        
        if hum and root and head and hum.Health > 0 and isTarget(v) then
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
                
                local p = hum.Health / hum.MaxHealth
                esp.HealthNum.Text = tostring(math.floor(hum.Health))
                esp.HealthNum.Position, esp.HealthNum.Size = UDim2.new(0, x - 40, 0, y - 18), UDim2.new(0, 35, 0, 15)
                esp.BarBG.Position, esp.BarBG.Size = UDim2.new(0, x - 8, 0, y), UDim2.new(0, 4, 0, h)
                esp.Bar.Size = UDim2.new(1, 0, p, 0)
                esp.Bar.BackgroundColor3 = p > 0.5 and Color3.new(0,1,0) or Color3.new(1,0,0)
                
                esp.Name.Text = v.DisplayName
                esp.Name.Position, esp.Name.Size = UDim2.new(0, x, 0, y - 20), UDim2.new(0, w, 0, 18)
                esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                esp.Ava.Position, esp.Ava.Size = UDim2.new(0, x + w + 5, 0, y), UDim2.new(0, h*0.3, 0, h*0.3)
                
                if not config.wallCheck or #C:GetPartsObscuringTarget({head.Position}, {char}) == 0 then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < nearest then target, nearest = v, dist end
                end
            else esp.Main.Visible = false end
        elseif playerESP[v] then
            playerESP[v].Main.Visible = false
        end
    end

    -- オートエイム (右クリック)
    if target and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local head = target.Character:FindFirstChild("Head")
        if head then
            local headPos = C:WorldToViewportPoint(head.Position)
            local targetPos = Vector2.new(headPos.X, headPos.Y)
            local move = (targetPos - mousePos) * config.smooth
            if mousemoverel then
                mousemoverel(move.X, move.Y)
            else
                -- 予備のエイム方式
                C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, head.Position), config.smooth)
            end
        end
    end
end)
