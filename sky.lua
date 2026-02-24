-- [[ 漆念：絶対支配・最終プロトコル (超高速強制ロック版) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"
local isTransparent = false

-- 1. 空と環境を物理的にロック（秒間60回上書き）
RunService.Heartbeat:Connect(function()
    -- 警告が出るCloudsは無視
    local sky = lighting:FindFirstChild("CustomSky") or Instance.new("Sky", lighting)
    sky.Name = "CustomSky"
    if sky.SkyboxBk ~= NEW_BK then
        sky.SkyboxFt = "rbxassetid://72529916859362"
        sky.SkyboxBk = NEW_BK
        sky.SkyboxRt = NEW_RT
        sky.SkyboxLf = "rbxassetid://116760075528148"
        sky.SkyboxUp = "rbxassetid://119892967613407"
        sky.SkyboxDn = "rbxassetid://123559461938777"
        sky.SunAngularSize, sky.MoonAngularSize = 0, 0
    end

    -- ライティングの強制固定
    lighting.ClockTime = 2
    lighting.Brightness = 0 -- 0にすることでゲーム側の「白さ」を消します
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    lighting.GlobalShadows = false
    lighting.FogEnd = 1e6
end)

-- 2. 全パーツの属性を「力」で固定する関数
local function ForceApply(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    if obj:IsDescendantOf(localPlayer.Character) then return end

    pcall(function()
        if isTransparent then
            -- 【透明：反射クリスタル】
            -- 透明度を下げ、反射を最大にすることで「透視」を遮断
            obj.Transparency = 0.35 
            obj.Reflectance = 1.0 
            obj.Material = Enum.Material.Glass
            obj.Color = Color3.fromRGB(150, 150, 255)
        else
            -- 【漆黒：完全塗りつぶし】
            -- 元の透明度を無視し、すべてを「不透明な漆黒」にする
            obj.Transparency = 0
            obj.Reflectance = 0
            obj.Material = Enum.Material.SmoothPlastic
            obj.Color = Color3.new(0, 0, 0)
        end
    end)
end

-- 3. 監視と高速ループ
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        print("Mode Switched: " .. (isTransparent and "Crystal" or "Blackout"))
    end
end)

-- 毎フレーム全パーツを強制スキャン（これで戻らなくなります）
RunService.Heartbeat:Connect(function()
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        ForceApply(obj)
    end
end)

-- 新規パーツも即座に支配
game.Workspace.DescendantAdded:Connect(ForceApply)

print("--- Zero Protocol Activated: Absolute Darkness ---")
