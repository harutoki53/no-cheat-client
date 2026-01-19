-- Rivals Script: Harutoki Ultimate (Exact UI Matching Version)
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
    fov = 150,
    pcFov = 800,
    maxDistance = 1000,
    menuOpen = false
}

local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate"
gui.IgnoreGuiInset = true

-- --- ESPオブジェクト作成 (画像レイアウトを1ピクセル単位で再現) ---
local function createESP(v)
    local container = Instance.new("Frame", gui)
    container.BackgroundTransparency = 1; container.Visible = false

    -- 1. コーナーボックス (メインの枠)
    local function createCorner(parent)
        local lines = {}
        for i = 1, 8 do
            local l = Instance.new("Frame", parent)
            l.BackgroundColor3 = Color3.new(1, 1, 1); l.BorderSizePixel = 0
            lines[i] = l
        end
        return lines
    end
    local corners = createCorner(container)

    -- 2. 敵の名前 (上部中央)
    local name = Instance.new("TextLabel", container)
    name.Size = UDim2.new(1, 0, 0, 15); name.Position = UDim2.new(0, 0, 0, -18)
    
    -- 3. 敵の体力数値 (左上)
    local healthNum = Instance.new("TextLabel", container)
    healthNum.Size = UDim2.new(0, 40, 0, 15); healthNum.Position = UDim2.new(0, -45, 0, -5)
    healthNum.TextXAlignment = Enum.TextXAlignment.Right

    -- 4. 敵のアバター (中央)
    local ava = Instance.new("ImageLabel", container)
    ava.Size = UDim2.new(0.5, 0, 0.5, 0); ava.Position = UDim2.new(0.25, 0, 0.25, 0)
    ava.BackgroundTransparency = 1

    -- 5. 体力バー (左側・縦)
    local barBG = Instance.new("Frame", container)
    barBG.Size = UDim2.new(0, 4, 1, 0); barBG.Position = UDim2.new(0, -8, 0, 0)
    barBG.BackgroundColor3 = Color3.new(0, 0, 0)
    local bar = Instance.new("Frame", barBG); bar.BorderSizePixel = 0; bar.Size = UDim2.new(1, 0, 1, 0)
    bar.AnchorPoint = Vector2.new(0, 1); bar.Position = UDim2.new(0, 0, 1, 0)

    -- 6. レベルと連勝 (右下)
    local stats = Instance.new("TextLabel", container)
    stats.Size = UDim2.new(1, 100, 0, 15); stats.Position = UDim2.new(1, 5, 1, -5)
    stats.TextXAlignment = Enum.TextXAlignment.Left

    local function style(t) 
        t.BackgroundTransparency, t.TextColor3, t.Font, t.TextScaled = 1, Color3.new(1, 1, 1), Enum.Font.RobotoMono, true
        Instance.new("UIStroke", t).Thickness = 1
    end
    style(name); style(healthNum); style(stats)

    return {Main = container, Corners = corners, Name = name, HealthNum = healthNum, Ava = ava, Bar = bar, Stats = stats}
end

local function updateCorners(lines, w, h)
    local l = math.clamp(w * 0.2, 5, 20); local t = 1.5
    lines[1].Size, lines[1].Position = UDim2.new(0, l, 0, t), UDim2.new(0, 0, 0, 0)
    lines[2].Size, lines[2].Position = UDim2.new(0, t, 0, l), UDim2.new(0, 0, 0, 0)
    lines[3].Size, lines[3].Position = UDim2.new(0, l, 0, t), UDim2.new(0, w-l, 0, 0)
    lines[4].Size, lines[4].Position = UDim2.new(0, t, 0, l), UDim2.new(0, w-t, 0, 0)
    lines[5].Size, lines[5].Position = UDim2.new(0, l, 0, t), UDim2.new(0, 0, 0, h-t)
    lines[6].Size, lines[6].Position = UDim2.new(0, t, 0, l), UDim2.new(0, 0, 0, h-l)
    lines[7].Size, lines[7].Position = UDim2.new(0, l, 0, t), UDim2.new(0, w-l, 0, h-t)
    lines[8].Size, lines[8].Position = UDim2.new(0, t, 0, l), UDim2.new(0, w-t, 0, h-l)
end

local pESP = {}

-- --- メインループ ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local currentFov = config.isPC and config.pcFov or config.fov
    local target, nearest = nil, currentFov

    for _, v in pairs(P:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Humanoid") then
            local char = v.Character; local hum = char.Humanoid
            if hum.Health > 0 and (not v.Team or v.Team ~= LP.Team) then
                if not pESP[v] then pESP[v] = createESP(v) end
                local esp = pESP[v]; local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos, onScreen = C:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local hPos = C:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 1, 0))
                        local fPos = C:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        local h = math.abs(hPos.Y - fPos.Y); local w = h * 0.7
                        
                        esp.Main.Visible = true; esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                        updateCorners(esp.Corners, w, h)
                        
                        esp.Name.Text = v.DisplayName
                        esp.HealthNum.Text = math.floor(hum.Health)
                        
                        -- 体力バーの色指定 (画像通り)
                        local hp = hum.Health
                        local color = Color3.new(1, 0, 0) -- 0-25: 赤
                        if hp > 80 then color = Color3.new(0, 1, 0)        -- 80-100: 緑
                        elseif hp > 50 then color = Color3.new(1, 1, 0)    -- 50-80: 黄色
                        elseif hp > 25 then color = Color3.new(1, 0.5, 0)  -- 25-50: オレンジ
                        end
                        esp.Bar.Size = UDim2.new(1, 0, hp/hum.MaxHealth, 0)
                        esp.Bar.BackgroundColor3 = color
                        esp.HealthNum.TextColor3 = color

                        esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"
                        
                        -- レベルと連勝の取得 (リーダーボード等から)
                        local lv = v:FindFirstChild("leaderstats") and v.leaderstats:FindFirstChild("Level") and v.leaderstats.Level.Value or 0
                        local ws = v:FindFirstChild("leaderstats") and v.leaderstats:FindFirstChild("Streak") and v.leaderstats.Streak.Value or 0
                        esp.Stats.Text = "Lv: "..lv..(ws > 0 and " ["..ws.." Win]" or "")

                        -- エイム判定
                        local isVisible = #C:GetPartsObscuringTarget({char.Head.Position}, {char, LP.Character}) == 0
                        if (not config.wallCheck) or isVisible then
                            local dC = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if dC < nearest then target = char.Head; nearest = dC end
                        end
                    else esp.Main.Visible = false end
                end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        end
    end

    -- エイム動作 (PC/スマホ共通)
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
