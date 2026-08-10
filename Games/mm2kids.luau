-- MM2 Kids / Bad Guy Mystery
local UILibrary = getgenv().UILibraryV2 or loadstring(game:HttpGet("https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/uilib/uilib_v2.luau?t=" .. tostring(tick())))()

if not UILibrary then
    warn("Failed to load UILibraryV2")
    return
end

local Window = UILibrary:CreateWindow({
    TitleFirst = "nebula",
    TitleSecond = "tech",
    FooterLeft = "MM2: Kids/Bad Guy Mystery",
    FooterRight = "nebulatech"
})

local ENV = (getfenv and getfenv()) or _ENV
local unpack = unpack or table.unpack

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- removed useless variables

local UISettings = {}

local State = {
    Chams = false,
    Nametags = false,
    Noclip = false,
    InfiniteJump = false,
    WalkSpeed = 16,
    AntiAFK = false,
        AntiFling = false,

    AutoKillAll = false,
    AutoGrabGun = false,
    SilentAim = false,
    AutofarmCoins = false,
    
    SelectedPlayer = nil,
}

local Connections = {}
local VisualObjects = {}
local SafePlatform = nil

local function notify(text, kind, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nebula UI",
            Text = tostring(text),
            Duration = duration or 3,
        })
    end)
end

local function disconnect(name)
    local connection = Connections[name]
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
        Connections[name] = nil
    end
end

local function getCharacter(player)
    player = player or LocalPlayer
    return player and player.Character or nil
end

local function getHumanoid(player)
    local character = getCharacter(player)
    return character and character:FindFirstChildOfClass("Humanoid") or nil
end

local function getRoot(player)
    local character = getCharacter(player)
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChild("RootPart")
        or character.PrimaryPart
end

local function attributeTrue(instance, ...)
    if not instance then
        return false
    end

    for index = 1, select("#", ...) do
        local name = select(index, ...)
        local ok, value = pcall(instance.GetAttribute, instance, name)
        if ok and value == true then
            return true
        end
    end

    return false
end

local function getRole(player)
    if not player then
        return "unknown"
    end

    local character = getCharacter(player)

    -- These spellings are all present in the recovered payload.
    if attributeTrue(player, "murderer", "Murderer", "murder")
        or attributeTrue(character, "murderer", "Murderer", "murder") then
        return "murderer"
    end

    if attributeTrue(player, "sheriff", "Sheriff", "sherif")
        or attributeTrue(character, "sheriff", "Sheriff", "sherif") then
        return "sheriff"
    end

    if attributeTrue(player, "innocent", "Innocent", "inocent")
        or attributeTrue(character, "innocent", "Innocent", "inocent") then
        return "innocent"
    end

    return "unknown"
end

local function findRole(role)
    role = string.lower(role)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getRole(player) == role then
            return player
        end
    end

    return nil
end

-- Visuals
-- -------------------------------------------------------------------------

local ROLE_TAGS = {
    murderer = '<font color="#FF0000">[MU] ',
    sheriff = '<font color="#0096FF">[SH] ',
    innocent = '<font color="#00FF00">[IN] ',
    unknown = '<font color="#808080">[?] ',
}

local ROLE_COLORS = {
    murderer = Color3.fromRGB(255, 0, 0),
    sheriff = Color3.fromRGB(0, 150, 255),
    innocent = Color3.fromRGB(0, 255, 0),
    unknown = Color3.fromRGB(128, 128, 128),
}


-- [DRAWING ESP]
local ESPDrawings = {}

local function CreateESP(player)
    if ESPDrawings[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1
    box.Filled = false
    
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Size = 14
    
    local lines = {}
    for i = 1, 15 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1
        table.insert(lines, line)
    end
    
    ESPDrawings[player] = {Box = box, Text = text, Lines = lines}
end

local function RemoveESP(player)
    local esp = ESPDrawings[player]
    if esp then
        esp.Box:Remove()
        esp.Text:Remove()
        for _, line in ipairs(esp.Lines) do
            line:Remove()
        end
        ESPDrawings[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateESP(player) end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then CreateESP(player) end
end)
Players.PlayerRemoving:Connect(RemoveESP)

Connections.ESPLoop = RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    for player, esp in pairs(ESPDrawings) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        local humanoid = character and character:FindFirstChild("Humanoid")
        
        if character and root and head and humanoid and humanoid.Health > 0 and (State.ESPBox or State.ESPSkeleton or State.ESPName) then
            local rootPos, rootVis = camera:WorldToViewportPoint(root.Position)
            local headPos, headVis = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
            local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            
            local role = getRole(player)
            local color = ROLE_COLORS[role]
            if not color then color = Color3.fromRGB(255, 255, 255) end
            
            if rootVis then
                if State.ESPBox then
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 2
                    esp.Box.Size = Vector2.new(width, height)
                    esp.Box.Position = Vector2.new(rootPos.X - width / 2, headPos.Y)
                    esp.Box.Color = color
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end
                

                if State.ESPName then
                    local roleName = ""
                    if role == "murderer" then roleName = "[Murderer] "
                    elseif role == "sheriff" then roleName = "[Sheriff] "
                    elseif role == "hero" then roleName = "[Hero] " end
                    esp.Text.Text = roleName .. player.Name
                    esp.Text.Position = Vector2.new(headPos.X, headPos.Y - 20)
                    esp.Text.Color = color
                    esp.Text.Visible = true
                else
                    esp.Text.Visible = false
                end
                
                                if State.ESPSkeleton then
                    local isR15 = character:FindFirstChild("UpperTorso") ~= nil
                    local jointPairs = {}
                    
                    if isR15 then
                        jointPairs = {
                            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
                            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
                            {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
                            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
                            {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
                        }
                    else
                        jointPairs = {
                            {"Head", "Torso"},
                            {"Torso", "Left Arm"},
                            {"Torso", "Right Arm"},
                            {"Torso", "Left Leg"},
                            {"Torso", "Right Leg"}
                        }
                    end
                    
                    local activeLines = 0
                    for i, pair in ipairs(jointPairs) do
                        local part1 = character:FindFirstChild(pair[1])
                        local part2 = character:FindFirstChild(pair[2])
                        if part1 and part2 then
                            local pos1, vis1 = camera:WorldToViewportPoint(part1.Position)
                            local pos2, vis2 = camera:WorldToViewportPoint(part2.Position)
                            if vis1 or vis2 then
                                activeLines = activeLines + 1
                                local line = esp.Lines[activeLines]
                                line.From = Vector2.new(pos1.X, pos1.Y)
                                line.To = Vector2.new(pos2.X, pos2.Y)
                                line.Color = color
                                line.Visible = true
                            end
                        end
                    end
                    
                    for i = activeLines + 1, 15 do
                        esp.Lines[i].Visible = false
                    end
                else
                    for i=1, 15 do esp.Lines[i].Visible = false end
                end

            else
                esp.Box.Visible = false
                esp.Text.Visible = false
                for i=1, 15 do esp.Lines[i].Visible = false end
            end
        else
            esp.Box.Visible = false
            esp.Text.Visible = false
            for i=1, 15 do esp.Lines[i].Visible = false end
        end
    end
end)


-- -------------------------------------------------------------------------
-- Game helpers
-- -------------------------------------------------------------------------

local function getCurrentMap()
    return workspace:FindFirstChild("CurrentMap")
end

local function findGunDrop()
    return workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("Gun")
end

local function removeToyCar(instance)
    if not instance then
        return
    end

    local name = instance.Name
    if name == "Toy Car" or name == "ToyCar" or name == "Car" then
        pcall(function()
            instance:Destroy()
        end)
    end
end

local function teleportToLobby()
    local root = getRoot()
    if not root then
        return
    end

    -- Exact constants recovered from the flattened callback.
    root.CFrame = CFrame.new(-3, -42, 12)
    notify("Teleported to Lobby", "success", 2)
end

local function teleportToMap()
    local map = workspace:FindFirstChild("CurrentMap")
    local spawns = map and map:FindFirstChild("Spawns", true)

    if not map or not spawns then
        notify("Map or spawns not found!", "error", 2)
        return
    end

    local spawnPoints = spawns:GetChildren()
    if #spawnPoints == 0 then
        notify("Map or spawns not found!", "error", 2)
        return
    end

    local root = getRoot()
    if not root then
        return
    end

    local spawnPoint = spawnPoints[math.random(1, #spawnPoints)]
    root.CFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
    notify("Teleported to Map!", "success", 2)
end

local function safeTeleport()
    if not SafePlatform or not SafePlatform.Parent then
        SafePlatform = Instance.new("Part")
        SafePlatform.Name = "SafeVigilPlatform"
        SafePlatform.Size = Vector3.new(50, 1, 50)
        SafePlatform.Position = Vector3.new(0, 5000, 0)
        SafePlatform.Anchored = true
        SafePlatform.Parent = workspace
    end

    local root = getRoot()
    if root then
        root.CFrame = CFrame.new(0, 5005, 0)
        notify("Teleported to Safe Platform", "success", 2)
    end
end

local function copyTelegram()
    if type(setclipboard) == "function" then
        setclipboard(TELEGRAM_URL)
        notify("Ссылка скопирована в буфер!", "success", 2)
    else
        notify("Ваш экзекутор не поддерживает копирование!", "error", 3)
    end
end

-- -------------------------------------------------------------------------
-- Fling reconstruction
-- -------------------------------------------------------------------------

local function flingPlayer(target)
    if not target or target == LocalPlayer then
        notify("Player not found!", "error", 2)
        return false
    end

    local character = getCharacter()
    local humanoid = getHumanoid()
    local root = getRoot()
    local targetCharacter = getCharacter(target)
    local targetHumanoid = getHumanoid(target)
    local targetRoot = getRoot(target)

    if not character or not humanoid or not root or not targetCharacter or not targetRoot then
        notify("Player not found!", "error", 2)
        return false
    end

    local targetHead = targetCharacter:FindFirstChild("Head")
    local targetAccessory = targetCharacter:FindFirstChildOfClass("Accessory")
    local targetHandle = targetAccessory and targetAccessory:FindFirstChild("Handle")

    local oldPosition = root.CFrame
    local oldFPDH = workspace.FallenPartsDestroyHeight
    local oldCameraSubject = workspace.CurrentCamera.CameraSubject

    -- These names are present literally in the recovered source.
    ENV.OldPos = oldPosition
    ENV.FPDH = oldFPDH

    local bodyVelocity = root:FindFirstChild("UnLeaked")
    if bodyVelocity then
        bodyVelocity:Destroy()
    end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "UnLeaked"
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(9e8, 9e8, 9e8)
    bodyVelocity.Parent = root

    -- NaN disables FallenPartsDestroyHeight in the same way as the flattened source.
    workspace.FallenPartsDestroyHeight = 0 / 0

    if targetHead then
        workspace.CurrentCamera.CameraSubject = targetHead
    elseif targetHandle then
        workspace.CurrentCamera.CameraSubject = targetHandle
    elseif targetHumanoid then
        workspace.CurrentCamera.CameraSubject = targetHumanoid
    end

    local function forcePosition(basePart, offset, angle)
        if not basePart or not basePart.Parent or not root.Parent then
            return
        end

        local cf = CFrame.new(basePart.Position) * offset * angle
        root.CFrame = cf

        if character.PrimaryPart then
            pcall(function()
                character:SetPrimaryPartCFrame(cf)
            end)
        end

        root.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        root.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local started = tick()
    local angle = 0

    repeat
        if not targetRoot.Parent or not targetCharacter.Parent then
            break
        end

        local speed = targetRoot.Velocity.Magnitude
        local moveDirection = targetHumanoid and targetHumanoid.MoveDirection or Vector3.zero

        if speed < 50 then
            angle = angle + 100
            local lead = moveDirection * (math.max(speed, 1) / 1.25)

            forcePosition(targetRoot, CFrame.new(0, 1.5, 0) + lead, CFrame.Angles(math.rad(angle), 0, 0))
            task.wait()
            forcePosition(targetRoot, CFrame.new(0, -1.5, 0) + lead, CFrame.Angles(math.rad(angle), 0, 0))
            task.wait()
            forcePosition(targetRoot, CFrame.new(2.25, 1.5, -2.25) + lead, CFrame.Angles(math.rad(angle), 0, 0))
            task.wait()
            forcePosition(targetRoot, CFrame.new(-2.25, -1.5, 2.25) + lead, CFrame.Angles(math.rad(angle), 0, 0))
            task.wait()
        else
            forcePosition(targetRoot, CFrame.new(0, 1.5, speed / 1.25), CFrame.Angles(math.rad(90), 0, 0))
            task.wait()
            forcePosition(targetRoot, CFrame.new(0, -1.5, -speed / 1.25), CFrame.Angles(math.rad(270), 0, 0))
            task.wait()
        end
    until targetRoot.Velocity.Magnitude > 500
        or target.Parent ~= Players
        or target.Character ~= targetCharacter
        or (targetHumanoid and targetHumanoid.Sit)
        or humanoid.Health <= 0
        or tick() > started + 2.5

    pcall(function()
        bodyVelocity:Destroy()
    end)

    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero

    pcall(function()
        root.CFrame = oldPosition
        if character.PrimaryPart then
            character:SetPrimaryPartCFrame(oldPosition)
        end
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end)

    workspace.CurrentCamera.CameraSubject = oldCameraSubject or humanoid
    workspace.FallenPartsDestroyHeight = oldFPDH

    notify("Fling Complete!", "success", 2)
    return true
end

local function flingRole(role)
    local target = findRole(role)
    if not target then
        if role == "murderer" then
            notify("Murderer not found!", "error", 2)
        else
            notify("Sheriff not found!", "error", 2)
        end
        return
    end

    if role == "murderer" then
        notify("Flinging Murderer: " .. target.Name, "success", 2)
    else
        notify("Flinging Sheriff: " .. target.Name, "success", 2)
    end

    flingPlayer(target)
end

-- -------------------------------------------------------------------------
-- Combat callbacks
-- -------------------------------------------------------------------------

local function getKnifeContainer()
    local character = getCharacter()
    local backpack = LocalPlayer:FindFirstChild("Backpack")

    local knife = character and character:FindFirstChild("KnifeServer")
    if not knife and backpack then
        knife = backpack:FindFirstChild("KnifeServer")
    end

    if knife then
        return knife
    end

    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") and child:FindFirstChild("KnifeServer") then
                return child
            end
        end
    end

    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and child:FindFirstChild("KnifeServer") then
                return child
            end
        end
    end

    return nil
end

local function killAll()
    local character = getCharacter()
    local root = getRoot()
    local humanoid = getHumanoid()
    local backpack = LocalPlayer:FindFirstChild("Backpack")

    if not character or not root then
        return
    end

    local knifeTool

    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and child:FindFirstChild("KnifeServer") then
                knifeTool = child
                break
            end
        end
    end

    if not knifeTool then
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") and child:FindFirstChild("KnifeServer") then
                knifeTool = child
                break
            end
        end
    end

    if not knifeTool then
        notify("No KnifeServer item found!", "error", 3)
        return
    end

    if humanoid and knifeTool.Parent == backpack then
        pcall(function()
            humanoid:EquipTool(knifeTool)
        end)
        task.wait()
    end

    local oldPosition = root.CFrame

    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= LocalPlayer then
            local targetCharacter = getCharacter(target)
            local targetRoot = getRoot(target)

            if targetCharacter and targetRoot then
                pcall(function()
                    root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
                    if character.PrimaryPart then
                        character:SetPrimaryPartCFrame(root.CFrame)
                    end
                end)

                task.wait(0.05)

                pcall(function()
                    knifeTool:Activate()
                end)

                if type(mouse1click) == "function" then
                    pcall(mouse1click)
                end

                task.wait(0.08)
            end
        end
    end

    pcall(function()
        root.Velocity = Vector3.zero
        root.RotVelocity = Vector3.zero
        root.CFrame = oldPosition
        if character.PrimaryPart then
            character:SetPrimaryPartCFrame(oldPosition)
        end
    end)

    notify("Used Kill All!", "success", 3)
end

local function autoGrabGunStep()
    if not State.AutoGrabGun then
        return
    end

    local gun = findGunDrop()
    local root = getRoot()
    if not gun or not root then
        return
    end

    local part = gun:IsA("BasePart") and gun
        or gun.PrimaryPart
        or gun:FindFirstChildWhichIsA("BasePart", true)

    if part then
        if type(firetouchinterest) == "function" then
            firetouchinterest(root, part, 0)
            task.wait()
            firetouchinterest(root, part, 1)
        else
            local oldCFrame = root.CFrame
            root.CFrame = part.CFrame
            task.wait(0.05)
            if root.Parent then
                root.CFrame = oldCFrame
            end
        end
    end
end

local SilentAimHookInstalled = false
local OldNamecall

local function installSilentAimHook()
    if SilentAimHookInstalled then
        return
    end

    if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then
        return
    end

    local closure = newcclosure or function(fn)
        return fn
    end

    OldNamecall = hookmetamethod(game, "__namecall", closure(function(self, ...)
        local method = getnamecallmethod()

        local callerIsScript = type(checkcaller) ~= "function" or not checkcaller()
        local remoteMethod = method == "FireServer" or method == "InvokeServer"

        if State.SilentAim and callerIsScript and remoteMethod and self then
            local remoteName = tostring(self.Name)
            local parentName = self.Parent and tostring(self.Parent.Name) or ""

            -- Both names occur in the recovered namecall state graph.
            local validRemote = remoteName == "ShootGun"
                or remoteName == "ShootStart"
                or (parentName == "GunServer" and (remoteName == "ShootGun" or remoteName == "ShootStart"))

            if validRemote then
                local target = findRole("murderer")
                local targetRoot = target and getRoot(target)
                local shooterRoot = getRoot()

                if targetRoot and shooterRoot then
                    local targetPosition = targetRoot.Position
                    local targetVelocity = targetRoot.AssemblyLinearVelocity

                    -- Exact threshold recovered from the dispatcher.
                    if targetVelocity.Magnitude > 200 then
                        targetVelocity = Vector3.zero
                    end

                    -- The flattened code divides distance by 1500 and applies
                    -- a 0.5 * Gravity * t^2 correction.
                    local travelTime = (shooterRoot.Position - targetPosition).Magnitude / 1500
                    local predictedPosition = targetPosition
                        + targetVelocity * travelTime
                        - Vector3.new(0, 0.5 * workspace.Gravity * travelTime * travelTime, 0)

                    local args = {...}
                    local argc = select("#", ...)
                    for index = 1, argc do
                        if typeof(args[index]) == "Vector3" then
                            args[index] = predictedPosition
                        end
                    end
                    
                    if type(setnamecallmethod) == "function" then
                        setnamecallmethod(method)
                    end
                    return OldNamecall(self, unpack(args, 1, argc))
                end
            end
        end

        if type(setnamecallmethod) == "function" then
            setnamecallmethod(method)
        end
        return OldNamecall(self, ...)
    end))

    SilentAimHookInstalled = true
end

-- -------------------------------------------------------------------------
-- Farming / background automation
-- -------------------------------------------------------------------------

local function farmCoinStep()
    if not State.AutofarmCoins then
        return
    end

    local root = getRoot()
    if not root then
        return
    end

    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant.Name == "Coin" or descendant.Name == "coin" then
            local part

            if descendant:IsA("BasePart") then
                part = descendant
            else
                part = descendant:FindFirstChildWhichIsA("BasePart", true)
            end

            if part then
                root.CFrame = part.CFrame
                task.wait()
                return
            end
        end
    end
end

local function automationLoop()
    local visualTick = 0

    while task.wait(0.2) do
        if State.AutoKillAll then
            pcall(killAll)
        end

        pcall(autoGrabGunStep)
        pcall(farmCoinStep)

        visualTick = visualTick + 1
        if visualTick >= 5 then
            visualTick = 0
            if State.Chams or State.Nametags then
                pcall(refreshVisuals)
            end
        end
    end
end

-- -------------------------------------------------------------------------
-- Fling selector
-- -------------------------------------------------------------------------

local PlayerSelector

local function fixRoleRichTextObject(object)
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        if type(object.Text) == "string" and object.Text:find("<font", 1, true) then
            object.RichText = true
        end
    end
end

local function refreshRoleRichText()
    local roots = {LocalPlayer:FindFirstChildOfClass("PlayerGui")}
    local ok, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if ok and coreGui then table.insert(roots, coreGui) end
    for _, root in ipairs(roots) do
        if root then
            for _, object in ipairs(root:GetDescendants()) do
                pcall(fixRoleRichTextObject, object)
            end
        end
    end
end

local function playerNames()
    local result = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local role = getRole(player)
            local tag = ROLE_TAGS[role] or ROLE_TAGS.unknown
            table.insert(result, tag .. player.Name .. "</font>")
        end
    end

    if #result == 0 then
        table.insert(result, "No Players")
    end

    return result
end


local function selectPlayer(value)
    local selected = tostring(value or "")
    selected = selected:gsub("<[^>]+>", "")
    selected = selected:gsub("%[.-%]%s*", "")

    if selected == "No Players" or selected == "" then
        State.SelectedPlayer = nil
    else
        State.SelectedPlayer = selected
    end
end

local function executeSelectedFling()
    if not State.SelectedPlayer then
        notify("Please select a target to fling!", "error", 3)
        return
    end

    local target = Players:FindFirstChild(State.SelectedPlayer)
    if not target then
        State.SelectedPlayer = nil
        notify("Player not found!", "error", 3)
        refreshPlayerSelector()
        return
    end

    notify("Flinging " .. target.Name, "success", 2)
    flingPlayer(target)
end

-- -------------------------------------------------------------------------
-- Runtime connections recovered from the dispatcher
-- -------------------------------------------------------------------------

local function setInfiniteJump(enabled)
    State.InfiniteJump = enabled
    if Connections.InfiniteJump then Connections.InfiniteJump:Disconnect() Connections.InfiniteJump = nil end
    if enabled then
        Connections.InfiniteJump = game:GetService("UserInputService").JumpRequest:Connect(function()
            local character = game.Players.LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end

local function applyNoclip()
    if not State.Noclip then return end
    local character = game.Players.LocalPlayer.Character
    if not character then return end
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then descendant.CanCollide = false end
    end
end

local function applyAntiFling()
    if not State.AntiFling then return end
    local character = game.Players.LocalPlayer.Character
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
        end
    end
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end

local function setWalkSpeed(value)
    State.WalkSpeed = value
    local character = game.Players.LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = value end
end

local function bindWalkSpeedLoop(character)
    if Connections.WalkSpeedLoop then Connections.WalkSpeedLoop:Disconnect() end
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 3)
    if humanoid then
        Connections.WalkSpeedLoop = game:GetService("RunService").Heartbeat:Connect(function()
            humanoid.WalkSpeed = State.WalkSpeed
        end)
    end
end

Connections.Stepped = RunService.Stepped:Connect(function()
    applyNoclip()
    applyAntiFling()
end)

bindWalkSpeedLoop(LocalPlayer.Character)

Connections.WalkSpeedCharacterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    if humanoid then
        bindWalkSpeedLoop(character)
    end
end)
local function installAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    if not VirtualUser then return end
    game.Players.LocalPlayer.Idled:Connect(function()
        if State.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

installAntiAFK()

Connections.DescendantAdded = workspace.DescendantAdded:Connect(function(instance)
end)

Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
    refreshPlayerSelector()
    player.CharacterAdded:Connect(function()
        task.wait()
            end)
end)

Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        if State.SelectedPlayer == player then
        State.SelectedPlayer = nil
    end
    refreshPlayerSelector()
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait()
                    end)
    end
end

-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- UI integration (uilib_v2)
-- -------------------------------------------------------------------------

local PlayersCat = Window:CreateCategory({Name = "Player"})
local VisualsCat = Window:CreateCategory({Name = "Visuals"})
local MiscCat = Window:CreateCategory({Name = "Misc"})

local LocalTab = PlayersCat:CreateTab("Player")
local CombatTab = PlayersCat:CreateTab("Autofarm/Fling")
local VisualsTab = VisualsCat:CreateTab("ESP")
local MiscTab = MiscCat:CreateTab("Settings")

-- [VISUALS]
local EspCard = VisualsTab:CreateSection("ESP Options")
UISettings.ESPBox = EspCard:CreateCheckbox("Enable Box ESP", false, function(value)
    State.ESPBox = value
end)
UISettings.ESPName = EspCard:CreateCheckbox("Enable Name ESP", false, function(value)
    State.ESPName = value
end)
UISettings.ESPSkeleton = EspCard:CreateCheckbox("Enable Skeleton ESP", false, function(value)
    State.ESPSkeleton = value
end)

-- [LOCAL PLAYER]
local MovementCard = LocalTab:CreateSection("Movement")
UISettings.WalkSpeed = MovementCard:CreateSlider("WalkSpeed", 16, 500, 16, function(value)
    setWalkSpeed(value)
end)
UISettings.Noclip = MovementCard:CreateCheckbox("Noclip", false, function(value)
    State.Noclip = value
end)
UISettings.InfiniteJump = MovementCard:CreateCheckbox("Infinite Jump", false, function(value)
    setInfiniteJump(value)
end)

local ProtectionCard = LocalTab:CreateSection("Protection")
UISettings.AntiAFK = ProtectionCard:CreateCheckbox("Anti-AFK", false, function(value)
    State.AntiAFK = value
end)
UISettings.AntiFling = ProtectionCard:CreateCheckbox("Anti-Fling", false, function(value)
    State.AntiFling = value
end)

-- [COMBAT]
local CombatCard = CombatTab:CreateSection("Combat Features")
CombatCard:CreateButton("Kill All (Needs Knife)", function()
    killAll()
end)
UISettings.AutoKillAll = CombatCard:CreateCheckbox("Auto Kill All", false, function(value)
    State.AutoKillAll = value
end)
UISettings.AutoGrabGun = CombatCard:CreateCheckbox("Auto Grab Gun", false, function(value)
    State.AutoGrabGun = value
end)
UISettings.SilentAim = CombatCard:CreateCheckbox("Silent Aim", false, function(value)
    State.SilentAim = value
end)

local FlingCard = CombatTab:CreateSection("Fling Targeting")
FlingCard:CreateButton("Fling Murderer", function()
    flingRole("murderer")
end)
FlingCard:CreateButton("Fling Sheriff", function()
    flingRole("sheriff")
end)

local initialPlayerOptions = playerNames()
local PlayerFlingDropdown = FlingCard:CreateDropdown("Select Player", initialPlayerOptions, initialPlayerOptions[1] or "No Players", function(value)
    selectPlayer(value)
end)

FlingCard:CreateButton("Execute Fling", function()
    executeSelectedFling()
end)

function refreshPlayerSelector()
    if PlayerFlingDropdown and type(PlayerFlingDropdown.UpdateOptions) == "function" then
        pcall(function()
            PlayerFlingDropdown:UpdateOptions(playerNames())
        end)
    end
    task.defer(refreshRoleRichText)
end

-- [MISC]
local FarmingCard = MiscTab:CreateSection("Farming")
UISettings.AutofarmCoins = FarmingCard:CreateCheckbox("Autofarm Coins", false, function(value)
    State.AutofarmCoins = value
end)

local TeleportCard = MiscTab:CreateSection("Teleports")
TeleportCard:CreateButton("Teleport to Lobby", function()
    teleportToLobby()
end)
TeleportCard:CreateButton("Teleport to Map", function()
    teleportToMap()
end)
TeleportCard:CreateButton("Safe Teleport (Platform)", function()
    safeTeleport()
end)

-- [CONFIG & UNLOAD]
local HttpService = game:GetService("HttpService")
if isfolder and not isfolder("BinHubConfigs") then makefolder("BinHubConfigs") end

local function GetConfigs()
    if not listfiles then return {"Default"} end
    local success, files = pcall(function() return listfiles("BinHubConfigs") end)
    if not success then return {"Default"} end
    local configs = {}
    for _, file in pairs(files) do
        local name = file:match("([^\\/]+)%.json$")
        if name then table.insert(configs, name) end
    end
    if #configs == 0 then table.insert(configs, "Default") end
    return configs
end

local ConfigDropdown, ConfigTextbox
local CurrentConfigName = "Default"

local function SaveConfig(name)
    if not writefile then return end
    local export = {}
    for k, v in pairs(State) do
        if typeof(v) == "EnumItem" then export[k] = {type = "EnumItem", val = v.Name}
        else export[k] = {type = "raw", val = v} end
    end
    export["ToggleKey"] = {type = "EnumItem", val = Window.ToggleKey.Name}
    
    writefile("BinHubConfigs/" .. name .. ".json", HttpService:JSONEncode(export))
    if ConfigDropdown and ConfigDropdown.UpdateOptions then
        ConfigDropdown:UpdateOptions(GetConfigs())
    end
end

local function LoadConfig(name)
    if not readfile then return end
    local path = "BinHubConfigs/" .. name .. ".json"
    if not isfile(path) then return end
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if success and type(decoded) == "table" then
        for k, item in pairs(decoded) do
            local val = item.val
            if item.type == "EnumItem" then val = Enum.KeyCode[val] or Enum.KeyCode.LeftAlt end
            
            if k == "ToggleKey" then
                Window.ToggleKey = val
                if UISettings.ToggleKey then UISettings.ToggleKey:SetValue(val) end
            else
                State[k] = val
                if UISettings[k] then 
                    UISettings[k]:SetValue(val) 
                end
            end
        end
    end
end

local function CheckAutoload()
    if isfile and isfile("BinHubConfigs/autoload.txt") then
        local name = readfile("BinHubConfigs/autoload.txt")
        LoadConfig(name)
    end
end

local ConfigCard = MiscTab:CreateSection("Configuration", "rbxassetid://7734053495")
UISettings.ToggleKey = ConfigCard:CreateKeybind("Toggle UI", Enum.KeyCode.LeftAlt, function(key)
    Window.ToggleKey = key
end)

ConfigDropdown = ConfigCard:CreateDropdown("Configs", GetConfigs(), "Default", function(v)
    CurrentConfigName = v
    if ConfigTextbox then ConfigTextbox:SetValue(v) end
end)

ConfigTextbox = ConfigCard:CreateTextbox("Config Name", "Enter name...", "Default", function(v)
    CurrentConfigName = v
end)

ConfigCard:CreateButton("Save Config", function()
    SaveConfig(CurrentConfigName)
end)

ConfigCard:CreateButton("Load Config", function()
    LoadConfig(CurrentConfigName)
end)

ConfigCard:CreateButton("Set Autoload", function()
    if writefile then writefile("BinHubConfigs/autoload.txt", CurrentConfigName) end
end)

ConfigCard:CreateButton("Unload UI", function()
    for _, conn in pairs(Connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    table.clear(Connections)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then pcall(RemoveESP, player) end
    end
    
    local success, core = pcall(function() return game:GetService("CoreGui"):FindFirstChild("BinHubV2") end)
    if success and core then core:Destroy() end
end)

CheckAutoload()

-- Post-UI init
refreshPlayerSelector()
setWalkSpeed(State.WalkSpeed)
installSilentAimHook()

task.spawn(automationLoop)
