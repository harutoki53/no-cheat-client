-- Rivals Script: Harutoki Ultimate (External Window & Hide-UI Mode)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = true,
    autoFire = true,
    wallCheck = true,
    smooth = 0.4,
    pcFov = 800,
    maxDistance = 1000,
    menuOpen = false,
    hideUI = true -- デフォルトでON（UI非表示）
}

-- --- GUI作成 ---
local gui = Instance.new("ScreenGui")
gui.Name = "HarutokiExternalControl"
gui.DisplayOrder = 999999
gui.IgnoreGuiInset = true

local success, parent = pcall(function() return game:GetService("CoreGui") end)
gui.Parent = success and parent or LP:WaitForChild("PlayerGui")

-- 設定画面（DraggableなのでOBSの枠外へ移動可能）
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 320)
menuFrame.Position = UDim2.new(0, 10, 0, 10)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.Active = true
menuFrame.Draggable = true
menuFrame.Visible = false
Instance.new("UICorner", menuFrame)

local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = txt
    b.TextScaled = true
    b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b)
    return b
end

local aimBtn = createMenuBtn("AIMBOT", 50)
local fireBtn = createMenuBtn("AUTO FIRE", 95)
local wallBtn = createMenuBtn("FILTER", 140)
local hideBtn = createMenuBtn("HIDE UI", 185) -- 新規追加
local closeBtn = createMenuBtn("CLOSE", 230)

local function updateUI()
    -- menuOpenが真、かつ hideUIが偽の時だけメニューを表示
    -- ただし設定変更のためにメニューを開いている間は見えるように設定
    menuFrame.Visible = config.menuOpen
    
    aimBtn.Text = "AIM: " .. (config.aimbot and "ON" or "OFF")
    fireBtn.Text = "FIRE: " .. (config.autoFire and "ON" or "OFF")
    wallBtn.Text = "FILTER: " .. (config.wallCheck and "ON" or "OFF")
    hideBtn.Text = "HIDE UI: " .. (config.hideUI and "ON" or "OFF")
    hideBtn.TextColor3 = config.hideUI and Color3.new(1, 0.4, 0.4) or Color3.new(1, 1, 1)
end

aimBtn.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; updateUI() end)
fireBtn.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
wallBtn.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
hideBtn.MouseButton1Click:Connect(function() config.hideUI = not config.hideUI; updateUI() end)
closeBtn.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)

-- --- ESP ---
local pESP = {}
local function createESP(v)
    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false
    local mainFrame = Instance.new("Frame", container); mainFrame.Size = UDim2.new(1, 0, 1, 0); mainFrame.BackgroundTransparency = 1
    local stroke = Instance.new("UIStroke", mainFrame); stroke.Thickness = 2
    local name = Instance.new("TextLabel", container); name.Size = UDim2.new(1, 0, 0, 15); name.Position = UDim2.new(0, 0, 0, -18)
    
    local function style(t)
        t.BackgroundTransparency, t.TextColor3, t.Font, t.TextScaled = 1, Color3.new(1, 1, 1), Enum.Font.RobotoMono, true
        Instance.new("UIStroke", t)
    end
    style(name)
    pESP[v] = {Main = container, Name = name, Stroke = stroke}
    return pESP[v]
end

-- --- キー入力判定 ---
U.InputBegan:Connect(function(i, gpe)
    -- 右Shiftでメニュー表示/非表示
    if not gpe and i.KeyCode == Enum.KeyCode.RightShift then
        config.menuOpen = not config.menuOpen
        updateUI()
    end
end)

-- --- メインエンジン ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character then return end
    
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local targetHead, nearestDist = nil, config.pcFov
    local fireAllowed = false

    for _, v in pairs(P:GetPlayers()) do
        local esp = pESP[v] or createESP(v)
        
        -- HIDE UI が ON の時は ESP を強制非表示
        if not (v.Character and v.Character:FindFirstChild("Head")) or v == LP or config.hideUI then
            esp.Main.Visible = false
            -- チーム判定（敵のみ狙うロジックは継続）
            if v ~= LP and v.Character and v.Character:FindFirstChild("Head") then
                -- エイム計算のみ裏で行う
                local head = v.Character.Head
                local pos, onScreen = C:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mouseDist < nearestDist then
                        targetHead = head
                        nearestDist = mouseDist
                    end
                end
            end
            continue
        end

        -- 通常時のESP表示ロジック（以下略）
        local char = v.Character
        local head = char.Head
        local pos, onScreen = C:WorldToViewportPoint(head.Position)
        if onScreen then
            esp.Main.Visible = true
            esp.Main.Position = UDim2.new(0, pos.X - 25, 0, pos.Y - 25)
            esp.Main.Size = UDim2.new(0, 50, 0, 50)
            -- エイム対象選定
            local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
            if mouseDist < nearestDist then
                targetHead = head
                nearestDist = mouseDist
            end
        else
            esp.Main.Visible = false
        end
    end

    -- オートエイム & オートファイヤ
    if targetHead and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local pos, _ = C:WorldToViewportPoint(targetHead.Position)
        if mousemoverel then
            mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)
        end
    end
end)

updateUI()
print("Harutoki Ultimate: External Window & Hide-UI Active")
