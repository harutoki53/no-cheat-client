-- [[ 漆念：常時支配・空固定プロトコル ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

local isTransparent = false

-- 1. 空を「絶対」に固定する（毎フレーム実行）
-- これにより、ゲーム側が空を消したり戻したりする暇を与えません
RunService.RenderStepped:Connect(function()
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = lighting
    end

    -- あなたの指定したIDを毎フレーム強制適用
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://89515271903361"
    sky.SkyboxRt = "rbxassetid://83741654156826"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"

    -- 霧と太陽の設定も固定
    lighting.FogEnd = 100000
    lighting.SunTextureId = ""
end)

-- 2. 建造物の黒化処理（ここは負荷を考えて1秒ごとのループ）
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
                obj.Transparency = 1
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

game.Workspace.DescendantAdded:Connect(ApplyStyle)
task.spawn(function()
    while true do
        FullRefresh()
        task.wait(1)
    end
end)

FullRefresh()
print("--- Absolute Sky Lock: Active ---")
