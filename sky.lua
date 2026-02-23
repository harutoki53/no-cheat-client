-- [[ 漆念：最終・完全版（多重Sky削除 ＆ 環境完全制圧） ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

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

-- 1. 環境と空の「完全上書き」関数
local function ForceSanitizeEnvironment()
    -- 既存のSky, Atmosphere, Cloudsをすべて消去して「真っさら」にする
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("PostEffect") then
            obj:Destroy()
        end
    end

    -- 新しいSkyを1つだけ作成
    local sky = Instance.new("Sky", lighting)
    sky.SkyboxFt = config.Ids.Ft
    sky.SkyboxBk = config.Ids.Bk
    sky.SkyboxRt = config.Ids.Rt
    sky.SkyboxLf = config.Ids.Lf
    sky.SkyboxUp = config.Ids.Up
    sky.SkyboxDn = config.Ids.Dn
    sky.SunAngularSize = 0 -- 太陽を消す
    sky.MoonAngularSize = 0 -- 月を消す

    -- ライティングを漆黒かつ視認性高く設定
    lighting.Brightness = 6               -- 反射を強めて角を見せる
    lighting.ClockTime = 14
    lighting.ExposureCompensation = -0.2  -- 「黒くない」対策：露出を下げて引き締める
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    lighting.FogEnd = 1e6                 -- 霧を消去
end

-- 2. 全オブジェクトの漆黒化（地形エッジ強調）
local function ApplyBlackout()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if obj:IsA("BasePart") then
                if obj.Transparency < 0.1 then
                    obj.Color = Color3.new(0, 0, 0)
                    obj.Material = Enum.Material.Plastic
                    obj.Reflectance = 0.04 -- わずかな反射で角を浮かび上がらせる
                    obj.Transparency = 0
                end
                -- 巨大な空隠しパーツの排除
                if obj.Size.Magnitude > 1500 then obj.Transparency = 1 end
            elseif obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
                obj.Transparency = 1
            elseif obj:IsA("Light") or obj:IsA("ParticleEmitter") then
                obj.Enabled = false
            end
        end
    end
end

-- 3. 実行（Heartbeatでゲーム側のスクリプトに競り勝つ）
RunService.Heartbeat:Connect(function()
    -- 空が存在しない、または1つより多い場合にリセット
    local skies = 0
    for _, v in pairs(lighting:GetChildren()) do if v:IsA("Sky") then skies = skies + 1 end end
    
    if skies ~= 1 then
        pcall(ForceSanitizeEnvironment)
    end
end)

task.spawn(function()
    while true do
        pcall(ApplyBlackout)
        task.wait(1)
    end
end)

print("--- Ultimate Environment Overwrite System Online ---")
