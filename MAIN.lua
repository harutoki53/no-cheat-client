-- Rivals Script: Final God Mode (Enhanced Aim + Auto Fire + Filter)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = true,
    autoFire = true,
    wallCheck = true,
    smooth = 0.4, -- マウス移動の滑らかさ (0.1〜1.0で調整)
    fov = 150,
    maxSize = 400,
    maxDistance = 500
}

-- UIの親を取得
local ParentGui = (gethui and gethui()) or game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name = "HarutokiGodMode"
gui.IgnoreGuiInset = true
gui.Parent = ParentGui

-- --- ステータスボタン ---
local function createButton(name, pos, color)
    local b = Instance.new("TextButton", gui)
    b.Name = name; b.Size = UDim2.new(0, 180, 0, 30); b.Position = pos
    b.BackgroundColor3 = Color3.new(0, 0, 0); b.BackgroundTransparency = 0.5
    b.TextColor3 = color; b.TextScaled = true; b.Font = Enum.Font.RobotoMono
    Instance.new("UIStroke", b).Thickness = 1
    return b
end

local aimBtn = createButton("AimBtn", UDim2.new(0, 10, 0, 10), Color3.new(0, 1, 0))
local fireBtn = createButton("FireBtn", UDim2.new(0, 10, 0, 45), Color3.new(1, 0.8, 0))
local wallBtn = createButton("WallBtn", UDim2.new(0, 10, 0, 80), Color3.new(0, 1, 1))

local function updateStatus()
    aimBtn.Text = "AIMBOT: " .. (config.aimbot and "ON [K]" or "OFF [K]")
    aimBtn.TextColor3 = config.aimbot and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    fireBtn.Text = "AUTO FIRE: " .. (config.autoFire and "ON [L]" or "OFF [L]")
    fireBtn.TextColor3 = config.autoFire and Color3.new(1, 0.8, 0) or Color3.new(1, 0, 0)
    wallBtn.Text = "FILTER: " .. (config.wallCheck and "ON [J]" or "OFF [J]")
    wallBtn.TextColor3 = config.wallCheck and Color3.new(0, 1, 1) or Color3.new(1, 0.5, 0)
end
updateStatus()

-- 入力判定
aimBtn.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; updateStatus() end)
fireBtn.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateStatus() end)
wallBtn.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateStatus() end)

U.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then config.aimbot = not config.aimbot; updateStatus()
    elseif input.KeyCode == Enum.KeyCode.L then config.autoFire = not config.autoFire; updateStatus()
    elseif input.KeyCode == Enum.KeyCode.J then config.wallCheck = not config.wallCheck; updateStatus() end
end)

-- --- ESP描写系 ---
local function createCornerBox(parent)
    local lines = {}
    for i = 1, 16 do
        local line = Instance.new("Frame", parent)
        line.BackgroundColor3 = (i <= 8) and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
        line.BorderSizePixel = 0; line.ZIndex = (i <= 8) and 1 or 2; lines[i] = line
    end
    return lines
end

local function updateCornerBox(lines, x, y, w, h)
    local t, l = 1.5, w * 0.25; local ot = t + 2
    local function set(i, px, py, sx, sy)
        if not lines[i] then return end
        lines[i].Position, lines[i].Size = UDim2.new(0, px, 0, py), UDim2.new(0, sx, 0, sy)
        lines[i+8].Position, lines[i+8].Size = UDim2.new(0, px+1, 0, py+1), UDim2.new(0, sx-2, 0, sy-2)
    end
    set(1,x,y,l,ot); set(2,x,y,ot,l); set(3,x+w-l,y,l,ot); set(4,x+w-ot,y,ot,l)
    set(5,x,y+h-ot,l,ot); set(6,x,y+h-l,ot,l); set(7,x+w-l,y+h-ot,l,ot); set(8,x+w-ot,y+h-l,ot,l)
end

local function createESP(v)
    local f = Instance.new("Frame", gui); f.BackgroundTransparency = 1; f.Visible = false
    local esp = {Main = f, Corners = createCornerBox(f), HealthNum = Instance.new("TextLabel", f), BarBG = Instance.new("Frame", f), Bar = nil, Name = Instance.new("TextLabel", f), Ava = Instance.new("ImageLabel", f)}
    local function style(l) l.BackgroundTransparency, l.TextColor3, l.TextScaled, l.Font = 1, Color3.new(1,1,1), true, Enum.Font.RobotoMono; Instance.new("UIStroke", l).Thickness = 1 end
    style(esp.HealthNum); style(esp.Name); esp.BarBG.BackgroundColor3 = Color3.new(0,0,0); esp.Bar = Instance.new("Frame", esp.BarBG); esp.Bar.BorderSizePixel = 0; esp.Ava.BackgroundTransparency = 1; Instance.new("UIStroke", esp.Ava).Thickness = 1
    return esp
end

local playerESP = {}

-- --- メインループ ---
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
        
        if hum and root and head and hum.Health > 0 and v ~= LP and (not v.Team or v.Team ~= LP.Team) then
            if not playerESP[v] then playerESP[v] = createESP(v) end
            local esp = playerESP[v]
            local pos, onScreen = C:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local dist = (root.Position - C.CFrame.Position).Magnitude
                local parts = C:GetPartsObscuringTarget({head.Position}, {char, LP.Character})
                local isVisible = (#parts == 0)

                local shouldShow = true
                if config.wallCheck and (not isVisible or dist > config.maxDistance) then shouldShow = false end

                if shouldShow then
                    local hPos = C:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0))
                    local lPos = C:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local h = math.clamp(math.abs(hPos.Y - lPos.Y), 40, config.maxSize)
                    local w = h * 0.6
                    local x, y = pos.X - w/2, pos.Y - h/2
                    
                    esp.Main.Visible = true
                    updateCornerBox(esp.Corners, x, y, w, h)
                    
                    local p = hum.Health / hum.MaxHealth
                    esp.HealthNum.Text = tostring(math.floor(hum.Health))
                    esp.HealthNum.Position, esp.HealthNum.Size = UDim2.new(0, x-40, 0, y-18), UDim2.new(0, 35, 0, 15)
                    esp.BarBG.Position, esp.BarBG.Size = UDim2.new(0, x-8, 0, y), UDim2.new(0, 4, 0, h)
                    esp.Bar.Size = UDim2.new(1, 0, p, 0)
                    esp.Bar.BackgroundColor3 = p > 0.5 and Color3.new(0,1,0) or Color3.new(1,0,0)
                    esp.Name.Text = v.DisplayName
                    esp.Name.Position, esp.Name.Size = UDim2.new(0, x, 0, y-20), UDim2.new(0, w, 0, 18)
                    esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                    esp.Ava.Position, esp.Ava.Size = UDim2.new(0, x+w+5, 0, y), UDim2.new(0, h*0.3, 0, h*0.3)
                    
                    if isVisible then
                        local distMouse = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if distMouse < nearest then target = head; nearest = distMouse end
                    end
                else esp.Main.Visible = false end
            else esp.Main.Visible = false end
        elseif playerESP[v] then playerESP[v].Main.Visible = false end
    end

    -- --- 実行部 (Aim & Auto Fire) ---
    if target and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local pos = C:WorldToViewportPoint(target.Position)
        local target2D = Vector2.new(pos.X, pos.Y)
        local offset = (target2D - mousePos)

        if mousemoverel then
            -- 物理マウス移動（Executor用）
            mousemoverel(offset.X * config.smooth, offset.Y * config.smooth)
        else
            -- 従来のカメラLerp（バックアップ用）
            C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, target.Position), 0.15)
        end

        if config.autoFire and mouse1press then
            mouse1press(); task.wait(0.02); mouse1release()
        end
    end
end)
