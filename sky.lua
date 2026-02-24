-- [[ 漆念：絶対執行・最終究極版 (ログ修正/透視防止/全建造物対象) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"
local isTransparent = false

-- 1. 空と大気の強制固定（警告を出さない方法）
local function ForceEnvironment()
    -- 警告対策：DestroyではなくEnabled操作に限定
    local clouds = game.Workspace:FindFirstChildOfClass("Clouds", true)
    if clouds then clouds.Enabled = false end

    -- カスタムスカイの絶対維持
    local sky = lighting:FindFirstChild("CustomSky") or Instance.new("Sky", lighting)
    sky.Name = "CustomSky"
    if sky.SkyboxBk ~= NEW_BK then
        sky.SkyboxFt = "rbxassetid://72529916859362"
        sky.SkyboxBk = NEW_BK
        sky.SkyboxRt = NEW_RT
        sky.SkyboxLf = "rbxassetid://116760075528148"
        sky.SkyboxUp = "rbxassetid://119892967613407"
        sky.SkyboxDn = "rbxassetid://123559461938777"
        sky.SunAngularSize, sky.MoonAngularSize = 0, 0
    end

    -- 視界を遮るエフェクトを排除
    lighting.ClockTime = 2
    lighting.Brightness = 2.5
    lighting.FogEnd = 1e6
    lighting.Ambient = Color3.fromRGB(60, 60, 80)
    
    local atm = lighting:FindFirstChildOfClass("Atmosphere")
    if atm then atm:Destroy() end
end

-- 2. パーツの質感適用（デコイ・窓・壁すべて）
local function ApplyStyle(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    if obj:IsDescendantOf(localPlayer.Character) then return end

    pcall(function()
        if isTransparent then
            -- 【透明（クリスタル）モード】
            -- 透視を防ぐため透明度を下げ、反射を全開にする
            obj.Color = Color3.fromRGB(150, 150, 255)
            obj.Material = Enum.Material.Glass
            obj.Transparency = 0.4 -- 向こう側が見えすぎない厚み
            obj.Reflectance = 1.0  -- 鏡にして視線を跳ね返す
        else
            -- 【黒（漆黒）モード】
            if obj.Transparency > 0.1 then
                -- 元々透明なもの（窓など）は「黒い色付きガラス」にする
                obj.Color = Color3.new(0, 0, 0)
                obj.Transparency = 0.5
            else
                -- 普通の壁やデコイは「完全な漆黒」
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.SmoothPlastic
                obj.Transparency = 0
                obj.Reflectance = 0.05
            end
        end
    end)
end

-- 全パーツの強制リフレッシュ
local function FullRefresh()
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        ApplyStyle(obj)
    end
end

-- 3. 実行制御
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        FullRefresh() -- 切り替え時に即座に反映
    end
end)

-- ラグを出さずに監視
game.Workspace.DescendantAdded:Connect(ApplyStyle)

task.spawn(function()
    while true do
        ForceEnvironment()
        task.wait(2)
    end
end)

-- 初回起動
ForceEnvironment()
FullRefresh()

print("--- Midnight System: Absolute Polish Ready ---")
