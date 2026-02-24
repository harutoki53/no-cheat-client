-- [[ 漆念：真・完結プロトコル ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

local isTransparent = false

-- 1. 空の「全削除 ＆ 再構築」プロトコル
local function SetupSky()
    for _, obj in ipairs(lighting:GetChildren()) do
        if obj:IsA("Sky") then obj:Destroy() end
    end

    local sky = Instance.new("Sky", lighting)
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://74808508289471"
    sky.SkyboxRt = "rbxassetid://103546862048950"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunTextureId = ""
end

-- ライティングを「見える暗さ」に固定
RunService.RenderStepped:Connect(function()
    if not lighting:FindFirstChildOfClass("Sky") then SetupSky() end
    
    lighting.ClockTime = 0 
    lighting.Brightness = 0.5
    lighting.OutdoorAmbient = Color3.fromRGB(25, 25, 30) -- 視認性を守る紺色
    lighting.Ambient = Color3.fromRGB(0, 0, 0)
    lighting.EnvironmentDiffuseScale = 0.3
    lighting.FogEnd = 1e6
end)

-- 2. パーツ判定：透明なら消す、不透明なら漆黒シルエット
local function ApplyStyle(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    if obj:IsDescendantOf(localPlayer.Character) then return end

    pcall(function()
        -- 初回の透明度を記録
        if not obj:FindFirstChild("OrigT") then
            local v = Instance.new("NumberValue", obj)
            v.Name = "OrigT"
            v.Value = obj.Transparency
        end

        if isTransparent then
            -- 【Pキー：クリスタル】
            obj.Transparency = 0.4
            obj.Reflectance = 0.8
            obj.Material = Enum.Material.Glass
            obj.Color = Color3.fromRGB(150, 150, 255)
        else
            -- 【通常：漆黒モード】
            if obj.OrigT.Value > 0 then
                -- ★透明度が少しでもあるものは「表示しない」
                obj.Transparency = 1
            else
                -- 不透明な建造物やデコイ
                obj.Transparency = 0
                obj.Color = Color3.fromRGB(15, 15, 15) -- 以前成功した質感
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
                
                -- 四角い箱に見える原因のテクスチャを消す
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
        task.wait(2)
    end
end)

SetupSky()
Refresh()
print("--- Final Authority: System Restored & Optimized ---")
