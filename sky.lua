-- [[ 漆念のコントラスト真・完全版：不可視オブジェクト除外モデル ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

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

-- 1. ライティング固定（変更なし）
local function ForceApply()
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
    if sky.SkyboxFt ~= config.Ids.Ft then
        sky.SkyboxFt = config.Ids.Ft
        sky.SkyboxBk = config.Ids.Bk
        sky.SkyboxRt = config.Ids.Rt
        sky.SkyboxLf = config.Ids.Lf
        sky.SkyboxUp = config.Ids.Up
        sky.SkyboxDn = config.Ids.Dn
    end
    lighting.Brightness = 0
    lighting.ClockTime = 14
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.ExposureCompensation = 1.1
end

-- 2. 建造物処理（ここを大幅修正！）
local function UpdateBuildings()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if _G.SkyIsTransparent then
                obj.Transparency = 1
            else
                -- 【重要】もともと透明なパーツ（見えない壁など）は黒くしない！
                -- 透明度が0.1以上あるものは、意図的に隠されているので無視します
                if obj.Transparency < 0.1 then
                    obj.Color = Color3.new(0, 0, 0)
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                end
            end
        elseif obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Light") then
            obj.Enabled = false
        end
    end
end

-- 3. Pキー検知（接続を一度切ってから再接続して重複防止）
if _G.SkyConn then _G.SkyConn:Disconnect() end
_G.SkyConn = UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then
        _G.SkyIsTransparent = not _G.SkyIsTransparent
        print("Mode Toggle: " .. tostring(_G.SkyIsTransparent))
        UpdateBuildings()
    end
end)

-- 4. 実行
game:GetService("RunService").RenderStepped:Connect(function()
    pcall(ForceApply)
end)

task.spawn(function()
    while true do
        pcall(UpdateBuildings)
        task.wait(2) -- 負荷軽減のため2秒間隔に
    end
end)
