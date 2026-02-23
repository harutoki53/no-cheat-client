-- [[ 最終制圧版：霧消去・全パーツ漆黒・超高速復旧 ]]
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

-- 1. ライティングの「完全破壊」と空の維持
RunService.RenderStepped:Connect(function()
    -- 空を最優先で維持
    local sky = lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", lighting)
    if sky.SkyboxFt ~= config.Ids.Ft then
        sky.SkyboxFt = config.Ids.Ft
        sky.SkyboxBk = config.Ids.Bk
        sky.SkyboxRt = config.Ids.Rt
        sky.SkyboxLf = config.Ids.Lf
        sky.SkyboxUp = config.Ids.Up
        sky.SkyboxDn = config.Ids.Dn
    end

    -- ゲーム側の「白飛び」と「霧」を毎フレーム殺す
    lighting.Brightness = 0                -- 太陽光カット
    lighting.OutdoorAmbient = Color3.new(0,0,0)
    lighting.Ambient = Color3.new(0,0,0)
    lighting.GlobalShadows = true          -- 影を有効にして暗さを強調
    lighting.ClockTime = 0                 -- 真夜中に固定
    lighting.FogEnd = 100000               -- 霧を遠くに飛ばす
    lighting.FogStart = 100000
    lighting.Atmosphere:Destroy() pcall(function() end) -- 大気エフェクト（白みの原因）を削除
end)

-- 2. 全オブジェクトの漆黒化（条件を排除）
local function ForceBlackout()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if not obj:IsDescendantOf(game.Players.LocalPlayer.Character) then
            -- パーツ類
            if obj:IsA("BasePart") then
                if _G.SkyIsTransparent then
                    obj.Transparency = 1
                else
                    -- 「もともと透明な塊」も含めて、画面内の全パーツを強制的に黒くする
                    obj.Color = Color3.new(0, 0, 0)
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    obj.Transparency = 0
                end
            -- デカール・テクスチャ・メッシュ装飾
            elseif obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
                obj.Transparency = 1
            -- パーティクル・光
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Light") or obj:IsA("PostEffect") then
                if obj:IsA("Light") then obj.Enabled = false
                else obj:Destroy() pcall(function() end) end -- エフェクト類は破壊
            end
        end
    end
end

-- 3. Pキー検知（接続ミス修正）
if _G.SkyConn then _G.SkyConn:Disconnect() end
_G.SkyConn = UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.P then
        _G.SkyIsTransparent = not _G.SkyIsTransparent
        ForceBlackout()
    end
end)

-- 超高速ループで黒さを維持
task.spawn(function()
    while true do
        pcall(ForceBlackout)
        task.wait(0.5) -- 監視速度を2倍にアップ
    end
end)

print("--- Ultimate Blackout System Online ---")
