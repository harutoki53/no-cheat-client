-- [[ 漆念：デザイン性維持・全マップ強制黒化コンプリート ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local workspace = game:GetService("Workspace")

print("SKY SCRIPT: DESIGNER BLACKOUT ONLINE!")

-- オブジェクトに「質の高い黒」を適用する関数
local function ApplyDesignBlack(v)
    if v:IsA("BasePart") and not v:IsDescendantOf(game.Players.LocalPlayer.Character) then
        pcall(function()
            -- 透明なものは除外（デザインを壊さないため）
            if v.Transparency < 0.5 then
                -- 単なる(0,0,0)ではなく、深みのある黒
                v.Color = Color3.fromRGB(12, 12, 15) 
                -- 質感を SmoothPlastic に統一して高級感を出す
                v.Material = Enum.Material.SmoothPlastic
                -- 空のキャラの光をうっすら反射させる（ここがデザインの肝）
                v.Reflectance = 0.05 
            end
        end)
    elseif v:IsA("Texture") or v:IsA("Decal") then
        -- 余計なポスターなどは消してデザインをシンプルに
        v.Transparency = 1
    end
end

local function ApplyFinalAdjustment()
    -- 1. 空の死守（キャラを鮮明に映す）
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

    -- 2. ライティング調整（コントラストを強調）
    lighting.ClockTime = 14.5
    lighting.Brightness = 2.0
    lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 35) -- 影を少し深く
    lighting.Ambient = Color3.fromRGB(10, 10, 10)
    lighting.ExposureCompensation = 0.6

    -- 3. 既存の全オブジェクトをスキャン（漏れを無くす）
    for _, v in workspace:GetDescendants() do
        ApplyDesignBlack(v)
    end
end

-- 【重要】新しいパーツが追加された瞬間にデザインを適用
workspace.DescendantAdded:Connect(ApplyDesignBlack)

-- 1秒おきの高速監視
task.spawn(function()
    while true do
        pcall(ApplyFinalAdjustment)
        task.wait(1)
    end
end)
