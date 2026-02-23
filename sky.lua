-- [[ 漆念のコントラスト完全版：Pキー強制反応 ＆ 視覚バグ修正 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

-- モード管理用のグローバル変数
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

-- 1. ライティングと空の「超・強制」固定（毎フレーム）
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
    lighting.ExposureCompensation = 1.1 -- 1.2より少し下げてバグを抑制
    lighting.FogEnd = 1e6
end

-- 2. 全オブジェクトの処理（トゲトゲ対策強化）
local function UpdateBuildings()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        -- 自分のキャラ以外を対象
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if _G.SkyIsTransparent then
                -- 透明モード：すべて消す
                if obj.Transparency ~= 1 then obj.Transparency = 1 end
            else
                -- 黒モード：見た目を黒く、形を保つ
                if obj.Transparency ~= 0 or obj.Color ~= Color3.new(0,0,0) then
                    obj.Transparency = 0
                    obj.Color = Color3.new(0, 0, 0)
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                end
            end
        -- デカール、テクスチャ、特殊メッシュをすべて透明化
        elseif obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
            obj.Transparency = 1
        -- パーティクル（謎の点々やエフェクト）を停止
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        -- 全ての光源をカット
        elseif obj:IsA("Light") then
            obj.Enabled = false
        end
    end
end

-- 3. Pキー検知（processedを無視して強制的に拾う設定）
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then
        _G.SkyIsTransparent = not _G.SkyIsTransparent
        print("Mode Toggled! Transparent: " .. tostring(_G.SkyIsTransparent))
        -- モード切り替え時に一気に全スキャン
        UpdateBuildings()
    end
end)

-- 4. 実行ループ
print("--- Final Version Loaded: Press 'P' to Toggle ---")

-- ライティングは最速で維持
game:GetService("RunService").RenderStepped:Connect(function()
    pcall(ForceApply)
end)

-- 建物や新パーツは1秒ごとにチェック（負荷対策）
task.spawn(function()
    while true do
        pcall(UpdateBuildings)
        task.wait(1)
    end
end)
