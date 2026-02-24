-- [[ 漆念：軽量化・透明度保護・クリア夜景モデル ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

-- 空ID
local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"
local isTransparent = false

-- 1. 環境設定（霧を消して空を出す）
local function SetupLighting()
    lighting.ClockTime = 2
    lighting.Brightness = 2
    lighting.GlobalShadows = false -- 影を消すと暗い場所がなくなって見やすくなります
    lighting.FogEnd = 1e5 -- 霧を実質削除
    
    -- 物の形が見える程度の暗い紺色
    local ambient = Color3.fromRGB(60, 60, 75)
    lighting.Ambient = ambient
    lighting.OutdoorAmbient = ambient
    lighting.ExposureCompensation = 1.0
end

-- 2. パーツ処理（透明なものは触らない）
local function ProcessPart(obj)
    if not obj:IsA("BasePart") then return end
    if obj:IsDescendantOf(localPlayer.Character or game.Workspace.CurrentCamera) then return end
    if obj:IsA("Terrain") then return end

    pcall(function()
        if isTransparent then
            -- 【Pキー：綺麗な透明質感】
            obj.Color = Color3.fromRGB(120, 120, 150)
            obj.Material = Enum.Material.Glass
            obj.Transparency = 0.4
            obj.Reflectance = 0.5
        else
            -- 【通常：不透明なものだけ黒くする】
            -- 透明度が0.05以下の「ハッキリした壁や床」だけを対象にする
            if obj.Transparency < 0.05 then
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.SmoothPlastic
                obj.Transparency = 0
                obj.Reflectance = 0.05 -- わずかな反射で形を見せる
            end
        end
    end)
end

-- 3. ラグ対策：一斉スキャンではなく、個別に処理
local function InitialScan()
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        ProcessPart(obj)
    end
end

-- 新しく生成されたパーツも自動で処理（負荷が非常に低い）
game.Workspace.DescendantAdded:Connect(ProcessPart)

-- 4. 空の維持
local function ForceSky()
    local sky = lighting:FindFirstChild("CustomSky") or Instance.new("Sky", lighting)
    sky.Name = "CustomSky"
    if sky.SkyboxBk ~= NEW_BK then
        sky.SkyboxFt = "rbxassetid://72529916859362"
        sky.SkyboxBk = NEW_BK
        sky.SkyboxRt = NEW_RT
        sky.SkyboxLf = "rbxassetid://116760075528148"
        sky.SkyboxUp = "rbxassetid://119892967613407"
        sky.SkyboxDn = "rbxassetid://123559461938777"
        sky.SunAngularSize = 0
    end
    -- 邪魔な大気エフェクトを削除
    local atm = lighting:FindFirstChildOfClass("Atmosphere")
    if atm then atm:Destroy() end
end

-- 5. 実行
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        InitialScan()
    end
end)

RunService.Heartbeat:Connect(ForceSky)
SetupLighting()
InitialScan()

print("--- Optimization System Loaded: Anti-Lag & Clear View ---")
