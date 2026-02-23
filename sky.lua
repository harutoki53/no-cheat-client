-- [[ 地形視認型：漆黒コントラスト ＆ 強制スカイ ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

_G.SkyIsTransparent = _G.SkyIsTransparent or false 

local config = {
    Ids = {
        Ft = "rbxassetid://72529916859362",
        Bk = "rbxassetid://89515271903361",
        Rt = "rbxassetid://83741654156826",
        Lf = "rbxassetid://116760075528148",
        Up = "rbxassetid://119892967613407",
        Dn = "rbxassetid://123559461938777"
    }
}

-- 1. 空と光の「絶対強制」ループ（空が変わらない対策）
RunService.RenderStepped:Connect(function()
    -- 空の強制上書き
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky", lighting)
    end
    -- IDが違っていたら即座に修正
    if sky.SkyboxFt ~= config.Ids.Ft then
        sky.SkyboxFt = config.Ids.Ft
        sky.SkyboxBk = config.Ids.Bk
        sky.SkyboxRt = config.Ids.Rt
        sky.SkyboxLf = config.Ids.Lf
        sky.SkyboxUp = config.Ids.Up
        sky.SkyboxDn = config.Ids.Dn
    end

    -- ライティング：地形が見えるように「影」と「反射」を少しだけ残す
    lighting.Brightness = 2            -- 明るさを上げつつ
    lighting.ClockTime = 14
    lighting.ExposureCompensation = 0.8 -- 少し露出を下げて引き締める
    lighting.Ambient = Color3.new(0.05, 0.05, 0.05) -- 完全に0にせず、わずかに色を出す
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
end)

-- 2. 建造物処理（地形把握しやすく変更）
local function UpdateBuildings()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if _G.SkyIsTransparent then
                obj.Transparency = 1
            else
                -- もともと透明な塊（見えない壁）は無視
                if obj.Transparency < 0.1 then
                    -- 完全に黒(0,0,0)ではなく、ごく暗いグレーにすることで「角」を見えるようにする
                    obj.Color = Color3.new(0.02, 0.02, 0.02)
                    -- 素材を「Metal」か「DiamondPlate」にすると、光が当たった時に輪郭が見やすくなります
                    obj.Material = Enum.Material.Metal 
                    obj.Reflectance = 0.1 -- わずかに反射させることで地形の凹凸を出す
                    obj.Transparency = 0
                end
            end
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Light") then
            obj.Enabled = false
        end
    end
end

-- 3. Pキー検知（重複防止）
if _G.SkyConn then _G.SkyConn:Disconnect() end
_G.SkyConn = UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.P then
        _G.SkyIsTransparent = not _G.SkyIsTransparent
        UpdateBuildings()
    end
end)

-- 定期スキャン
task.spawn(function()
    while true do
        pcall(UpdateBuildings)
        task.wait(2)
    end
end)
