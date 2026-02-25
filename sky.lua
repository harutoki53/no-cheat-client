-- [[ 漆念：エラー修正・視認性維持・完全版 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")

-- 1. 空の作成（一度だけ実行し、その後は監視のみ）
local function CreateSky()
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
    sky.SunTextureId = "" -- 正しくSkyに対して設定
    sky.SunAngularSize = 0
end

-- 2. ライティングと建造物の調整（黒くしすぎない）
local function ApplyVisuals()
    -- ライティング固定（エラーの原因となる不要な命令を削除）
    lighting.ClockTime = 0 
    lighting.Brightness = 0.5 
    lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 20) 
    lighting.Ambient = Color3.fromRGB(5, 5, 5)

    -- 建造物の塗りつぶし（負荷対策：一回だけ実行するか、長い間隔で回す）
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(game.Players.LocalPlayer.Character) then
            pcall(function()
                if v.Transparency < 0.5 then
                    v.Color = Color3.fromRGB(15, 15, 15)
                    v.Reflectance = 0.05
                end
            end)
        elseif v:IsA("Texture") or v:IsA("Decal") then
            v.Transparency = 1
        end
    end
end

-- 3. 実行とループ
CreateSky()
ApplyVisuals()

-- 監視ループ（空が消された時だけ再生成するようにして負荷を激減させる）
task.spawn(function()
    print("--- System Fixed & Online ---")
    while true do
        if not lighting:FindFirstChildOfClass("Sky") then
            pcall(CreateSky)
        end
        -- ライティングの強制維持
        lighting.ClockTime = 0
        task.wait(5)
    end
end)
