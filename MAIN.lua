-- Rivals Script: Final God Mode Hybrid (Visual Enhanced)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = true,
    autoFire = true,
    wallCheck = true,
    isPC = true,
    smooth = 0.4,
    fov = 150,        -- スマホ用
    pcFov = 800,      -- PC用（固定）
    maxSize = 400,
    maxDistance = 1000,
    menuOpen = false
}

-- GUI初期化
local old = LP:WaitForChild("PlayerGui"):FindFirstChild("HarutokiUltimate")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.IgnoreGuiInset = true

-- --- コーナーボックス作成用関数 (復活) ---
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

-- --- ESPオブジェクト作成 (アバターアイコン付き) ---
local function createESP(v)
    local f = Instance.new("Frame", gui); f.BackgroundTransparency = 1; f.Visible = false
    local esp = {
        Main = f, 
        Corners = createCornerBox(f), 
        HealthNum = Instance.new("TextLabel", f), 
        BarBG = Instance.new("Frame", f), 
        Bar = nil, 
        Name = Instance.new("TextLabel", f), 
        Ava = Instance.new("ImageLabel", f)
    }
    local function style(l) 
        l.BackgroundTransparency, l.TextColor3, l.TextScaled, l.Font = 1, Color3.new(1,1,1), true, Enum.Font.RobotoMono
        Instance.new("UIStroke", l).Thickness = 1 
    end
    style(esp.HealthNum); style(esp.Name)
    esp.BarBG.BackgroundColor3 = Color3.new(0,0,0)
    esp.Bar = Instance.new("Frame", esp.BarBG); esp.Bar.BorderSizePixel = 0
    esp.Ava.BackgroundTransparency = 1; Instance.new("UIStroke", esp.Ava).Thickness = 1
    return esp
end
local pESP = {}

-- --- メインUI系 (PC/スマホ切替) ---
local modeToggle = Instance.new("TextButton", gui)
modeToggle.Size = UDim2.new(0, 160, 0, 35); modeToggle.Position = UDim2.new(0, 10, 0, 10)
modeToggle.BackgroundColor3 = Color3.new(0,0,0); modeToggle.BackgroundTransparency = 0.5; modeToggle.TextColor3 = Color3.new(1,1,1); modeToggle.TextScaled = true; modeToggle.Font = Enum.Font.RobotoMono
Instance.new("UIStroke", modeToggle)

local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 280); menuFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
menuFrame.BackgroundColor3 = Color3.new(0,0,0); menuFrame.Visible = false; Instance.new("UIStroke", menuFrame).Color = Color3.new(1,1,1)

local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame); b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); b.TextColor3 = Color3.new(1, 1, 1); b.Text = txt; b.TextScaled = true; b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b); return b
end

local aimBtn = createMenuBtn("AIMBOT", 50)
local fireBtn = createMenuBtn("AUTO FIRE", 95)
local wallBtn = createMenuBtn("FILTER", 140)
local fovBtn = createMenuBtn("MOBILE FOV", 185)
local closeBtn = createMenuBtn("CLOSE", 230); closeBtn.BackgroundColor3 = Color3.new(0.4, 0.1, 0.1)

local function updateUI()
    modeToggle.Text = "MODE: " .. (config.isPC and "PC" or "MOBILE")
    menuFrame.Visible = config.menuOpen
    fovBtn.Visible = not config.isPC
    aimBtn.Text = "AIM: " .. (config.aimbot and "ON" or "OFF")
    fireBtn.Text = "FIRE: " .. (config.autoFire and "ON" or "OFF")
    wallBtn.Text = "FILTER: " .. (config.wallCheck and "ON" or "OFF")
    fovBtn.Text = "FOV: " .. config.fov
end

modeToggle.MouseButton1Click:Connect(function() config.isPC = not config.isPC; config.menuOpen = false; updateUI() end)
closeBtn.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)
aimBtn.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; updateUI() end)
fireBtn.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
wallBtn.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
fovBtn.MouseButton1Click:Connect(function() config.fov = (config.fov >= 450) and 100 or config.fov + 50; updateUI() end)

U.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift and config.isPC then config.menuOpen = not config.menuOpen; updateUI()
    elseif input.KeyCode == Enum.KeyCode.J then config.wallCheck = not config.wallCheck; updateUI() end
end)

-- --- メインループ (エイム & ESP) ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local currentFov = config.isPC and config.pcFov or config.fov
    local target, nearest = nil, currentFov

    for _, v in pairs(P:GetPlayers()) do
        local char = v.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if v ~= LP and hum and root and hum.Health > 0 and (not v.Team or v.Team ~= LP.Team) then
            if not pESP[v] then pESP[v] = createESP(v) end
            local esp = pESP[v]
            local pos, onScreen = C:WorldToViewportPoint(root.Position)

            if onScreen then
                local dist = (root.Position - C.CFrame.Position).Magnitude
                local hPos = C:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.7, 0))
                local lPos = C:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local h = math.clamp(math.abs(hPos.Y - lPos.Y), 40, config.maxSize)
                local w = h * 0.6
                local x, y = pos.X - w/2, pos.Y - h/2

                esp.Main.Visible = true
                updateCornerBox(esp.Corners, x, y, w, h)
                
                esp.HealthNum.Text = tostring(math.floor(hum.Health))
                esp.HealthNum.Position, esp.HealthNum.Size = UDim2.new(0, x-40, 0, y-18), UDim2.new(0, 35, 0, 15)
                esp.BarBG.Position, esp.BarBG.Size = UDim2.new(0, x-8, 0, y), UDim2.new(0, 4, 0, h)
                esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)
                esp.Bar.BackgroundColor3 = (hum.Health/hum.MaxHealth > 0.5) and Color3.new(0,1,0) or Color3.new(1,0,0)
                esp.Name.Text = v.DisplayName
                esp.Name.Position, esp.Name.Size = UDim2.new(0, x, 0, y-20), UDim2.new(0, w, 0, 18)
                esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                esp.Ava.Position, esp.Ava.Size = UDim2.new(0, x+w+5, 0, y), UDim2.new(0, h*0.3, 0, h*0.3)

                -- エイム判定 (FILTER連動)
                local isVisible = #C:GetPartsObscuringTarget({char.Head.Position}, {char, LP.Character}) == 0
                if (not config.wallCheck) or isVisible then
                    local distCenter = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if distCenter < nearest then target = char.Head; nearest = distCenter end
                end
            else esp.Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    if target and config.aimbot then
        local isAim = config.isPC and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or not config.isPC
        if isAim then
            local pos = C:WorldToViewportPoint(target.Position)
            if config.isPC and mousemoverel then
                mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)
            else
                C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, target.Position), config.smooth * 0.4)
            end
            if config.autoFire and mouse1press then mouse1press(); task.wait(0.01); mouse1release() end
        end
    end
end)
updateUI()
