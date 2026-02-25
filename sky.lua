-- [[ 漆念：成功コードをベースに、エラー回避だけを追加した決定版 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local workspace = game:GetService("Workspace")
-- エラー回避のため、Playersサービスを安全に取得
local playersService = game:GetService("Players")

-- ログ
print("SKY SCRIPT: TOTAL BLACKOUT SYSTEM ONLINE (SUCCESS BASE)!")

-- オブジェクトを黒くする共通関数（あなたの「行けたコード」をベース）
local function BlackoutObject(v)
    -- game.Players... の部分を playersService に変えてエラーを完全に防ぐ
    local lp = playersService.LocalPlayer
    if v:IsA("BasePart") then
        local isMyChar = false
        if lp and lp.Character and v:IsDescendantOf(lp.Character) then
            isMyChar = true
        end
        
        if not isMyChar then
            pcall(function()
                if v.Transparency < 0.5 then
                    v.Color = Color3.fromRGB(12, 12, 15) 
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0.04
                end
            end)
        end
    elseif v:IsA("Texture") or v:IsA("Decal") then
        v.Transparency = 1
    end
end

local function ApplyFinalAdjustment()
    -- 1. 空の死守（あなたの設定をそのまま維持）
    for _, obj in pairs(lighting:GetChildren()) do
        if (obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("Clouds")) and obj.Name ~= "LatestSky_Final" then
            obj:Destroy()
        end
    end

    local sky = lighting:FindFirstChild("LatestSky_Final")
    if not sky then
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
    sky.SunTextureId = ""
    sky.SunAngularSize = 0

    -- 2. ライティング（あなたの設定をそのまま維持）
    lighting.ClockTime = 14.5
    lighting.Brightness = 2.0
    lighting.OutdoorAmbient = Color3.fromRGB(35, 35, 40)
    lighting.Ambient = Color3.fromRGB(15, 15, 15)
    lighting.ExposureCompensation = 0.6

    -- 3. 既存の全オブジェクトをスキャン
    for _, v in pairs(workspace:GetDescendants()) do
        BlackoutObject(v)
    end
end

-- 【新機能】新しいマップパーツが追加されたら即座に黒くする（成功した仕組み）
workspace.DescendantAdded:Connect(function(v)
    BlackoutObject(v)
end)

-- 1秒おきの高速監視ループ
task.spawn(function()
    while true do
        pcall(ApplyFinalAdjustment)
        task.wait(1)
    end
end)

print("SKY SCRIPT: Success-based 1-second loop active!")
