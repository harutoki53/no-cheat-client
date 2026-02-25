-- [[ 漆念：視認性改善・1秒高速ループ・最終調整版 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")

-- ログ
print("SKY SCRIPT: 1-SECOND HIGH-SPEED LOOP STARTING!")

local function ApplyFinalAdjustment()
    -- 1. 競合する空・エフェクトを即座に削除
    for _, obj in pairs(lighting:GetChildren()) do
        if (obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("Clouds")) and obj.Name ~= "LatestSky_Final" then
            obj:Destroy()
        end
    end

    local sky = lighting:FindFirstChild("LatestSky_Final")
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "LatestSky_Final"
        sky.Parent = lighting
    end

    -- 空のID設定
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://111173485460565"
    sky.SkyboxRt = "rbxassetid://88926366882961"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunTextureId = ""
    sky.SunAngularSize = 0

    -- 2. ライティング調整（空を明るく、影を暗く）
    lighting.ClockTime = 14.5 -- 【重要】昼間にすることで空のテクスチャを100%の明るさで表示
    lighting.Brightness = 2.0 -- 全体の光量を上げ、空を鮮明にする
    lighting.OutdoorAmbient = Color3.fromRGB(35, 35, 40) -- 建物にはあまり光を当てない
    lighting.Ambient = Color3.fromRGB(15, 15, 15) -- 室内や影をしっかり暗く保つ
    lighting.ExposureCompensation = 0.6 -- 露出を上げて、空のキャラをはっきり見せる
    lighting.FogEnd = 100000

    -- 3. 建造物の徹底黒化
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(game.Players.LocalPlayer.Character) then
            pcall(function()
                if v.Transparency < 0.5 then
                    -- 建物自体を深い黒にすることで、明るい空とのコントラストを作る
                    v.Color = Color3.fromRGB(12, 12, 15) 
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0.04 -- わずかな反射で「形」だけ分からせる
                end
            end)
        elseif v:IsA("Texture") or v:IsA("Decal") then
            v.Transparency = 1
        end
    end
end

-- 1秒おきの超高速監視ループ
task.spawn(function()
    while true do
        pcall(ApplyFinalAdjustment)
        -- 時間と明るさを秒速で死守
        lighting.ClockTime = 14.5
        lighting.Brightness = 2.0
        task.wait(1) -- 1秒指定
    end
end)

print("SKY SCRIPT: 1-second loop active!")
