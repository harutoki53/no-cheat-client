-- [[ 漆念：真・完成版 (ラグ修正/キャラ形状維持/反射クリスタル) ]]
repeat task.wait() until game:IsLoaded()

local lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game:GetService("Players").LocalPlayer

local NEW_BK = "rbxassetid://88926366882961"
local NEW_RT = "rbxassetid://111173485460565"
local isTransparent = false

-- 1. 環境と空のセットアップ (エラー回避Ver)
local function SetupEnvironment()
    -- 警告を止めるため、一度だけ実行
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Clouds") then obj.Enabled = false end
    end
    
    lighting.ClockTime = 2
    lighting.Brightness = 2
    lighting.GlobalShadows = false
    lighting.FogEnd = 1e6
    
    local ambient = Color3.fromRGB(60, 60, 80)
    lighting.Ambient = ambient
    lighting.OutdoorAmbient = ambient

    -- 空の強制適用
    local sky = lighting:FindFirstChild("CustomSky") or Instance.new("Sky", lighting)
    sky.Name = "CustomSky"
    if sky.SkyboxBk ~= NEW_BK then
        sky.SkyboxFt = "rbxassetid://72529916859362"
        sky.SkyboxBk = NEW_BK
        sky.SkyboxRt = NEW_RT
        sky.SkyboxLf = "rbxassetid://116760075528148"
        sky.SkyboxUp = "rbxassetid://119892967613407"
        sky.SkyboxDn = "rbxassetid://123559461938777"
        sky.SunAngularSize = 0
    end
    
    local atm = lighting:FindFirstChildOfClass("Atmosphere")
    if atm then atm:Destroy() end
end

-- 2. パーツ処理 (キャラの形を守りつつ質感を変える)
local function ProcessPart(obj)
    if not obj:IsA("BasePart") or obj:IsA("Terrain") then return end
    
    -- 【重要】キャラクターやデコイの形（頭など）を守るための除外設定
    if obj:IsDescendantOf(localPlayer.Character) or obj.Parent:FindFirstChildOfClass("Humanoid") then 
        return 
    end

    pcall(function()
        if isTransparent then
            -- 【クリアモード：反射クリスタル】
            -- 透明度を上げすぎず、反射を最大にすることで「透視」を防ぎ「綺麗さ」を出す
            obj.Color = Color3.fromRGB(150, 150, 200)
            obj.Material = Enum.Material.Glass
            obj.Transparency = 0.5 -- これ以上上げると透視できてしまうので固定
            obj.Reflectance = 1.0 -- 空を鏡のように反射させる
        else
            -- 【ブラックモード：漆黒】
            if obj.Transparency < 0.1 then
                obj.Color = Color3.new(0, 0, 0)
                obj.Material = Enum.Material.SmoothPlastic
                obj.Transparency = 0
                obj.Reflectance = 0.05
            end
        end
    end)
end

-- 全パーツの更新
local function Refresh()
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        ProcessPart(obj)
    end
end

-- 3. イベント登録
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.P then
        isTransparent = not isTransparent
        print("Mode: " .. (isTransparent and "Crystal" or "Blackout"))
        Refresh() -- モード切り替え時に一括更新
    end
end)

-- 新しく追加されたパーツも自動処理
game.Workspace.DescendantAdded:Connect(ProcessPart)

-- 空とライティングを一定間隔でチェック (ラグ防止のためHeartbeatから分離)
task.spawn(function()
    while true do
        pcall(SetupEnvironment)
        task.wait(2)
    end
end)

-- 初回実行
SetupEnvironment()
Refresh()

print("--- Midnight Final: Anti-Lag & Shape Protection Loaded ---")
