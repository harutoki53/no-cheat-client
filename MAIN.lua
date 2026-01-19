-- Rivals Script: Harutoki Ultimate (Full Fix)
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = true,
    autoFire = true,
    wallCheck = true, -- ON: 見える敵のみエイム / OFF: 壁越しもエイム
    smooth = 0.4,
    pcFov = 600,
    maxDistance = 1000,
    menuOpen = false
}

-- --- GUI 強制再生成 ---
local gui = LP:WaitForChild("PlayerGui"):FindFirstChild("HarutokiUltimate")
if gui then gui:Destroy() end

gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "HarutokiUltimate"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 10000 -- 確実に最前面

-- --- ターゲット取得 (Rivals対応) ---
local function getTarget(char)
    if not char then return nil end
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart", true)
end

local function isEnemy(v)
    if v == LP then return false end
    if LP.Team and v.Team then return LP.Team ~= v.Team end
    return true
end

-- --- ESP & メインループ ---
local pESP = {}
local function createESP(v)
    local c = Instance.new("Frame", gui); c.BackgroundTransparency = 1; c.Visible = false
    local m = Instance.new("Frame", c); m.Size = UDim2.new(1, 0, 1, 0); m.BackgroundTransparency = 1; local s = Instance.new("UIStroke", m); s.Thickness = 2
    local n = Instance.new("TextLabel", c); n.Size = UDim2.new(1, 0, 0, 15); n.Position = UDim2.new(0, 0, 0, -20)
    local function style(t) t.BackgroundTransparency, t.TextColor3, t.Font, t.TextScaled = 1, Color3.new(1, 1, 1), Enum.Font.RobotoMono, true; Instance.new("UIStroke", t) end
    style(n)
    pESP[v] = {Main = c, Name = n, Stroke = s}
    return pESP[v]
end

R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C or not LP.Character then return end
    
    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)
    local targetHead, nearestDist = nil, config.pcFov
    local fireTarget = false

    for _, v in pairs(P:GetPlayers()) do
        if not isEnemy(v) then 
            if pESP[v] then pESP[v].Main.Visible = false end 
            continue 
        end

        local char = v.Character
        local head = getTarget(char)
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if head and hum and hum.Health > 0 then
            local pos, onScreen = C:WorldToViewportPoint(head.Position)
            local dist = (head.Position - C.CFrame.Position).Magnitude

            if onScreen and dist <= config.maxDistance then
                local esp = pESP[v] or createESP(v)
                
                -- 壁判定 (厳密)
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LP.Character, char, C}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(C.CFrame.Position, (head.Position - C.CFrame.Position).Unit * dist, rayParams)
                local isVisible = not result

                -- ESP描画
                esp.Main.Visible = true
                local h = math.clamp(1000/pos.Z, 10, 500); local w = h * 0.7
                esp.Main.Position = UDim2.new(0, pos.X - w/2, 0, pos.Y - h/2); esp.Main.Size = UDim2.new(0, w, 0, h)
                esp.Stroke.Color = isVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                esp.Name.Text = v.DisplayName .. " [" .. math.floor(dist) .. "m]"

                -- エイムターゲット選定 (FILTER反映)
                local mouseDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mouseDist < nearestDist then
                    if (not config.wallCheck) or isVisible then
                        targetHead = head
                        nearestDist = mouseDist
                    end
                end

                -- 自動発射判定 (画面中央付近 & 視認可能なら)
                if isVisible and mouseDist < 80 then
                    fireTarget = true
                end
            elseif pESP[v] then pESP[v].Main.Visible = false end
        elseif pESP[v] then pESP[v].Main.Visible = false end
    end

    -- オートエイム実行 (右クリック押下中)
    if targetHead and config.aimbot and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local pos, _ = C:WorldToViewportPoint(targetHead.Position)
        if mousemoverel then
            mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)
        else
            C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, targetHead.Position), 0.15)
        end
    end

    -- 自動発射実行 (エイム中・非エイム中問わず敵が中心にいれば撃つ)
    if config.autoFire and fireTarget then
        if mouse1press then
            mouse1press(); task.wait(0.02); mouse1release()
        end
    end
end)

-- 右クリックが使えない環境（一部のExecutor）用のバックアップ
U.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.F2 then -- F2キーでFILTER切り替えのショートカット
        config.wallCheck = not config.wallCheck
        print("FILTER: " .. tostring(config.wallCheck))
    end
end)
