-- [[ 漆念：修正版（空の強制適用モデル） ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- 1. 空の設定（ID形式の修正と重複生成防止）
local function ApplySky()
    local sky = lighting:FindFirstChild("CustomSky") or lighting:FindFirstChildOfClass("Sky")
    
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "CustomSky"
        sky.Parent = lighting
    end
    
    -- IDの適用（http://www.roblox.com/asset/?id= 形式が最も安定します）
    local prefix = "http://www.roblox.com/asset/?id="
    
    if sky.SkyboxFt ~= prefix .. "72529916859362" then
        sky.SkyboxFt = prefix .. "72529916859362"
        sky.SkyboxBk = prefix .. "74808508289471"
        sky.SkyboxRt = prefix .. "103546862048950"
        sky.SkyboxLf = prefix .. "116760075528148"
        sky.SkyboxUp = prefix .. "119892967613407"
        sky.SkyboxDn = prefix .. "123559461938777"
        sky.SunTextureId = ""
        sky.SunAngularSize = 0 -- 太陽を完全に消す場合に有効
    end
end

-- 2. ライティングと地形の黒化
local function ApplyWorldEffect()
    lighting.FogEnd = 100000
    lighting.Brightness = 5
    lighting.ClockTime = 14
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)

    for _, obj in pairs(workspace:GetDescendants()) do
        -- 自分のキャラ以外を対象にする
        if not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if obj:IsA("BasePart") and obj.Transparency < 0.1 then
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0.04
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 1
            elseif obj:IsA("Atmosphere") or obj:IsA("Clouds") then
                obj.Parent = nil -- Destroyより安全な場合があります
            end
        end
    end
end

-- 3. 実行（ここが重要です）
-- 元のコードの pcall(ApplySky) は「関数の実行結果」を渡してしまっていたため動作していませんでした
RunService.RenderStepped:Connect(function()
    pcall(ApplySky)
end)

task.spawn(function()
    while true do
        pcall(ApplyWorldEffect)
        task.wait(2) -- 負荷軽減のため少し間隔を広げています
    end
end)

print("Skybox fixed and World effect applied!")
