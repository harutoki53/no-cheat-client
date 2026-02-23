-- [[ 安定・高感度版：Pキー切替 ＆ ちらつき防止 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

-- 1. 設定
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

_G.SkyMode = "Black" -- "Black" or "Invisible"

-- 2. キー入力イベント（InputBeganがダメな時用の予備）
UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.P then
        if _G.SkyMode == "Black" then
            _G.SkyMode = "Invisible"
        else
            _G.SkyMode = "Black"
        end
        print("Current Mode: " .. _G.SkyMode)
    end
end)

-- 3. メイン監視ループ（チラつき防止のため、あえて少し待機を入れる）
task.spawn(function()
    while true do
        pcall(function()
            -- 空の維持
            local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
            if sky.SkyboxFt ~= config.Ids.Ft then
                sky.SkyboxFt = config.Ids.Ft
                sky.SkyboxBk = config.Ids.Bk
                sky.SkyboxRt = config.Ids.Rt
                sky.SkyboxLf = config.Ids.Lf
                sky.SkyboxUp = config.Ids.Up
                sky.SkyboxDn = config.Ids.Dn
            end

            -- ライティング固定
            lighting.Brightness = 0
            lighting.ClockTime = 14
            lighting.ExposureCompensation = 1.2
            lighting.Ambient = Color3.new(0, 0, 0)
            lighting.OutdoorAmbient = Color3.new(0, 0, 0)

            -- 建造物処理
            for _, obj in pairs(game.Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
                    if _G.SkyMode == "Invisible" then
                        obj.Transparency = 1
                    else
                        -- 黒モード
                        if obj.Transparency ~= 0 or obj.Color ~= Color3.new(0,0,0) then
                            obj.Transparency = 0
                            obj.Color = Color3.new(0, 0, 0)
                            obj.Material = Enum.Material.SmoothPlastic
                        end
                    end
                elseif (obj:IsA("Texture") or obj:IsA("Decal")) and obj.Transparency ~= 1 then
                    obj.Transparency = 1
                end
            end
        end)
        task.wait(0.1) -- 0.1秒ごとに修正（速すぎると逆にチラつくため）
    end
end)

print("--- System Reloaded: Try Pressing 'P' ---")
