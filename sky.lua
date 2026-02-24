-- [[ 漆念：視認性重視・黒コントラスト（最適化版） ]]
local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- 1. 空の変更（新IDを死守）
local function ApplySky()
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
    sky.SkyboxFt = "rbxassetid://72529916859362"
    sky.SkyboxBk = "rbxassetid://74808508289471"
    sky.SkyboxRt = "rbxassetid://103546862048950"
    sky.SkyboxLf = "rbxassetid://116760075528148"
    sky.SkyboxUp = "rbxassetid://119892967613407"
    sky.SkyboxDn = "rbxassetid://123559461938777"
    sky.SunTextureId = ""
end

-- 2. 地形の黒化調整（「もう少し黒く」を反映）
local function ApplyBalancedBlack()
    lighting.FogEnd = 100000
    lighting.Brightness = 4
    lighting.ClockTime = 14
    -- 0.3 から 0.1 に下げることで、白っぽさを消して「黒」を引き締めます
    lighting.ExposureCompensation = 0.1 
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)

    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if obj:IsA("BasePart") and obj.Transparency < 0.1 then
                obj.Color = Color3.new(0, 0, 0) -- 完全な漆黒
                obj.Material = Enum.Material.Plastic
                -- 反射を 0.08 から 0.05 に微調整。エッジの光をより鋭くします
                obj.Reflectance = 0.05 
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 1
            elseif obj:IsA("Atmosphere") or obj:IsA("Clouds") then
                obj:Destroy()
            end
        end
    end
end

-- 3. 実行と維持（Heartbeatで常に最新状態をキープ）
pcall(ApplySky)
pcall(ApplyBalancedBlack)

-- 定期的に地形を再スキャンして黒さを維持（テレポート対策）
task.spawn(function()
    while true do
        pcall(ApplyBalancedBlack)
        task.wait(2)
    end
end)

-- 空のIDを監視
RunService.Heartbeat:Connect(function()
    local sky = lighting:FindFirstChildOfClass("Sky")
    if not sky or sky.SkyboxBk ~= "rbxassetid://74808508289471" then
        pcall(ApplySky)
    end
end)

print("Final Balanced Black Applied!")
