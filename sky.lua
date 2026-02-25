-- [[ 漆念：全マップ・全パーツ・強制黒化コンプリート ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")

-- ログ
print("SKY SCRIPT: TOTAL BLACKOUT RELOADED!")

-- 黒化の核心関数
local function ForceBlackout(v)
    if v:IsA("BasePart") and not v:IsDescendantOf(game.Players.LocalPlayer.Character) then
        pcall(function()
            -- 透明度が低い（目に見える）パーツはすべて対象
            if v.Transparency < 0.8 then
                v.Color = Color3.fromRGB(12, 12, 15) 
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0.04
            end
        end)
    elseif v:IsA("Texture") or v:IsA("Decal") then
        -- テクスチャやポスターはすべて消去
        v.Transparency = 1
    end
end

-- 全体を一括スキャンする関数
local function ScanAndFix()
    -- 1. ライティングの死守
    lighting.ClockTime = 14.5
    lighting.Brightness = 2.0
    lighting.OutdoorAmbient = Color3.fromRGB(35, 35, 40)
    lighting.Ambient = Color3.fromRGB(15, 15, 15)
    
    -- 2. 空の死守
    local sky = lighting:FindFirstChild("LatestSky_Final")
    if not sky then
        for _, obj in pairs(lighting:GetChildren()) do
            if obj:IsA("Sky") then obj:Destroy() end
        end
        sky = Instance.new("Sky")
        sky.Name = "LatestSky_Final"
        sky.Parent = lighting
    end
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://111173485460565"
    sky.SkyboxRt = "rbxassetid://88926366882961"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunAngularSize = 0

    -- 3. 全パーツを強制塗りつぶし
    for _, v in pairs(game.Workspace:GetDescendants()) do
        ForceBlackout(v)
    end
end

-- 監視：新しいパーツが追加されたら即実行
game.Workspace.DescendantAdded:Connect(ForceBlackout)

-- 1秒おきの超高速ループ
task.spawn(function()
    while true do
        pcall(ScanAndFix)
        task.wait(1)
    end
end)
