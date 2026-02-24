-- [[ 漆念：視認性改善・透明排除プロトコル ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

local isTransparent = false

-- 1. 空の固定 ＆ 視認性のためのライティング調整
RunService.RenderStepped:Connect(function()
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
    
    -- 今の綺麗な星空ID
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://88926366882961"
    sky.SkyboxRt = "rbxassetid://111173485460565"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunTextureId = ""

    -- 【改善】「黒すぎる」を解消するためのライティング
    lighting.ClockTime = 2
    lighting.Brightness = 2 -- 0から2へ引き上げ
    lighting.GlobalShadows = true -- 影を出すことで物の「立体感」を出す
    
    -- 紺色に近い環境光を入れ、闇の中でも形が見えるようにする
    local moonAmbient = Color3.fromRGB(45, 45, 60)
    lighting.Ambient = moonAmbient
    lighting.OutdoorAmbient = moonAmbient
    
    lighting.EnvironmentDiffuseScale = 0.2 -- わずかに光を拡散させる
    lighting.FogEnd = 1e6
end)

-- 2. パーツ判定（透明排除 ＆ シルエット維持）
local function ApplyStyle(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    if obj:IsDescendantOf(localPlayer.Character) then return end

    pcall(function()
        if not obj:FindFirstChild("OrigT") then
            local v = Instance.new("NumberValue", obj)
            v.Name = "OrigT"
            v.Value = obj.Transparency
        end

        if isTransparent then
            -- 【Pキー：クリスタルモード】
            obj.Transparency = 0.4
            obj.Reflectance = 0.8
            obj.Material = Enum.Material.Glass
            obj.Color = Color3.fromRGB(150, 150, 200)
        else
            -- 【漆黒モード】
            if obj.OrigT.Value > 0 then
                -- 透明度が少しでもあるものは「表示しない」
                obj.Transparency = 1
            else
                -- 不透明な建造物やデコイ
                obj.Transparency = 0
                obj.Color = Color3.new(0, 0, 0)
                -- PlasticではなくMetalにすることで、星明かりをエッジで反射させて形を見せる
                obj.Material = Enum.Material.Metal 
                obj.Reflectance = 0.1 -- わずかな反射が視認性を生む
                
                -- デカール（顔や服のテクスチャ）を消して四角い箱化を防ぐ
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("Decal") or child:IsA("Texture") then
                        child.Transparency = 1
                    end
                end
            end
        end
    end)
end

-- 3. 全体制御
local function Refresh()
    for _, item in ipairs(game.Workspace:GetDescendants()) do
        ApplyStyle(item)
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        Refresh()
    end
end)

game.Workspace.DescendantAdded:Connect(ApplyStyle)
task.spawn(function()
    while true do
        Refresh()
        task.wait(1.5)
    end
end)

Refresh()
print("--- Midnight Polish: Visible Shadows & Clean Sky ---")
