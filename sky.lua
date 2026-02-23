-- [[ 漆念：最終調整版（ID更新 ＆ 地形視認性特化） ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- 指定された最新のIDセット
local config = {
    Ids = {
        Ft = "rbxassetid://72529916859362",
        Bk = "rbxassetid://74808508289471",
        Rt = "rbxassetid://103546862048950",
        Lf = "rbxassetid://116760075528148",
        Up = "rbxassetid://119892967613407",
        Dn = "rbxassetid://123559461938777"
    }
}

-- 1. 環境の完全固定（青白いモヤを根絶）
RunService.RenderStepped:Connect(function()
    -- Atmosphere（大気）や雲があると白っぽくなるので、見つけ次第消去
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("PostEffect") then
            obj:Destroy()
        end
    end

    -- 空の強制上書き
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
    if sky.SkyboxFt ~= config.Ids.Ft then
        sky.SkyboxFt = config.Ids.Ft
        sky.SkyboxBk = config.Ids.Bk
        sky.SkyboxRt = config.Ids.Rt
        sky.SkyboxLf = config.Ids.Lf
        sky.SkyboxUp = config.Ids.Up
        sky.SkyboxDn = config.Ids.Dn
    end

    -- 地形を浮かび上がらせるための極限ライティング
    lighting.Brightness = 5               -- 輝度を最大級に。これで「角」が光ります
    lighting.ClockTime = 14
    lighting.ExposureCompensation = 0.4   -- 全体をギュッと暗くします
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    lighting.FogEnd = 1e6                 -- 霧を消滅させる
end)

-- 2. 漆黒化 ＆ 地形把握処理
local function ApplyBlackContrast()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        -- 自分のキャラ以外が対象
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            -- 透明な塊（判定パーツ）は無視して、実体のある壁や床だけ黒くする
            if obj.Transparency < 0.1 then
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.Plastic -- 反射を受けやすいプラスチック
                obj.Reflectance = 0.03 -- このわずかな反射が、高いBrightnessでエッジを光らせる
                obj.Transparency = 0
            end
        -- 的のマーク、デカール、巨大な板の原因となるメッシュを透明化
        elseif obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
            if not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
                obj.Transparency = 1
            end
        -- 光源とエフェクトをカット
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Light") then
            obj.Enabled = false
        end
    end
end

-- 3. 高速ループで状態を維持
task.spawn(function()
    while true do
        pcall(ApplyBlackContrast)
        task.wait(0.5) -- 0.5秒おきに再スキャン
    end
end)

print("--- System Updated with New IDs ---")
