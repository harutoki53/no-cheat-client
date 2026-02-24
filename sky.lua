-- [[ 漆念：最終執行版 (全オブジェクト・全環境強制上書き) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"
local isTransparent = false

-- 1. 空と環境の「絶対固定」
local function ForceEnvironment()
    -- 空の強制適用 (CustomSkyという名前で死守)
    local sky = lighting:FindFirstChild("CustomSky") or Instance.new("Sky", lighting)
    sky.Name = "CustomSky"
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = NEW_BK
    sky.SkyboxRt = NEW_RT
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunAngularSize = 0
    sky.MoonAngularSize = 0

    -- 他のSkyを根絶
    for _, obj in ipairs(lighting:GetChildren()) do
        if obj:IsA("Sky") and obj ~= sky then obj:Destroy() end
    end

    -- 霧と大気を根絶
    lighting.ClockTime = 2
    lighting.Brightness = 2
    lighting.GlobalShadows = false
    lighting.FogEnd = 1e6
    local ambient = Color3.fromRGB(80, 80, 100)
    lighting.Ambient = ambient
    lighting.OutdoorAmbient = ambient
    
    local atm = lighting:FindFirstChildOfClass("Atmosphere")
    if atm then atm:Destroy() end
end

-- 2. 全パーツの「絶対色固定」
local function ApplyTheme(obj)
    -- プレイヤー本人以外、デコイも透明物も「すべて」対象
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    if obj:IsDescendantOf(localPlayer.Character) then return end

    pcall(function()
        if isTransparent then
            -- 【透明モード：透視させない高反射クリスタル】
            obj.Color = Color3.fromRGB(180, 180, 220)
            obj.Material = Enum.Material.Glass
            obj.Transparency = 0.6 -- 透視を防ぐギリギリのライン
            obj.Reflectance = 1.0 -- 表面を鏡にして中身を見せない
        else
            -- 【黒モード：完全漆黒】
            -- デコイも窓も関係なく、すべてを黒に染める
            obj.Color = Color3.new(0, 0, 0)
            obj.Material = Enum.Material.SmoothPlastic
            obj.Transparency = 0
            obj.Reflectance = 0.05
        end
    end)
end

-- 3. 強制ループ (ラグ対策しつつ頻度を上げる)
task.spawn(function()
    while true do
        ForceEnvironment()
        -- マップ全体を定期的に強制再スキャン（戻れないバグ対策）
        for _, obj in ipairs(game.Workspace:GetDescendants()) do
            ApplyTheme(obj)
        end
        task.wait(1.5) -- 1.5秒ごとに世界を塗り替える
    end
end)

-- Pキー切り替え
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        print("Switching Mode... Target: " .. (isTransparent and "Crystal" or "Black"))
        -- 切り替えの瞬間だけ全力でスキャン
        for _, obj in ipairs(game.Workspace:GetDescendants()) do
            ApplyTheme(obj)
        end
    end
end)

-- 常に新しいパーツを監視
game.Workspace.DescendantAdded:Connect(ApplyTheme)

print("--- Midnight Absolute System: ACTIVE ---")
