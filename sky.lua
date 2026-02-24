-- [[ 漆念：空更新エラー修正 ＆ クリア夜景確定版 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

-- 空ID
local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"
local isTransparent = false

-- 1. 空の強制更新 (ログのエラーを止める)
local function ForceSky()
    -- エラーの元「Clouds」を消さずに、無力化する
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Clouds") then
            obj.Enabled = false
            obj.Cover = 0
            obj.Density = 0
        end
    end

    -- 既存のSkyboxを全て消去して、自分の設定を最優先にする
    for _, obj in ipairs(lighting:GetChildren()) do
        if obj:IsA("Sky") and obj.Name ~= "CustomSky" then
            obj:Destroy()
        end
    end

    local sky = lighting:FindFirstChild("CustomSky") or Instance.new("Sky", lighting)
    sky.Name = "CustomSky"
    
    -- IDが一致しない場合は強制的に上書きし続ける
    if sky.SkyboxBk ~= NEW_BK then
        sky.SkyboxFt = "rbxassetid://72529916859362"
        sky.SkyboxBk = NEW_BK
        sky.SkyboxRt = NEW_RT
        sky.SkyboxLf = "rbxassetid://116760075528148"
        sky.SkyboxUp = "rbxassetid://119892967613407"
        sky.SkyboxDn = "rbxassetid://123559461938777"
        sky.SunAngularSize = 0
        sky.MoonAngularSize = 0
    end

    -- Atmosphere（大気）が空を隠すので見つけ次第消す
    local atm = lighting:FindFirstChildOfClass("Atmosphere")
    if atm then atm:Destroy() end
end

-- 2. ライティング（クッキリ見える深夜）
local function SetupLighting()
    lighting.ClockTime = 2
    lighting.Brightness = 2
    lighting.GlobalShadows = false
    lighting.FogEnd = 1e6
    
    local ambient = Color3.fromRGB(65, 65, 80)
    lighting.Ambient = ambient
    lighting.OutdoorAmbient = ambient
    lighting.ExposureCompensation = 1.0
end

-- 3. パーツ処理（Pキーでクリスタル ↔ 漆黒）
local function ProcessPart(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    if obj:IsDescendantOf(localPlayer.Character or game.Workspace.CurrentCamera) then return end

    pcall(function()
        if isTransparent then
            -- シャープなクリスタル質感 (Ice)
            obj.Color = Color3.fromRGB(180, 180, 255)
            obj.Material = Enum.Material.Ice
            obj.Transparency = 0.6
            obj.Reflectance = 0.3
        else
            -- 磨き抜かれた漆黒 (SmoothPlastic)
            if obj.Transparency < 0.1 then
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.SmoothPlastic
                obj.Transparency = 0
                obj.Reflectance = 0.05
            end
        end
    end)
end

local function RefreshAll()
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        ProcessPart(obj)
    end
end

-- 4. 実行ループ
game.Workspace.DescendantAdded:Connect(ProcessPart)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        RefreshAll()
    end
end)

-- Heartbeatで空を監視（エラーが出ない方法に変更）
RunService.Heartbeat:Connect(function()
    pcall(ForceSky)
end)

SetupLighting()
RefreshAll()

print("--- Midnight Fix: Errors Suppressed & Sky Forced ---")
