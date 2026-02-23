-- [[ 漆念：究極完全版（地形視認性MAX ＆ 空強制描画） ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

-- 最新のIDセット
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

-- 1. 空の「絶対領域」確保（描画順序とモヤの徹底破壊）
local function ForceEnforceEnvironment()
    -- 霧、大気、雲、ポストエフェクト（画面の色味を変えるもの）を全削除
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("PostEffect") or obj:IsA("ColorCorrectionEffect") then
            obj:Destroy()
        end
    end

    -- Skyオブジェクトの生成・維持
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
    if sky.SkyboxFt ~= config.Ids.Ft then
        sky.SkyboxFt = config.Ids.Ft
        sky.SkyboxBk = config.Ids.Bk
        sky.SkyboxRt = config.Ids.Rt
        sky.SkyboxLf = config.Ids.Lf
        sky.SkyboxUp = config.Ids.Up
        sky.SkyboxDn = config.Ids.Dn
    end

    -- ライティング：地形把握のための「エッジ強調」設定
    lighting.Brightness = 8               -- 輝度を限界まで上げ、黒パーツの角を光らせる
    lighting.ClockTime = 14
    lighting.ExposureCompensation = 0.2   -- 全体を絞って、反射部分だけを浮き立たせる
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    lighting.FogEnd = 1e9                 -- 霧を宇宙の果てまで飛ばす
    lighting.EnvironmentDiffuseScale = 1  -- 空の色を地形に反射させる
    lighting.EnvironmentSpecularScale = 1
end

-- 2. 漆黒化（的、巨大な板、全パーツを制圧）
local function ApplyTotalBlackout()
    for _, obj in pairs(workspace:GetDescendants()) do
        if not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            -- パーツの黒化とエッジ出し
            if obj:IsA("BasePart") then
                -- 透明な判定用パーツを無視（塊対策）
                if obj.Transparency < 0.1 then
                    obj.Color = Color3.new(0.01, 0.01, 0.01)
                    obj.Material = Enum.Material.Plastic
                    obj.Reflectance = 0.05 -- 空の光を角で反射させて形を見せる
                    obj.Transparency = 0
                end
                
                -- 巨大すぎるパーツ（偽物の空など）を強制非表示
                if obj.Size.Magnitude > 1500 then
                    obj.Transparency = 1
                end
            -- デカール、テクスチャ、特殊メッシュを消去（的のマークもここ）
            elseif obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
                obj.Transparency = 1
            -- 光源とエフェクトを無効化
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Light") then
                obj.Enabled = false
            end
        end
    end
end

-- 3. 最速実行ループ（Heartbeatでゲーム側の上書きを許さない）
RunService.Heartbeat:Connect(function()
    pcall(ForceEnforceEnvironment)
end)

task.spawn(function()
    while true do
        pcall(ApplyTotalBlackout)
        task.wait(1)
    end
end)

print("--- Ultimate Suppression System Activated ---")
