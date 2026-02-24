-- [[ 漆念：最終完全版 (夜の雰囲気維持・夜間視力Ver) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

-- 指定の空ID
local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"

local isTransparent = false

-- 1. 空の制御（雲バグ対策＋深夜固定）
local function ForceSky()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Clouds") then
            obj.Enabled = false -- 2枚目の写真の白い塊を消す
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
    
    -- 時間を深夜に固定（夜の雰囲気を守る）
    lighting.ClockTime = 2
end

-- 2. 環境制御（夜間視力：明るすぎない設定）
local function ApplyNightVision()
    lighting.Brightness = 1 -- 眩しくない程度
    lighting.GlobalShadows = false -- これにより「真っ黒で見えない」場所をなくす
    
    -- 白ではなく、深いグレーに設定（これが「夜の雰囲気」の秘訣です）
    local nightTone = Color3.fromRGB(60, 60, 65) 
    lighting.Ambient = nightTone
    lighting.OutdoorAmbient = nightTone
    
    -- 露出を少しだけ上げて、モニターで見やすく調整
    lighting.ExposureCompensation = 0.5
end

-- 3. 地形黒化（Pキーで切り替え）
local function ForceEnvironment()
    ApplyNightVision()

    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if not obj:IsDescendantOf(localPlayer.Character or game.Workspace.CurrentCamera) and not obj:IsA("Terrain") then
            pcall(function()
                if isTransparent then
                    -- 【Pキー：透き通るクリスタル】
                    obj.Color = Color3.fromRGB(60, 60, 80)
                    obj.Material = Enum.Material.ForceField
                    obj.Transparency = 0.4
                    obj.Reflectance = 0
                else
                    -- 【通常：夜に溶け込む黒】
                    if obj:IsA("BasePart") and obj.Transparency < 0.5 then
                        obj.Color = Color3.new(0, 0, 0)
                        obj.Material = Enum.Material.SmoothPlastic
                        obj.Transparency = 0
                        obj.Reflectance = 0.05 -- わずかな光沢で高級感を出す
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
    print("--- Midnight Vision Online: Clear but Dark ---")
    while true do
        pcall(ForceEnvironment)
        task.wait(5)
    end
end)
