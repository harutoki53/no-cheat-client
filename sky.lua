-- [[ 漆念：極・夜間視認モデル (雲バグ回避・高級透明質感) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

-- 空ID
local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"

local isTransparent = false

-- 1. 空と大気の完全制御
local function ForceSky()
    -- 警告の原因（Clouds）を、消すのではなく無効化してバグを止める
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Clouds") then obj.Enabled = false end
    end
    
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = lighting
    end
    if sky.SkyboxBk ~= NEW_BK then
        sky.SkyboxFt = "rbxassetid://72529916859362"
        sky.SkyboxBk = NEW_BK
        sky.SkyboxRt = NEW_RT
        sky.SkyboxLf = "rbxassetid://116760075528148"
        sky.SkyboxUp = "rbxassetid://119892967613407"
        sky.SkyboxDn = "rbxassetid://123559461938777"
    end
    
    lighting.ClockTime = 2 -- 深夜の雰囲気
end

-- 2. 「夜間視力」環境設定（フルブライトではない自然な明るさ）
local function ApplyNightVision()
    lighting.Brightness = 1.2
    lighting.GlobalShadows = false -- 影による真っ暗な死角を消す
    
    -- 環境光を「濃いグレー」にして、夜のしっとり感を出しつつ視認性を確保
    local nightVisionColor = Color3.fromRGB(75, 75, 85)
    lighting.Ambient = nightVisionColor
    lighting.OutdoorAmbient = nightVisionColor
    
    -- 露出を少しだけプラスにして、モニターで見やすく
    lighting.ExposureCompensation = 0.8
end

-- 3. オブジェクトの質感制御
local function ForceEnvironment()
    ApplyNightVision()

    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if not obj:IsDescendantOf(localPlayer.Character or game.Workspace.CurrentCamera) and not obj:IsA("Terrain") then
            pcall(function()
                if isTransparent then
                    -- 【Pキー：綺麗な透明感モード】
                    -- 向こう側を透視するのではなく、表面の輝きを重視した質感
                    obj.Color = Color3.fromRGB(120, 120, 140)
                    obj.Material = Enum.Material.Glass -- ガラス素材で光を反射させる
                    obj.Transparency = 0.4 -- ほどよい透明感
                    obj.Reflectance = 0.6 -- 空の光を反射してキラキラさせる
                else
                    -- 【通常：深みのある漆黒モード】
                    if obj:IsA("BasePart") and obj.Transparency < 0.5 then
                        obj.Color = Color3.new(0, 0, 0)
                        obj.Material = Enum.Material.SmoothPlastic
                        obj.Transparency = 0
                        obj.Reflectance = 0.05 -- わずかな反射で形を出す
                    elseif obj:IsA("Texture") or obj:IsA("Decal") then
                        obj.Transparency = 1
                    end
                end
            end)
        end
    end
end

-- 4. キー入力 (Pキー)
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        pcall(ForceEnvironment)
    end
end)

-- 5. 実行ループ
RunService.Heartbeat:Connect(function()
    pcall(ForceSky)
    pcall(ApplyNightVision)
end)

task.spawn(function()
    print("--- Midnight Vision: High Visibility Edition ---")
    while true do
        pcall(ForceEnvironment)
        task.wait(5)
    end
end)
