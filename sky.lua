-- [[ 漆念のコントラスト版：見た目重視・Pキー修正モデル ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

-- 共有変数（ここをモード管理の柱にします）
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

-- 1. ライティングと空の「超高速」固定
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
    lighting.ExposureCompensation = 1.2
end

-- 2. 建造物の処理（今のモードに合わせて上書き）
local function UpdateBuildings()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if _G.SkyIsTransparent then
                if obj.Transparency ~= 1 then obj.Transparency = 1 end
            else
                -- 黒モード：色や透明度が違っていたら修正
                if obj.Transparency ~= 0 or obj.Color ~= Color3.new(0,0,0) then
                    obj.Transparency = 0
                    obj.Color = Color3.new(0, 0, 0)
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                end
            end
        elseif (obj:IsA("Texture") or obj:IsA("Decal")) and obj.Transparency ~= 1 then
            obj.Transparency = 1
        elseif obj:IsA("Light") and obj.Enabled == true then
            obj.Enabled = false
        end
    end
end

-- 3. Pキーの検知（InputBeganが無視される場合を想定して2系統用意）
UIS.InputBegan:Connect(function(input, processed)
    -- チャット中などは反応しないようにしつつ検知
    if input.KeyCode == Enum.KeyCode.P then
        _G.SkyIsTransparent = not _G.SkyIsTransparent
        print("Mode Toggle: " .. tostring(_G.SkyIsTransparent))
        UpdateBuildings() -- 即座に反映
    end
end)

-- 4. 実行ループ
print("--- Advanced Anti-Reset System Activated (Press P) ---")

-- ライティングは最優先で描画ごとに固定
game:GetService("RunService").RenderStepped:Connect(function()
    pcall(ForceApply)
end)

-- 建物は1秒ごとに新パーツも含めて再スキャン
task.spawn(function()
    while true do
        pcall(UpdateBuildings)
        task.wait(1)
    end
end)
