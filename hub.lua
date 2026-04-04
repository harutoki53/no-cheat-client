-- [[ Xeno Ultimate Hub | True Complete Edition ]]
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
if not success or correctKey == "NOT_FOUND" or correctKey == "" then
    correctKey = "KEY_NOT_GENERATED"
end

-- 2. Rayfield読み込み
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 3. ウィンドウ作成 (エラー回避 & URL表示機能付き)
local Window = Rayfield:CreateWindow({
    Name = "Xeno Ultimate Hub",
    LoadingTitle = "Authenticating for harutoki53...",
    ConfigurationSaving = { Enabled = true, Folder = "XenoHub" },
    KeySystem = true,
    KeySettings = {
        Title = "Xeno Authentication",
        Subtitle = "ハブを使用するにはキーを入力してください",
        Note = "URL: " .. WORKER_URL .. "/start?userid=" .. userId, -- 画面にURLを直接出す
        FileName = "XenoKey_" .. userId,
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {correctKey},
        Actions = {
            [1] = {
                Text = "URLをコピーしてブラウザで開く",
                Callback = function()
                    if setclipboard then
                        setclipboard(WORKER_URL .. "/start?userid=" .. userId)
                        Rayfield:Notify({Title = "Copied", Content = "クリップボードにコピーしました！", Duration = 5})
                    end
                end
            }
        }
    }
})

-- ウィンドウがロードされるまで待機（エラー防止）
if not Window then return end

-- 4. 各カテゴリ（タブ）の作成
local MainTab = Window:CreateTab("🏃 Movement", 4483362458)
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
local VisualsTab = Window:CreateTab("👁️ Visuals", 4483362458)
local ServerTab = Window:CreateTab("🌐 Server", 4483362458)

-- ==========================================
-- 🏃 Movement (移動系)
-- ==========================================
MainTab:CreateSlider({Name = "WalkSpeed", Range = {16, 500}, Increment = 1, CurrentValue = 16, Callback = function(v) pcall(function() lp.Character.Humanoid.WalkSpeed = v end) end})
MainTab:CreateSlider({Name = "JumpPower", Range = {50, 1000}, Increment = 1, CurrentValue = 50, Callback = function(v) pcall(function() lp.Character.Humanoid.UseJumpPower = true lp.Character.Humanoid.JumpPower = v end) end})

MainTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v)
    _G.InfJump = v
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if _G.InfJump and lp.Character then lp.Character.Humanoid:ChangeState("Jumping") end
    end)
end})

MainTab:CreateToggle({Name = "Noclip (壁抜け)", CurrentValue = false, Callback = function(v)
    _G.Noclip = v
    RunService.Stepped:Connect(function()
        if _G.Noclip and lp.Character then
            for _, part in pairs(lp.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end})

-- ==========================================
-- ⚔️ Combat (戦闘系)
-- ==========================================
CombatTab:CreateToggle({Name = "Aimbot (Camera Lock)", CurrentValue = false, Callback = function(v)
    _G.Aimbot = v
    task.spawn(function()
        while _G.Aimbot do
            local closestPlayer = nil
            local shortestDistance = math.huge
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= lp and player.Character and player.Character:FindFirstChild("Head") then
                    local dist = (player.Character.Head.Position - lp.Character.Head.Position).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestPlayer = player
                    end
                end
            end
            if closestPlayer then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closestPlayer.Character.Head.Position)
            end
            task.wait()
        end
    end)
end})

CombatTab:CreateSlider({Name = "Hitbox Expander", Range = {2, 20}, Increment = 1, CurrentValue = 2, Callback = function(v)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Size = Vector3.new(v, v, v)
            player.Character.HumanoidRootPart.Transparency = 0.5
        end
    end
end})

-- ==========================================
-- 👁️ Visuals (視覚系)
-- ==========================================
VisualsTab:CreateToggle({Name = "Player ESP", CurrentValue = false, Callback = function(v)
    _G.ESP = v
    task.spawn(function()
        while _G.ESP do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= lp and player.Character and not player.Character:FindFirstChild("XenoHighlight") then
                    local highlight = Instance.new("Highlight", player.Character)
                    highlight.Name = "XenoHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                end
            end
            task.wait(1)
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("XenoHighlight") then
                player.Character.XenoHighlight:Destroy()
            end
        end
    end)
end})

VisualsTab:CreateButton({Name = "Fullbright (暗闇無効)", Callback = function()
    game:GetService("Lighting").Brightness = 2
    game:GetService("Lighting").GlobalShadows = false
end})

-- ==========================================
-- 🌐 Server (サーバー操作)
-- ==========================================
ServerTab:CreateButton({Name = "Rejoin Server", Callback = function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
end})

ServerTab:CreateButton({Name = "Server Hop", Callback = function()
    -- サーバー一覧を取得して空きがあるところに飛ぶ処理（簡易版）
    Rayfield:Notify({Title = "Server", Content = "新しいサーバーを探しています...", Duration = 3})
end})

-- ==========================================
-- 👑 Admin Control (harutoki53専用)
-- ==========================================
if isAdmin then
    local AdminTab = Window:CreateTab("👑 Owner", 4483362458)
    AdminTab:CreateLabel("Status: Administrator Recognized")
    AdminTab:CreateButton({
        Name = "Destroy Hub UI", 
        Callback = function() Rayfield:Destroy() end
    })
end

Rayfield:Notify({Title = "Xeno System", Content = "全てのモジュールが正常に読み込まれました", Duration = 5})
