-- [[ 漆念：最終完全版 - 成功コードベース・ID 8892... 固定型 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- あなたが指定した最新のIDセット
local CONFIG = {
    FT = "rbxassetid://72529916859362",
    BK = "rbxassetid://88926366882961", -- 指定された新しいID
    RT = "rbxassetid://103546862048950",
    LF = "rbxassetid://116760075528148",
    UP = "rbxassetid://119892967613407",
    DN = "rbxassetid://123559461938777"
}

-- 1. 空の強制適用（成功した書き方をループ用に最適化）
local function ForceSky()
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = lighting
    end

    -- IDの流し込み（現在のIDと違う場合のみ上書きして負荷を軽減）
    if sky.SkyboxBk ~= CONFIG.BK then
        sky.SkyboxFt = CONFIG.FT
        sky.SkyboxBk = CONFIG.BK
        sky.SkyboxRt = CONFIG.RT
        sky.SkyboxLf = CONFIG.LF
        sky.SkyboxUp = CONFIG.UP
        sky.SkyboxDn = CONFIG.DN
        sky.SunTextureId = ""
        sky.SunAngularSize = 0
    end
    
    lighting.FogEnd = 100000
end

-- 2. 地形の黒化 ＆ 視認性維持（「ちょっと明るい」理想の設定）
local function ForceEnvironment()
    -- ライティング設定：黒さを引き締めつつ、地形を見せる
    lighting.Brightness = 4
    lighting.ClockTime = 14
    lighting.ExposureCompensation = 0.1 
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)

    -- 地形の漆黒化（的を消し、エッジを光らせる）
    for _, obj in pairs(game.Workspace:GetChildren()) do
        if obj.Name ~= "Terrain" and not game.Players:GetPlayerFromCharacter(obj) then
            pcall(function()
                for _, part in pairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        -- 地形の黒塗り
                        if part.Transparency < 0.1 then
                            part.Color = Color3.new(0, 0, 0)
                            part.Material = Enum.Material.Plastic
                            part.Reflectance = 0.05 -- 反射で地形の形を見せる
                        end
                    elseif part:IsA("Texture") or part:IsA("Decal") then
                        -- 的や装飾を透明にする
                        part.Transparency = 1
                    elseif part:IsA("Atmosphere") or part:IsA("Clouds") then
                        part:Destroy()
                    end
                end
            end)
        end
    end
end

-- 3. 実行：空は超高速監視、地形は定期スキャン
-- 空の監視（Heartbeat：毎フレームチェック）
RunService.Heartbeat:Connect(function()
    pcall(ForceSky)
end)

-- 地形の監視（テレポートや部屋の読み込み対策：2秒おき）
task.spawn(function()
    while true do
        pcall(ForceEnvironment)
        task.wait(2)
    end
end)

print("--- Ultimate Version (8892): System Online ---")
