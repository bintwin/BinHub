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

local UI_LIBRARY_URL = "https://pastefy.app/vnSH5mJP/raw"
local TELEGRAM_URL = "https://t.me/Namedadudes"
local SCRIPT_TITLE = "selfcode.cc cracked by @Zlopiq"

local State = {
    Chams = false,
    Nametags = false,
    Noclip = false,
    InfiniteJump = false,
    WalkSpeed = 16,
    AntiAFK = false,
    AntiSit = false,
    AntiFling = false,

    AutoKillAll = false,
    AutoGrabGun = false,
    SilentAim = false,
    AutofarmCoins = false,
    AutoRemoveToyCars = false,

    SelectedPlayer = nil,
}

local Connections = {}
local VisualObjects = {}
local SafePlatform = nil

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
    murderer = '<font color="#FF0000">[M] ',
    sheriff = '<font color="#0096FF">[S] ',
    innocent = '<font color="#00FF00">[I] ',
    unknown = '<font color="#808080">[?] ',
}

local ROLE_COLORS = {
    murderer = Color3.fromRGB(255, 0, 0),
    sheriff = Color3.fromRGB(0, 150, 255),
    innocent = Color3.fromRGB(0, 255, 0),
    unknown = Color3.fromRGB(128, 128, 128),
}

local function clearVisual(player)
    local stored = VisualObjects[player]
    if stored then
        for _, object in pairs(stored) do
            pcall(function()
                object:Destroy()
            end)
        end
        VisualObjects[player] = nil
    end

    local character = getCharacter(player)
    if character then
        local existingChams = character:FindFirstChild("VigilChams")
        if existingChams then
            existingChams:Destroy()
        end

        local head = character:FindFirstChild("Head")
        if head then
            local existingTag = head:FindFirstChild("VigilNametag")
            if existingTag then
                existingTag:Destroy()
            end
        end
    end
end

local function updateVisual(player)
    if player == LocalPlayer then
        return
    end

    clearVisual(player)

    local character = getCharacter(player)
    local head = character and character:FindFirstChild("Head")
    if not character then
        return
    end

    local role = getRole(player)
    local stored = {}
    VisualObjects[player] = stored

    if State.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "VigilChams"
        highlight.OutlineTransparency = 1
        highlight.FillTransparency = 0.5
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = ROLE_COLORS[role] or ROLE_COLORS.unknown
        highlight.Adornee = character
        highlight.Parent = character
        stored.Chams = highlight
    end

    if State.Nametags and head then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "VigilNametag"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = head
        billboard.Parent = head

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 14
        label.TextStrokeTransparency = 0
        label.TextColor3 = ROLE_COLORS[role] or ROLE_COLORS.unknown
        label.RichText = true
        label.Text = (ROLE_TAGS[role] or ROLE_TAGS.unknown) .. player.Name .. "</font>"
        label.Parent = billboard

        stored.Nametag = billboard
    end
end

local function refreshVisuals()
    for _, player in ipairs(Players:GetPlayers()) do
        updateVisual(player)
    end
end

-- -------------------------------------------------------------------------
-- Local-player features
-- -------------------------------------------------------------------------

local function setInfiniteJump(enabled)
    State.InfiniteJump = enabled
    disconnect("InfiniteJump")

    if enabled then
        Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
            local humanoid = getHumanoid()
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

local function applyNoclip()
    if not State.Noclip then
        return
    end

    local character = getCharacter()
    if not character then
        return
    end

    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.CanCollide = false
        end
    end
end

local function applyWalkSpeed()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = State.WalkSpeed
    end
end

local function bindWalkSpeedLoop(character)
    if Connections.WalkSpeedChanged then
        Connections.WalkSpeedChanged:Disconnect()
        Connections.WalkSpeedChanged = nil
    end

    character = character or LocalPlayer.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then
        return
    end

    local function WalkSpeedChange()
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = State.WalkSpeed
        end
    end

    -- Same pattern used by Infinite Yield loopspeed: set it once, then
    -- restore it whenever something changes Humanoid.WalkSpeed.
    WalkSpeedChange()
    Connections.WalkSpeedChanged = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
end

local function setWalkSpeed(value)
    value = tonumber(value)
    if not value then
        return
    end

    State.WalkSpeed = value
    bindWalkSpeedLoop(LocalPlayer.Character)
end

local function applyAntiSit()
    if not State.AntiSit then
        return
    end

    local humanoid = getHumanoid()
    if not humanoid then
        return
    end

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    if humanoid.Sit then
        humanoid.Sit = false
    end
end

local function setAntiSit(enabled)
    State.AntiSit = enabled

    if not enabled then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        end
    end
end

-- The original "Anti-Fling" does not zero our own velocity.  The recovered
-- Stepped callback disables collision on BaseParts belonging to another player
-- when that player's HumanoidRootPart is within 3 studs of our root.
local function applyAntiFling()
    if not State.AntiFling then
        return
    end

    local localRoot = getRoot()
    if not localRoot then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = getCharacter(player)
            local targetRoot = getRoot(player)

            if character and targetRoot then
                local distance = (localRoot.Position - targetRoot.Position).Magnitude
                if distance < 3 then
                    for _, descendant in ipairs(character:GetDescendants()) do
                        if descendant:IsA("BasePart") and descendant.CanCollide then
                            descendant.CanCollide = false
                        end
                    end
                end
            end
        end
    end
end

local function installAntiAFK()
    disconnect("AntiAFK")

    Connections.AntiAFK = LocalPlayer.Idled:Connect(function()
        if not State.AntiAFK then
            return
        end

        local camera = workspace.CurrentCamera
        VirtualUser:Button2Down(Vector2.new(0, 0), camera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), camera.CFrame)
    end)
end

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

local function removeExistingToyCars()
    for _, descendant in ipairs(workspace:GetDescendants()) do
        removeToyCar(descendant)
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
        SafePlatform.Position = Vector3.new(0, 500, 0)
        SafePlatform.Anchored = true
        SafePlatform.Parent = workspace
    end

    local root = getRoot()
    if root then
        root.CFrame = CFrame.new(0, 505, 0)
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

local function refreshPlayerSelector()
    if PlayerSelector and type(PlayerSelector.UpdateOptions) == "function" then
        pcall(function()
            PlayerSelector:UpdateOptions(playerNames())
        end)
    end
    task.defer(refreshRoleRichText)
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

Connections.Stepped = RunService.Stepped:Connect(function()
    applyNoclip()
    applyAntiSit()
    applyAntiFling()
end)

bindWalkSpeedLoop(LocalPlayer.Character)

Connections.WalkSpeedCharacterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    if humanoid then
        bindWalkSpeedLoop(character)
    end
end)

installAntiAFK()

Connections.DescendantAdded = workspace.DescendantAdded:Connect(function(instance)
    if State.AutoRemoveToyCars then
        removeToyCar(instance)
    end
end)

Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
    refreshPlayerSelector()
    player.CharacterAdded:Connect(function()
        task.wait()
        updateVisual(player)
    end)
end)

Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
    clearVisual(player)
    if State.SelectedPlayer == player then
        State.SelectedPlayer = nil
    end
    refreshPlayerSelector()
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait()
            updateVisual(player)
        end)
    end
end

-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- UI integration (uilib_v2)
-- -------------------------------------------------------------------------

local LocalTab = Window:CreateTab("Local Player", "rbxassetid://2795572800")
local CombatTab = Window:CreateTab("Combat", "rbxassetid://10709790644")
local VisualsTab = Window:CreateTab("Visuals", "rbxassetid://7733799275")
local MiscTab = Window:CreateTab("Misc", "rbxassetid://7734053495")

-- [VISUALS]
local EspCard = VisualsTab:CreateSection("ESP Settings")
EspCard:CreateCheckbox("Enable Chams", false, function(value)
    State.Chams = value
    refreshVisuals()
end)
EspCard:CreateCheckbox("Enable Nametags", false, function(value)
    State.Nametags = value
    refreshVisuals()
end)

-- [LOCAL PLAYER]
local MovementCard = LocalTab:CreateSection("Movement")
MovementCard:CreateSlider("WalkSpeed", 16, 500, 16, function(value)
    setWalkSpeed(value)
end)
MovementCard:CreateCheckbox("Noclip", false, function(value)
    State.Noclip = value
end)
MovementCard:CreateCheckbox("Infinite Jump", false, function(value)
    setInfiniteJump(value)
end)

local ProtectionCard = LocalTab:CreateSection("Protection")
ProtectionCard:CreateCheckbox("Anti-AFK", false, function(value)
    State.AntiAFK = value
end)
ProtectionCard:CreateCheckbox("Anti-Sit", false, function(value)
    setAntiSit(value)
end)
ProtectionCard:CreateCheckbox("Anti-Fling", false, function(value)
    State.AntiFling = value
end)

-- [COMBAT]
local CombatCard = CombatTab:CreateSection("Combat Features")
CombatCard:CreateButton("Kill All (Needs Knife)", function()
    killAll()
end)
CombatCard:CreateCheckbox("Auto Kill All", false, function(value)
    State.AutoKillAll = value
end)
CombatCard:CreateCheckbox("Auto Grab Gun", false, function(value)
    State.AutoGrabGun = value
end)
CombatCard:CreateCheckbox("Silent Aim", false, function(value)
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
end

-- [MISC]
local FarmingCard = MiscTab:CreateSection("Farming")
FarmingCard:CreateCheckbox("Autofarm Coins", false, function(value)
    State.AutofarmCoins = value
end)
FarmingCard:CreateCheckbox("Auto Remove Toy Cars", false, function(value)
    State.AutoRemoveToyCars = value
    if value then
        removeExistingToyCars()
    end
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

-- Post-UI init
refreshPlayerSelector()
setWalkSpeed(State.WalkSpeed)
refreshVisuals()
installSilentAimHook()

task.spawn(automationLoop)
