-- [[ 漆念：最終完成版 (視認性クッキリ・黒水晶質感) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

-- 空ID
local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"

local isTransparent = false

-- 1. 空と「霧」の完全排除（クリアな視界の確保）
local function ForceSky()
    -- 警告の原因になるCloudsを完全に無効化
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Clouds") then 
            obj.Enabled = false
            obj.Cover = 0
        end
    end
    
    -- 視界をぼやけさせる大気エフェクトを削除
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Atmosphere") or obj:IsA("FogEnd") then
            obj:Destroy()
        end
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
    
    lighting.ClockTime = 2 -- 深夜
    lighting.FogEnd = 999999 -- 霧を無限遠へ飛ばす
end

-- 2. 環境光の最適化（暗いのに「見える」バランス）
local function ApplyEnvironment()
    -- 前回のグレーすぎる設定を修正。コントラストを強める。
    lighting.Brightness = 2
    lighting.GlobalShadows = true -- 影を有効にして「物の形」をハッキリさせる
    
    -- 環境光を少し落として夜の闇を出し、代わりに「露出」で視認性を稼ぐ
    lighting.Ambient = Color3.fromRGB(20, 20, 25)
    lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 15)
    
    -- モニターで見やすくするための補正
    lighting.ExposureCompensation = 1.2
end

-- 3. パーツの質感（漆黒 ＆ 綺麗な透明感）
local function ForceEnvironment()
    ApplyEnvironment()

    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if not obj:IsDescendantOf(localPlayer.Character or game.Workspace.CurrentCamera) and not obj:IsA("Terrain") then
            pcall(function()
                if obj:IsA("BasePart") then
                    if isTransparent then
                        -- 【Pキー：綺麗な透明モード】
                        -- 透視ではなく、深い色のクリスタルのような質感
                        obj.Color = Color3.fromRGB(40, 40, 60)
                        obj.Material = Enum.Material.Glass 
                        obj.Transparency = 0.4
                        obj.Reflectance = 0.8 -- 鏡のような反射で「綺麗さ」を出す
                    else
                        -- 【通常：磨き抜かれた漆黒モード】
                        if obj.Transparency < 0.5 then
                            obj.Color = Color3.new(0, 0, 0)
                            obj.Material = Enum.Material.SmoothPlastic
                            obj.Transparency = 0
                            obj.Reflectance = 0.1 -- わずかに光を拾うことで高級感と立体感を出す
                        end
                    end
                elseif obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Transparency = 1
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
    pcall(ApplyEnvironment)
end)

task.spawn(function()
    print("--- Midnight Black-Pearl Edition Online ---")
    while true do
        pcall(ForceEnvironment)
        task.wait(5)
    end
end)
