-- [[ 漆念：成功確定コード・視認性重視ループ ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- 1. 空の作成と固定（成功した手順をそのまま使用）
local function ForceSky()
    -- 既存のSkyをクリアして競合を防ぐ
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Sky") then obj:Destroy() end
    end

    local sky = Instance.new("Sky")
    sky.Parent = lighting
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://89515271903361"
    sky.SkyboxRt = "rbxassetid://83741654156826"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunTextureId = ""
end

-- 2. 黒くしすぎない環境設定
local function ForceBalancedBlack()
    -- ライティング調整
    lighting.ClockTime = 0 
    lighting.Brightness = 0.5 -- 完全に0にせず、わずかに光を残す
    lighting.OutdoorAmbient = Color3.fromRGB(25, 25, 25) -- ほんのり明るいグレーで影を緩和
    lighting.Ambient = Color3.fromRGB(10, 10, 10) -- 全くの無光状態を避ける
    lighting.ExposureCompensation = 0 -- 露出を下げすぎない

    -- 建造物の塗りつぶし
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(game.Players.LocalPlayer.Character) then
            pcall(function()
                -- 透明なパーツ（バリアなど）は無視して、不透明な壁だけを黒くする
                if v.Transparency < 0.5 then
                    -- 真っ黒(0,0,0)ではなく、質感の残るダークグレー
                    v.Color = Color3.fromRGB(15, 15, 15) 
                    
                    -- 反射をわずかに入れることで、空の光を受けて形が判別しやすくなる
                    v.Reflectance = 0.05 
                end
            end)
        elseif v:IsA("Texture") or v:IsA("Decal") then
            -- 的などの装飾は透明にする
            v.Transparency = 1
        end
    end
end

-- 3. 死守ループ
-- 空は10秒おきにチェック（安定性重視）
task.spawn(function()
    while true do
        pcall(ForceSky)
        task.wait(10)
    end
end)

-- 地形とライティングは定期的に上書き（負荷を抑えつつ維持）
task.spawn(function()
    print("--- Balanced Blackout System Online ---")
    while true do
        pcall(ForceBalancedBlack)
        task.wait(5)
    end
end)
