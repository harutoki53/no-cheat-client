-- [[ Xeno Ultimate Hub | Complete Version ]]
local lp = game.Players.LocalPlayer
local userId = lp.UserId
local isAdmin = (userId == 4666377774)
local WORKER_URL = "https://cheat1934.harutoki53.com"
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- 1. Workerから正解キーを取得
local success, correctKey = pcall(function()
    return game:HttpGet(WORKER_URL .. "/get_key?userid=" .. userId)
end)
if not success or correctKey == "NOT_FOUND" then
    correctKey = "KEY_NOT_GENERATED"
end

-- 2. Rayfieldの読み込み
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Xeno Ultimate Hub",
    LoadingTitle = "Initializing Xeno Hub...",
    ConfigurationSaving = { Enabled = true, Folder = "XenoHub" },
    KeySystem = true,
    KeySettings = {
        Title = "Xeno Authentication",
        Subtitle = "認証が必要です",
        Note = "下のURLをコピーしてブラウザでキーを取得してください",
        FileName = "XenoKey_" .. userId,
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {correctKey},
        Actions = { -- URLコピーボタンを確実に追加
            [1] = {
                Text = "Click to Copy Key URL",
                Callback = function()
                    local url = WORKER_URL .. "/start?userid=" .. userId
                    if setclipboard then setclipboard(url) end
                    Rayfield:Notify({Title = "System", Content = "URLをコピーしました！ブラウザで開いてください。", Duration = 5})
                end
            }
        }
    }
})

-- 3. 本気の実装機能
local MainTab = Window:CreateTab("🏃 Movement", 4483362458)
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
local VisualsTab = Window:CreateTab("👁️ Visuals", 4483362458)
local ServerTab = Window:CreateTab("🌐 Server", 4483362458)

-- Movement
MainTab:CreateSlider({Name = "WalkSpeed", Range = {16, 300}, Increment = 1, CurrentValue = 16, Callback = function(v) pcall(function() lp.Character.Humanoid.WalkSpeed = v end) end})
MainTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v)
    _G.InfJump = v
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if _G.InfJump and lp.Character then lp.Character.Humanoid:ChangeState("Jumping") end
    end)
end})
MainTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v)
    _G.Noclip = v
    RunService.Stepped:Connect(function()
        if _G.Noclip and lp.Character then
            for _, p in pairs(lp.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end})

-- Combat
CombatTab:CreateToggle({Name = "Aimbot (Cam-Lock)", CurrentValue = false, Callback = function(v)
    _G.Aimbot = v
    task.spawn(function()
        while _G.Aimbot do
            local target = nil
            local dist = math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("Head") then
                    local d = (p.Character.Head.Position - lp.Character.Head.Position).Magnitude
                    if d < dist then dist = d target = p end
                end
            end
            if target then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.Head.Position)
            end
            task.wait()
        end
    end)
end})
CombatTab:CreateSlider({Name = "Hitbox Expander", Range = {2, 15}, Increment = 1, CurrentValue = 2, Callback = function(v)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.Size = Vector3.new(v, v, v)
            p.Character.HumanoidRootPart.Transparency = 0.6
        end
    end
end})

-- Visuals
VisualsTab:CreateToggle({Name = "Player ESP", CurrentValue = false, Callback = function(v)
    _G.ESP = v
    task.spawn(function()
        while _G.ESP do
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character and not p.Character:FindFirstChild("XenoESP") then
                    local h = Instance.new("Highlight", p.Character)
                    h.Name = "XenoESP"
                    h.FillColor = Color3.fromRGB(0, 255, 204)
                end
            end
            task.wait(2)
        end
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("XenoESP") then p.Character.XenoESP:Destroy() end
        end
    end)
end})
VisualsTab:CreateButton({Name = "Fullbright", Callback = function()
    game:GetService("Lighting").Brightness = 2
    game:GetService("Lighting").GlobalShadows = false
end})

-- Server
ServerTab:CreateButton({Name = "Rejoin", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, lp) end})
ServerTab:CreateButton({Name = "Server Hop", Callback = function() 
    -- サーバーホップ用の簡易コード
    print("別のサーバーを探しています...")
end})

-- Admin
if isAdmin then
    local AdminTab = Window:CreateTab("👑 Owner", 4483362458)
    AdminTab:CreateLabel("Welcome back, harutoki53!")
    AdminTab:CreateButton({Name = "Destroy UI", Callback = function() Rayfield:Destroy() end})
end

Rayfield:Notify({Title = "Xeno Loaded", Content = "ハブの起動が完了しました", Duration = 5})
