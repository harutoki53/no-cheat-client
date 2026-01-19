-- Rivals Script: Final J/K Perfect Fix
local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer

local config = {
    aimbot = true,
    wallCheck = true, -- 最初は壁チェックON（壁裏は見えない）
    smooth = 0.1,
    fov = 150,
    maxSize = 400
}

local ParentGui = (gethui and gethui()) or game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui", ParentGui)
gui.Name = "HarutokiFinalFixed"

-- ステータス表示
local function createLabel(pos, color)
    local l = Instance.new("TextLabel", gui)
    l.Size = UDim2.new(0, 180, 0, 25); l.Position = pos
    l.BackgroundColor3 = Color3.new(0,0,0); l.BackgroundTransparency = 0.5
    l.TextColor3 = color; l.TextScaled = true; l.Font = Enum.Font.RobotoMono
    return l
end
local aimL = createLabel(UDim2.new(0, 10, 0, 10), Color3.new(0, 1, 0))
local wallL = createLabel(UDim2.new(0, 10, 0, 40), Color3.new(0, 1, 1))

local function updateStatus()
    aimL.Text = "AIMBOT: " .. (config.aimbot and "ON [K]" or "OFF [K]")
    aimL.TextColor3 = config.aimbot and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    wallL.Text = "WALL CHECK: " .. (config.wallCheck and "ON [J]" or "OFF [J]")
    wallL.TextColor3 = config.wallCheck and Color3.new(0, 1, 1) or Color3.new(1, 0.5, 0)
end
updateStatus()

-- キー入力判定
U.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then config.aimbot = not config.aimbot; updateStatus() end
    if input.KeyCode == Enum.KeyCode.J then config.wallCheck = not config.wallCheck; updateStatus() end
end)

-- (ESP作成関数は変更なしのため内部処理のみ記載)
local playerESP = {}
local function getESP(v)
    if not playerESP[v] then
        local f = Instance.new("Frame", gui); f.Visible = false; f.BackgroundTransparency = 1
        -- ...（ここに前回のコーナー作成等を統合）...
        playerESP[v] = {Main = f} -- 簡易化して記載
    end
    return playerESP[v]
end

R.RenderStepped:Connect(function()
    local C = workspace.CurrentCamera
    if not C then return end
    local target, nearest = nil, config.fov

    for _, v in pairs(P:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Head") then
            local head = v.Character.Head
            local pos, onScreen = C:WorldToViewportPoint(head.Position)
            local esp = playerESP[v] -- 既存のESPを取得
            
            if onScreen then
                -- 壁チェック判定
                local isVisible = true
                local parts = C:GetPartsObscuringTarget({head.Position}, {v.Character, LP.Character})
                if #parts > 0 then isVisible = false end

                -- 【重要】Jキー（wallCheck）の設定で表示を切り替える
                if config.wallCheck and not isVisible then
                    -- 壁チェックONかつ壁裏なら、表示を消す
                    if esp then esp.Main.Visible = false end
                else
                    -- 表示する条件
                    if esp then esp.Main.Visible = true end
                    -- エイムターゲット選定
                    local dist = (Vector2.new(pos.X, pos.Y) - U:GetMouseLocation()).Magnitude
                    if dist < nearest then target = v; nearest = dist end
                end
            elseif esp then esp.Main.Visible = false end
        end
    end

    -- エイム実行
    if config.aimbot and target and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local head = target.Character.Head
        C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, head.Position), config.smooth)
    end
end)
