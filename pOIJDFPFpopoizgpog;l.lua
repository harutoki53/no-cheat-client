-- [[ Xeno Executor 用 究極統合スクリプト V11 (Rivals対応版) ]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 設定用
_G.GodMode = _G.GodMode or false
_G.Noclip = _G.Noclip or false
_G.FlyEnabled = _G.FlyEnabled or false
_G.ForcedSpeed = _G.ForcedSpeed or 0
_G.FlySpeed = _G.FlySpeed or 50
_G.HitboxSize = _G.HitboxSize or 2 -- デフォルトは2（普通）

-- 1. 空を明るくする
Lighting.Brightness = 3
Lighting.ClockTime = 14
Lighting.GlobalShadows = false

-- 2. メインループ (無敵・速度・壁抜け)
local function SetupCharacter(char)
    local hum = char:WaitForChild("Humanoid")
    task.spawn(function()
        while char.Parent do
            RunService.RenderStepped:Wait()
            if _G.GodMode then
                hum.Health = 9e9
                hum.BreakJointsOnDeath = false
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            end
            if _G.ForcedSpeed > 0 then hum.WalkSpeed = _G.ForcedSpeed end
            if _G.Noclip then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(SetupCharacter)
if LocalPlayer.Character then SetupCharacter(LocalPlayer.Character) end

-- 3. ヒットボックス拡大 (Rivals対策: 敵の頭を大きくする)
task.spawn(function()
    while true do
        task.wait(1)
        if _G.HitboxSize > 2 then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local head = p.Character.Head
                    head.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                    head.Transparency = 0.7 -- 少し透明にして見やすく
                    head.CanCollide = false
                end
            end
        end
    end
end)

-- 4. 飛行機能 (Fly)
local bv, bg
function StartFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 9e4
    task.spawn(function()
        while _G.FlyEnabled and char.Parent do
            local camera = workspace.CurrentCamera
            local moveDir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
            bv.Velocity = moveDir * _G.FlySpeed
            bg.CFrame = camera.CFrame
            RunService.RenderStepped:Wait()
        end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end)
end

-- 5. ESP (場所特定)
local function CreateESP(player)
    if player == LocalPlayer then return end
    local function apply(char)
        task.wait(0.5)
        local hl = char:FindFirstChild("ESP_HL") or Instance.new("Highlight", char)
        hl.Name = "ESP_HL"; hl.FillColor = Color3.fromRGB(255, 0, 0); hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    if player.Character then apply(player.Character) end
    player.CharacterAdded:Connect(apply)
end
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- 6. GUI
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 250, 0, 520); mainFrame.Position = UDim2.new(0.5, -125, 0.5, -260)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); mainFrame.Active = true; mainFrame.Draggable = true; mainFrame.Visible = false

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 35); title.Text = "Xeno Rivals-V11 (U)"; title.BackgroundColor3 = Color3.fromRGB(35, 35, 35); title.TextColor3 = Color3.new(1, 1, 1)

local function createBtn(txt, pos, cb)
    local b = Instance.new("TextButton", mainFrame); b.Size = UDim2.new(0.9,0,0,35); b.Position = pos; b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(45,45,45); b.TextColor3 = Color3.new(1,1,1); b.MouseButton1Click:Connect(function() cb(b) end)
    return b
end

createBtn("God Mode (Classic)", UDim2.new(0.05, 0, 0, 45), function() _G.GodMode = not _G.GodMode end)
createBtn("Noclip (Wall Hack)", UDim2.new(0.05, 0, 0, 85), function() _G.Noclip = not _G.Noclip end)
createBtn("Fly Toggle", UDim2.new(0.05, 0, 0, 125), function() _G.FlyEnabled = not _G.FlyEnabled if _G.FlyEnabled then StartFly() end end)

-- ヒットボックス設定 (Rivalsで勝つための機能)
local hbLabel = Instance.new("TextLabel", mainFrame)
hbLabel.Size = UDim2.new(0.9, 0, 0, 20); hbLabel.Position = UDim2.new(0.05, 0, 0, 170)
hbLabel.Text = "Hitbox Size (2=Normal, 15=Huge)"; hbLabel.TextColor3 = Color3.new(1,1,1); hbLabel.BackgroundTransparency = 1; hbLabel.TextSize = 10

local hbInput = Instance.new("TextBox", mainFrame)
hbInput.Size = UDim2.new(0.9, 0, 0, 30); hbInput.Position = UDim2.new(0.05, 0, 0, 190)
hbInput.Text = tostring(_G.HitboxSize); hbInput.BackgroundColor3 = Color3.fromRGB(60,60,60); hbInput.TextColor3 = Color3.new(1,1,1)
hbInput.FocusLost:Connect(function() _G.HitboxSize = tonumber(hbInput.Text) or 2 end)

-- 速度・飛行速度入力
local function createInp(lbl, pos, def, onUpdate)
    local l = Instance.new("TextLabel", mainFrame); l.Size = UDim2.new(0.4, 0, 0, 30); l.Position = pos; l.Text = lbl; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextSize = 12
    local b = Instance.new("TextBox", mainFrame); b.Size = UDim2.new(0.45, 0, 0, 30); b.Position = pos + UDim2.new(0.45, 0, 0, 0); b.Text = tostring(def); b.BackgroundColor3 = Color3.fromRGB(60, 60, 60); b.TextColor3 = Color3.new(1,1,1)
    b.FocusLost:Connect(function() onUpdate(tonumber(b.Text) or 0) end)
end

createInp("WalkSpd:", UDim2.new(0.05, 0, 0, 230), _G.ForcedSpeed, function(v) _G.ForcedSpeed = v end)
createInp("FlySpd:", UDim2.new(0.05, 0, 0, 270), _G.FlySpeed, function(v) _G.FlySpeed = v end)

-- プレイヤーリスト (TP)
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size = UDim2.new(0.9, 0, 0, 180); scroll.Position = UDim2.new(0.05, 0, 0, 310)
scroll.BackgroundTransparency = 0.8; scroll.CanvasSize = UDim2.new(0,0,0,0)
local layout = Instance.new("UIListLayout", scroll)

local function UpdateList()
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local f = Instance.new("Frame", scroll); f.Size = UDim2.new(1,0,0,35); f.BackgroundTransparency = 1
            local n = Instance.new("TextLabel", f); n.Size = UDim2.new(0.7,0,1,0); n.Text = p.DisplayName; n.TextColor3 = Color3.new(1,1,1); n.BackgroundTransparency = 1; n.TextXAlignment = Enum.TextXAlignment.Left
            local t = Instance.new("TextButton", f); t.Size = UDim2.new(0.25,0,0.8,0); t.Position = UDim2.new(0.7,0,0.1,0); t.Text = "TP"; t.BackgroundColor3 = Color3.fromRGB(0, 100, 255); t.TextColor3 = Color3.new(1, 1, 1)
            t.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,3,0)
                end
            end)
        end
    end
    scroll.CanvasSize = UDim2.new(0,0,0, #Players:GetPlayers() * 37)
end

UserInputService.InputBegan:Connect(function(input, proc)
    if not proc and input.KeyCode == Enum.KeyCode.U then
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then UpdateList() end
    end
end)
