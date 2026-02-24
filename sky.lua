-- [[ 漆念：オーバーレイ・ドームプロトコル ]]
repeat task.wait() until game:IsLoaded()

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera

local isTransparent = false

-- 1. 物理的な「空のドーム」を作成
local skyDome = Instance.new("Part")
skyDome.Name = "SkyOverlay"
skyDome.Size = Vector3.new(2000, 2000, 2000) -- マップを包む巨大サイズ
skyDome.Shape = Enum.PartType.Ball
skyDome.Transparency = 0
skyDome.CanCollide = false
skyDome.CanTouch = false
skyDome.CanQuery = false
skyDome.CastShadow = false
skyDome.Anchored = true
skyDome.Material = Enum.Material.SmoothPlastic
skyDome.Parent = workspace

-- 内側にテクスチャを貼る（Meshにして内側を表示）
local mesh = Instance.new("SpecialMesh", skyDome)
mesh.MeshType = Enum.MeshType.Sphere
mesh.Scale = Vector3.new(-1, -1, -1) -- 反転させて「内側」を向かせる

-- あなたの星空IDをテクスチャとして適用
-- ※球体なので1枚のIDで全方位をカバーするか、Decalを6面に貼る調整
local skyTex = Instance.new("Decal", skyDome)
skyTex.Texture = "rbxassetid://72529916859362" -- メインの星空ID
skyTex.Face = Enum.NormalId.Front -- 全面に広がるよう調整

-- カメラに追従させて「常に空」として機能させる
RunService.RenderStepped:Connect(function()
    skyDome.Position = camera.CFrame.Position
end)

-- 2. 建造物の黒化（ここは以前の成功ロジックを継承）
local function ApplyStyle(obj)
    if not obj:IsA("BasePart") or obj == skyDome or obj:IsA("Terrain") then return end
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
        task.wait(2)
    end
end)

FullRefresh()
print("--- Overlay Sky System: Physical Layer Active ---")
