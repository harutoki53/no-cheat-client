-- [[ 漆念：真・神威 (透明完全排除 / 空・絶対固定版) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"
local isTransparent = false

-- 1. 空の「絶対支配」：ゲーム側のリセットを物理的に許さない
RunService.RenderStepped:Connect(function()
    local sky = lighting:FindFirstChild("CustomSky") or Instance.new("Sky", lighting)
    sky.Name = "CustomSky"
    -- 毎フレーム強制書き換え
    sky.SkyboxBk = NEW_BK
    sky.SkyboxRt = NEW_RT
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunAngularSize, sky.MoonAngularSize = 0, 0

    -- ライティングのキショい白を根絶
    lighting.Brightness = 0
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    lighting.EnvironmentDiffuseScale = 0
    lighting.EnvironmentSpecularScale = 0
    lighting.FogEnd = 1e8 -- 霧を宇宙の果てまで飛ばす
end)

-- 2. パーツ判定：透明なら消す、不透明なら漆黒
local function ApplyStyle(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    if obj:IsDescendantOf(localPlayer.Character) then return end

    pcall(function()
        -- 初回の透明度を記録
        if not obj:FindFirstChild("T_Save") then
            local v = Instance.new("NumberValue", obj)
            v.Name = "T_Save"
            v.Value = obj.Transparency
        end

        local originalT = obj.T_Save.Value

        if isTransparent then
            -- 【クリスタルモード】透視不可の鏡面
            obj.Transparency = 0.4
            obj.Reflectance = 1.0
            obj.Material = Enum.Material.Glass
            obj.Color = Color3.fromRGB(130, 130, 200)
        else
            -- 【漆黒モード】
            if originalT > 0 then
                -- ★透明度があるものは「表示しない」
                obj.Transparency = 1
            else
                -- 不透明な建造物・デコイは「形を保った漆黒」
                obj.Transparency = 0
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false -- 四角い箱に見える原因の影を消す
            end
        end
    end)
end

-- 3. 全体リフレッシュ
local function FullUpdate()
    for _, item in ipairs(game.Workspace:GetDescendants()) do
        ApplyStyle(item)
    end
end

-- Pキーでモード切替
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        FullUpdate()
    end
end)

-- 監視維持
game.Workspace.DescendantAdded:Connect(ApplyStyle)
task.spawn(function()
    while true do
        FullUpdate()
        task.wait(1)
    end
end)

FullUpdate()
print("--- Final Authority: Darkness & Custom Sky Loaded ---")
