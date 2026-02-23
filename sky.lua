-- [[ 漆念のコントラスト版：強制キー検知 ＆ 超速監視 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local isTransparent = false

-- 1. 設定データ
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

-- 2. 毎フレーム実行する「超・強制」設定
local function SuperForce()
    -- 空の維持（Skyオブジェクトが消されたら即座に作り直す）
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky", lighting)
    end
    
    sky.SkyboxFt = config.Ids.Ft
    sky.SkyboxBk = config.Ids.Bk
    sky.SkyboxRt = config.Ids.Rt
    sky.SkyboxLf = config.Ids.Lf
    sky.SkyboxUp = config.Ids.Up
    sky.SkyboxDn = config.Ids.Dn

    -- ライティングの維持
    lighting.Brightness = 0
    lighting.ClockTime = 14
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.ExposureCompensation = 1.2
end

-- 3. 建造物の処理（黒 or 透明）
local function UpdateBuildings()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if isTransparent then
                obj.Transparency = 1
            else
                obj.Transparency = 0
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

-- 4. キー入力を「マウス・キーボード直接検知」に変える
-- UserInputServiceが効かないゲーム向けの別ルート
game:GetService("RunService").Stepped:Connect(function()
    -- Pキー (KeyCode 112 は 'p' の場合があるが、Enumで指定)
    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.P) then
        task.wait(0.2) -- 連続反応防止
        isTransparent = not isTransparent
        print("Toggle: " .. tostring(isTransparent))
        UpdateBuildings()
    end
    
    -- 毎フレーム実行
    pcall(SuperForce)
end)

-- 建物だけ1秒おきにチェック（新しく出現する建物対策）
task.spawn(function()
    while true do
        pcall(UpdateBuildings)
        task.wait(1)
    end
end)

print("--- System Ready: Press P to Toggle ---")
