-- [[ 漆念：成功コードベース・視認性アップデート版 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")

local function ApplyImprovedSuccessCode()
    -- 1. 既存のSkyオブジェクトをクリア（成功手順を維持）
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Sky") then
            obj:Destroy()
        end
    end

    local sky = Instance.new("Sky")
    sky.Parent = lighting

    -- 指定のアセットID（空の絵をしっかり見せる）
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://89515271903361"
    sky.SkyboxRt = "rbxassetid://83741654156826"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunTextureId = ""
    sky.SunAngularSize = 0

    -- 2. ライティングの微調整（暗すぎ問題を解決）
    lighting.ClockTime = 18 -- 【変更】深夜0時から夕方18時に。これで空が少し明るくなる
    lighting.Brightness = 1.0 -- 【変更】0.5から1.0へ。全体の視認性を確保
    lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 55) -- 【変更】建物の輪郭が見える程度の明るさ
    lighting.Ambient = Color3.fromRGB(20, 20, 20) -- 【変更】真っ暗闇を回避
    lighting.ExposureCompensation = 0.5 -- 露出を少し上げて絵を見えやすくする

    -- 3. 建造物を一括で黒に変更
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if not v:IsDescendantOf(game.Players.LocalPlayer.Character) then
                v.Color = Color3.fromRGB(20, 20, 20) -- 【変更】15から20へ。少しだけ明るい黒
                v.Reflectance = 0.03 -- わずかな反射で形を出す
            end
        end
    end
end

-- 無限ループで死守
task.spawn(function()
    print("--- Visuals Improved & System Online ---")
    while true do
        pcall(ApplyImprovedSuccessCode)
        task.wait(10) -- 負荷を考えて10秒おきに再適用
    end
end)
