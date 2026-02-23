-- [[ 漆念のコントラスト版：Pキー切替 ＆ 超高速監視 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local isTransparent = false -- 透明モードのフラグ

-- 適用したいID
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

-- ライティングを強制固定する関数（毎フレーム実行用）
local function ForceApply()
    -- 1. 空の固定
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
    if sky.SkyboxFt ~= config.Ids.Ft then
        sky.SkyboxFt = config.Ids.Ft
        sky.SkyboxBk = config.Ids.Bk
        sky.SkyboxRt = config.Ids.Rt
        sky.SkyboxLf = config.Ids.Lf
        sky.SkyboxUp = config.Ids.Up
        sky.SkyboxDn = config.Ids.Dn
    end

    -- 2. ライティングの強制固定
    lighting.Brightness = 0
    lighting.ClockTime = 14
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.ExposureCompensation = 1.2
end

-- 建造物を処理する関数（モードによって黒か透明か分ける）
local function UpdateBuildings()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if isTransparent then
                obj.Transparency = 1 -- 透明モード
            else
                obj.Transparency = 0 -- 黒モード
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.SmoothPlastic
            end
        elseif obj:IsA("Texture") or obj:IsA("Decal") then
            obj.Transparency = 1
        elseif obj:IsA("Light") then
            obj.Enabled = false
        end
    end
end

-- Pキーで切り替え
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        print("Mode Switched: " .. (isTransparent and "Transparent" or "Black"))
        UpdateBuildings() -- キーを押した瞬間に一回更新
    end
end)

-- 実行開始
print("--- Anti-Reset System: Press 'P' to Toggle ---")

-- 超高速監視ループ（RenderStepped = 画面が描画されるたびに実行）
game:GetService("RunService").RenderStepped:Connect(function()
    pcall(ForceApply)
end)

-- 建物は重いので、1秒ごとに新しく出たパーツをチェック
task.spawn(function()
    while true do
        pcall(UpdateBuildings)
        task.wait(1)
    end
end)
