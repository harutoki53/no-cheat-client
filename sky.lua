-- [[ 漆念：最終完成版 (空のモヤ完全排除・クッキリ漆黒質感) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

-- 空ID
local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"

local isTransparent = false

-- 1. 空の周りの「モヤ」を徹底排除
local function CleanEnvironment()
    -- 雲（Clouds）を透明にして完全に黙らせる（Destroyしないのでエラーも出ません）
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Clouds") then
            obj.Enabled = false
            obj.Cover = 0
            obj.Density = 0
        end
    end

    -- 視界をグレーにする大気エフェクトを即座に消去
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Atmosphere") or obj:IsA("Sky") then
            if obj.Name ~= "CustomSky" then obj:Destroy() end
        end
    end

    -- 霧を限界まで遠ざけて「クリアな夜」を作る
    lighting.FogEnd = 1000000
    lighting.FogStart = 0
end

-- 2. 自然な夜の明るさ（クッキリ見える設定）
local function ApplyLighting()
    lighting.ClockTime = 2 -- 深夜
    lighting.Brightness = 2 -- パーツの輪郭を出すための輝度
    lighting.GlobalShadows = true -- 影で立体感を出す
    
    -- 「フルブライト」ではなく、夜の雰囲気を壊さない程度の環境光
    lighting.Ambient = Color3.fromRGB(35, 35, 40)
    lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 25)
    
    -- モニター越しでも地形が見えるように露出を調整
    lighting.ExposureCompensation = 1.0
end

-- 3. パーツの質感（漆黒 ＆ 磨かれた透明）
local function ForceEnvironment()
    CleanEnvironment()
    ApplyLighting()

    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if not obj:IsDescendantOf(localPlayer.Character or game.Workspace.CurrentCamera) and not obj:IsA("Terrain") then
            pcall(function()
                if obj:IsA("BasePart") then
                    if isTransparent then
                        -- 【Pキー：綺麗な透明モード】
                        -- 向こう側を透視するのではなく、高級感のあるクリスタル質感
                        obj.Color = Color3.fromRGB(50, 50, 70)
                        obj.Material = Enum.Material.Glass 
                        obj.Transparency = 0.4
                        obj.Reflectance = 0.7 -- 星空を美しく反射させる
                    else
                        -- 【通常：磨き抜かれた漆黒】
                        if obj.Transparency < 0.5 then
                            obj.Color = Color3.new(0, 0, 0)
                            obj.Material = Enum.Material.SmoothPlastic
                            obj.Transparency = 0
                            obj.Reflectance = 0.08 -- わずかな反射でエッジを見せる
                        end
                    end
                elseif obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Transparency = 1
                end
            end)
        end
    end
end

-- 4. 空の絶対死守
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

-- 5. 実行
RunService.Heartbeat:Connect(function()
    pcall(ForceSky)
    pcall(CleanEnvironment)
end)

task.spawn(function()
    print("--- Midnight Crystal System Online: Clouds Removed ---")
    while true do
        pcall(ForceEnvironment)
        task.wait(5)
    end
end)
