-- [[ 漆念：絶対支配・零式 (光消滅プロトコル) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"
local isTransparent = false

-- 1. 世界から「光」を奪う（白さを消す）
RunService.RenderStepped:Connect(function()
    -- 空の強制固定
    local sky = lighting:FindFirstChild("CustomSky") or Instance.new("Sky", lighting)
    sky.Name = "CustomSky"
    sky.SkyboxBk = NEW_BK
    sky.SkyboxRt = NEW_RT
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    
    -- ライティングを全破壊して真っ黒にする
    lighting.Brightness = 0
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.EnvironmentDiffuseScale = 0
    lighting.EnvironmentSpecularScale = 0
    lighting.GlobalShadows = false
    lighting.ClockTime = 2
end)

-- 2. 全てのモノを「絶対」に塗り替える
local function AbsoluteApply(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    -- 自分だけは見えるように除外
    if obj:IsDescendantOf(localPlayer.Character) then return end

    pcall(function()
        if isTransparent then
            -- 【透明：超反射クリスタル】
            -- Reflectanceを爆上げして「鏡」にすることで透視を100%防ぐ
            obj.Transparency = 0.5
            obj.Reflectance = 10 -- 鏡面反射を極限まで強化
            obj.Material = Enum.Material.Glass
            obj.Color = Color3.fromRGB(100, 100, 150)
        else
            -- 【黒：絶対漆黒】
            -- 全ての建造物、デコイ、窓を例外なく不透明な黒へ
            obj.Transparency = 0
            obj.Reflectance = 0
            obj.Material = Enum.Material.SmoothPlastic
            obj.Color = Color3.new(0, 0, 0)
        end
    end)
end

-- 3. 秒間ループで「戻る」のを阻止
task.spawn(function()
    while true do
        for _, obj in ipairs(game.Workspace:GetDescendants()) do
            AbsoluteApply(obj)
        end
        task.wait(0.5) -- 0.5秒ごとに全スキャンして塗り直す
    end
end)

-- Pキーで切り替え
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        for _, obj in ipairs(game.Workspace:GetDescendants()) do
            AbsoluteApply(obj)
        end
    end
end)

game.Workspace.DescendantAdded:Connect(AbsoluteApply)
print("--- Zero Protocol: Eternal Darkness Loaded ---")
