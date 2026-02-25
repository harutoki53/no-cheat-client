-- [[ 漆念：エラー回避・成功コードベース・視認性維持 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")

-- 1. 空の作成（エラーが出ないように「Sky」に対して命令する）
local function CreateSky()
    -- 既存の空を掃除
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Sky") then obj:Destroy() end
    end

    local sky = Instance.new("Sky")
    sky.Parent = lighting

    -- あなたの指定IDを適用
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://89515271903361"
    sky.SkyboxRt = "rbxassetid://83741654156826"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    
    -- 【修正】SunTextureIdは必ずSkyに対して設定する
    sky.SunTextureId = "" 
    sky.SunAngularSize = 0
    sky.MoonAngularSize = 0
end

-- 2. 環境設定（黒くしすぎない絶妙なライン）
local function ApplyEnvironment()
    -- ライティング調整
    lighting.ClockTime = 0 
    lighting.Brightness = 0.5 -- ほんのり明るさを残す
    lighting.OutdoorAmbient = Color3.fromRGB(25, 25, 25) -- 影を少し明るくして形を見せる
    lighting.Ambient = Color3.fromRGB(10, 10, 10)
    lighting.ExposureCompensation = 0 -- 露出を下げすぎない
    lighting.FogEnd = 100000

    -- 不要なエフェクト（Clouds等）を消す（存在チェック付きで警告回避）
    local clouds = lighting:FindFirstChildOfClass("Clouds")
    if clouds then clouds:Destroy() end

    -- 建造物を「質感の残る黒」に
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(game.Players.LocalPlayer.Character) then
            pcall(function()
                if v.Transparency < 0.5 then
                    -- 真っ黒(0,0,0)の一歩手前、15,15,15のグレー黒
                    v.Color = Color3.fromRGB(15, 15, 15) 
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0.05 -- 空を少し反射させてエッジを見せる
                end
            end)
        elseif v:IsA("Texture") or v:IsA("Decal") then
            v.Transparency = 1
        end
    end
end

-- 3. 実行と死守ループ
CreateSky()
ApplyEnvironment()

-- 空が消されたり、時間が勝手に変えられたりしないよう監視
task.spawn(function()
    print("--- System Fixed: Visuals Online ---")
    while true do
        if not lighting:FindFirstChildOfClass("Sky") then
            pcall(CreateSky)
        end
        lighting.ClockTime = 0 -- 深夜固定
        task.wait(10) -- 5〜10秒おきで十分安定する
    end
end)
