-- Rivals Script: Harutoki Ultimate (Nuclear ESP Fix)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = true,
    autoFire = true,
    wallCheck = false, -- 最初は表示確認のためOFFにします
    isPC = true,
    smooth = 0.4,
    fov = 150,
    pcFov = 800,
    maxDistance = 2000, -- 距離を大幅に延長
    menuOpen = false
}

-- --- GUI完全初期化 (最上位レイヤー) ---
local gui = LP:WaitForChild("PlayerGui"):FindFirstChild("HarutokiDebug")
if gui then gui:Destroy() end

gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "HarutokiDebug"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 99999 -- 絶対に最前面

-- --- パーツ探索関数 (Rivalsの特殊構造に対応) ---
local function getBestPart(char)
    if not char then return nil end
    -- Head, RootPart, もしくは何かしらのMeshPartを探す
    return char:FindFirstChild("Head") 
        or char:FindFirstChild("HumanoidRootPart") 
        or char:FindFirstChildWhichIsA("BasePart", true)
end

-- --- チーム判定 ---
local function isEnemy(v)
    if v == LP then return false end
    if LP.Team and v.Team then return LP.Team ~= v.Team end
    return true
end

-- --- ESPオブジェクト管理 ---
local pESP = {}
local function createESP(v)
    local c = Instance.new("Frame", gui)
    c.Size = UDim2.new(0, 100, 0, 100) -- 固定サイズで初期化
    c.BackgroundTransparency = 1
    c.Visible = false

    -- 枠 (Stroke)
    local box = Instance.new("Frame", c)
    box.Size = UDim2.new(1, 0, 1, 0)
    box.BackgroundTransparency = 1
    local s = Instance.new("UIStroke", box)
    s.Color = Color3.new(1, 0, 0) -- 視認性のため一旦「赤」固定
    s.Thickness = 2

    -- 名前
    local n = Instance.new("TextLabel", c)
    n.Size = UDim2.new(1, 0, 0, 20)
    n.Position = UDim2.new(0, 0, 0, -25)
    n.BackgroundTransparency = 1
    n.TextColor3 = Color3.new(1, 1, 1)
    n.TextStrokeTransparency = 0
    n.Font = Enum.Font.RobotoMono
    n.TextScaled = true

    pESP[v] = {Main = c, Name = n, Stroke = s}
    return pESP[v]
end

-- --- メインループ ---
R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character then return end
    
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local targetHead = nil
    local nearestDist = (config.isPC and config.pcFov or config.fov)

    for _, v in pairs(P:GetPlayers()) do
        if not isEnemy(v) then 
            if pESP[v] then pESP[v].Main.Visible = false end
            continue 
        end

        local char = v.Character
        local part = getBestPart(char)
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")

        -- 生存チェックを一時的に緩めて「存在すれば出す」設定に
        if part then
            local pos, onScreen = C:WorldToViewportPoint(part.Position)
            local dist = (part.Position - C.CFrame.Position).Magnitude

            if onScreen and dist <= config.maxDistance then
                local esp = pESP[v] or createESP(v)
                esp.Main.Visible = true
                
                -- サイズ計算を強制固定して「点」でも見えるように
                local size = math.clamp(2000 / pos.Z, 10, 500)
                esp.Main.Size = UDim2.new(0, size * 0.7, 0, size)
                esp.Main.Position = UDim2.new(0, pos.X - (size * 0.7)/2, 0, pos.Y - size/2)
                
                esp.Name.Text = v.Name .. " [" .. math.floor(dist) .. "m]"
                
                -- エイム判定
                local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mouseDist < nearestDist then
                    targetHead = part
                    nearestDist = mouseDist
                end
            else
                if pESP[v] then pESP[v].Main.Visible = false end
            end
        elseif pESP[v] then
            pESP[v].Main.Visible = false
        end
    end

    -- エイム実行
    if targetHead and config.aimbot then
        local isAim = (config.isPC and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) or not config.isPC
        if isAim then
            local pos, _ = C:WorldToViewportPoint(targetHead.Position)
            if config.isPC and mousemoverel then
                mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)
            else
                C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, targetHead.Position), config.smooth * 0.25)
            end
        end
    end
end)
