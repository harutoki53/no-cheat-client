-- [[ 漆念：最終確定版 - エラー修正・全マップ対応・デザイン黒化 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local runService = game:GetService("RunService")
-- game.Players を直接取得することでエラーを回避
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

print("SKY SCRIPT: FINAL CORRECTED VERSION STARTING!")

-- デザイン性の高い黒を適用する関数
local function ApplyDesignBlack(v)
    -- キャラクターの判定をより確実に修正
    if v:IsA("BasePart") then
        local isChar = false
        if localPlayer and localPlayer.Character then
            if v:IsDescendantOf(localPlayer.Character) then
                isChar = true
            end
        end

        if not isChar then
            pcall(function()
                if v.Transparency < 0.5 then
                    v.Color = Color3.fromRGB(12, 12, 15) 
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0.05 -- 反射で単調さを回避
                end
            end)
        end
    elseif v:IsA("Texture") or v:IsA("Decal") then
        v.Transparency = 1
    end
end

local function ApplyFinalVisuals()
    -- 1. ライティング設定（空を鮮明にし、地上を締める）
    lighting.ClockTime = 14.5
    lighting.Brightness = 2.0
    lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 35)
    lighting.Ambient = Color3.fromRGB(10, 10, 10)
    lighting.ExposureCompensation = 0.6

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

    -- 3. 全パーツをスキャン（既存のマップ用）
    for _, v in pairs(game.Workspace:GetDescendants()) do
        ApplyDesignBlack(v)
    end
end

-- 【重要】新しく読み込まれたマップパーツも即座に黒くする
game.Workspace.DescendantAdded:Connect(ApplyDesignBlack)

-- 1秒おきのループで設定を死守
task.spawn(function()
    while true do
        pcall(ApplyFinalVisuals)
        task.wait(1)
    end
end)

print("SKY SCRIPT: Total Blackout Active (Error-Free)!")
