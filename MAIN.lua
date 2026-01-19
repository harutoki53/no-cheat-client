-- Rivals Script: Final God Mode Hybrid (Perfect Visual + Functional)

local P = game:GetService("Players")

local R = game:GetService("RunService")

local U = game:GetService("UserInputService")

local LP = P.LocalPlayer



local config = {

    aimbot = true,

    autoFire = true,

    wallCheck = true,

    isPC = true,      -- PCかスマホか

    smooth = 0.4,

    fov = 150,        -- スマホ用FOV

    pcFov = 800,      -- PC用FOV（固定）

    maxDistance = 1000,

    menuOpen = false

}



-- UIの親を取得（最も安定する方法）

local gui = Instance.new("ScreenGui")

gui.Name = "HarutokiUltimate"

gui.IgnoreGuiInset = true

gui.ResetOnSpawn = false

gui.Parent = LP:WaitForChild("PlayerGui")



-- 古いGUIを消去

for _, v in pairs(LP.PlayerGui:GetChildren()) do

    if v.Name == "HarutokiUltimate" and v ~= gui then v:Destroy() end

end



-- --- FOV円 (スマホ専用) ---

local fovCircle = Instance.new("Frame", gui)

fovCircle.BackgroundColor3 = Color3.new(1, 1, 1); fovCircle.BackgroundTransparency = 0.9

fovCircle.AnchorPoint = Vector2.new(0.5, 0.5); fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)

Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

Instance.new("UIStroke", fovCircle).Color = Color3.new(1, 1, 1)



-- --- 設定ウィンドウ ---

local menuFrame = Instance.new("Frame", gui)

menuFrame.Size = UDim2.new(0, 220, 0, 280); menuFrame.Position = UDim2.new(0.5, -110, 0.5, -140)

menuFrame.BackgroundColor3 = Color3.new(0, 0, 0); menuFrame.BackgroundTransparency = 0.1; menuFrame.Visible = false

Instance.new("UICorner", menuFrame); Instance.new("UIStroke", menuFrame).Color = Color3.new(1, 1, 1)



local title = Instance.new("TextLabel", menuFrame)

title.Size = UDim2.new(1, 0, 0, 40); title.Text = "HARUTOKI SETTINGS"; title.TextColor3 = Color3.new(1, 1, 1)

title.BackgroundTransparency = 1; title.TextScaled = true; title.Font = Enum.Font.RobotoMono



-- --- ボタン作成 ---

local function createMenuBtn(txt, y)

    local b = Instance.new("TextButton", menuFrame)

    b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = UDim2.new(0.05, 0, 0, y)

    b.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2); b.TextColor3 = Color3.new(1, 1, 1); b.Text = txt; b.TextScaled = true; b.Font = Enum.Font.RobotoMono

    Instance.new("UICorner", b); return b

end



local aimBtn = createMenuBtn("AIMBOT", 50)

local fireBtn = createMenuBtn("AUTO FIRE", 95)

local wallBtn = createMenuBtn("FILTER", 140)

local fovBtn = createMenuBtn("MOBILE FOV", 185) -- PC版では消す

local closeBtn = createMenuBtn("CLOSE", 230); closeBtn.BackgroundColor3 = Color3.new(0.4, 0.1, 0.1)



-- モード切替ボタン

local modeToggle = Instance.new("TextButton", gui)

modeToggle.Size = UDim2.new(0, 160, 0, 35); modeToggle.Position = UDim2.new(0, 10, 0, 10)

modeToggle.BackgroundColor3 = Color3.new(0, 0, 0); modeToggle.BackgroundTransparency = 0.5; modeToggle.TextColor3 = Color3.new(1, 1, 1); modeToggle.TextScaled = true; modeToggle.Font = Enum.Font.RobotoMono; Instance.new("UIStroke", modeToggle)



local function updateUI()

    modeToggle.Text = "MODE: " .. (config.isPC and "PC" or "MOBILE")

    menuFrame.Visible = config.menuOpen

    fovBtn.Visible = not config.isPC -- PCなら消す

    fovCircle.Visible = (not config.isPC and config.aimbot)

    fovCircle.Size = UDim2.new(0, config.fov * 2, 0, config.fov * 2)

    aimBtn.Text = "AIMBOT: " .. (config.aimbot and "ON" or "OFF")

    fireBtn.Text = "AUTO FIRE: " .. (config.autoFire and "ON" or "OFF")

    wallBtn.Text = "FILTER: " .. (config.wallCheck and "ON" or "OFF")

    fovBtn.Text = "MOBILE FOV: " .. config.fov

end



-- --- インタラクション ---

modeToggle.MouseButton1Click:Connect(function() config.isPC = not config.isPC; config.menuOpen = false; updateUI() end)

closeBtn.MouseButton1Click:Connect(function() config.menuOpen = false; updateUI() end)

aimBtn.MouseButton1Click:Connect(function() config.aimbot = not config.aimbot; updateUI() end)

fireBtn.MouseButton1Click:Connect(function() config.autoFire = not config.autoFire; updateUI() end)

wallBtn.MouseButton1Click:Connect(function() config.wallCheck = not config.wallCheck; updateUI() end)

fovBtn.MouseButton1Click:Connect(function() config.fov = (config.fov >= 450) and 100 or config.fov + 50; updateUI() end)



U.InputBegan:Connect(function(input, gpe)

    if gpe then return end

    if input.KeyCode == Enum.KeyCode.RightShift and config.isPC then config.menuOpen = not config.menuOpen; updateUI()

    elseif input.KeyCode == Enum.KeyCode.J then config.wallCheck = not config.wallCheck; updateUI() end

end)



-- --- ESPライン作成関数 (詳細版) ---

local function createLine(p)

    local l = Instance.new("Frame", p); l.BorderSizePixel = 0; l.ZIndex = 2; return l

end



local function createESP(v)

    local container = Instance.new("Frame", gui); container.BackgroundTransparency = 1; container.Visible = false

    local esp = {

        Main = container,

        Lines = {},

        Name = Instance.new("TextLabel", container),

        Dist = Instance.new("TextLabel", container),

        Ava = Instance.new("ImageLabel", container),

        BarBG = Instance.new("Frame", container),

        Bar = nil

    }

    for i=1,16 do esp.Lines[i] = createLine(container); if i <= 8 then esp.Lines[i].BackgroundColor3 = Color3.new(0,0,0); esp.Lines[i].ZIndex = 1 else esp.Lines[i].BackgroundColor3 = Color3.new(1,1,1) end end

    local function style(t) t.BackgroundTransparency, t.TextColor3, t.Font, t.TextScaled = 1, Color3.new(1,1,1), Enum.Font.RobotoMono, true; Instance.new("UIStroke", t) end

    style(esp.Name); style(esp.Dist)

    esp.BarBG.BackgroundColor3 = Color3.new(0,0,0); esp.Bar = Instance.new("Frame", esp.BarBG); esp.Bar.BorderSizePixel = 0; esp.Bar.BackgroundColor3 = Color3.new(0,1,0)

    esp.Ava.BackgroundTransparency = 1; Instance.new("UIStroke", esp.Ava)

    return esp

end

local pESP = {}



-- --- メインループ ---

R.RenderStepped:Connect(function()

    local C = workspace.CurrentCamera

    if not C then return end

    local center = Vector2.new(C.ViewportSize.X/2, C.ViewportSize.Y/2)

    local target, nearest = nil, (config.isPC and config.pcFov or config.fov)



    for _, v in pairs(P:GetPlayers()) do

        if v ~= LP and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") then

            local char = v.Character; local hum = char.Humanoid

            if hum.Health > 0 and (not v.Team or v.Team ~= LP.Team) then

                if not pESP[v] then pESP[v] = createESP(v) end

                local esp = pESP[v]

                local headPos, onScreen = C:WorldToViewportPoint(char.Head.Position)

                

                if onScreen then

                    local dist = (char.Head.Position - C.CFrame.Position).Magnitude

                    local hPos = C:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.7, 0))

                    local bPos = C:WorldToViewportPoint(char.HumanoidRootPart.Position - Vector3.new(0, 3, 0))

                    local h = math.abs(hPos.Y - bPos.Y); local w = h * 0.6

                    local x, y = headPos.X - w/2, headPos.Y - h/4

                    

                    esp.Main.Visible = true

                    -- コーナーボックス描画

                    local l = w*0.2; local t=1

                    local function draw(i,px,py,sx,sy) local line=esp.Lines[i]; line.Position=UDim2.new(0,px,0,py); line.Size=UDim2.new(0,sx,0,sy) end

                    draw(9,x,y,l,t); draw(10,x,y,t,l); draw(11,x+w-l,y,l,t); draw(12,x+w,y,t,l); draw(13,x,y+h,l,t); draw(14,x,y+h-l,t,l); draw(15,x+w-l,y+h,l,t); draw(16,x+w,y+h-l,t,l)

                    for i=1,8 do local s=esp.Lines[i+8]; draw(i,s.Position.X.Offset-1, s.Position.Y.Offset-1, s.Size.X.Offset+2, s.Size.Y.Offset+2) end

                    

                    esp.Name.Text = v.DisplayName; esp.Name.Position = UDim2.new(0, x, 0, y-20); esp.Name.Size = UDim2.new(0, w, 0, 15)

                    esp.Dist.Text = math.floor(dist).."m"; esp.Dist.Position = UDim2.new(0, x, 0, y+h+5); esp.Dist.Size = UDim2.new(0, w, 0, 12)

                    esp.BarBG.Position = UDim2.new(0, x-6, 0, y); esp.BarBG.Size = UDim2.new(0, 3, 0, h)

                    esp.Bar.Size = UDim2.new(1, 0, hum.Health/hum.MaxHealth, 0)

                    esp.Ava.Image = "rbxthumb://type=AvatarHeadShot&id="..v.UserId.."&w=150&h=150"; esp.Ava.Position = UDim2.new(0, x+w+5, 0, y); esp.Ava.Size = UDim2.new(0, 30, 0, 30)



                    -- エイム判定

                    local isVisible = #C:GetPartsObscuringTarget({char.Head.Position}, {char, LP.Character}) == 0

                    if (not config.wallCheck) or isVisible then

                        local dC = (Vector2.new(headPos.X, headPos.Y) - center).Magnitude

                        if dC < nearest then target = char.Head; nearest = dC end

                    end

                else esp.Main.Visible = false end

            elseif pESP[v] then pESP[v].Main.Visible = false end

        end

    end



    if target and config.aimbot then

        local isAim = config.isPC and U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or not config.isPC

        if isAim then

            local pos = C:WorldToViewportPoint(target.Position)

            if config.isPC and mousemoverel then

                mousemoverel((pos.X - center.X) * config.smooth, (pos.Y - center.Y) * config.smooth)

            else

                C.CFrame = C.CFrame:Lerp(CFrame.new(C.CFrame.Position, target.Position), config.smooth * 0.4)

            end

            if config.autoFire and mouse1press then mouse1press(); task.wait(0.01); mouse1release() end

        end

    end

end)

updateUI()
