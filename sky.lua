-- [[ 漆念：純粋黒化プロトコル (環境・空はいつも通り) ]]
repeat task.wait() until game:IsLoaded()

local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer
local isTransparent = false

-- パーツを黒く、または透明にする核心関数
local function ApplyBlack(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    if obj:IsDescendantOf(localPlayer.Character) then return end

    pcall(function()
        -- 元の透明度を保存（初回のみ）
        if not obj:FindFirstChild("OrigT") then
            local v = Instance.new("NumberValue", obj)
            v.Name = "OrigT"
            v.Value = obj.Transparency
        end

        if isTransparent then
            -- 【Pキー：クリスタルモード】
            obj.Transparency = 0.5
            obj.Material = Enum.Material.Glass
            obj.Color = Color3.fromRGB(160, 160, 255)
        else
            -- 【漆黒モード】
            if obj.OrigT.Value > 0 then
                -- 透明度が少しでもある（窓や火など）なら「表示しない」
                obj.Transparency = 1
            else
                -- 不透明な建造物やデコイだけを「真っ黒」にする
                obj.Transparency = 0
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.SmoothPlastic
                
                -- デカール（顔や服）を消して人型シルエットを守る
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("Decal") or child:IsA("Texture") then
                        child.Transparency = 1
                    end
                end
            end
        end
    end)
end

-- 全パーツへの一括適用
local function Refresh()
    for _, item in ipairs(game.Workspace:GetDescendants()) do
        ApplyBlack(item)
    end
end

-- Pキーでの切り替え
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        Refresh()
    end
end)

-- 新しく追加された建造物も即座に黒くする
game.Workspace.DescendantAdded:Connect(ApplyBlack)

-- 定期的にチェック（ゲーム側の色戻し防止）
task.spawn(function()
    while true do
        Refresh()
        task.wait(2)
    end
end)

Refresh()
print("--- Blackout System: Sky & Lighting Untouched ---")
