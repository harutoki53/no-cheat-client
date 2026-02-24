-- [[ 漆念：視認性重視・黒コントラストモデル ]]
local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- 1. 空の変更（新ID固定）
local function ApplySky()
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://74808508289471"
    sky.SkyboxRt = "rbxassetid://103546862048950"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunTextureId = ""
end

-- 2. 地形の調整（「ちょっと明るい」視認性を確保）
local function ApplyBalancedBlack()
    -- ライティング：影を引き締めつつ、光を反射させる
    lighting.FogEnd = 100000
    lighting.Brightness = 4              -- 輝度を上げて反射を強くする
    lighting.ClockTime = 14              -- 昼間に戻して光を当てる
    lighting.ExposureCompensation = 0.3  -- 露出を少し上げて全体を「見える」明るさに
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.OutdoorAmbient = Color3.new(0.05, 0.05, 0.05) -- わずかに環境光を入れて真っ暗を防ぐ

    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            -- 地形を黒くするが、反射で形を見せる
            if obj.Transparency < 0.1 then
                obj.Color = Color3.new(0.01, 0.01, 0.01) -- 完全な0より、ごく微かにグレー
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0.08 -- 反射をアップ。角や面が空の光を拾って白く見える
            end
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            obj.Transparency = 1
        elseif obj:IsA("Atmosphere") or obj:IsA("Clouds") then
            obj:Destroy()
        end
    end
end

-- 3. 実行と維持
pcall(ApplySky)
pcall(ApplyBalancedBlack)

-- 空と明るさを維持
RunService.Heartbeat:Connect(function()
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky or sky.SkyboxBk ~= "rbxassetid://74808508289471" then
        pcall(ApplySky)
    end
end)

print("Balanced Black System Applied!")
