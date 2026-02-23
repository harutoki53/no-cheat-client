-- [[ 真・強制ブラックアウト：全オブジェクト完全漆黒化 ]]
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

-- 1. 空の「絶対強制」維持
RunService.RenderStepped:Connect(function()
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
    if sky.SkyboxFt ~= config.Ids.Ft then
        sky.SkyboxFt = config.Ids.Ft
        sky.SkyboxBk = config.Ids.Bk
        sky.SkyboxRt = config.Ids.Rt
        sky.SkyboxLf = config.Ids.Lf
        sky.SkyboxUp = config.Ids.Up
        sky.SkyboxDn = config.Ids.Dn
    end

    -- ライティングを極限まで暗くし、ツヤだけで地形を出す
    lighting.Brightness = 3 -- 反射（ツヤ）を強く出すために輝度を上げる
    lighting.ClockTime = 14
    lighting.ExposureCompensation = 1.0
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
end)

-- 2. 「的」も「床」も「壁」もすべて黒くする関数
local function ForceBlackout()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        -- 自分のキャラ以外をすべて対象
        if obj:IsA("BasePart") and not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if _G.SkyIsTransparent then
                obj.Transparency = 1
            else
                -- すべてを完全な黒に強制（的などの赤いパーツも逃さない）
                obj.Color = Color3.new(0, 0, 0)
                -- 鏡面反射（Reflectance）を設定して、空の光で地形の形だけを見せる
                obj.Material = Enum.Material.Glass 
                obj.Reflectance = 0.2 -- この「0.2」が地形把握の鍵（ツヤ）
                obj.Transparency = 0
            end
        -- 画像やテクスチャ（的のマークなど）をすべて消去
        elseif obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
            if not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
                if obj:IsA("BasePart") then
                    obj.Color = Color3.new(0,0,0) -- メッシュパーツも黒く
                elseif obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Transparency = 1 -- 的のマークなどは消す
                end
            end
        -- 光源とエフェクトを完全カット
        elseif obj:IsA("Light") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = false
        end
    end
end

-- 3. Pキー検知
if _G.SkyConn then _G.SkyConn:Disconnect() end
_G.SkyConn = UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.P then
        _G.SkyIsTransparent = not _G.SkyIsTransparent
        print("Switching Mode...")
        ForceBlackout()
    end
end)

-- 常に新しいパーツを黒くし続ける
task.spawn(function()
    while true do
        pcall(ForceBlackout)
        task.wait(1)
    end
end)

print("--- Total Blackout System Online ---")
