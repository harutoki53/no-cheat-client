-- [[ 漆念：真プロトコル (透明排除・人影シルエット版) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"
local isTransparent = false

-- 1. 空の「超」強制固定 (ゲーム側のCloudsに負けない)
RunService.RenderStepped:Connect(function()
    local sky = lighting:FindFirstChild("CustomSky") or Instance.new("Sky", lighting)
    sky.Name = "CustomSky"
    sky.SkyboxBk = NEW_BK
    sky.SkyboxRt = NEW_RT
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.CelestialBodiesShown = false

    -- ライティングの白さを物理的に殺す
    lighting.Brightness = 0
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    lighting.EnvironmentDiffuseScale = 0
    lighting.EnvironmentSpecularScale = 0
    lighting.FogEnd = 1e6
end)

-- 2. パーツ判定 (透明なら消し、不透明なら黒く、人型は影に)
local function ApplyStyle(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    if obj:IsDescendantOf(localPlayer.Character) then return end

    pcall(function()
        -- 最初の状態をタグで記録
        if not obj:FindFirstChild("OrigT") then
            local val = Instance.new("NumberValue", obj)
            val.Name = "OrigT"
            val.Value = obj.Transparency
        end

        local originT = obj.OrigT.Value

        if isTransparent then
            -- 【透明（クリスタル）モード】
            obj.Transparency = 0.4
            obj.Reflectance = 1.0 -- 透視防止
            obj.Material = Enum.Material.Glass
            obj.Color = Color3.fromRGB(120, 120, 180)
        else
            -- 【黒（漆黒）モード】
            if originT > 0 then
                -- ★透明度が少しでもあるものは「消去」
                obj.Transparency = 1
            else
                -- 不透明な建造物やデコイ
                obj.Color = Color3.new(0, 0, 0)
                obj.Transparency = 0
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                -- 四角い塊に見える原因の「境界線」を消すためにCastShadowをオフにする
                obj.CastShadow = false
            end
        end
    end)
end

-- 3. システム制御
local function RefreshAll()
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        ApplyStyle(obj)
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        RefreshAll()
    end
end)

-- 常に監視
game.Workspace.DescendantAdded:Connect(ApplyStyle)
task.spawn(function()
    while true do
        RefreshAll()
        task.wait(1.5)
    end
end)

RefreshAll()
print("--- Final Protocol: Pure Black & Clear Sky Loaded ---")
