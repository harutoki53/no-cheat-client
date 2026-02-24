-- [[ 漆念：成功コードベース ＆ ループ維持モデル ]]
local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- 1. 空の変更関数（あなたが成功したコード）
local function ApplySky()
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
    
    -- IDの適用（新IDに固定しています）
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://74808508289471"
    sky.SkyboxRt = "rbxassetid://103546862048950"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunTextureId = ""
end

-- 2. 黒さの調整関数（「ちょっと明るい」をさらに引き締め）
local function ApplyWorldEffect()
    lighting.FogEnd = 100000
    lighting.Brightness = 4
    lighting.ClockTime = 14
    lighting.ExposureCompensation = 0.1 -- ここを下げて「黒さ」を強調
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)

    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if obj.Transparency < 0.1 then
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0.05 -- エッジの光り具合
            end
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            obj.Transparency = 1
        end
    end
end

-- 3. ループ実行（ここが「付け足した」部分）
-- 空の画像が剥がされないか監視（毎フレーム）
RunService.Heartbeat:Connect(function()
    local sky = lighting:FindFirstChildOfClass("Sky")
    -- 空がない、またはIDが違う場合に再適用
    if not sky or sky.SkyboxBk ~= "rbxassetid://74808508289471" then
        pcall(ApplySky)
    end
end)

-- 地形の黒さを維持（2秒おき）
task.spawn(function()
    while true do
        pcall(ApplyWorldEffect)
        task.wait(2)
    end
end)

print("Sky & Blackout Loop Started!")
