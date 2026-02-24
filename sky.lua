-- [[ 漆念：真プロトコル (透明排除・人影維持版) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"
local isTransparent = false

-- 1. 空と光の完全支配（毎フレーム実行）
RunService.RenderStepped:Connect(function()
    local sky = lighting:FindFirstChild("CustomSky") or Instance.new("Sky", lighting)
    sky.Name = "CustomSky"
    if sky.SkyboxBk ~= NEW_BK then
        sky.SkyboxBk = NEW_BK
        sky.SkyboxRt = NEW_RT
        sky.SkyboxFt = "rbxassetid://72529916859362"
        sky.SkyboxLf = "rbxassetid://116760075528148"
        sky.SkyboxUp = "rbxassetid://119892967613407"
        sky.SkyboxDn = "rbxassetid://123559461938777"
    end

    -- 世界の白さを消し、漆黒を際立たせる
    lighting.Brightness = 0
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    lighting.EnvironmentDiffuseScale = 0
    lighting.EnvironmentSpecularScale = 0
    lighting.FogEnd = 1e6
end)

-- 2. オブジェクト判定
local function ApplyStyle(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    if obj:IsDescendantOf(localPlayer.Character) then return end

    pcall(function()
        -- 元の透明度をタグで記録（初回のみ）
        if not obj:FindFirstChild("OriginT") then
            local val = Instance.new("NumberValue", obj)
            val.Name = "OriginT"
            val.Value = obj.Transparency
        end

        local originT = obj.OriginT.Value

        if isTransparent then
            -- 【透明（クリスタル）モード】
            obj.Transparency = 0.4
            obj.Reflectance = 1.0
            obj.Material = Enum.Material.Glass
            obj.Color = Color3.fromRGB(150, 150, 255)
        else
            -- 【漆黒モード】
            if originT > 0 then
                -- ★透明度が少しでもあるものは「表示しない」
                obj.Transparency = 1
                obj.CanCollide = obj.CanCollide -- 判定は残す
            else
                -- 不透明な建造物やデコイは「形を保ったまま漆黒」
                obj.Transparency = 0
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            end
        end
    end)
end

-- 3. 高速リフレッシュ（Pキー対応）
local function FullRefresh()
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        ApplyStyle(obj)
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        FullRefresh()
    end
end)

-- 新規出現物への即時適用
game.Workspace.DescendantAdded:Connect(ApplyStyle)

-- 1秒おきの強制再判定（戻り防止）
task.spawn(function()
    while true do
        FullRefresh()
        task.wait(1)
    end
end)

FullRefresh()
print("--- Protocol Updated: Transparency Removed & Shapes Kept ---")
