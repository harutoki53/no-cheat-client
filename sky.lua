-- [[ 漆念のコントラスト版：カスタムスカイ ＆ 建物黒化 ]]
local lighting = game:GetService("Lighting")

-- 1. 空の書き換え（高輝度設定）
for _, v in pairs(lighting:GetChildren()) do
    if v:IsA("Sky") then v:Destroy() end
end

local sky = Instance.new("Sky", lighting)
sky.SkyboxFt = "rbxassetid://72529916859362"
sky.SkyboxBk = "rbxassetid://89515271903361"
sky.SkyboxRt = "rbxassetid://83741654156826"
sky.SkyboxLf = "rbxassetid://116760075528148"
sky.SkyboxUp = "rbxassetid://119892967613407"
sky.SkyboxDn = "rbxassetid://123559461938777"

-- 2. ライティングの追い込み設定
lighting.Brightness = 0               -- 太陽の直接光をカット
lighting.ClockTime = 14               -- 昼に設定（空の色を出すため）
lighting.OutdoorAmbient = Color3.new(0, 0, 0) -- 建物に当たる外光をゼロに
lighting.Ambient = Color3.new(0, 0, 0)        -- 環境光をゼロに（これで影が死にます）
lighting.ExposureCompensation = 1.2   -- 露出を上げて、空の画像だけを強制発光させる
lighting.FogEnd = 1e6

-- 3. 建造物を完全に漆黒へ
for _, obj in pairs(game.Workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        if not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            obj.Color = Color3.new(0, 0, 0) -- 漆黒に戻す
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = true -- 影を落としてより暗く
        end
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        obj.Transparency = 1
    elseif obj:IsA("Light") then
        obj.Enabled = false -- 街灯などもすべてカット
    end
end

print("--- Deep Dark Contrast Loaded! ---")
