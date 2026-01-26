-- Rivals Script: Harutoki Ultimate (True Independent Window & Hide-UI)
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
    hideUI = true -- デフォルトON
}

-- --- UIレイヤー構築 ---
local gui = Instance.new("ScreenGui")
gui.Name = "Harutoki_Independent_Window"
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999 -- 最前面

-- Xenoの環境で可能な限り深いレイヤー(CoreGui)に挿入
local success, parent = pcall(function() return game:GetService("CoreGui") end)
gui.Parent = success and parent or LP:WaitForChild("PlayerGui")

-- --- 設定ウィンドウ（擬似別ウィンドウ） ---
local menuFrame = Instance.new("Frame", gui)
menuFrame.Size = UDim2.new(0, 220, 0, 320)
menuFrame.Position = UDim2.new(0, 50, 0, 50) -- 初期位置
menuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menuFrame.BorderSizePixel = 2
menuFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
menuFrame.Active = true
menuFrame.Draggable = true -- これでOBSの枠外へ移動させる
menuFrame.Visible = false
Instance.new("UICorner", menuFrame)

-- ウィンドウタイトル
local title = Instance.new("TextLabel", menuFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "HARUTOKI SETTINGS"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.RobotoMono

local function createMenuBtn(txt, y)
    local b = Instance.new("TextButton", menuFrame)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = txt
    b.TextScaled = true
    b.Font = Enum.Font.RobotoMono
    Instance.new("UICorner", b)
    return b
end

-- ボタン生成（配置 y座標を調整）
local aimBtn = createMenuBtn("AIMBOT", 50)
local fireBtn = createMenuBtn("AUTO FIRE", 100)
local wallBtn = createMenuBtn("FILTER", 150)
local hideBtn = createMenuBtn("HIDE UI", 200) -- ボタン追加
local closeBtn = createMenuBtn("CLOSE", 250)

local function updateUI()
    menuFrame.Visible = config.menuOpen
    aimBtn.Text = "AIM: " .. (config.aimbot and "ON" or "OFF")
    fireBtn.Text = "FIRE: " .. (config.autoFire and "ON" or "OFF")
    wallBtn.Text = "FILTER: " .. (config.wallCheck and "ON" or "OFF")
    hideBtn.Text = "HIDE UI: " .. (config.hideUI and "ON" or "OFF")
    
    -- HIDE UIの状態に応じて色を変える（視認用）
    hideBtn.BackgroundColor3 = config.hideUI and Color3.fromRGB(80, 20, 20) or Color3.fromRGB(35, 35, 35)
end

-- ボタン操作
aimBtn.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; updateUI() end)
fireBtn.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)
wallBtn.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)
hideBtn.MouseButton1Click:Connect(function() config.hideUI = not config.hideUI; updateUI() end)
closeBtn.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)

-- --- ESP表示用オブジェクト ---
local pESP = {}
local function createESP(v)
    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false
    local box = Instance.new("Frame", container); box.Size = UDim2.new(1, 0, 1, 0); box.BackgroundTransparency = 1
    local stroke = Instance.new("UIStroke", box); stroke.Thickness = 2; stroke.Color = Color3.new(1,1,1)
    pESP[v] = {Main = container, Stroke = stroke}
    return pESP[v]
end

-- --- 入力判定 ---
U.InputBegan:Connect(function(i, gpe)
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

    for _, v in pairs(P:GetPlayers()) do
        if v == LP then continue end
        local esp = pESP[v] or createESP(v)
        
        -- HIDE UI が ON の時は描画をスキップ
        if config.hideUI then
            esp.Main.Visible = false
        end

        local char = v.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        
        if head then
            local pos, onScreen = C:WorldToViewportPoint(head.Position)
            
            if onScreen then
                -- ESP描画（HIDE UIがOFFの時のみ）
                if not config.hideUI then
                    esp.Main.Visible = true
                    local h = math.clamp(1000/pos.Z, 10, 500)
                    esp.Main.Size = UDim2.new(0, h*0.7, 0, h)
                    esp.Main.Position = UDim2.new(0, pos.X - (h*0.7)/2, 0, pos.Y - h/2)
                end

                -- エイムターゲット計算（HIDE UIの状態に関わらずバックグラウンドで実行）
                local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mouseDist < nearestDist then
                    targetHead = head
                    nearestDist = mouseDist
                end
            else
                esp.Main.Visible = false
            end
        else
            esp.Main.Visible = false
        end
    end

    -- エイム実行
    if targetHead and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local pos, _ = C:WorldToViewportPoint(targetHead.Position)
        if mousemoverel then
            mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)
        end
    end
end)

updateUI()
print("Harutoki Ultimate: Independent Window Mode Loaded")
