-- [[ 漆念のコントラスト版：監視・自動修復機能付き ]]
local lighting = game:GetService("Lighting")

-- 適用したいIDと設定
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

-- メインの処理関数
local function ForceApply()
    -- 1. 空の固定
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky", lighting)
    end
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

-- 3. 建造物の黒化（これは重いので1回 or たまに実行）
local function BlackenBuildings()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if obj.Color ~= Color3.new(0, 0, 0) then
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            end
        elseif (obj:IsA("Texture") or obj:IsA("Decal")) and obj.Transparency ~= 1 then
            obj.Transparency = 1
        elseif obj:IsA("Light") and obj.Enabled == true then
            obj.Enabled = false
        end
    end
end

-- 実行開始
print("--- Anti-Reset Sky System Activated ---")

-- 無限ループで監視し続ける（これが重要！）
task.spawn(function()
    while true do
        ForceApply()
        -- 建物は負荷が高いので、5秒に1回チェック
        -- もし新しい建物が出てきてもこれで黒くなります
        BlackenBuildings() 
        task.wait(1) -- 1秒ごとにチェック
    end
end)
