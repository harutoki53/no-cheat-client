-- [[ 漆念：極限制圧版（全環境破壊・漆黒・Pキー絶対動作） ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

_G.SkyIsTransparent = _G.SkyIsTransparent or false 

local config = {
    Ids = {
        Ft = "rbxassetid://72529916859362",
        Bk = "rbxassetid://74808508289471",
        Rt = "rbxassetid://103546862048950",
        Lf = "rbxassetid://116760075528148",
        Up = "rbxassetid://119892967613407",
        Dn = "rbxassetid://123559461938777"
    }
}

-- 1. 環境破壊：ゲーム側のエフェクトを物理的に消し続ける
local function EraseEnvironment()
    -- 霧や青みの原因を破壊
    for _, obj in pairs(lighting:GetChildren()) do
        if obj:IsA("Atmosphere") or obj:IsA("Sky") or obj:IsA("Clouds") or obj:IsA("PostEffect") then
            obj:Destroy()
        end
    end
    -- 新しい空を強制生成
    local sky = Instance.new("Sky", lighting)
    sky.SkyboxFt = config.Ids.Ft
    sky.SkyboxBk = config.Ids.Bk
    sky.SkyboxRt = config.Ids.Rt
    sky.SkyboxLf = config.Ids.Lf
    sky.SkyboxUp = config.Ids.Up
    sky.SkyboxDn = config.Ids.Dn
    
    -- ライティングを物理的な限界まで暗くする
    lighting.Brightness = 0
    lighting.ClockTime = 0
    lighting.ExposureCompensation = -1 -- マイナス値で白飛びを完全に殺す
    lighting.FogEnd = 9e9
    lighting.OutdoorAmbient = Color3.new(0,0,0)
    lighting.Ambient = Color3.new(0,0,0)
end

-- 2. オブジェクト制圧（塊も的も逃さない）
local function ForceBlackout()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if obj:IsA("BasePart") then
                if _G.SkyIsTransparent then
                    obj.Transparency = 1
                else
                    -- すべてを黒に。さらにMaterialをNeon以外にして発光を殺す
                    obj.Color = Color3.new(0, 0, 0)
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Transparency = 0
                    obj.Reflectance = 0
                end
            elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SpecialMesh") then
                obj.Transparency = 1 -- 的の模様や巨大なテクスチャを消す
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Light") then
                if obj:IsA("Light") then obj.Enabled = false else obj.Enabled = false end
            end
        end
    end
end

-- 3. Pキー：イベントではなくループで監視（絶対反応）
task.spawn(function()
    while true do
        if UIS:IsKeyDown(Enum.KeyCode.P) then
            _G.SkyIsTransparent = not _G.SkyIsTransparent
            print("Toggle Mode")
            ForceBlackout()
            task.wait(0.5) -- 連続反応防止
        end
        task.wait(0.05)
    end
end)

-- 4. 実行ループ（超高速）
RunService.RenderStepped:Connect(function()
    pcall(EraseEnvironment)
end)

task.spawn(function()
    while true do
        pcall(ForceBlackout)
        task.wait(0.5)
    end
end)

print("--- Ultimate Suppression System Online ---")
