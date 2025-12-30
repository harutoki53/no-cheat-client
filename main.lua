-- [[ Not Cheat Client v1.3 - THE FINAL REPAIR ]] --
-- Created by harutoki53

local Services = setmetatable({}, {__index = function(t, k) return game:GetService(k) end})
local Player = Services.Players.LocalPlayer
local Mouse = Player:GetMouse()
local RunService = Services.RunService
local CoreGui = Services.CoreGui
local OWNER_ID = 4666377774

-- [ 1. 初期データ ]
if not _G.NCC_Data then
    _G.NCC_Data = {
        Settings = {HUD = true, Inventory = true, AntiCheat = true, Fullbright = false, ESP = true},
        History = {}
    }
end
local startTime = os.time()

-- [ 2. UI基盤 ]
local ScreenGui = CoreGui:FindFirstChild("NCC_UI") or Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "NCC_UI"
ScreenGui:ClearAllChildren()

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 320)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "NCC v1.3 - harutoki53"; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold;

-- [ 3. ボタン作成関数 ]
local function addBtn(text, configKey, yPos)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 40); btn.Position = UDim2.new(0.05, 0, 0, yPos);
    btn.Font = Enum.Font.Gotham; btn.TextSize = 14; btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn)

    local function update()
        local isOn = _G.NCC_Data.Settings[configKey]
        btn.Text = text .. ": " .. (isOn and "ON" or "OFF")
        btn.BackgroundColor3 = isOn and Color3.fromRGB(45, 160, 45) or Color3.fromRGB(160, 45, 45)
    end
    btn.MouseButton1Click:Connect(function() _G.NCC_Data.Settings[configKey] = not _G.NCC_Data.Settings[configKey]; update() end)
    update()
end

addBtn("Status HUD", "HUD", 60)
addBtn("Skeleton ESP", "ESP", 110)
addBtn("Fullbright", "Fullbright", 160)
addBtn("Anti-Cheat", "AntiCheat", 210)

-- [ 4. スケルトンESP（修正済み） ]
local function createSkeleton(char)
    if not char or char == Player.Character then return end
    local folder = Instance.new("Folder", ScreenGui)
    folder.Name = "Skel_" .. char.Name
    
    local connections = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}
    }

    RunService.RenderStepped:Connect(function()
        folder:ClearAllChildren()
        -- 修正箇所: char.Parent() ではなく char.Parent を使用
        if not char.Parent or not _G.NCC_Data.Settings.ESP then return end
        
        for _, pair in ipairs(connections) do
            local p1, p2 = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
            if p1 and p2 then
                local pos1, vis1 = workspace.CurrentCamera:WorldToViewportPoint(p1.Position)
                local pos2, vis2 = workspace.CurrentCamera:WorldToViewportPoint(p2.Position)
                if vis1 and vis2 then
                    local l = Instance.new("Frame", folder); l.BackgroundColor3 = Color3.new(0, 1, 0.5); l.BorderSizePixel = 0;
                    local dist = Vector2.new(pos1.X - pos2.X, pos1.Y - pos2.Y)
                    l.Size = UDim2.new(0, dist.Magnitude, 0, 1); l.Position = UDim2.new(0, (pos1.X + pos2.X)/2, 0, (pos1.Y + pos2.Y)/2);
                    l.Rotation = math.atan2(dist.Y, dist.X) * (180 / math.pi)
                end
            end
        end
    end)
end

-- [ 5. メインループ ]
local infoFrame = Instance.new("Frame", ScreenGui)
infoFrame.Size = UDim2.new(0, 200, 0, 80); infoFrame.Position = UDim2.new(0, 10, 0.5, -40);
infoFrame.BackgroundColor3 = Color3.new(0,0,0); infoFrame.BackgroundTransparency = 0.5; Instance.new("UICorner", infoFrame)
local statsLabel = Instance.new("TextLabel", infoFrame)
statsLabel.Size = UDim2.new(1,-10,1,-10); statsLabel.Position = UDim2.new(0,5,0,5);
statsLabel.TextColor3 = Color3.new(1,1,1); statsLabel.BackgroundTransparency = 1; statsLabel.Font = Enum.Font.Code; statsLabel.TextSize = 12;

RunService.RenderStepped:Connect(function()
    infoFrame.Visible = _G.NCC_Data.Settings.HUD
    if infoFrame.Visible then
        statsLabel.Text = string.format("FPS: %d\nPING: %dms\nESP: %s", 
            math.floor(1/RunService.RenderStepped:Wait()), 
            math.floor(Player:GetNetworkPing()*1000),
            _G.NCC_Data.Settings.ESP and "ON" or "OFF"
        )
    end
    if _G.NCC_Data.Settings.Fullbright then Services.Lighting.Brightness = 2; Services.Lighting.ClockTime = 14 end
end)

-- [ 6. キー入力 ]
Services.UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then MainFrame.Visible = not MainFrame.Visible end
end)

-- 初期適用
for _, p in ipairs(Services.Players:GetPlayers()) do if p.Character then createSkeleton(p.Character) end p.CharacterAdded:Connect(createSkeleton) end
Services.Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(createSkeleton) end)

warn("NCC v1.3: All Errors Patched. Fully Operational.")
