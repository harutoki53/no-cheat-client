-- [[ 漆念：最終完全版 (真夜中・Pキー透視・絶対死守) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

-- あなたが用意した最新の空ID
local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"

local isTransparent = false

-- 1. 空と時間の強制固定（深夜の静寂を維持）
local function ForceSky()
    lighting.ClockTime = 2 -- 深夜2時
    lighting.GeographicLatitude = 41.7
    
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)

    if sky.SkyboxBk ~= NEW_BK or sky.SkyboxRt ~= NEW_RT then
        sky.SkyboxFt = "rbxassetid://72529916859362"
        sky.SkyboxBk = NEW_BK
        sky.SkyboxRt = NEW_RT
        sky.SkyboxLf = "rbxassetid://116760075528148"
        sky.SkyboxUp = "rbxassetid://119892967613407"
        sky.SkyboxDn = "rbxassetid://123559461938777"
        sky.SunTextureId = ""
        sky.SunAngularSize = 0
        sky.MoonAngularSize = 0
    end
    lighting.FogEnd = 100000
end

-- 2. 環境 ＆ 全オブジェクトの漆黒化
local function ForceEnvironment()
    lighting.Brightness = 0.2
    lighting.ExposureCompensation = -0.1 
    lighting.Ambient = Color3.fromRGB(10, 10, 10)
    lighting.OutdoorAmbient = Color3.fromRGB(2, 2, 2)

    -- 不要エフェクト排除（警告が出ないように個別にチェック）
    local effects = {"Clouds", "Atmosphere", "Bloom", "SunRays"}
    for _, name in pairs(effects) do
        local e = lighting:FindFirstChildOfClass(name)
        if e then e:Destroy() end
    end

    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if not obj:IsDescendantOf(localPlayer.Character or game.Workspace.CurrentCamera) and not obj:IsA("Terrain") then
            pcall(function()
                if isTransparent then
                    -- 【Pキー：透明クリスタル】
                    if obj:IsA("BasePart") then
                        obj.Color = Color3.fromRGB(30, 30, 45)
                        obj.Material = Enum.Material.ForceField
                        obj.Transparency = 0.4
                        obj.Reflectance = 0.3
                    end
                else
                    -- 【通常：夜に溶け込む黒】
                    if obj:IsA("BasePart") and obj.Transparency < 0.5 then
                        obj.Color = Color3.new(0, 0, 0)
                        obj.Material = Enum.Material.SmoothPlastic
                        obj.Transparency = 0
                        obj.Reflectance = 0.05
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
        print("Transparency Mode:", isTransparent)
        pcall(ForceEnvironment)
    end
end)

-- 4. 実行ループ
RunService.RenderStepped:Connect(function()
    pcall(ForceSky)
end)

task.spawn(function()
    print("--- Midnight Blackout System: Online ---")
    while true do
        pcall(ForceEnvironment)
        task.wait(5)
    end
end)
