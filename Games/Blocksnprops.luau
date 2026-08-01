-- Try to get UILibrary from the loader, or fetch it directly from GitHub
local UILibrary = getgenv().UILibrary or loadstring(game:HttpGet("https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/uilib/uilib.luau?t=" .. tostring(tick())))()

if not UILibrary then
    warn("Failed to load UILibrary")
    return
end

local Window = UILibrary:CreateWindow({
    Name = "BinHUb - Blocks n Props"
})

local PlayerTab = Window:CreateTab("Player", "user")
local VisualsTab = Window:CreateTab("Visuals", "view")
local MiscTab = Window:CreateTab("Misc", "box")
local SettingsTab = Window:CreateTab("Settings", "settings")

-- Player Tab
PlayerTab:CreateTextSection("Local Player")

PlayerTab:CreateSlider("WalkSpeed", 16, 100, 16, function(value)
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end, "Player_WalkSpeed")

PlayerTab:CreateSlider("JumpPower", 50, 200, 50, function(value)
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
    end
end, "Player_JumpPower")

-- Visuals Tab Setup
VisualsTab:CreateTextSection("Player ESP")

local PlayerESP = { 
    Box = false, BoxColor = Color3.fromRGB(255, 255, 255),
    Name = false, NameColor = Color3.fromRGB(255, 255, 255),
    Skeleton = false, SkeletonColor = Color3.fromRGB(255, 255, 255)
}
local Drawings = { Players = {}, Props = {}, Prediction = {} }

VisualsTab:CreateToggle("Box ESP", false, function(state)
    PlayerESP.Box = state
end, "Visuals_PlayerBox")
VisualsTab:CreateColorPicker("Box Color", Color3.fromRGB(255, 255, 255), function(color)
    PlayerESP.BoxColor = color
end, "Visuals_PlayerBoxColor")

VisualsTab:CreateToggle("Nametag ESP", false, function(state)
    PlayerESP.Name = state
end, "Visuals_PlayerName")
VisualsTab:CreateColorPicker("Nametag Color", Color3.fromRGB(255, 255, 255), function(color)
    PlayerESP.NameColor = color
end, "Visuals_PlayerNameColor")

VisualsTab:CreateToggle("Skeleton ESP", false, function(state)
    PlayerESP.Skeleton = state
end, "Visuals_PlayerSkeleton")
VisualsTab:CreateColorPicker("Skeleton Color", Color3.fromRGB(255, 255, 255), function(color)
    PlayerESP.SkeletonColor = color
end, "Visuals_PlayerSkeletonColor")

VisualsTab:CreateTextSection("Prop ESP")

local PropESP = { Enabled = false, Box = false, Transparency = 0.5, FillColor = Color3.fromRGB(255, 100, 100), OutlineColor = Color3.fromRGB(255, 255, 255), Predict = false }

local function updatePropHighlights()
    for _, prop in ipairs(workspace.Projectiles:GetChildren()) do
        if PropESP.Enabled then
            local h = prop:FindFirstChild("PropHighlight")
            if not h then
                h = Instance.new("Highlight")
                h.Name = "PropHighlight"
                h.Parent = prop
            end
            h.FillColor = PropESP.FillColor
            h.OutlineColor = PropESP.OutlineColor
            h.FillTransparency = PropESP.Transparency
        else
            if prop:FindFirstChild("PropHighlight") then
                prop.PropHighlight:Destroy()
            end
        end
    end
end

VisualsTab:CreateToggle("Prop ESP", false, function(state)
    PropESP.Enabled = state
    updatePropHighlights()
end, "Visuals_PropESP")

VisualsTab:CreateToggle("Prop Box", false, function(state)
    PropESP.Box = state
end, "Visuals_PropBox")

VisualsTab:CreateSlider("Fill Transparency", 0, 100, 50, function(val)
    PropESP.Transparency = val / 100
    updatePropHighlights()
end, "Visuals_PropTrans")

VisualsTab:CreateColorPicker("Fill Color", Color3.fromRGB(255, 100, 100), function(color)
    PropESP.FillColor = color
    updatePropHighlights()
end, "Visuals_PropFillColor")

VisualsTab:CreateColorPicker("Outline Color", Color3.fromRGB(255, 255, 255), function(color)
    PropESP.OutlineColor = color
    updatePropHighlights()
end, "Visuals_PropOutlineColor")

VisualsTab:CreateToggle("Predict Arrow Prop", false, function(state)
    PropESP.Predict = state
end, "Visuals_PredictProp")

-- ESP RenderStepped Loop
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function createDrawing(type, props)
    local d = Drawing.new(type)
    for k, v in pairs(props) do d[k] = v end
    return d
end

local function clearDrawings(tbl)
    for _, d in pairs(tbl) do d:Remove() end
    table.clear(tbl)
end

if getgenv().ESPLoop then getgenv().ESPLoop:Disconnect() end
if getgenv().PropSpawnConn then getgenv().PropSpawnConn:Disconnect() end

getgenv().PropSpawnConn = workspace.Projectiles.ChildAdded:Connect(function(prop)
    task.wait(0.1)
    if PropESP.Enabled then updatePropHighlights() end
end)

getgenv().ESPLoop = RunService.RenderStepped:Connect(function()
    -- Handle Player ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not Drawings.Players[player] then
                Drawings.Players[player] = {
                    Box = createDrawing("Square", {Thickness = 1, Color = Color3.fromRGB(255, 255, 255), Filled = false}),
                    Name = createDrawing("Text", {Size = 16, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255)}),
                    Skeleton = {}
                }
                for i=1, 15 do
                    Drawings.Players[player].Skeleton[i] = createDrawing("Line", {Thickness = 1, Color = Color3.fromRGB(255, 255, 255)})
                end
            end
            
            local draws = Drawings.Players[player]
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            
            if root and head and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and (PlayerESP.Box or PlayerESP.Name or PlayerESP.Skeleton) then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    -- Box Math using proper top and bottom bounds
                    local rootPos = root.Position
                    local top3D = rootPos + Vector3.new(0, 3, 0)
                    local bottom3D = rootPos - Vector3.new(0, 3.5, 0)
                    local top2D = Camera:WorldToViewportPoint(top3D)
                    local bottom2D = Camera:WorldToViewportPoint(bottom3D)
                    
                    local height = math.abs(top2D.Y - bottom2D.Y)
                    local width = height * 0.65
                    
                    draws.Box.Visible = PlayerESP.Box
                    if PlayerESP.Box then
                        draws.Box.Size = Vector2.new(width, height)
                        draws.Box.Position = Vector2.new(pos.X - width/2, top2D.Y)
                        draws.Box.Color = PlayerESP.BoxColor
                    end
                    
                    draws.Name.Visible = PlayerESP.Name
                    if PlayerESP.Name then
                        draws.Name.Text = player.Name
                        draws.Name.Position = Vector2.new(pos.X, top2D.Y - 20)
                        draws.Name.Color = PlayerESP.NameColor
                    end
                    
                    if PlayerESP.Skeleton then
                        local joints = {}
                        if char:FindFirstChild("UpperTorso") then
                            -- R15
                            joints = {
                                {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                                {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                                {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                                {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                                {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
                            }
                        else
                            -- R6
                            joints = {
                                {"Head", "Torso"},
                                {"Torso", "Left Arm"},
                                {"Torso", "Right Arm"},
                                {"Torso", "Left Leg"},
                                {"Torso", "Right Leg"}
                            }
                        end
                        
                        for i, v in ipairs(joints) do
                            local p1 = char:FindFirstChild(v[1])
                            local p2 = char:FindFirstChild(v[2])
                            if p1 and p2 then
                                local pos1, vis1 = Camera:WorldToViewportPoint(p1.Position)
                                local pos2, vis2 = Camera:WorldToViewportPoint(p2.Position)
                                if vis1 and vis2 then
                                    draws.Skeleton[i].Visible = true
                                    draws.Skeleton[i].From = Vector2.new(pos1.X, pos1.Y)
                                    draws.Skeleton[i].To = Vector2.new(pos2.X, pos2.Y)
                                    draws.Skeleton[i].Color = PlayerESP.SkeletonColor
                                else
                                    draws.Skeleton[i].Visible = false
                                end
                            else
                                draws.Skeleton[i].Visible = false
                            end
                        end
                        for i=#joints+1, 15 do draws.Skeleton[i].Visible = false end
                    else
                        for i=1, 15 do draws.Skeleton[i].Visible = false end
                    end
                else
                    draws.Box.Visible = false
                    draws.Name.Visible = false
                    for i=1, 15 do draws.Skeleton[i].Visible = false end
                end
            else
                draws.Box.Visible = false
                draws.Name.Visible = false
                for i=1, 15 do draws.Skeleton[i].Visible = false end
            end
        end
    end
    
    -- Clean up disconnected players
    for player, draws in pairs(Drawings.Players) do
        if not player.Parent then
            draws.Box:Remove()
            draws.Name:Remove()
            for i=1, 15 do draws.Skeleton[i]:Remove() end
            Drawings.Players[player] = nil
        end
    end
    
    -- Handle Prop ESP & Prediction
    clearDrawings(Drawings.Props)
    clearDrawings(Drawings.Prediction)
    
    for _, prop in ipairs(workspace.Projectiles:GetChildren()) do
        if PropESP.Box and prop:IsA("BasePart") then
            local pos, onScreen = Camera:WorldToViewportPoint(prop.Position)
            if onScreen then
                local b = createDrawing("Square", {Thickness = 1, Color = PropESP.OutlineColor, Filled = false, Visible = true})
                local size = 2000 / pos.Z
                b.Size = Vector2.new(size, size)
                b.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                table.insert(Drawings.Props, b)
            end
        end
        
        if PropESP.Predict and prop:IsA("BasePart") and prop.AssemblyLinearVelocity.Magnitude > 5 then
            local currentPos = prop.Position
            local currentVel = prop.AssemblyLinearVelocity
            
            -- Detect if projectile has custom straight-line velocity physics
            local grav = Vector3.new(0, -workspace.Gravity, 0)
            if prop:FindFirstChildWhichIsA("BodyVelocity") or prop:FindFirstChildWhichIsA("LinearVelocity") or prop:FindFirstChildWhichIsA("VectorForce") then
                grav = Vector3.new(0, 0, 0)
            end
            
            local dt = 0.05
            local maxTime = 3
            
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local ignoreList = {workspace:FindFirstChild("Projectiles") or prop}
            if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
            rayParams.FilterDescendantsInstances = ignoreList
            
            for t = 0, maxTime, dt do
                local nextPos = currentPos + currentVel * dt + 0.5 * grav * dt * dt
                local nextVel = currentVel + grav * dt
                
                local dir = nextPos - currentPos
                local res = workspace:Raycast(currentPos, dir, rayParams)
                
                if res then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(res.Position)
                    if onScreen then
                        local circle = createDrawing("Circle", {Radius = 15, Position = Vector2.new(screenPos.X, screenPos.Y), Color = Color3.fromRGB(255, 0, 0), Filled = true, Transparency = 1, Visible = true})
                        table.insert(Drawings.Prediction, circle)
                        
                        local outline = createDrawing("Circle", {Radius = 15, Position = Vector2.new(screenPos.X, screenPos.Y), Color = Color3.fromRGB(255, 255, 255), Filled = false, Thickness = 2, Transparency = 1, Visible = true})
                        table.insert(Drawings.Prediction, outline)
                    end
                    break
                else
                    local screenPos, onScreen = Camera:WorldToViewportPoint(nextPos)
                    if onScreen then
                        local dot = createDrawing("Square", {Size = Vector2.new(6, 6), Position = Vector2.new(screenPos.X-3, screenPos.Y-3), Color = Color3.fromRGB(0, 255, 0), Filled = true, Transparency = 1, Visible = true})
                        table.insert(Drawings.Prediction, dot)
                    end
                end
                
                currentPos = nextPos
                currentVel = nextVel
            end
        end
    end
end)

-- Misc Tab
MiscTab:CreateTextSection("Blocks n Props Features")

MiscTab:CreateButton("Become Random Prop", function()
    print("Become Random Prop clicked")
end)

MiscTab:CreateButton("Teleport to Map", function()
    print("Teleport to Map clicked")
end)

-- Settings Tab
SettingsTab:CreateTextSection("UI Settings")

SettingsTab:CreateKeybind("Menu Keybind", Enum.KeyCode.RightControl, function()
    -- This callback is for when the key is pressed, but the library already handles the toggle logic internally.
    -- So we don't need to do anything here unless we want an extra action.
end, "Settings_ToggleKey", function(newKeyName)
    -- This callback fires when the user sets a new key!
    Window:SetToggleKey(newKeyName)
end)

SettingsTab:CreateButton("Clear Config", function()
    -- An example button
    print("Clearing Config is not yet implemented")
end)

Window:OnClose(function()
    if getgenv().ESPLoop then
        getgenv().ESPLoop:Disconnect()
        getgenv().ESPLoop = nil
    end
    if getgenv().PropSpawnConn then
        getgenv().PropSpawnConn:Disconnect()
        getgenv().PropSpawnConn = nil
    end
    
    for _, draws in pairs(Drawings.Players) do
        if draws.Box then draws.Box:Remove() end
        if draws.Name then draws.Name:Remove() end
        for i=1, 15 do
            if draws.Skeleton[i] then draws.Skeleton[i]:Remove() end
        end
    end
    Drawings.Players = {}
    
    clearDrawings(Drawings.Props)
    clearDrawings(Drawings.Prediction)
end)
