local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

-- --- デフォルト設定 (ご要望通りに調整) ---
local config = {
    aimbot = true,      -- J: デフォルトON
    autoFire = false,   -- K: デフォルトOFF
    wallCheck = true,   -- L: デフォルトON (壁越しでは動かない = チェックを有効にする)
    hideUI = true,      -- O: デフォルトOFF (ESP非表示)
    smooth = 0.4,
    pcFov = 800,
    maxDistance = 500,
    menuOpen = false
}

-- --- GUI表示用通知関数 (Shiftキー用) ---
local function notify(text)
    local n = Instance.new("Message", game.CoreGui) -- 画面全体に一瞬出す通知
    n.Text = text
    task.wait(1)
    n:Destroy()
end

-- --- キー入力による切り替え (画面表示なし) ---
U.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    
    -- J: エイム切り替え
    if i.KeyCode == Enum.KeyCode.J then
        config.aimbot = not config.aimbot
    
    -- K: 自動発射切り替え
    elseif i.KeyCode == Enum.KeyCode.K then
        config.autoFire = not config.autoFire
    
    -- L: Wall切り替え (壁越しチェックのON/OFF)
    elseif i.KeyCode == Enum.KeyCode.L then
        config.wallCheck = not config.wallCheck
        
    -- O: ESP切り替え (勝手に切り替わらないようココで一括管理)
    elseif i.KeyCode == Enum.KeyCode.O then
        config.hideUI = not config.hideUI
        
    -- LeftShiftまたはRightShift: 通知ありのアクション
    elseif i.KeyCode == Enum.KeyCode.LeftShift or i.KeyCode == Enum.KeyCode.RightShift then
        -- ここにShift時のアクションを記述
        notify("Shiftアクションを実行しました")
    end
end)

-- --- ESP & 判定ロジック ---
local function isEnemy(v)
    if not v or v == LP then return false end
    if LP.Team and v.Team then return LP.Team ~= v.Team end
    return true
end

local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "HarutokiUltimate_Final"
gui.ResetOnSpawn = false

local pESP = {}
local function createESP(v)
    if v == LP then return nil end
    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false
    local mainFrame = Instance.new("Frame", container); mainFrame.Size = UDim2.new(1, 0, 1, 0); mainFrame.BackgroundTransparency = 1
    local stroke = Instance.new("UIStroke", mainFrame); stroke.Thickness = 2; stroke.Color = Color3.new(0, 1, 0)
    pESP[v] = {Main = container, Stroke = stroke}
    return pESP[v]
end

-- --- メインエンジン ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character then return end
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local targetHead, nearestDist = nil, config.pcFov
    local fireAllowed = false

    for _, v in pairs(P:GetPlayers()) do
        if not isEnemy(v) then 
            if pESP[v] then pESP[v].Main.Visible = false end continue 
        end

        local char = v.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")

        if head and hum and hum.Health > 0 then
            local dist = (head.Position - C.CFrame.Position).Magnitude
            local pos, onScreen = C:WorldToViewportPoint(head.Position)
            
            -- 壁判定 (config.wallCheckがONなら壁越しを無視する)
            local isVisible = true
            if config.wallCheck then
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LP.Character, char, C}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position).Unit * dist, rayParams)
                isVisible = not result
            end

            -- ESP表示条件
            if onScreen and not config.hideUI and dist <= config.maxDistance then
                local esp = pESP[v] or createESP(v)
                if esp then
                    esp.Main.Visible = true
                    local h = math.clamp(1000/pos.Z, 10, 500); local w = h * 0.7
                    esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                end
            elseif pESP[v] then pESP[v].Main.Visible = false end

            -- エイムターゲット (壁判定がONなら見えている敵だけ狙う)
            if onScreen and isVisible and dist <= config.maxDistance then
                local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mouseDist < nearestDist then
                    targetHead = head
                    nearestDist = mouseDist
                end
                if mouseDist < 100 then fireAllowed = true end
            end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    -- エイム実行
    if targetHead and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local pos, _ = C:WorldToViewportPoint(targetHead.Position)
        if mousemoverel then
            mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)
        end
    end

    -- 発射
    if config.autoFire and fireAllowed and mouse1press then
        mouse1press(); task.wait(0.01); mouse1release()
    end
end)
