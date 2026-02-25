-- [[ 漆念：キャッシュ回避・強制リセット版 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")

-- 実行されたことが分かるようにログを出す
print("SKY SCRIPT: STARTING UPDATE...")

local function ApplyFinalForce()
    -- 1. 古いSkyを根こそぎ削除
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("Clouds") then
            obj:Destroy()
        end
    end

    -- 2. 新しいSkyを作成
    local sky = Instance.new("Sky")
    sky.Name = "LatestSky_Final" -- 名前を変えて古いものと区別
    sky.Parent = lighting

    -- 最新のID（ここでIDが正しいか再確認してください）
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://111173485460565" -- 以前の成功IDなら 89515271903361
    sky.SkyboxRt = "rbxassetid://88926366882961"  -- 以前の成功IDなら 83741654156826
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunTextureId = ""
    sky.SunAngularSize = 0

    -- 3. ライティング調整（少し明るく）
    lighting.ClockTime = 16 -- 18時より少し明るい16時に設定
    lighting.Brightness = 1.5
    lighting.OutdoorAmbient = Color3.fromRGB(60, 60, 65)
    lighting.Ambient = Color3.fromRGB(30, 30, 30)
    lighting.ExposureCompensation = 0.8
end

-- 初回実行
pcall(ApplyFinalForce)

-- ループ監視
task.spawn(function()
    while true do
        -- LatestSky_Finalが存在しない、または名前が違う場合のみ再生成
        if not lighting:FindFirstChild("LatestSky_Final") then
            pcall(ApplyFinalForce)
        end
        -- 時間と明るさは常に固定
        lighting.ClockTime = 16
        task.wait(5)
    end
end)

print("SKY SCRIPT: UPDATE COMPLETE!")
