-- [[ 漆念：地形視認 ＆ 空強制描画 完全版 ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

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

-- 環境の徹底固定
local function EnforceEnv()
    -- 霧・大気・画面の色味補正を全て消去
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("Atmosphere") or v:IsA("Clouds") or v:IsA("PostEffect") or v:IsA("ColorCorrectionEffect") then
            v:Destroy()
        end
    end

    -- 空を生成・維持
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
    sky.SkyboxFt = config.Ids.Ft
    sky.SkyboxBk = config.Ids.Bk
    sky.SkyboxRt = config.Ids.Rt
    sky.SkyboxLf = config.Ids.Lf
    sky.SkyboxUp = config.Ids.Up
    sky.SkyboxDn = config.Ids.Dn

    -- ライティング調整（地形が見えるように輝度を上げる）
    lighting.Brightness = 5
    lighting.ClockTime = 14
    lighting.ExposureCompensation = 0.5
    lighting.Ambient = Color3.new(0, 0, 0)
    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    lighting.FogEnd = 1e6
end

-- 全パーツの黒化（エッジ強調）
local function Blackout()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            if obj:IsA("BasePart") then
                if obj.Transparency < 0.1 then
                    obj.Color = Color3.new(0, 0, 0)
                    obj.Material = Enum.Material.Plastic
                    obj.Reflectance = 0.05 -- 角を光らせる
                    obj.Transparency = 0
                end
                -- 巨大な空隠しパーツを消す
                if obj.Size.Magnitude > 1500 then obj.Transparency = 1 end
            elseif obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
                obj.Transparency = 1
            end
        end
    end
end

RunService.Heartbeat:Connect(EnforceEnv)
task.spawn(function()
    while true do
        pcall(Blackout)
        task.wait(1)
    end
end)
