-- [[ 漆念：透明度保護・漆黒質感モデル ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

-- 空ID
local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"

local isTransparent = false

-- 1. 環境クリーンアップ
local function CleanEnvironment()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Clouds") then obj.Enabled = false end
    end
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Atmosphere") then obj:Destroy() end
    end
    lighting.FogEnd = 1000000
end

-- 2. ライティング設定（夜の質感を出しつつ形を見せる）
local function ApplyLighting()
    lighting.ClockTime = 2
    lighting.Brightness = 2.5
    lighting.GlobalShadows = true
    
    -- 真っ黒にせず、わずかに深みのある色を入れることで視認性を確保
    local ambientColor = Color3.fromRGB(40, 40, 50)
    lighting.Ambient = ambientColor
    lighting.OutdoorAmbient = ambientColor
    lighting.ExposureCompensation = 1.0
end

-- 3. パーツの制御（透明なものは除外）
local function ForceEnvironment()
    CleanEnvironment()
    ApplyLighting()

    for _, obj in pairs(game.Workspace:GetDescendants()) do
        -- プレイヤー自身やカメラ、地形、水(Terrain)は除外
        if not obj:IsDescendantOf(localPlayer.Character or game.Workspace.CurrentCamera) and not obj:IsA("Terrain") then
            pcall(function()
                if obj:IsA("BasePart") then
                    if isTransparent then
                        -- 【Pキー：クリスタルモード】
                        -- 透明度を活かしつつ、鏡のような反射を追加
                        obj.Color = Color3.fromRGB(100, 100, 120)
                        obj.Material = Enum.Material.Glass
                        obj.Transparency = 0.5
                        obj.Reflectance = 0.8
                    else
                        -- 【通常モード：賢い漆黒】
                        -- 元々透明なパーツ(Transparencyが0.1以上)は無視する
                        if obj.Transparency < 0.1 then
                            obj.Color = Color3.new(0, 0, 0)
                            obj.Material = Enum.Material.Metal -- 反射を活かして形を見せる
                            obj.Transparency = 0
                            obj.Reflectance = 0.12 -- 星空をわずかに反射させて輪郭を出す
                        end
                    end
                elseif obj:IsA("Texture") or obj:IsA("Decal") then
                    -- 完全に見た目を邪魔するデカールのみ消去
                    obj.Transparency = 1
                end
            end)
        end
    end
end

-- 4. 空の維持
local function ForceSky()
    local sky = lighting:FindFirstChild("CustomSky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "CustomSky"
        sky.Parent = lighting
    end
    if sky.SkyboxBk ~= NEW_BK then
        sky.SkyboxFt = "rbxassetid://72529916859362"
        sky.SkyboxBk = NEW_BK
        sky.SkyboxRt = NEW_RT
        sky.SkyboxLf = "rbxassetid://116760075528148"
        sky.SkyboxUp = "rbxassetid://119892967613407"
        sky.SkyboxDn = "rbxassetid://123559461938777"
        sky.SunAngularSize = 0
    end
end

-- 5. ループ実行
RunService.Heartbeat:Connect(function()
    pcall(ForceSky)
    pcall(CleanEnvironment)
end)

task.spawn(function()
    print("--- Midnight Script Online (Transparency Guard Active) ---")
    while true do
        pcall(ForceEnvironment)
        task.wait(5)
    end
end)
