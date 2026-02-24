-- [[ 漆念：最終完全版 - 成功コードベース・無限ループ維持 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- あなたがダッシュボードから取得した最新のIDをセット
local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"

-- 1. 空の強制適用（成功した書き方をループ用に最適化）
local function ForceSky()
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = lighting
    end

    -- 現在のIDが指定のものと違う場合のみ上書き（点滅防止と負荷軽減）
    if sky.SkyboxBk ~= NEW_BK or sky.SkyboxRt ~= NEW_RT then
        sky.SkyboxFt = "rbxassetid://72529916859362"
        sky.SkyboxBk = NEW_BK -- 新ID (8892...)
        sky.SkyboxRt = NEW_RT -- 新ID (1111...)
        sky.SkyboxLf = "rbxassetid://116760075528148"
        sky.SkyboxUp = "rbxassetid://119892967613407"
        sky.SkyboxDn = "rbxassetid://123559461938777"
        sky.SunTextureId = ""
        sky.SunAngularSize = 0
    end
    
    lighting.FogEnd = 100000
end

-- 2. 地形の黒化 ＆ 視認性維持（「ちょっと明るい」理想の設定）
local function ForceEnvironment()
    -- ライティング設定：黒さを引き締めつつ、地形の形を見せる
    lighting.Brightness = 4
    lighting.ClockTime = 14
    lighting.ExposureCompensation = 0.1 
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)

    -- 警告(Cloud)対策：存在を確認してから消去
    local cloud = lighting:FindFirstChildOfClass("Clouds")
    if cloud then cloud:Destroy() end
    local atm = lighting:FindFirstChildOfClass("Atmosphere")
    if atm then atm:Destroy() end

    -- マップ内のパーツを黒く塗りつぶす
    for _, obj in pairs(game.Workspace:GetChildren()) do
        if obj.Name ~= "Terrain" and not game.Players:GetPlayerFromCharacter(obj) then
            pcall(function()
                for _, part in pairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if part.Transparency < 0.1 then
                            part.Color = Color3.new(0, 0, 0)
                            part.Material = Enum.Material.Plastic
                            part.Reflectance = 0.05 -- 空の光を反射してエッジを見せる
                        end
                    elseif part:IsA("Texture") or part:IsA("Decal") then
                        -- 「的」などの装飾を消去
                        part.Transparency = 1
                    end
                end
            end)
        end
    end
end

-- 3. 実行：空は超高速監視、地形は定期スキャン
-- 空の監視（Heartbeat：ゲーム側のリセットを許さない速度）
RunService.Heartbeat:Connect(function()
    pcall(ForceSky)
end)

-- 地形の監視（テレポートやマップ読み込み対策：2秒おき）
task.spawn(function()
    print("--- Final System Online: Sky & Blackout Ready ---")
    while true do
        pcall(ForceEnvironment)
        task.wait(2)
    end
end)
