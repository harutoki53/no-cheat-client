-- [[ 漆念：空固定・最優先モデル（ID更新版） ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

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

-- 空を「絶対に」作り直して固定する関数
local function ForceSkyUpdate()
    -- 1. 既存の空をすべて消す（ゲーム側のSkyboxを排除）
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Sky") then
            obj:Destroy()
        end
    end
    
    -- 2. 新しい空を生成してIDを流し込む
    local newSky = Instance.new("Sky")
    newSky.SkyboxFt = config.Ids.Ft
    newSky.SkyboxBk = config.Ids.Bk
    newSky.SkyboxRt = config.Ids.Rt
    newSky.SkyboxLf = config.Ids.Lf
    newSky.SkyboxUp = config.Ids.Up
    newSky.SkyboxDn = config.Ids.Dn
    newSky.Parent = lighting
    
    -- 3. 霧や余計なエフェクトを即死させる
    lighting.FogEnd = 1e6
    lighting.Brightness = 5
    lighting.ExposureCompensation = 0.4
    lighting.ClockTime = 14
end

-- 物理計算のたびに空をチェックして上書き（RenderSteppedより確実）
RunService.Heartbeat:Connect(function()
    local currentSky = lighting:FindFirstChildOfClass("Sky")
    -- 空が存在しない、あるいはIDが1つでも違っていたら強制更新
    if not currentSky or currentSky.SkyboxFt ~= config.Ids.Ft then
        pcall(ForceSkyUpdate)
    end
    
    -- 大気エフェクト（青白い原因）を破壊し続ける
    local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
    if atmosphere then atmosphere:Destroy() end
end)

-- 地形を黒くする処理（視認性重視）
local function ApplyBlackContrast()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if obj.Transparency < 0.1 then
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0.03
                obj.Transparency = 0
            end
        elseif obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
            -- 視界を遮る巨大な板や的のマークを抹殺
            if not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
                obj.Transparency = 1
            end
        end
    end
end

-- 高速スキャン
task.spawn(function()
    while true do
        pcall(ApplyBlackContrast)
        task.wait(0.5)
    end
end)
