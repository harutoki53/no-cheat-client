-- [[ 漆念：合体究極プロトコル ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

local isTransparent = false

-- 1. 空の読み込み ＆ ループ固定（頂いたコードをそのまま使用）
local function UpdateSky()
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = lighting
    end

    -- あなたの指定したIDを適用
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://89515271903361"
    sky.SkyboxRt = "rbxassetid://83741654156826"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"

    lighting.FogEnd = 100000
    lighting.SunTextureId = ""
end

-- 2. 建造物を黒くする処理（透明なものは消去）
local function ApplyBlack(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    if obj:IsDescendantOf(localPlayer.Character) then return end

    pcall(function()
        -- 透明度の記録
        if not obj:FindFirstChild("OrigT") then
            local v = Instance.new("NumberValue", obj)
            v.Name = "OrigT"
            v.Value = obj.Transparency
        end

        if isTransparent then
            -- Pキー：クリスタル
            obj.Transparency = 0.5
            obj.Material = Enum.Material.Glass
            obj.Color = Color3.fromRGB(150, 150, 255)
        else
            -- 漆黒モード
            if obj.OrigT.Value > 0 then
                obj.Transparency = 1 -- 透明パーツは消去
            else
                obj.Transparency = 0
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.SmoothPlastic
                
                -- デカール（服や顔）を消す
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("Decal") or child:IsA("Texture") then
                        child.Transparency = 1
                    end
                end
            end
        end
    end)
end

-- 3. メインループ
local function FullRefresh()
    UpdateSky() -- 空を更新
    for _, item in ipairs(game.Workspace:GetDescendants()) do
        ApplyBlack(item)
    end
end

-- キー操作
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        FullRefresh()
    end
end)

-- 監視と定期実行
game.Workspace.DescendantAdded:Connect(ApplyBlack)
task.spawn(function()
    while true do
        FullRefresh()
        task.wait(2) -- 2秒ごとに空とパーツをチェック
    end
end)

FullRefresh()
print("--- Absolute System: Merged & Fixed ---")
