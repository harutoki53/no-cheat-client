-- [[ 漆念：成功コードベース・最終暗度調整版 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")

-- 実行ログ
print("SKY SCRIPT: FINAL ADJUSTMENT ACTIVE!")

local function ApplyFinalAdjustment()
    -- 1. 古い空を掃除
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

    -- ID指定
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://111173485460565"
    sky.SkyboxRt = "rbxassetid://88926366882961"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunTextureId = ""
    sky.SunAngularSize = 0

    -- 2. ライティング調整（スクショを参考に「もう少し暗く」）
    lighting.ClockTime = 20 -- 16時から20時に変更（夜の帳が下りる時間）
    lighting.Brightness = 0.8 -- 1.5から0.8へ下げて重厚感を出す
    lighting.OutdoorAmbient = Color3.fromRGB(40, 40, 45) -- 少し暗めのグレー
    lighting.Ambient = Color3.fromRGB(15, 10, 13) -- スクショの数値を参考に設定
    lighting.ExposureCompensation = 0.3 -- 露出を抑えて「黒さ」を強調
    lighting.FogEnd = 100000

    -- 3. 建造物の黒化
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(game.Players.LocalPlayer.Character) then
            pcall(function()
                if v.Transparency < 0.5 then
                    v.Color = Color3.fromRGB(10, 10, 12) -- 15よりさらに深い黒
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0.02
                end
            end)
        elseif v:IsA("Texture") or v:IsA("Decal") then
            v.Transparency = 1
        end
    end
end

-- 3秒おきのループ監視
task.spawn(function()
    while true do
        pcall(ApplyFinalAdjustment)
        lighting.ClockTime = 20
        task.wait(3)
    end
end)

print("SKY SCRIPT: LatestSky active!")
