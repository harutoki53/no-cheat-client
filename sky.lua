-- [[ 漆念：視界復元プロトコル（建造物のみ黒化） ]]
repeat task.wait() until game:IsLoaded()

local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer
local isTransparent = false

-- パーツを黒く、または透明にする核心関数
local function ApplyStyle(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    if obj:IsDescendantOf(localPlayer.Character) then return end

    pcall(function()
        -- 初回の透明度を属性(Attribute)で記録（壊れないように）
        local origT = obj:GetAttribute("OriginalT")
        if origT == nil then
            origT = obj.Transparency
            obj:SetAttribute("OriginalT", origT)
        end

        if isTransparent then
            -- 【Pキー：クリスタルモード】
            obj.Transparency = 0.5
            obj.Material = Enum.Material.Glass
            obj.Color = Color3.fromRGB(160, 160, 255)
        else
            -- 【漆黒モード】
            if origT > 0 then
                -- ★透明度が少しでもあるものは「表示しない」
                obj.Transparency = 1
            else
                -- 不透明な建造物やデコイだけを「真っ黒」にする
                obj.Transparency = 0
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.SmoothPlastic
                
                -- デカール（顔や服）を透明化して人影を守る
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("Decal") or child:IsA("Texture") then
                        child.Transparency = 1
                    end
                end
            end
        end
    end)
end

-- 全パーツへの適用
local function Refresh()
    for _, item in ipairs(game.Workspace:GetDescendants()) do
        ApplyStyle(item)
    end
end

-- Pキーでの切り替え
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        Refresh()
    end
end)

-- 監視維持
game.Workspace.DescendantAdded:Connect(ApplyStyle)
task.spawn(function()
    while true do
        Refresh()
        task.wait(2)
    end
end)

Refresh()
print("--- Visibility Fixed: Building Blackout Only ---")
