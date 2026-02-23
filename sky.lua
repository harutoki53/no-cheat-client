-- [[ 漆念：真・完全版（空優先・シンプル統合モデル） ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- 1. 空の設定（あなたが行けた書き方をベースに固定）
local function ApplySky()
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky", lighting)
    end
    
    -- IDの適用（確実に上書き）
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://74808508289471"
    sky.SkyboxRt = "rbxassetid://103546862048950"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunTextureId = "" 
end

-- 2. ライティングと地形の黒化（視認性重視）
local function ApplyWorldEffect()
    -- 霧を消して視界をクリアにする
    lighting.FogEnd = 100000
    lighting.Brightness = 5
    lighting.ClockTime = 14
    lighting.ExposureCompensation = 0.5
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)

    -- 全オブジェクトを黒く、かつ角を光らせる
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if obj:IsA("BasePart") then
                -- もともと透明な塊は無視
                if obj.Transparency < 0.1 then
                    obj.Color = Color3.new(0, 0, 0)
                    obj.Material = Enum.Material.Plastic
                    obj.Reflectance = 0.04 -- わずかな反射が地形を見やすくする
                    obj.Transparency = 0
                end
            elseif obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
                -- 的のマークや装飾を透明にする
                obj.Transparency = 1
            elseif obj:IsA("Atmosphere") or obj:IsA("Clouds") then
                obj:Destroy()
            end
        end
    end
end

-- 3. 実行：空は最速で、地形は1秒おきにチェック
RunService.RenderStepped:Connect(pcall(ApplySky))

task.spawn(function()
    while true do
        pcall(ApplyWorldEffect)
        task.wait(1)
    end
end)

print("Skybox changed and World Blacked out!")
