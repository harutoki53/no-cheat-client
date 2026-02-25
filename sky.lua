-- [[ 漆念：あなたが提示した成功コードをそのままループ化 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")

local function ApplyYourSuccessCode()
    -- 1. 既存のSkyオブジェクトをクリアして新しく作成（そのまま採用）
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Sky") then
            obj:Destroy()
        end
    end

    local sky = Instance.new("Sky")
    sky.Parent = lighting

    -- ユーザー指定のアセットIDを適用
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://89515271903361"
    sky.SkyboxRt = "rbxassetid://83741654156826"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunTextureId = "" -- 太陽を消す設定も追加
    sky.SunAngularSize = 0

    -- 2. ライティングの調整（そのまま採用）
    lighting.ClockTime = 0 
    lighting.Brightness = 0.5 
    lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 20) 
    lighting.Ambient = Color3.fromRGB(0, 0, 0)

    -- 3. 建造物を一括で黒に変更（そのまま採用）
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            -- 自分のキャラだけは黒くならないように除外（これだけ足しました）
            if not v:IsDescendantOf(game.Players.LocalPlayer.Character) then
                v.Color = Color3.fromRGB(15, 15, 15)
            end
        end
    end
end

-- 無限ループ：5秒おきに「いけるコード」を再実行して状態を死守する
task.spawn(function()
    print("--- Your Success Code is now Running in Loop ---")
    while true do
        pcall(ApplyYourSuccessCode)
        task.wait(5) -- 5秒おきにチェック
    end
end)
