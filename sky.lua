-- [[ 漆念：最終完全版 (空の強制再生成・視認性強化) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

-- 指定の空ID
local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"

local isTransparent = false

-- 1. 空の「強制再生成」ループ（既存の空を破壊して上書き）
local function ForceSky()
    -- 霧や大気エフェクトが邪魔をして空が見えない場合が多いので、これらを徹底排除
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("FogEnd") then
            obj:Destroy()
        end
    end

    -- Skyオブジェクトの管理
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "CustomSky"
        sky.Parent = lighting
    end

    -- IDが一致しない場合は強制上書き
    if sky.SkyboxBk ~= NEW_BK then
        sky.SkyboxFt = "rbxassetid://72529916859362"
        sky.SkyboxBk = NEW_BK
        sky.SkyboxRt = NEW_RT
        sky.SkyboxLf = "rbxassetid://116760075528148"
        sky.SkyboxUp = "rbxassetid://119892967613407"
        sky.SkyboxDn = "rbxassetid://123559461938777"
        sky.SunAngularSize = 0
        sky.MoonAngularSize = 20 -- 月の光を少しだけ残して視認性を助ける
    end
    
    -- 時間と霧の設定
    lighting.ClockTime = 2
    lighting.FogEnd = 100000
    lighting.GlobalShadows = true -- 影を有効にして立体感を出す
end

-- 2. 環境 ＆ 全オブジェクトの黒化（輪郭強調Ver）
local function ForceEnvironment()
    -- 【視認性改善】真っ暗すぎて見えないのを防ぐ設定
    lighting.Brightness = 1.5 -- 輝度を少し上げて反射を際立たせる
    lighting.Ambient = Color3.fromRGB(30, 30, 30) -- 環境光を少し上げ、黒の中にも「形」が見えるように
    lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 15)
    lighting.ExposureCompensation = 0 -- 露出を標準に戻す

    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if not obj:IsDescendantOf(localPlayer.Character or game.Workspace.CurrentCamera) and not obj:IsA("Terrain") then
            pcall(function()
                if isTransparent then
                    -- 【Pキー：透明モード】
                    obj.Color = Color3.fromRGB(80, 80, 100)
                    obj.Material = Enum.Material.ForceField
                    obj.Transparency = 0.4
                else
                    -- 【通常：エッジ強調の黒】
                    if obj:IsA("BasePart") and obj.Transparency < 0.5 then
                        obj.Color = Color3.new(0, 0, 0)
                        obj.Material = Enum.Material.Metal -- Plasticより反射が綺麗に出るMetalに変更
                        obj.Transparency = 0
                        -- 反射率を0.15までアップ。これで「黒いけど形がクッキリ見える」ようになります。
                        obj.Reflectance = 0.15 
                    elseif obj:IsA("Texture") or obj:IsA("Decal") then
                        obj.Transparency = 1
                    end
                end
            end)
        end
    end
end

-- 3. キー入力 (Pキー)
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        pcall(ForceEnvironment)
    end
end)

-- 4. 実行ループ
RunService.Heartbeat:Connect(function()
    pcall(ForceSky)
end)

task.spawn(function()
    while true do
        pcall(ForceEnvironment)
        task.wait(5)
    end
end)
