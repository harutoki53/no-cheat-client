-- [[ Xeno Ultimate Hub | GitHub Hosted Framework ]]
local lp = game.Players.LocalPlayer
local userId = lp.UserId
local isAdmin = (userId == 4666377774)
local WORKER_URL = "https://cheat1934.harutoki53.com"
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- === 1. Workerから現在の正解キーを取得 ===
local success, correctKey = pcall(function()
    return game:HttpGet(WORKER_URL .. "/get_key?userid=" .. userId)
end)
if not success or correctKey == "NOT_FOUND" or correctKey == "" then
    correctKey = "KEY_NOT_GENERATED_YET" -- キーがない場合は適当な文字にして認証を通さない
end

-- === 2. UIライブラリの読み込みとキーシステム画面 ===
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Xeno Ultimate Hub",
    LoadingTitle = "Loading Xeno Framework...",
    ConfigurationSaving = { Enabled = true, Folder = "XenoHub" },
    KeySystem = true, -- ここをtrueにすると最初にキー入力画面が出ます！
    KeySettings = {
        Title = "Xeno Authentication",
        Subtitle = "ハブを使用するにはキーを入力してください",
        Note = "下のボタンからURLをコピーしてブラウザで開いてください",
        FileName = "XenoKey_" .. userId,
        SaveKey = true,
        GrabKeyFromSite = true, -- 「Get Key(URLコピー)」ボタンを表示する
        KeyLink = WORKER_URL .. "/start?userid=" .. userId, -- コピーされるURL
        Key = {correctKey} -- Workerから取得した正解キー
    }
})

-- === 3. スカスカじゃない充実したメイン機能 ===

-- 【タブ構成】
local MainTab = Window:CreateTab("🏃 Movement", 4483362458)
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
local VisualsTab = Window:CreateTab("👁️ Visuals", 4483362458)
local ServerTab = Window:CreateTab("🌐 Server", 4483362458)

-- 👑 【管理者専用タブ】
if isAdmin then
    local AdminTab = Window:CreateTab("👑 Admin Control", 4483362458)
    AdminTab:CreateLabel("Welcome Administrator: harutoki53")
    AdminTab:CreateButton({Name = "Force Close UI", Callback = function() Rayfield:Destroy() end})
end

-- ==========================================
-- 🏃 Movement (移動系)
-- ==========================================
local walkSpeedSlider = MainTab:CreateSlider({Name = "WalkSpeed", Range = {16, 500}, Increment = 1, CurrentValue = 16, Callback = function(v) pcall(function() lp.Character.Humanoid.WalkSpeed = v end) end})
local jumpPowerSlider = MainTab:CreateSlider({Name = "JumpPower", Range = {50, 1000}, Increment = 1, CurrentValue = 50, Callback = function(v) pcall(function() lp.Character.Humanoid.UseJumpPower = true lp.Character.Humanoid.JumpPower = v end) end})

MainTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v)
    _G.InfJump = v
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if _G.InfJump and lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid:ChangeState("Jumping")
        end
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
    RunService.RenderStepped:Connect(function()
        if _G.Aimbot then
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
        end
    end)
end})

CombatTab:CreateSlider({Name = "Hitbox Expander (当たり判定拡大)", Range = {2, 20}, Increment = 1, CurrentValue = 2, Callback = function(v)
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
VisualsTab:CreateToggle({Name = "Player ESP (ハイライト)", CurrentValue = false, Callback = function(v)
    _G.ESP = v
    while _G.ESP do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= lp and player.Character then
                if not player.Character:FindFirstChild("Highlight") then
                    local highlight = Instance.new("Highlight", player.Character)
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            end
        end
        task.wait(1)
    end
    -- ESPオフ時に消去
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Highlight") then
            player.Character.Highlight:Destroy()
        end
    end
end})

VisualsTab:CreateButton({Name = "Fullbright (暗闇無効)", Callback = function()
    game:GetService("Lighting").Brightness = 2
    game:GetService("Lighting").ClockTime = 14
    game:GetService("Lighting").FogEnd = 100000
    game:GetService("Lighting").GlobalShadows = false
end})

-- ==========================================
-- 🌐 Server (サーバー操作)
-- ==========================================
ServerTab:CreateButton({Name = "Rejoin Server (再接続)", Callback = function()
    local ts = game:GetService("TeleportService")
    ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
end})

ServerTab:CreateButton({Name = "Server Hop (別のサーバーへ)", Callback = function()
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/"
    local _place = game.PlaceId
    local _servers = Api..tostring(_place).."/servers/Public?sortOrder=Asc&limit=100"
    local function ListServers(cursor)
        local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
        return Http:JSONDecode(Raw)
    end
    local Server
    local Next
    repeat
        local Servers = ListServers(Next)
        Server = Servers.data[1]
        Next = Servers.nextPageCursor
    until Server
    TPS:TeleportToPlaceInstance(_place, Server.id, lp)
end})

Rayfield:Notify({Title = "Xeno Loaded", Content = "認証に成功しました！", Duration = 5})
