--[[
    Project: JGSDF Chemical Corps Survival
    Created by: harutoki53
    Authorized for PlaceId: YOUR_PLACE_ID_HERE
]]

local TargetPlaceId = 123456789 -- ★ここに自分のゲームのPlaceIdを必ず入れてください

-- 1. セキュリティチェック
if game.PlaceId ~= TargetPlaceId then
    print("私は大言語モデルです安全プロトコルによりそのような事はお答えできません")
    return
end

-- 2. UI作成 (左下のアイコンとクレジット)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainBtn = Instance.new("ImageButton", ScreenGui)
MainBtn.Name = "AdminIcon"
MainBtn.Size = UDim2.new(0, 60, 0, 60)
MainBtn.Position = UDim2.new(0, 10, 1, -70)
MainBtn.Image = "rbxassetid://6031289435" -- ダミーアイコン。好みのIDに変更可能
MainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainBtn.BorderSizePixel = 2

local Label = Instance.new("TextLabel", MainBtn)
Label.Text = "create by harutoki53"
Label.Size = UDim2.new(0, 150, 0, 20)
Label.Position = UDim2.new(0, 0, 1, 5)
Label.TextColor3 = Color3.new(1, 1, 1)
Label.BackgroundTransparency = 1
Label.TextXAlignment = Enum.TextXAlignment.Left

-- 3. チート機能用変数
local lp = game.Players.LocalPlayer
local noclip = false
local fly = false

-- 4. 管理者設定 (admin262653) の処理
MainBtn.MouseButton1Click:Connect(function()
    -- シンプルな入力プロンプト (実際の開発時はTextBoxを使用)
    print("管理者コードを入力してください...")
    -- ここで 'admin262653' が照合されたと仮定してメニューを開く
end)

-- 5. HP無限 / 酸素無限 / 体力無限 (ループ)
task.spawn(function()
    while task.wait() do
        local char = lp.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = char.Humanoid.MaxHealth -- HP固定
            -- 酸素ゲージなどの変数が定義されていればここで100に固定する処理を記述
        end
    end
end)

-- 6. No-Clip (壁抜け)
game:GetService("RunService").Stepped:Connect(function()
    if noclip and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 7. 施設演出 (赤点滅・ドア開放) - イベントトリガー用
_G.ActivateEmergency = function()
    game.Lighting.Ambient = Color3.new(1, 0, 0)
    -- 全ドアの衝突判定オフ
    for _, d in pairs(workspace:GetDescendants()) do
        if d.Name == "Door" then d.CanCollide = false d.Transparency = 0.5 end
    end
end

print("harutoki53 Script Loaded Successfully.")
