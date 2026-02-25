-- [[ 漆念：不退転・空固定 ＆ 建造物黒化プロトコル ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

local isTransparent = false

-- 1. 空を「削除不能」にして固定する
-- ゲーム側がSkyを消しても、即座に作り直してIDを叩き込みます
local function EnsureSky()
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "FixedSky"
        sky.Parent = lighting
    end

    -- あなたの指定した成功IDを固定
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://89515271903361"
    sky.SkyboxRt = "rbxassetid://83741654156826"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    
    lighting.FogEnd = 100000
    lighting.SunTextureId = ""
end

-- 毎フレームチェック（上書き・削除対策）
RunService.RenderStepped:Connect(EnsureSky)

-- 2. 建造物・デコイの黒化（以前の成功ロジック）
local function ApplyStyle(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    if obj:IsDescendantOf(localPlayer.Character) then return end

    pcall(function()
        local origT = obj:GetAttribute("OrigT")
        if origT == nil then
            origT = obj.Transparency
            obj:SetAttribute("OrigT", origT)
        end

        if isTransparent then
            obj.Transparency = 0.5
            obj.Material = Enum.Material.Glass
            obj.Color = Color3.fromRGB(150, 150, 255)
        else
            if origT > 0 then
                obj.Transparency = 1 -- 透明パーツは消去
            else
                obj.Transparency = 0
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.SmoothPlastic
                
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("Decal") or child:IsA("Texture") then
                        child.Transparency = 1
                    end
                end
            end
        end
    end)
end

-- 全体リフレッシュ
local function FullRefresh()
    for _, item in ipairs(game.Workspace:GetDescendants()) do
        ApplyStyle(item)
    end
end

-- Pキー切り替え
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        FullRefresh()
    end
end)

-- 監視と定期ループ
game.Workspace.DescendantAdded:Connect(ApplyStyle)
task.spawn(function()
    while true do
        FullRefresh()
        task.wait(1.5)
    end
end)

FullRefresh()
print("--- Absolute Sky Lock & Blackout: Force Active ---")
