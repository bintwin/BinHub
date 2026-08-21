-- A Quiet Place: Deadzone (Pre-Alpha)
-- Config-only BinHub UI for place 106920577206536.

local ALLOWED_PLACE_ID = 106920577206536
local GAME_NAME = "A Quiet Place: Deadzone (Pre-Alpha)"
local CONFIG_ROOT = "BinHubConfigs/AQuietPlaceDeadzone"
local AUTOLOAD_PATH = CONFIG_ROOT .. "/autoload.txt"

local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if getgenv().AQuietPlaceDeadzoneCleanup then
    pcall(getgenv().AQuietPlaceDeadzoneCleanup)
end

local CharacterConfiguration = require(ReplicatedStorage.Character.Configuration)
local CharacterUtilities = require(ReplicatedStorage.Character.Utilities)
local GameUtilities = require(ReplicatedStorage.Game.Utilities)
local ItemConfiguration = require(ReplicatedStorage.Item.Configuration)
local MonsterConfiguration = require(ReplicatedStorage.Monster.Configuration)
local Events = ReplicatedStorage:WaitForChild("Events")
local Remotes = Events:WaitForChild("Remotes")
local RequestCharacterAction = Remotes:WaitForChild("RequestCharacterAction")
local VoicePing = Remotes:WaitForChild("VoicePing")
local OriginalStaminaDeductionRate = CharacterConfiguration.StaminaDeductionRate
local OriginalStaminaRegenRate = CharacterConfiguration.StaminaRegenRate
local OriginalCanUseItem = CharacterUtilities.CanUseItem
local OriginalNoiseConfiguration = {
    -- Fall back to the game's current module defaults when a prior injected
    -- copy was reloaded while its zeroed values were still applied.
    FootstepWeightMultiplier = CharacterConfiguration.FootstepWeightMultiplier ~= 0 and CharacterConfiguration.FootstepWeightMultiplier or 0.1,
    SplashWeightMultiplier = CharacterConfiguration.SplashWeightMultiplier ~= 0 and CharacterConfiguration.SplashWeightMultiplier or 0.125,
    MinimumFootstepWeight = CharacterConfiguration.MinimumFootstepWeight ~= 0 and CharacterConfiguration.MinimumFootstepWeight or 0.8,
    MaximumFootstepWeight = CharacterConfiguration.MaximumFootstepWeight ~= 0 and CharacterConfiguration.MaximumFootstepWeight or 5,
    PingWeights = {}
}
local DefaultPingWeights = {Splash = 1.8, Land = 1.568, Jump = 0.8}
for name, value in pairs(CharacterConfiguration.PingWeights or {}) do
    OriginalNoiseConfiguration.PingWeights[name] = value ~= 0 and value or DefaultPingWeights[name] or value
end

-- These are the clean values from the game's Item.Configuration module.
-- Keeping them separately prevents a re-execution while a mod is enabled
-- from treating the previously modified values as the new originals.
local KnownWeaponDefaults = {
    RPG7 = {UseCooldown = 0.5, UseDuration = 0.2, ReloadDuration = 1.75, ReloadVisualDelay = 0.5, ReloadVisualDuration = 1.25},
    FlareGun = {UseCooldown = 0.5, UseDuration = 0.2, ReloadDuration = 0.4},
    RPK74 = {UseCooldown = 0.1, UseDuration = 0.1, ReloadDuration = 4, Automatic = true},
    LSAT = {UseCooldown = 0.05, UseDuration = 0.05, ReloadDuration = 4, Automatic = true},
    AA12 = {UseCooldown = 0.5, UseDuration = 0.2, ReloadDuration = 2, Automatic = true},
    M16A4 = {UseCooldown = 0.1, UseDuration = 0.1, ReloadDuration = 3, Automatic = false, BurstDelta = 0.1, BurstCooldown = 0.6},
    CZ75 = {UseCooldown = 0.2, UseDuration = 0.2, ReloadDuration = 3},
    ColtPython = {UseCooldown = 0.4, UseDuration = 0.2, ReloadDuration = 2.65},
    PSG1 = {UseCooldown = 1, UseDuration = 0.2, ReloadDuration = 3},
    KSVK = {UseCooldown = 2.5, UseDuration = 0.2, ReloadDuration = 5},
    XM1014 = {UseCooldown = 0.2, UseDuration = 0.2, ReloadDuration = 0.6}
}

local OriginalWeaponConfigs = {}
for name, item in pairs(ItemConfiguration.Items or {}) do
    if type(item) == "table" and item.Class == "Gun" then
        OriginalWeaponConfigs[name] = KnownWeaponDefaults[name] or {
            UseCooldown = item.UseCooldown,
            UseDuration = item.UseDuration,
            Automatic = item.Automatic,
            BurstDelta = item.BurstDelta,
            BurstCooldown = item.BurstCooldown,
            ReloadDuration = item.ReloadDuration,
            ReloadVisualDelay = item.ReloadVisualDelay,
            ReloadVisualDuration = item.ReloadVisualDuration
        }
    end
end

local State = {
    TPWalk = false,
    TPWalkSpeed = 0.3,
    InfiniteStamina = false,
    CtrlLock = false,
    SilentAim = false,
    SilentAimUseFOV = false,
    SilentAimFOV = 200,
    SilentAimFOVColor = Color3.fromRGB(0, 170, 255),
    SilentAimIgnored = {},
    SilentAimPlayerTargetPart = "Head",
    SilentAimMonsterTargetPart = "Head",
    TargetViewerType = "Monster",
    MonsterAngerAlert = false,
    MonsterEscapeKey = Enum.KeyCode.X,
    KeybindPanelPinned = false,
    KeybindPanelX = 18,
    KeybindPanelY = 220,
    SilentMode = false,
    Aimlock = false,
    AimlockUseFOV = false,
    AimlockFOV = 200,
    AimlockFOVColor = Color3.fromRGB(123, 97, 255),
    AimlockFOVFollowCursor = false,
    AimlockIgnored = {},
    AimlockKey = Enum.KeyCode.Q,
    AimlockKeyHeld = false,
    MonsterESP = false,
    MonsterNametag = false,
    MonsterNametagColor = Color3.fromRGB(255, 90, 90),
    MonsterBox = false,
    MonsterBoxColor = Color3.fromRGB(255, 70, 70),
    MonsterHealthbar = false,
    MonsterHealthbarColor = Color3.fromRGB(90, 220, 110),
    MonsterSkeleton = false,
    MonsterSkeletonColor = Color3.fromRGB(255, 150, 70),
    PlayerESP = false,
    PlayerNametag = false,
    PlayerNametagColor = Color3.fromRGB(100, 180, 255),
    PlayerBox = false,
    PlayerBoxColor = Color3.fromRGB(80, 150, 255),
    PlayerHealthbar = false,
    PlayerHealthbarColor = Color3.fromRGB(90, 220, 110),
    PlayerSkeleton = false,
    PlayerSkeletonColor = Color3.fromRGB(140, 210, 255),
    ItemESP = false,
    ItemNametag = false,
    ItemNametagColor = Color3.fromRGB(255, 230, 100),
    ItemBox = false,
    ItemBoxColor = Color3.fromRGB(255, 200, 70),
    AutoWeapons = false,
    InstantReload = false,
    AutoReload = false,
    FastFireRate = false,
    FireRateRPM = "600",
    InstantProximityPrompts = false
}
local UISettings = {}
local Unloaded = false
local StaminaTargets = {}
local StaminaLocks = {}
local AimCandidates = {}
local MouseLockBoundKeys
local OriginalMouseLockKeys = "LeftShift,RightShift"

local SilentRuntime = getgenv().AQuietPlaceDeadzoneSilentRuntime or {}
getgenv().AQuietPlaceDeadzoneSilentRuntime = SilentRuntime
SilentRuntime.Enabled = false
SilentRuntime.DesyncActive = false
local SilentDesyncConnection
local SilentGhost

local function DestroySilentGhost()
    if SilentGhost then
        SilentGhost:Destroy()
        SilentGhost = nil
    end
    SilentRuntime.Ghost = nil
end

local function CreateSilentGhost(character, root)
    DestroySilentGhost()
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or root
    local ghost = Instance.new("Part")
    ghost.Name = "BinHubSilentGhost"
    ghost.Size = torso.Size
    ghost.CFrame = torso.CFrame
    ghost.Anchored = true
    ghost.CanCollide = false
    ghost.CanTouch = false
    ghost.CanQuery = false
    ghost.CastShadow = false
    ghost.Material = Enum.Material.ForceField
    ghost.Color = Color3.fromRGB(40, 170, 255)
    ghost.Transparency = 0.16
    ghost.Parent = workspace

    local glow = Instance.new("PointLight")
    glow.Name = "Glow"
    glow.Color = ghost.Color
    glow.Brightness = 2.4
    glow.Range = 14
    glow.Shadows = false
    glow.Parent = ghost

    local outline = Instance.new("Highlight")
    outline.Name = "Outline"
    outline.Adornee = ghost
    outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    outline.FillColor = ghost.Color
    outline.FillTransparency = 0.42
    outline.OutlineColor = Color3.fromRGB(205, 240, 255)
    outline.OutlineTransparency = 0
    outline.Parent = ghost

    SilentGhost = ghost
    SilentRuntime.Ghost = ghost
end

local function SetCharacterNetworkSleeping(value)
    if not sethiddenproperty then return false end
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local success = pcall(sethiddenproperty, root, "NetworkIsSleeping", value)
    -- Sleeping the whole character assembly causes this game to replace the
    -- character. Only hold the locally owned root asleep.
    return success
end

local function StopSilentDesync()
    if SilentDesyncConnection then
        SilentDesyncConnection:Disconnect()
        SilentDesyncConnection = nil
    end
    SetCharacterNetworkSleeping(false)
    SilentRuntime.DesyncActive = false
    SilentRuntime.ServerAnchor = nil
    SilentRuntime.DesyncRoot = nil
    DestroySilentGhost()
end

local function StartSilentDesync()
    StopSilentDesync()
    if not sethiddenproperty then
        return false
    end

    local function AttachCurrentCharacter()
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return false end
        if root ~= SilentRuntime.DesyncRoot then
            if not SetCharacterNetworkSleeping(true) then return false end
            -- The server keeps the character at the position where Silent Mode
            -- attached while the locally owned character keeps moving locally.
            SilentRuntime.ServerAnchor = root.Position
            SilentRuntime.DesyncRoot = root
            SilentRuntime.DesyncActive = true
            CreateSilentGhost(character, root)
        else
            pcall(sethiddenproperty, root, "NetworkIsSleeping", true)
        end
        return true
    end

    AttachCurrentCharacter()
    SilentDesyncConnection = RunService.Heartbeat:Connect(function()
        if not SilentRuntime.Enabled then return end
        AttachCurrentCharacter()
    end)
    return true
end

local function IsLocalCharacterSource(source)
    local character = LocalPlayer.Character
    return character ~= nil and typeof(source) == "Instance"
        and (source == character or source:IsDescendantOf(character))
end

local MutedCharacterSounds = {}
local CharacterSoundDescendantConnection
local CharacterSoundCharacterConnection

local function MuteCharacterSound(sound)
    if not SilentRuntime.Enabled or not sound:IsA("Sound") or MutedCharacterSounds[sound] then return end
    local record = {Volume = sound.Volume}
    record.Connection = sound:GetPropertyChangedSignal("Volume"):Connect(function()
        if SilentRuntime.Enabled and sound.Parent and sound.Volume ~= 0 then
            sound.Volume = 0
        end
    end)
    MutedCharacterSounds[sound] = record
    sound.Volume = 0
end

local function RestoreCharacterSounds()
    for sound, record in pairs(MutedCharacterSounds) do
        if record.Connection then record.Connection:Disconnect() end
        if sound.Parent then sound.Volume = record.Volume end
        MutedCharacterSounds[sound] = nil
    end
end

local function AttachCharacterSoundMute(character)
    if CharacterSoundDescendantConnection then CharacterSoundDescendantConnection:Disconnect() end
    CharacterSoundDescendantConnection = character.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Sound") then MuteCharacterSound(descendant) end
    end)
    if SilentRuntime.Enabled then
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("Sound") then MuteCharacterSound(descendant) end
        end
    end
end

CharacterSoundCharacterConnection = LocalPlayer.CharacterAdded:Connect(AttachCharacterSoundMute)
if LocalPlayer.Character then AttachCharacterSoundMute(LocalPlayer.Character) end

-- Remove the local sound and its weight while preserving the action itself
if SilentRuntime.PatchVersion ~= 2 then
    SilentRuntime.OriginalPing = SilentRuntime.OriginalPing or GameUtilities.Ping
    SilentRuntime.OriginalPlayAudio = SilentRuntime.OriginalPlayAudio or GameUtilities.PlayAudio

    GameUtilities.Ping = function(self, position, weight, source)
        local runtime = getgenv().AQuietPlaceDeadzoneSilentRuntime
        if runtime and runtime.Enabled and IsLocalCharacterSource(source) then
            return nil
        end
        return SilentRuntime.OriginalPing(self, position, weight, source)
    end

    GameUtilities.PlayAudio = function(self, audioFolder, audioName, parent, properties)
        local runtime = getgenv().AQuietPlaceDeadzoneSilentRuntime
        if runtime and runtime.Enabled and (typeof(parent) == "CFrame" or IsLocalCharacterSource(parent)) then
            local silentProperties = {}
            if type(properties) == "table" then
                for key, propertyValue in pairs(properties) do
                    if key ~= "Weight" then silentProperties[key] = propertyValue end
                end
            end
            silentProperties.Volume = 0
            properties = silentProperties
        end
        return SilentRuntime.OriginalPlayAudio(self, audioFolder, audioName, parent, properties)
    end
    SilentRuntime.PatchVersion = 2
end

local function ApplySilentMode(value)
    value = value == true
    State.SilentMode = value
    SilentRuntime.Enabled = value

    CharacterConfiguration.FootstepWeightMultiplier = value and 0 or OriginalNoiseConfiguration.FootstepWeightMultiplier
    CharacterConfiguration.SplashWeightMultiplier = value and 0 or OriginalNoiseConfiguration.SplashWeightMultiplier
    CharacterConfiguration.MinimumFootstepWeight = value and 0 or OriginalNoiseConfiguration.MinimumFootstepWeight
    CharacterConfiguration.MaximumFootstepWeight = value and 0 or OriginalNoiseConfiguration.MaximumFootstepWeight
    for name, originalValue in pairs(OriginalNoiseConfiguration.PingWeights) do
        CharacterConfiguration.PingWeights[name] = value and 0 or originalValue
    end
    if value then
        local character = LocalPlayer.Character
        if character then AttachCharacterSoundMute(character) end
    else
        RestoreCharacterSounds()
    end
    -- Monster sight and targeting run on the server so client position hooks
    -- cannot safely make the character invisible to the AI
    StopSilentDesync()
    return false
end

SilentRuntime.SetEnabled = ApplySilentMode

ApplySilentMode(false)

local function Notify(text)
    text = tostring(text or ""):lower():gsub("[%.%,;]", "")
    text = text:gsub("^%l", string.upper)
    task.spawn(function()
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Binhub",
                Text = text,
                Duration = 6
            })
        end)
    end)
end

if game.PlaceId ~= ALLOWED_PLACE_ID then
    warn("[BinHub] " .. GAME_NAME .. " can only run in place " .. tostring(ALLOWED_PLACE_ID) .. ".")
    Notify("Wrong game. This script only works in " .. GAME_NAME .. ".")
    return
end

local oldGui = CoreGui:FindFirstChild("BinHubV2")
if oldGui then
    oldGui:Destroy()
end

local UILibrary = getgenv().UILibraryV2
if not UILibrary then
    local success, result = pcall(function()
        local url = "https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/uilib/uilib_v2.luau?t=" .. tostring(tick())
        return loadstring(game:HttpGet(url))()
    end)

    if not success then
        warn("[BinHub] Failed to load UILibV2: " .. tostring(result))
        Notify("UILibV2 failed to load.")
        return
    end

    UILibrary = result
    getgenv().UILibraryV2 = result
end

local Window = UILibrary:CreateWindow({
    TitleFirst = "bin",
    TitleSecond = "hub",
    FooterLeft = GAME_NAME,
    FooterRight = "binhub"
})

local AimCategory = Window:CreateCategory({Name = "Aim", Icon = "rbxassetid://83752373575368", Section = "Guns"})
local GunsModCategory = Window:CreateCategory({Name = "Gun Mods", Icon = "rbxassetid://121091323240554", Section = "Guns"})
local VisualsCategory = Window:CreateCategory({Name = "Visuals", Icon = "rbxassetid://127234874352422", Section = "Player"})
local PlayerCategory = Window:CreateCategory({Name = "Player", Icon = "rbxassetid://114567720540659", Section = "Player"})
local MiscCategory = Window:CreateCategory({Name = "Misc", Icon = "rbxassetid://106205298246017", Section = "Other"})
local AimTab = AimCategory:CreateTab("Aim")
local GunsModTab = GunsModCategory:CreateTab("Gun Mods")
local VisualsTab = VisualsCategory:CreateTab("Visuals")
local PlayerTab = PlayerCategory:CreateTab("Player")
local SettingsTab = MiscCategory:CreateTab("Settings")
local OPAimSection = AimTab:CreateSection("OP Aim")
local SilentAimSection = AimTab:CreateSection("Silent Aim")
local GunsModSection = GunsModTab:CreateSection("Gun Mods")
local MonsterESPSection = VisualsTab:CreateSection("Monster")
local PlayerESPSection = VisualsTab:CreateSection("Player")
local ItemESPSection = VisualsTab:CreateSection("Item")
local ModelViewerSection = VisualsTab:CreateSection("Model Viewer")
local MovementSection = PlayerTab:CreateSection("Movement")
local CameraSection = PlayerTab:CreateSection("Camera")
local StaminaSection = PlayerTab:CreateSection("Stamina")
local ConfigSection = SettingsTab:CreateSection("Configuration", "rbxassetid://7734053495")
local MiscSettingsSection = SettingsTab:CreateSection("Misc")
-- Fix for icons.rest asset padding (scales icons up slightly and recenters them)
local targetIcons = {
    "rbxassetid://83752373575368",
    "rbxassetid://121091323240554",
    "rbxassetid://127234874352422",
    "rbxassetid://114567720540659",
    "rbxassetid://106205298246017"
}
local binhubGui = CoreGui:FindFirstChild("BinHubV2")
if binhubGui then
    for _, obj in pairs(binhubGui:GetDescendants()) do
        if obj:IsA("ImageLabel") and table.find(targetIcons, obj.Image) then
            obj.Size = UDim2.new(0, 22, 0, 22)
            obj.Position = UDim2.new(0, 9, 0.5, -11)
        end
    end
end

MiscSettingsSection:CreateButton("Load Whole Map", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then 
        Notify("Character not found!")
        return 
    end

    Notify("Loading map... Please wait 3 seconds.")
    local originalCFrame = hrp.CFrame
    local originalAnchored = hrp.Anchored
    
    hrp.Anchored = true
    
    task.spawn(function()
        local range = 2000
        local step = 1000
        
        for x = -range, range, step do
            for z = -range, range, step do
                hrp.CFrame = CFrame.new(x, 150, z)
                task.wait(0.1)
            end
        end
        
        hrp.CFrame = originalCFrame
        hrp.Anchored = originalAnchored
        Notify("Map load complete!")
    end)
end)

local PlayerTargetPartOptions = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"}
local MonsterTargetPartOptions = {"Head", "UpperTorso", "HumanoidRootPart", "Mesh"}

local oldMonsterAlertGui = CoreGui:FindFirstChild("BinHubMonsterAlert")
if oldMonsterAlertGui then oldMonsterAlertGui:Destroy() end
local oldMonsterAlertSound = SoundService:FindFirstChild("BinHubMonsterAlertSound")
if oldMonsterAlertSound then oldMonsterAlertSound:Destroy() end

local MonsterAlertGui = Instance.new("ScreenGui")
MonsterAlertGui.Name = "BinHubMonsterAlert"
MonsterAlertGui.IgnoreGuiInset = true
MonsterAlertGui.ResetOnSpawn = false
MonsterAlertGui.DisplayOrder = 999999
MonsterAlertGui.Enabled = false
MonsterAlertGui.Parent = CoreGui

local MonsterAlertFrame = Instance.new("Frame")
MonsterAlertFrame.Name = "Alert"
MonsterAlertFrame.AnchorPoint = Vector2.new(0.5, 0)
MonsterAlertFrame.Position = UDim2.fromScale(0.5, 0.1)
MonsterAlertFrame.Size = UDim2.fromOffset(280, 58)
MonsterAlertFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MonsterAlertFrame.BackgroundTransparency = 0
MonsterAlertFrame.BorderSizePixel = 0
MonsterAlertFrame.Parent = MonsterAlertGui

local MonsterAlertCorner = Instance.new("UICorner")
MonsterAlertCorner.CornerRadius = UDim.new(0, 8)
MonsterAlertCorner.Parent = MonsterAlertFrame

local MonsterAlertStroke = Instance.new("UIStroke")
MonsterAlertStroke.Color = Color3.fromRGB(28, 28, 34)
MonsterAlertStroke.Thickness = 1
MonsterAlertStroke.Transparency = 0.2
MonsterAlertStroke.Parent = MonsterAlertFrame

local MonsterAlertAccent = Instance.new("Frame")
MonsterAlertAccent.Name = "Accent"
MonsterAlertAccent.Size = UDim2.new(0, 3, 1, -12)
MonsterAlertAccent.Position = UDim2.fromOffset(7, 6)
MonsterAlertAccent.BackgroundColor3 = Color3.fromRGB(144, 184, 112)
MonsterAlertAccent.BorderSizePixel = 0
MonsterAlertAccent.Parent = MonsterAlertFrame

local MonsterAlertAccentCorner = Instance.new("UICorner")
MonsterAlertAccentCorner.CornerRadius = UDim.new(1, 0)
MonsterAlertAccentCorner.Parent = MonsterAlertAccent

local MonsterAlertTitle = Instance.new("TextLabel")
MonsterAlertTitle.Size = UDim2.new(1, -30, 0, 20)
MonsterAlertTitle.Position = UDim2.fromOffset(18, 7)
MonsterAlertTitle.BackgroundTransparency = 1
MonsterAlertTitle.Text = "Monster alert"
MonsterAlertTitle.TextColor3 = Color3.fromRGB(235, 235, 239)
MonsterAlertTitle.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
MonsterAlertTitle.TextSize = 15
MonsterAlertTitle.TextXAlignment = Enum.TextXAlignment.Left
MonsterAlertTitle.Parent = MonsterAlertFrame

local MonsterAlertDistance = Instance.new("TextLabel")
MonsterAlertDistance.Size = UDim2.new(1, -30, 0, 18)
MonsterAlertDistance.Position = UDim2.fromOffset(18, 30)
MonsterAlertDistance.BackgroundTransparency = 1
MonsterAlertDistance.Text = "Running at you  ·  0 studs"
MonsterAlertDistance.TextColor3 = Color3.fromRGB(143, 143, 153)
MonsterAlertDistance.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
MonsterAlertDistance.TextSize = 13
MonsterAlertDistance.TextXAlignment = Enum.TextXAlignment.Left
MonsterAlertDistance.Parent = MonsterAlertFrame

local MonsterAlertSound
local alertSoundTemplate = ReplicatedStorage.Monster:FindFirstChild("Audio") and ReplicatedStorage.Monster.Audio:FindFirstChild("Alert")
if alertSoundTemplate and alertSoundTemplate:IsA("Sound") then
    MonsterAlertSound = alertSoundTemplate:Clone()
    MonsterAlertSound.Name = "BinHubMonsterAlertSound"
    MonsterAlertSound.Parent = SoundService
end

local oldKeybindOverlay = CoreGui:FindFirstChild("BinHubKeybindOverlay")
if oldKeybindOverlay then oldKeybindOverlay:Destroy() end

local KeybindOverlayGui = Instance.new("ScreenGui")
KeybindOverlayGui.Name = "BinHubKeybindOverlay"
KeybindOverlayGui.IgnoreGuiInset = true
KeybindOverlayGui.ResetOnSpawn = false
KeybindOverlayGui.DisplayOrder = 999998
KeybindOverlayGui.Parent = CoreGui

local KeybindPanel = Instance.new("Frame")
KeybindPanel.Name = "KeybindPanel"
KeybindPanel.Size = UDim2.fromOffset(224, 150)
KeybindPanel.Position = UDim2.fromOffset(State.KeybindPanelX, State.KeybindPanelY)
KeybindPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
KeybindPanel.BorderSizePixel = 0
KeybindPanel.Parent = KeybindOverlayGui

local KeybindPanelCorner = Instance.new("UICorner")
KeybindPanelCorner.CornerRadius = UDim.new(0, 8)
KeybindPanelCorner.Parent = KeybindPanel

local KeybindPanelStroke = Instance.new("UIStroke")
KeybindPanelStroke.Color = Color3.fromRGB(28, 28, 34)
KeybindPanelStroke.Thickness = 1
KeybindPanelStroke.Parent = KeybindPanel

local KeybindPanelTitle = Instance.new("TextLabel")
KeybindPanelTitle.Size = UDim2.new(1, -48, 0, 40)
KeybindPanelTitle.Position = UDim2.fromOffset(14, 0)
KeybindPanelTitle.BackgroundTransparency = 1
KeybindPanelTitle.Text = "Keybinds"
KeybindPanelTitle.TextColor3 = Color3.fromRGB(235, 235, 239)
KeybindPanelTitle.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
KeybindPanelTitle.TextSize = 16
KeybindPanelTitle.TextXAlignment = Enum.TextXAlignment.Left
KeybindPanelTitle.Parent = KeybindPanel

local KeybindHeaderDivider = Instance.new("Frame")
KeybindHeaderDivider.Size = UDim2.new(1, -24, 0, 1)
KeybindHeaderDivider.Position = UDim2.fromOffset(12, 40)
KeybindHeaderDivider.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
KeybindHeaderDivider.BorderSizePixel = 0
KeybindHeaderDivider.Parent = KeybindPanel

local KeybindDragArea = Instance.new("TextButton")
KeybindDragArea.Name = "DragArea"
KeybindDragArea.Size = UDim2.new(1, -46, 0, 40)
KeybindDragArea.BackgroundTransparency = 1
KeybindDragArea.Text = ""
KeybindDragArea.AutoButtonColor = false
KeybindDragArea.Parent = KeybindPanel

local KeybindPinButton = Instance.new("ImageButton")
KeybindPinButton.Name = "Pin"
KeybindPinButton.Size = UDim2.fromOffset(20, 20)
KeybindPinButton.Position = UDim2.new(1, -32, 0, 10)
KeybindPinButton.BackgroundTransparency = 1
KeybindPinButton.Image = "rbxassetid://10734922324"
KeybindPinButton.ImageColor3 = Color3.fromRGB(96, 96, 107)
KeybindPinButton.AutoButtonColor = false
KeybindPinButton.ZIndex = 4
KeybindPinButton.Parent = KeybindPanel

local function CreateKeybindPanelRow(order, labelText)
    local y = 46 + (order - 1) * 33
    local row = Instance.new("Frame")
    row.Name = labelText:gsub("%s+", "") .. "Row"
    row.Size = UDim2.new(1, 0, 0, 33)
    row.Position = UDim2.fromOffset(0, y)
    row.BackgroundTransparency = 1
    row.Parent = KeybindPanel

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -82, 0, 32)
    label.Position = UDim2.fromOffset(14, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(143, 143, 153)
    label.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local key = Instance.new("TextLabel")
    key.Name = labelText:gsub("%s+", "") .. "Key"
    key.Size = UDim2.fromOffset(58, 23)
    key.Position = UDim2.new(1, -72, 0, 4)
    key.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    key.TextColor3 = Color3.fromRGB(235, 235, 239)
    key.Font = Enum.Font.GothamBold
    key.TextSize = 11
    key.Parent = row
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = key

    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, -28, 0, 1)
    divider.Position = UDim2.new(0, 14, 1, -1)
    divider.BackgroundColor3 = Color3.fromRGB(29, 29, 35)
    divider.BackgroundTransparency = 0.25
    divider.BorderSizePixel = 0
    divider.Parent = row
    return key, row
end

local ToggleUIKeyLabel = CreateKeybindPanelRow(1, "Toggle UI")
local AimlockKeyLabel = CreateKeybindPanelRow(2, "Aimlock")
local MonsterEscapeKeyLabel = CreateKeybindPanelRow(3, "Monster escape")
local KeybindPinHovered = false
local KeybindDragging = false
local KeybindDragStart
local KeybindStartPosition
local KeybindInputChangedConnection
local KeybindInputEndedConnection
local KeybindMenuVisibilityConnection
local MonsterEscapeInputConnection
local MonsterEscapeBusy = false
local MonsterEscapeCharacter
local MonsterEscapeOriginalCFrame
local MonsterEscapeReturnCFrame
local MonsterEscapeBaseplate
local MonsterEscapeSkyCFrame
local MonsterEscapeKeyChangedAt = 0
local MonsterEscapeSettings = {
    ReturnDistance = 60,
    ReturnTweenTime = 1.25,
    SnapDistance = 18,
    StableTime = 1,
    PlatformHeight = 1500,
    RetryHeightStep = 2,
    MaxRetryHeight = 14,
    RetryTimeStep = 0.75,
    MaxTweenTime = 5,
}

local function MoveWholeCharacter(character, targetCFrame)
    if not character or not character.Parent then return false end
    character:PivotTo(targetCFrame)
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.AssemblyLinearVelocity = Vector3.zero
            descendant.AssemblyAngularVelocity = Vector3.zero
        end
    end
    return true
end

local function GetSaferReturnCFrame(character, originalCFrame)
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return originalCFrame end

    local nearestRoot
    local nearestDistance = math.huge
    for _, monster in ipairs(CollectionService:GetTagged("Monster")) do
        if monster:IsA("Model") and monster:IsDescendantOf(workspace) then
            local monsterRoot = monster:FindFirstChild("HumanoidRootPart") or monster.PrimaryPart
            local monsterHumanoid = monster:FindFirstChildOfClass("Humanoid")
            if monsterRoot and monsterHumanoid and monsterHumanoid.Health > 0 then
                local distance = (root.Position - monsterRoot.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestRoot = monsterRoot
                end
            end
        end
    end

    local away = Vector3.new(-1, 0, 0)
    if nearestRoot then
        local difference = root.Position - nearestRoot.Position
        local flatDifference = Vector3.new(difference.X, 0, difference.Z)
        if flatDifference.Magnitude > 0 then
            away = flatDifference.Unit
        end
    end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local filter = {character}
    local monsterFolder = workspace:FindFirstChild("_Monsters")
    if monsterFolder then table.insert(filter, monsterFolder) end
    raycastParams.FilterDescendantsInstances = filter
    raycastParams.IgnoreWater = false
    raycastParams.RespectCanCollide = true

    local pivotOffset = originalCFrame.Position - root.Position
    local angleOptions = {0, 25, -25, 50, -50, 75, -75}
    for _, angle in ipairs(angleOptions) do
        local direction = CFrame.Angles(0, math.rad(angle), 0):VectorToWorldSpace(away)
        local candidate = root.Position + direction * MonsterEscapeSettings.ReturnDistance
        local castOrigin = Vector3.new(candidate.X, root.Position.Y + 350, candidate.Z)
        local ground = workspace:Raycast(castOrigin, Vector3.new(0, -1200, 0), raycastParams)
        if ground and ground.Material ~= Enum.Material.Water and ground.Normal.Y >= 0.6 then
            local targetRootPosition = Vector3.new(
                candidate.X,
                ground.Position.Y + humanoid.HipHeight + root.Size.Y * 0.5 + 0.35,
                candidate.Z
            )
            local targetPivotPosition = targetRootPosition + pivotOffset
            return CFrame.new(targetPivotPosition) * originalCFrame.Rotation
        end
    end

    -- If streamed terrain is unavailable still return the requested distance
    -- instead of falling back to the original position
    return originalCFrame + away * MonsterEscapeSettings.ReturnDistance
end

local function UpdateKeybindPanel()
    ToggleUIKeyLabel.Text = Window.ToggleKey.Name
    AimlockKeyLabel.Text = State.AimlockKey.Name
    MonsterEscapeKeyLabel.Text = State.MonsterEscapeKey.Name
    KeybindPinButton.ImageColor3 = KeybindPinHovered and Color3.fromRGB(255, 255, 255)
        or (State.KeybindPanelPinned and Color3.fromRGB(144, 184, 112) or Color3.fromRGB(96, 96, 107))
    local menuVisible = Window.Gui and Window.Gui.Enabled
    local rows = {
        {ToggleUIKeyLabel.Parent, true},
        {AimlockKeyLabel.Parent, State.Aimlock == true},
        {MonsterEscapeKeyLabel.Parent, true},
    }
    local visibleRowCount = 0
    for _, rowInfo in ipairs(rows) do
        local row = rowInfo[1]
        local visible = rowInfo[2]
        row.Visible = visible
        if visible then
            row.Position = UDim2.fromOffset(0, 46 + visibleRowCount * 33)
            visibleRowCount += 1
        end
    end
    KeybindPanel.Size = UDim2.fromOffset(224, 51 + visibleRowCount * 33)
    KeybindPanel.Visible = State.KeybindPanelPinned or menuVisible
    KeybindPinButton.Visible = menuVisible
end

KeybindPinButton.MouseEnter:Connect(function()
    KeybindPinHovered = true
    UpdateKeybindPanel()
end)
KeybindPinButton.MouseLeave:Connect(function()
    KeybindPinHovered = false
    UpdateKeybindPanel()
end)
KeybindPinButton.MouseButton1Click:Connect(function()
    State.KeybindPanelPinned = not State.KeybindPanelPinned
    UpdateKeybindPanel()
end)

KeybindDragArea.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Window.Gui.Enabled then
        KeybindDragging = true
        KeybindDragStart = input.Position
        KeybindStartPosition = KeybindPanel.Position
    end
end)
KeybindInputEndedConnection = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then KeybindDragging = false end
end)
KeybindInputChangedConnection = UserInputService.InputChanged:Connect(function(input)
    if KeybindDragging and input.UserInputType == Enum.UserInputType.MouseMovement and Window.Gui.Enabled then
        local delta = input.Position - KeybindDragStart
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
        local x = math.clamp(KeybindStartPosition.X.Offset + delta.X, 0, math.max(0, viewport.X - KeybindPanel.AbsoluteSize.X))
        local y = math.clamp(KeybindStartPosition.Y.Offset + delta.Y, 0, math.max(0, viewport.Y - KeybindPanel.AbsoluteSize.Y))
        State.KeybindPanelX = math.floor(x + 0.5)
        State.KeybindPanelY = math.floor(y + 0.5)
        KeybindPanel.Position = UDim2.fromOffset(State.KeybindPanelX, State.KeybindPanelY)
    end
end)
KeybindMenuVisibilityConnection = Window.Gui:GetPropertyChangedSignal("Enabled"):Connect(UpdateKeybindPanel)

local function FinishMonsterEscape()
    local character = MonsterEscapeCharacter
    local originalCFrame = MonsterEscapeOriginalCFrame
    local returnCFrame = MonsterEscapeReturnCFrame
    local baseplate = MonsterEscapeBaseplate
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if character and character == LocalPlayer.Character and root and originalCFrame and returnCFrame then
        local stable = false
        local retryCount = 0
        while not stable and character == LocalPlayer.Character and root.Parent do
            local retryHeight = math.min(retryCount * MonsterEscapeSettings.RetryHeightStep, MonsterEscapeSettings.MaxRetryHeight)
            local retryCFrame = returnCFrame + Vector3.new(0, retryHeight, 0)
            local tweenTime = math.min(
                MonsterEscapeSettings.ReturnTweenTime + retryCount * MonsterEscapeSettings.RetryTimeStep,
                MonsterEscapeSettings.MaxTweenTime
            )
            local tweenStart = character:GetPivot()
            local tweenStartedAt = os.clock()
            repeat
                local alpha = math.clamp((os.clock() - tweenStartedAt) / tweenTime, 0, 1)
                local easedAlpha = 1 - (1 - alpha) * (1 - alpha)
                MoveWholeCharacter(character, tweenStart:Lerp(retryCFrame, easedAlpha))
                RunService.Heartbeat:Wait()
            until os.clock() - tweenStartedAt >= tweenTime
                or character ~= LocalPlayer.Character
                or not root.Parent

            if character ~= LocalPlayer.Character or not root.Parent then break end
            MoveWholeCharacter(character, retryCFrame)

            if baseplate then
                baseplate:Destroy()
                baseplate = nil
                MonsterEscapeBaseplate = nil
            end

            local stableStartedAt = os.clock()
            stable = true
            repeat
                RunService.Heartbeat:Wait()
                local offset = character:GetPivot().Position - retryCFrame.Position
                local horizontalDistance = Vector3.new(offset.X, 0, offset.Z).Magnitude
                if horizontalDistance >= MonsterEscapeSettings.SnapDistance or math.abs(offset.Y) >= MonsterEscapeSettings.SnapDistance then
                    stable = false
                    retryCount += 1
                    break
                end
            until os.clock() - stableStartedAt >= MonsterEscapeSettings.StableTime
                or character ~= LocalPlayer.Character
                or not root.Parent
        end
    end
    if baseplate then baseplate:Destroy() end
    MonsterEscapeCharacter = nil
    MonsterEscapeOriginalCFrame = nil
    MonsterEscapeReturnCFrame = nil
    MonsterEscapeBaseplate = nil
    MonsterEscapeSkyCFrame = nil
    MonsterEscapeBusy = false
end

local function StartMonsterEscape()
    if MonsterEscapeBusy then return end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not character or not humanoid or humanoid.Health <= 0 or not root then return end

    MonsterEscapeBusy = true
    MonsterEscapeCharacter = character
    local originalCFrame = character:GetPivot()
    MonsterEscapeOriginalCFrame = originalCFrame
    MonsterEscapeReturnCFrame = GetSaferReturnCFrame(character, originalCFrame)
    humanoid.Sit = false

    local oldBaseplate = workspace:FindFirstChild("BinHubMonsterEscapeBaseplate")
    if oldBaseplate then oldBaseplate:Destroy() end
    -- Stay below common sky kill boundaries while moving far enough sideways
    -- for the server monster AI to lose its current target
    local skyCFrame = originalCFrame + Vector3.new(-12000, MonsterEscapeSettings.PlatformHeight, 0)
    MonsterEscapeSkyCFrame = skyCFrame
    MonsterEscapeBaseplate = Instance.new("Part")
    MonsterEscapeBaseplate.Name = "BinHubMonsterEscapeBaseplate"
    MonsterEscapeBaseplate.Size = Vector3.new(72, 1, 72)
    MonsterEscapeBaseplate.CFrame = CFrame.new(skyCFrame.Position - Vector3.new(0, 3.5, 0))
    MonsterEscapeBaseplate.Anchored = true
    MonsterEscapeBaseplate.CanCollide = true
    MonsterEscapeBaseplate.Color = Color3.fromRGB(32, 32, 38)
    MonsterEscapeBaseplate.Material = Enum.Material.Slate
    MonsterEscapeBaseplate.Parent = workspace

    MoveWholeCharacter(character, skyCFrame)
    task.spawn(function()
        local started = os.clock()
        while MonsterEscapeBusy and MonsterEscapeCharacter == character and os.clock() - started < 2 do
            if character ~= LocalPlayer.Character or not root.Parent then break end
            MoveWholeCharacter(character, skyCFrame)
            RunService.Heartbeat:Wait()
        end
        if MonsterEscapeBusy and MonsterEscapeCharacter == character then FinishMonsterEscape() end
    end)
end

MonsterEscapeInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == State.MonsterEscapeKey and os.clock() - MonsterEscapeKeyChangedAt > 0.35 then
        StartMonsterEscape()
    end
end)
UpdateKeybindPanel()

local function ApplyGunMods()
    local rpm = math.clamp(tonumber(State.FireRateRPM) or 600, 100, 1200)
    local cooldown = 60 / math.max(1, rpm)
    for name, item in pairs(ItemConfiguration.Items or {}) do
        if type(item) == "table" and item.Class == "Gun" then
            local orig = OriginalWeaponConfigs[name]
            if not orig then continue end
            
            item.UseCooldown = orig.UseCooldown
            item.UseDuration = orig.UseDuration
            item.Automatic = orig.Automatic
            item.BurstDelta = orig.BurstDelta
            item.BurstCooldown = orig.BurstCooldown
            item.ReloadDuration = orig.ReloadDuration
            item.ReloadVisualDelay = orig.ReloadVisualDelay
            item.ReloadVisualDuration = orig.ReloadVisualDuration
            
            if State.InstantReload then
                item.ReloadDuration = 0
                item.ReloadVisualDelay = 0
                item.ReloadVisualDuration = 0
            end
            
            if State.AutoWeapons then
                item.Automatic = true
            end
            
            if State.FastFireRate then
                item.UseCooldown = math.min(tonumber(orig.UseCooldown) or cooldown, cooldown)
                item.UseDuration = math.min(tonumber(orig.UseDuration) or cooldown, cooldown)
                if orig.BurstDelta ~= nil then
                    item.BurstDelta = math.min(tonumber(orig.BurstDelta) or cooldown, cooldown)
                end
                if orig.BurstCooldown ~= nil then
                    item.BurstCooldown = math.min(tonumber(orig.BurstCooldown) or cooldown, cooldown)
                end
            end
        end
    end
end

local function GetEquippedGun()
    local character = LocalPlayer.Character
    local values = character and character:FindFirstChild("Values")
    local itemValue = values and values:FindFirstChild("Item")
    local item = itemValue and itemValue.Value
    if not item then return nil end

    local itemData = ItemConfiguration.Items and ItemConfiguration.Items[item.Name]
    if not itemData or itemData.Class ~= "Gun" then return nil end
    return item, item:FindFirstChild("Values")
end

CharacterUtilities.CanUseItem = function(self, character, itemName)
    if State.FastFireRate or State.InstantReload then
        local itemData = ItemConfiguration.Items and ItemConfiguration.Items[itemName]
        local values = character and character:FindFirstChild("Values")
        local equippedValue = values and values:FindFirstChild("Item")
        local equipped = equippedValue and equippedValue.Value
        if itemData and itemData.Class == "Gun" and equipped and equipped.Parent and equipped.Name == itemName then
            return true
        end
    end
    return OriginalCanUseItem(self, character, itemName)
end

UISettings.AutoWeapons = GunsModSection:CreateCheckbox("Automatic Weapons", false, function(value)
    State.AutoWeapons = value
    ApplyGunMods()
end)

UISettings.InstantReload = GunsModSection:CreateCheckbox("Instant Reload", false, function(value)
    State.InstantReload = value
    ApplyGunMods()
end)

UISettings.AutoReload = GunsModSection:CreateCheckbox("Auto Reload", false, function(value)
    State.AutoReload = value
end)

task.spawn(function()
    local lastReloadRequest = 0
    while not Unloaded do
        task.wait()
        local itemInst, gunValues = GetEquippedGun()
        if gunValues then
            if State.FastFireRate then
                local cooldownValue = gunValues:FindFirstChild("Cooldown")
                local usingValue = gunValues:FindFirstChild("Using")
                if cooldownValue and cooldownValue:IsA("BoolValue") and cooldownValue.Value then cooldownValue.Value = false end
                if usingValue and usingValue:IsA("BoolValue") and usingValue.Value then usingValue.Value = false end
            end
            if State.InstantReload then
                local reloadingValue = gunValues:FindFirstChild("Reloading")
                if reloadingValue and reloadingValue:IsA("BoolValue") and reloadingValue.Value then reloadingValue.Value = false end
            end
        end

        if State.AutoReload then
            local magazine = gunValues and gunValues:FindFirstChild("Magazine")
            if itemInst and magazine and tonumber(magazine.Value) and magazine.Value <= 0 and os.clock() - lastReloadRequest >= 0.25 then
                lastReloadRequest = os.clock()
                RequestCharacterAction:FireServer("Reload")
                if State.InstantReload then
                    local reloadingValue = gunValues:FindFirstChild("Reloading")
                    if reloadingValue and reloadingValue:IsA("BoolValue") then reloadingValue.Value = false end
                end
            end
        end
    end
end)

UISettings.FastFireRate = GunsModSection:CreateCheckbox("Fast Fire Rate", false, function(value)
    State.FastFireRate = value
    ApplyGunMods()
end)

UISettings.FireRateRPM = GunsModSection:CreateSlider("Fire Rate (RPM)", 100, 1200, 600, function(value)
    State.FireRateRPM = tostring(value)
    if State.FastFireRate then ApplyGunMods() end
end, 10)

local PROMPT_DURATION_ATTRIBUTE = "BinHubOriginalHoldDuration"
local PromptAddedConnection

local function ApplyInstantPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if prompt:GetAttribute(PROMPT_DURATION_ATTRIBUTE) == nil then
        prompt:SetAttribute(PROMPT_DURATION_ATTRIBUTE, prompt.HoldDuration)
    end
    prompt.HoldDuration = 0
end

local function SetInstantProximityPrompts(enabled)
    State.InstantProximityPrompts = enabled
    if enabled then
        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then ApplyInstantPrompt(descendant) end
        end
    else
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local duration = prompt:GetAttribute(PROMPT_DURATION_ATTRIBUTE)
                if typeof(duration) == "number" then
                    prompt.HoldDuration = duration
                    prompt:SetAttribute(PROMPT_DURATION_ATTRIBUTE, nil)
                end
            end
        end
    end
end

PromptAddedConnection = workspace.DescendantAdded:Connect(function(descendant)
    if State.InstantProximityPrompts and descendant:IsA("ProximityPrompt") then
        ApplyInstantPrompt(descendant)
    end
end)

UISettings.InstantProximityPrompts = MiscSettingsSection:CreateCheckbox("Instant Proximity Prompts", false, function(value)
    SetInstantProximityPrompts(value)
end)

UISettings.MonsterEscapeKey = MiscSettingsSection:CreateKeybind("Monster Escape Key", State.MonsterEscapeKey, function(key)
    State.MonsterEscapeKey = key
    MonsterEscapeKeyChangedAt = os.clock()
    UpdateKeybindPanel()
end)
for _, descendant in ipairs(Window.Gui:GetDescendants()) do
    if descendant:IsA("TextLabel") and descendant.Text == "Monster Escape Key" then
        descendant.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
        descendant.TextSize = 15
        descendant.Size = UDim2.new(1, -88, 1, 0)
        descendant.ClipsDescendants = true
        local bindButton = descendant.Parent and descendant.Parent:FindFirstChildOfClass("TextButton")
        if bindButton then
            bindButton.Size = UDim2.fromOffset(56, 24)
            bindButton.Position = UDim2.new(1, -68, 0.5, -12)
        end
    end
end

UISettings.MonsterAngerAlert = MiscSettingsSection:CreateCheckbox("Monster Anger Alert", false, function(value)
    State.MonsterAngerAlert = value
    if not value then MonsterAlertGui.Enabled = false end
end)

UISettings.SilentMode = MiscSettingsSection:CreateCheckbox("Silent Mode", false, function(value)
    ApplySilentMode(value)
    if not SilentRuntime.SuppressNotification then
        Notify(value
            and "Silent mode mutes your character sounds monsters can still see you"
            or "Silent mode is off")
    end
end)
SilentRuntime.Control = UISettings.SilentMode

UISettings.MonsterESP = MonsterESPSection:CreateCheckbox("Enable ESP", false, function(value)
    State.MonsterESP = value
end)
UISettings.MonsterNametag = MonsterESPSection:CreateColorCheckbox("Nametag", State.MonsterNametagColor, false, function(color)
    State.MonsterNametagColor = color
end, function(value)
    State.MonsterNametag = value
end)
UISettings.MonsterBox = MonsterESPSection:CreateColorCheckbox("Box", State.MonsterBoxColor, false, function(color)
    State.MonsterBoxColor = color
end, function(value)
    State.MonsterBox = value
end)
UISettings.MonsterHealthbar = MonsterESPSection:CreateColorCheckbox("Health Bar", State.MonsterHealthbarColor, false, function(color)
    State.MonsterHealthbarColor = color
end, function(value)
    State.MonsterHealthbar = value
end)
UISettings.MonsterSkeleton = MonsterESPSection:CreateColorCheckbox("Skeleton", State.MonsterSkeletonColor, false, function(color)
    State.MonsterSkeletonColor = color
end, function(value)
    State.MonsterSkeleton = value
end)

UISettings.PlayerESP = PlayerESPSection:CreateCheckbox("Enable ESP", false, function(value)
    State.PlayerESP = value
end)
UISettings.PlayerNametag = PlayerESPSection:CreateColorCheckbox("Nametag", State.PlayerNametagColor, false, function(color)
    State.PlayerNametagColor = color
end, function(value)
    State.PlayerNametag = value
end)
UISettings.PlayerBox = PlayerESPSection:CreateColorCheckbox("Box", State.PlayerBoxColor, false, function(color)
    State.PlayerBoxColor = color
end, function(value)
    State.PlayerBox = value
end)
UISettings.PlayerHealthbar = PlayerESPSection:CreateColorCheckbox("Health Bar", State.PlayerHealthbarColor, false, function(color)
    State.PlayerHealthbarColor = color
end, function(value)
    State.PlayerHealthbar = value
end)
UISettings.PlayerSkeleton = PlayerESPSection:CreateColorCheckbox("Skeleton", State.PlayerSkeletonColor, false, function(color)
    State.PlayerSkeletonColor = color
end, function(value)
    State.PlayerSkeleton = value
end)

UISettings.ItemESP = ItemESPSection:CreateCheckbox("Enable ESP", false, function(value)
    State.ItemESP = value
end)
UISettings.ItemNametag = ItemESPSection:CreateColorCheckbox("Nametag", State.ItemNametagColor, false, function(color)
    State.ItemNametagColor = color
end, function(value)
    State.ItemNametag = value
end)
UISettings.ItemBox = ItemESPSection:CreateColorCheckbox("Box", State.ItemBoxColor, false, function(color)
    State.ItemBoxColor = color
end, function(value)
    State.ItemBox = value
end)

local function RefreshAimCandidates()
    table.clear(AimCandidates)
    local seen = {}
    local function AddModel(model, player)
        if not model or seen[model] or model == LocalPlayer.Character then return end
        seen[model] = true
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        local targetPart = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
        if humanoid and humanoid.Health > 0 and targetPart and targetPart:IsA("BasePart") then
            table.insert(AimCandidates, {
                Humanoid = humanoid,
                Model = model,
                PlayerName = player and player.Name or nil,
                IsMonster = player == nil
            })
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then AddModel(player.Character, player) end
    end
    for _, monster in ipairs(CollectionService:GetTagged("Monster")) do
        if monster:IsA("Model") and monster:IsDescendantOf(workspace) then
            AddModel(monster, nil)
        end
    end
end

local function GetCandidatePart(candidate, mode)
    local model = candidate.Model
    if not model then return nil end

    local preferredPart = "Head"
    if mode == "SilentAim" then
        preferredPart = candidate.PlayerName and State.SilentAimPlayerTargetPart or State.SilentAimMonsterTargetPart
    end

    local part = model:FindFirstChild(preferredPart, true)
    if part and part:IsA("BasePart") then return part end

    -- Cross-rig fallbacks keep R6, R15, and the game's custom monster rig valid.
    for _, fallbackName in ipairs({"Head", "UpperTorso", "Torso", "HumanoidRootPart", "Mesh"}) do
        part = model:FindFirstChild(fallbackName)
        if part and part:IsA("BasePart") then return part end
    end
    return model.PrimaryPart
end

local function IsPlayerIgnored(ignoredPlayers, playerName)
    if not playerName then return false end
    for _, ignoredName in ipairs(ignoredPlayers) do
        if ignoredName == playerName then return true end
    end
    return false
end

local function GetAimTarget(mode)
    Camera = workspace.CurrentCamera
    if not Camera then return nil end

    local aimCenter
    if mode == "SilentAim" or State.AimlockFOVFollowCursor then
        aimCenter = UserInputService:GetMouseLocation()
    else
        aimCenter = Camera.ViewportSize / 2
    end
    local closestPart
    local closestDistance = math.huge
    local useFOV
    local maximumDistance
    local ignoredPlayers
    if mode == "SilentAim" then
        useFOV = State.SilentAimUseFOV
        maximumDistance = State.SilentAimFOV
        ignoredPlayers = State.SilentAimIgnored
    else
        useFOV = State.AimlockUseFOV
        maximumDistance = State.AimlockFOV
        ignoredPlayers = State.AimlockIgnored
    end

    for index = #AimCandidates, 1, -1 do
        local candidate = AimCandidates[index]
        local candidatePart = GetCandidatePart(candidate, mode)
        if not candidate.Humanoid.Parent or candidate.Humanoid.Health <= 0 or not candidate.Model.Parent or not candidatePart then
            table.remove(AimCandidates, index)
        elseif not IsPlayerIgnored(ignoredPlayers, candidate.PlayerName) then
            local screenPosition, onScreen = Camera:WorldToViewportPoint(candidatePart.Position)
            if onScreen and screenPosition.Z > 0 then
                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - aimCenter).Magnitude
                if (not useFOV or distance <= maximumDistance) and distance < closestDistance then
                    closestDistance = distance
                    closestPart = candidatePart
                end
            end
        end
    end

    return closestPart
end

local AimRuntime = getgenv().AQuietPlaceDeadzoneAimRuntime or {}
getgenv().AQuietPlaceDeadzoneAimRuntime = AimRuntime
AimRuntime.State = State
AimRuntime.GetTarget = GetAimTarget
AimRuntime.RefreshTargets = RefreshAimCandidates
AimRuntime.SilentAimEnabled = false

local function IsGunEquipped()
    local character = LocalPlayer.Character
    local values = character and character:FindFirstChild("Values")
    local itemValue = values and values:FindFirstChild("Item")
    local item = itemValue and itemValue.Value
    local itemData = item and ItemConfiguration.Items[item.Name]
    return itemData and itemData.Class == "Gun" or false
end

AimRuntime.IsGunEquipped = IsGunEquipped

if AimRuntime.HookVersion ~= 8 and hookmetamethod and newcclosure and getnamecallmethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local runtime = getgenv().AQuietPlaceDeadzoneAimRuntime
        local arguments = table.pack(...)
        local state = runtime and runtime.State

        if self == VoicePing and method == "FireServer" and SilentRuntime.Enabled then
            SilentRuntime.LastBlockedVoicePing = os.clock()
            return nil
        end

        -- Never perform another Roblox namecall from inside this hook. A nested
        -- WorldToViewportPoint/GetFullName call replaces the active namecall method
        -- and causes FireServer to run that method on the RemoteEvent instead.
        local isUseItem = self == RequestCharacterAction
            and method == "FireServer"
            and arguments[1] == "UseItem"
            
        local actionData = isUseItem and arguments[2] or nil
        local target = runtime and runtime.SilentAimTarget or nil
        local redirected = false
        local originalPosition
        local redirectedPosition

        if isUseItem and (not checkcaller or not checkcaller()) and runtime.SilentAimEnabled
            and type(actionData) == "table" and actionData.MousePosition ~= nil
            and target and target.Parent then
            local redirectedData = {}
            for key, value in pairs(actionData) do
                redirectedData[key] = value
            end
            originalPosition = actionData.MousePosition
            redirectedPosition = target.Position
            redirectedData.MousePosition = redirectedPosition
            arguments[2] = redirectedData
            redirected = true
        end

        -- Disable previously installed hook versions while this call passes down
        -- the stack. Those old hooks performed unsafe nested namecalls.
        local muteLegacyHooks = isUseItem or (self == workspace and method == "Raycast")
        local silentAimEnabled = runtime and runtime.SilentAimEnabled
        local silentAimState = state and state.SilentAim
        if muteLegacyHooks then
            if runtime then runtime.SilentAimEnabled = false end
            if state then state.SilentAim = false end
        end
        local results = table.pack(oldNamecall(self, unpack(arguments, 1, arguments.n)))
        if muteLegacyHooks then
            if runtime then runtime.SilentAimEnabled = silentAimEnabled end
            if state then state.SilentAim = silentAimState end
        end

        if isUseItem and runtime then
            runtime.LastUseItemCall = {
                Enabled = silentAimEnabled == true,
                HasMousePosition = type(actionData) == "table" and actionData.MousePosition ~= nil,
                Redirected = redirected,
                Time = os.clock()
            }
            if redirected then
                runtime.LastSilentAimRedirect = {
                    Target = runtime.SilentAimTargetName or target.Name,
                    OriginalPosition = originalPosition,
                    RedirectedPosition = redirectedPosition,
                    Time = os.clock()
                }
            end
        end
        return unpack(results, 1, results.n)
    end))
    AimRuntime.Hooked = true
    AimRuntime.HookVersion = 8
end

local function GetPlayerOptions()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    table.sort(names)
    return names
end

UISettings.Aimlock = OPAimSection:CreateCheckbox("Aimlock", false, function(value)
    State.Aimlock = value
    if value then RefreshAimCandidates() end
    UpdateKeybindPanel()
end)

UISettings.AimlockKey = OPAimSection:CreateKeybind("Aimlock Key", Enum.KeyCode.Q, function(key)
    State.AimlockKey = key
    UpdateKeybindPanel()
end)

UISettings.AimlockUseFOV = OPAimSection:CreateColorCheckbox("Enable FOV", State.AimlockFOVColor, false, function(color)
    State.AimlockFOVColor = color
end, function(value)
    State.AimlockUseFOV = value
end)

UISettings.AimlockFOV = OPAimSection:CreateSlider("Aimlock FOV", 25, 800, 200, function(value)
    State.AimlockFOV = value
end)

UISettings.AimlockFOVFollowCursor = OPAimSection:CreateCheckbox("FOV Follow Cursor", false, function(value)
    State.AimlockFOVFollowCursor = value
end)

UISettings.AimlockIgnored = OPAimSection:CreateDropdown("Ignore Players", GetPlayerOptions(), "None", function(values)
    State.AimlockIgnored = type(values) == "table" and table.clone(values)
        or (values and values ~= "None" and {tostring(values)} or {})
end, true)

UISettings.SilentAim = SilentAimSection:CreateCheckbox("Silent Aim", false, function(value)
    State.SilentAim = value
    AimRuntime.SilentAimEnabled = value
    if value then
        RefreshAimCandidates()
    else
        AimRuntime.SilentAimTarget = nil
        AimRuntime.SilentAimTargetName = nil
    end
end)

UISettings.SilentAimUseFOV = SilentAimSection:CreateColorCheckbox("Enable FOV", State.SilentAimFOVColor, false, function(color)
    State.SilentAimFOVColor = color
end, function(value)
    State.SilentAimUseFOV = value
end)

UISettings.SilentAimFOV = SilentAimSection:CreateSlider("Silent Aim FOV", 25, 800, 200, function(value)
    State.SilentAimFOV = value
end)

UISettings.SilentAimPlayerTargetPart = SilentAimSection:CreateDropdown("Player Target Part", PlayerTargetPartOptions, State.SilentAimPlayerTargetPart, function(value)
    State.SilentAimPlayerTargetPart = value
end)

UISettings.SilentAimMonsterTargetPart = SilentAimSection:CreateDropdown("Monster Target Part", MonsterTargetPartOptions, State.SilentAimMonsterTargetPart, function(value)
    State.SilentAimMonsterTargetPart = value
end)

UISettings.SilentAimIgnored = SilentAimSection:CreateDropdown("Ignore Players", GetPlayerOptions(), "None", function(values)
    State.SilentAimIgnored = type(values) == "table" and table.clone(values)
        or (values and values ~= "None" and {tostring(values)} or {})
end, true)

local function GetTargetViewerModel(viewerType)
    if viewerType == "Monster" then
        for _, tagged in ipairs(CollectionService:GetTagged("Monster")) do
            if tagged:IsA("Model") and tagged:IsDescendantOf(workspace) then
                return tagged
            end
        end
    else
        return LocalPlayer.Character
    end
    return nil
end

local TargetModelViewer
local function RefreshTargetModelViewer()
    if not TargetModelViewer then return end
    TargetModelViewer:SetPartFilter(function(part)
        if State.TargetViewerType == "Player" then
            return not string.find(string.lower(part.Name), "hitbox", 1, true)
        end
        return true
    end)
    local model = GetTargetViewerModel(State.TargetViewerType)
    if not TargetModelViewer:SetModel(model) then
        Notify("No " .. string.lower(State.TargetViewerType) .. " model is currently available.")
        return
    end
    local selectedPart = State.TargetViewerType == "Monster"
        and State.SilentAimMonsterTargetPart
        or State.SilentAimPlayerTargetPart
    TargetModelViewer:SetSelectedPart(selectedPart)
end

UISettings.TargetViewerType = ModelViewerSection:CreateDropdown("View Model", {"Monster", "Player"}, State.TargetViewerType, function(value)
    State.TargetViewerType = value
    RefreshTargetModelViewer()
end)

TargetModelViewer = ModelViewerSection:CreateModelViewer("Body Part Inspector", GetTargetViewerModel(State.TargetViewerType), function(partName)
    local options
    local dropdown
    if State.TargetViewerType == "Monster" then
        options = MonsterTargetPartOptions
        dropdown = UISettings.SilentAimMonsterTargetPart
    else
        options = PlayerTargetPartOptions
        dropdown = UISettings.SilentAimPlayerTargetPart
    end

    if not table.find(options, partName) then
        table.insert(options, partName)
        table.sort(options)
        dropdown:UpdateOptions(options)
    end
    dropdown:SetValue(partName)
    Notify(State.TargetViewerType .. " Silent Aim target set to " .. partName .. ".")
end)

ModelViewerSection:CreateButton("Refresh Model", RefreshTargetModelViewer)
RefreshTargetModelViewer()

local function CreateFOVCircle(color)
    if not Drawing or not Drawing.new then return nil end
    local circle = Drawing.new("Circle")
    circle.Color = color
    circle.Thickness = 1.5
    circle.NumSides = 72
    circle.Filled = false
    circle.Transparency = 1
    circle.Visible = false
    return circle
end

local AimlockFOVCircle = CreateFOVCircle(State.AimlockFOVColor)
local SilentAimFOVCircle = CreateFOVCircle(State.SilentAimFOVColor)
AimRuntime.AimlockFOVCircle = AimlockFOVCircle
AimRuntime.SilentAimFOVCircle = SilentAimFOVCircle

local AimInputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == State.AimlockKey then
        State.AimlockKeyHeld = true
    end
end)

local AimInputEnded = UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == State.AimlockKey then
        State.AimlockKeyHeld = false
    end
end)

local ESPRecords = {
    Monster = {},
    Player = {},
    Item = {}
}
getgenv().AQuietPlaceDeadzoneESPRuntime = {
    Records = ESPRecords,
    State = State
}

local SkeletonLinks = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"}
}

local function NewDrawing(kind)
    if not Drawing or not Drawing.new then return nil end
    local drawing = Drawing.new(kind)
    drawing.Visible = false
    return drawing
end

local function HideESPRecord(record)
    if record.Box then record.Box.Visible = false end
    if record.Nametag then record.Nametag.Visible = false end
    if record.HealthbarBackground then record.HealthbarBackground.Visible = false end
    if record.Healthbar then record.Healthbar.Visible = false end
    for _, line in ipairs(record.Lines) do
        line.Visible = false
    end
end

local function RemoveESPRecord(record)
    if record.Box then record.Box:Remove() end
    if record.Nametag then record.Nametag:Remove() end
    if record.HealthbarBackground then record.HealthbarBackground:Remove() end
    if record.Healthbar then record.Healthbar:Remove() end
    for _, line in ipairs(record.Lines) do
        line:Remove()
    end
end

local function CreateESPRecord(object, displayName, skeletonAllowed)
    local box = NewDrawing("Square")
    if box then
        box.Filled = false
        box.Thickness = 1.5
        box.Transparency = 1
    end

    local nametag = NewDrawing("Text")
    if nametag then
        nametag.Center = true
        nametag.Outline = true
        nametag.Size = 14
        nametag.Transparency = 1
    end

    local healthbarBackground
    local healthbar
    if object:IsA("Model") then
        healthbarBackground = NewDrawing("Square")
        if healthbarBackground then
            healthbarBackground.Filled = true
            healthbarBackground.Color = Color3.fromRGB(12, 12, 14)
            healthbarBackground.Transparency = 0.8
        end
        healthbar = NewDrawing("Square")
        if healthbar then
            healthbar.Filled = true
            healthbar.Transparency = 1
        end
    end

    local lines = {}
    if skeletonAllowed then
        for _ = 1, #SkeletonLinks do
            local line = NewDrawing("Line")
            if line then
                line.Thickness = 1.5
                line.Transparency = 1
                table.insert(lines, line)
            end
        end
    end

    return {
        Object = object,
        DisplayName = displayName,
        Box = box,
        Nametag = nametag,
        HealthbarBackground = healthbarBackground,
        Healthbar = healthbar,
        Lines = lines,
        SkeletonAllowed = skeletonAllowed,
        Humanoid = object:IsA("Model") and object:FindFirstChildOfClass("Humanoid") or nil
    }
end

local function GetESPBounds(object)
    Camera = workspace.CurrentCamera
    if not Camera then return nil end

    local cframe
    local size
    if object:IsA("Model") then
        local success
        success, cframe, size = pcall(function()
            return object:GetBoundingBox()
        end)
        if not success then return nil end
    elseif object:IsA("BasePart") then
        cframe = object.CFrame
        size = object.Size
    else
        return nil
    end

    local half = size / 2
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local worldPoint = cframe:PointToWorldSpace(Vector3.new(half.X * x, half.Y * y, half.Z * z))
                local screenPoint = Camera:WorldToViewportPoint(worldPoint)
                if screenPoint.Z <= 0 then return nil end
                minX = math.min(minX, screenPoint.X)
                minY = math.min(minY, screenPoint.Y)
                maxX = math.max(maxX, screenPoint.X)
                maxY = math.max(maxY, screenPoint.Y)
            end
        end
    end

    return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
end

local function GetSkeletonSegments(model)
    local segments = {}
    local foundBones = false

    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("Bone") then
            foundBones = true
            local parent = object.Parent
            if parent and parent:IsA("Bone") then
                table.insert(segments, {parent.WorldPosition, object.WorldPosition})
            elseif parent and parent:IsA("BasePart") then
                table.insert(segments, {parent.Position, object.WorldPosition})
            end
        end
    end

    if foundBones and #segments > 0 then
        return segments
    end

    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("Motor6D") and object.Part0 and object.Part1 then
            table.insert(segments, {object.Part0.Position, object.Part1.Position})
        end
    end

    if #segments > 0 then
        return segments
    end

    for _, link in ipairs(SkeletonLinks) do
        local fromPart = model:FindFirstChild(link[1])
        local toPart = model:FindFirstChild(link[2])
        if fromPart and toPart and fromPart:IsA("BasePart") and toPart:IsA("BasePart") then
            table.insert(segments, {fromPart.Position, toPart.Position})
        end
    end

    return segments
end

getgenv().AQuietPlaceDeadzoneESPRuntime.GetSkeletonSegments = GetSkeletonSegments

local function BuildSkeletonSources(model)
    local descendants = model:GetDescendants()
    local sources = {}
    for _, object in ipairs(descendants) do
        if object:IsA("Bone") then
            local parent = object.Parent
            if parent and (parent:IsA("Bone") or parent:IsA("BasePart")) then
                table.insert(sources, {parent, object})
            end
        end
    end
    if #sources > 0 then return sources end

    for _, object in ipairs(descendants) do
        if object:IsA("Motor6D") and object.Part0 and object.Part1 then
            table.insert(sources, {object.Part0, object.Part1})
        end
    end
    if #sources > 0 then return sources end

    for _, link in ipairs(SkeletonLinks) do
        local fromPart = model:FindFirstChild(link[1])
        local toPart = model:FindFirstChild(link[2])
        if fromPart and toPart and fromPart:IsA("BasePart") and toPart:IsA("BasePart") then
            table.insert(sources, {fromPart, toPart})
        end
    end
    return sources
end

local function GetSkeletonPoint(object)
    if object:IsA("Bone") then return object.WorldPosition end
    if object:IsA("BasePart") then return object.Position end
    return nil
end

local function UpdateSkeleton(record, enabled, color)
    if not enabled or not record.SkeletonAllowed or not record.Object:IsA("Model") then
        for _, line in ipairs(record.Lines) do line.Visible = false end
        return
    end

    record.SkeletonSources = record.SkeletonSources or BuildSkeletonSources(record.Object)
    local sources = record.SkeletonSources
    while #record.Lines < #sources do
        local line = NewDrawing("Line")
        if not line then break end
        line.Thickness = 1.5
        line.Transparency = 1
        table.insert(record.Lines, line)
    end

    for index, source in ipairs(sources) do
        local line = record.Lines[index]
        local fromPosition = source[1].Parent and GetSkeletonPoint(source[1]) or nil
        local toPosition = source[2].Parent and GetSkeletonPoint(source[2]) or nil
        if line and fromPosition and toPosition then
            local fromPoint, fromVisible = Camera:WorldToViewportPoint(fromPosition)
            local toPoint, toVisible = Camera:WorldToViewportPoint(toPosition)
            line.Visible = fromVisible and toVisible and fromPoint.Z > 0 and toPoint.Z > 0
            if line.Visible then
                line.From = Vector2.new(fromPoint.X, fromPoint.Y)
                line.To = Vector2.new(toPoint.X, toPoint.Y)
                line.Color = color
            end
        elseif line then line.Visible = false end
    end

    for index = #sources + 1, #record.Lines do
        record.Lines[index].Visible = false
    end
end

local function GetESPSettings(group)
    if group == "Monster" then
        return State.MonsterESP, State.MonsterNametag, State.MonsterNametagColor, State.MonsterBox, State.MonsterBoxColor, State.MonsterSkeleton, State.MonsterSkeletonColor, State.MonsterHealthbar, State.MonsterHealthbarColor
    elseif group == "Player" then
        return State.PlayerESP, State.PlayerNametag, State.PlayerNametagColor, State.PlayerBox, State.PlayerBoxColor, State.PlayerSkeleton, State.PlayerSkeletonColor, State.PlayerHealthbar, State.PlayerHealthbarColor
    end
    return State.ItemESP, State.ItemNametag, State.ItemNametagColor, State.ItemBox, State.ItemBoxColor, false, Color3.new(1, 1, 1), false, Color3.new(1, 1, 1)
end

local ESPGroupActive = {Monster = false, Player = false, Item = false}
local function UpdateESPGroup(group)
    local enabled, nametagEnabled, nametagColor, boxEnabled, boxColor, skeletonEnabled, skeletonColor, healthbarEnabled, healthbarColor = GetESPSettings(group)
    if not enabled then
        if ESPGroupActive[group] then
            for _, record in pairs(ESPRecords[group]) do HideESPRecord(record) end
            ESPGroupActive[group] = false
        end
        return
    end
    ESPGroupActive[group] = true
    for object, record in pairs(ESPRecords[group]) do
        local humanoid = record.Humanoid
        if not enabled or not object.Parent or (humanoid and humanoid.Health <= 0) then
            HideESPRecord(record)
        else
            local topLeft, bottomRight = GetESPBounds(object)
            if not topLeft then
                HideESPRecord(record)
            else
                if record.Box then
                    record.Box.Visible = boxEnabled
                    record.Box.Position = topLeft
                    record.Box.Size = bottomRight - topLeft
                    record.Box.Color = boxColor
                end
                if record.Nametag then
                    record.Nametag.Visible = nametagEnabled
                    record.Nametag.Text = record.DisplayName
                    record.Nametag.Position = Vector2.new((topLeft.X + bottomRight.X) / 2, topLeft.Y - 16)
                    record.Nametag.Color = nametagColor
                end
                if record.HealthbarBackground and record.Healthbar then
                    local maxHealth = humanoid and humanoid.MaxHealth or 0
                    local healthRatio = maxHealth > 0 and math.clamp(humanoid.Health / maxHealth, 0, 1) or 0
                    local height = math.max(1, bottomRight.Y - topLeft.Y)
                    record.HealthbarBackground.Visible = healthbarEnabled
                    record.HealthbarBackground.Position = Vector2.new(topLeft.X - 7, topLeft.Y)
                    record.HealthbarBackground.Size = Vector2.new(4, height)
                    record.Healthbar.Visible = healthbarEnabled
                    record.Healthbar.Position = Vector2.new(topLeft.X - 6, bottomRight.Y - height * healthRatio + 1)
                    record.Healthbar.Size = Vector2.new(2, math.max(1, height * healthRatio - 2))
                    record.Healthbar.Color = healthbarColor
                end
                UpdateSkeleton(record, skeletonEnabled, skeletonColor)
            end
        end
    end
end

local function SyncESPGroup(group, desired, skeletonAllowed)
    local records = ESPRecords[group]
    for object, record in pairs(records) do
        if not desired[object] or not object.Parent then
            RemoveESPRecord(record)
            records[object] = nil
        end
    end
    for object, displayName in pairs(desired) do
        if not records[object] then
            records[object] = CreateESPRecord(object, displayName, skeletonAllowed)
        else
            records[object].DisplayName = displayName
        end
    end
end

local function RefreshESPRecords()
    local players = {}
    if State.PlayerESP then
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if player ~= LocalPlayer and character and humanoid and humanoid.Health > 0 then
                players[character] = player.DisplayName
            end
        end
    end

    local monsters = {}
    local monsterFolder = State.MonsterESP and workspace:FindFirstChild("_Monsters") or nil
    if monsterFolder then
        for _, monster in ipairs(monsterFolder:GetChildren()) do
            local humanoid = monster:IsA("Model") and monster:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                monsters[monster] = monster.Name
            end
        end
    end

    local items = {}
    local itemFolder = State.ItemESP and workspace:FindFirstChild("_Items") or nil
    if itemFolder then
        for _, item in ipairs(itemFolder:GetChildren()) do
            if item:IsA("Model") or item:IsA("BasePart") then
                items[item] = item.Name
            end
        end
    end

    SyncESPGroup("Player", players, true)
    SyncESPGroup("Monster", monsters, true)
    SyncESPGroup("Item", items, false)
end

local ESPConnection = RunService.RenderStepped:Connect(function()
    UpdateESPGroup("Monster")
    UpdateESPGroup("Player")
    UpdateESPGroup("Item")
end)

local function IsLocalPlayerLikelyTarget(monsterRoot, localRoot)
    local monsterPosition = monsterRoot.Position
    local localOffset = Vector3.new(localRoot.Position.X - monsterPosition.X, 0, localRoot.Position.Z - monsterPosition.Z)
    local localDistance = localOffset.Magnitude
    if localDistance <= 0 then return true end

    local velocity = monsterRoot.AssemblyLinearVelocity
    local movement = Vector3.new(velocity.X, 0, velocity.Z)
    if movement.Magnitude <= 1 then
        local look = monsterRoot.CFrame.LookVector
        movement = Vector3.new(look.X, 0, look.Z)
    end
    if movement.Magnitude <= 0 then return false end

    local movementDirection = movement.Unit
    local localDot = movementDirection:Dot(localOffset.Unit)
    if localDot < 0.65 then return false end
    local localCrossTrack = localDistance * math.sqrt(math.max(0, 1 - localDot * localDot))
    local localScore = localCrossTrack + localDistance * 0.025 - localDot * 8

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and root then
                local otherOffset = Vector3.new(root.Position.X - monsterPosition.X, 0, root.Position.Z - monsterPosition.Z)
                local otherDistance = otherOffset.Magnitude
                if otherDistance + 3 < localDistance then
                    return false
                end
                if otherDistance > 0 then
                    local otherDot = movementDirection:Dot(otherOffset.Unit)
                    if otherDot >= 0.55 then
                        local otherCrossTrack = otherDistance * math.sqrt(math.max(0, 1 - otherDot * otherDot))
                        local otherScore = otherCrossTrack + otherDistance * 0.025 - otherDot * 8
                        if otherScore <= localScore + 4 then return false end
                    end
                end
            end
        end
    end
    return true
end

local function GetNearestAngryMonster()
    local character = LocalPlayer.Character
    local localHumanoid = character and character:FindFirstChildOfClass("Humanoid")
    local localRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not localRoot or not localHumanoid or localHumanoid.Health <= 0 then return nil end

    local closestMonster
    local closestDistance = math.huge
    local patrolSpeed = tonumber(MonsterConfiguration.PatrolSpeed) or 16
    local targetSpeed = tonumber(MonsterConfiguration.TargetSpeed) or 75
    local chaseThreshold = patrolSpeed + (targetSpeed - patrolSpeed) * 0.55

    for _, monster in ipairs(CollectionService:GetTagged("Monster")) do
        if monster:IsA("Model") and monster:IsDescendantOf(workspace) then
            local humanoid = monster:FindFirstChildOfClass("Humanoid")
            local root = monster:FindFirstChild("HumanoidRootPart") or monster.PrimaryPart
            if humanoid and humanoid.Health > 0 and root then
                local offset = localRoot.Position - root.Position
                local distance = offset.Magnitude
                if distance < closestDistance and distance <= 500 then
                    local values = monster:FindFirstChild("Values")
                    local attackingValue = values and values:FindFirstChild("Attacking")
                    local actingValue = values and values:FindFirstChild("Acting")
                    local attacking = attackingValue and attackingValue.Value == true
                    local acting = actingValue and actingValue.Value == true
                    local velocity = root.AssemblyLinearVelocity
                    local flatVelocity = Vector3.new(velocity.X, 0, velocity.Z)
                    local flatOffset = Vector3.new(offset.X, 0, offset.Z)
                    local towardLocal = false
                    if flatVelocity.Magnitude > 1 and flatOffset.Magnitude > 0 then
                        towardLocal = flatVelocity.Unit:Dot(flatOffset.Unit) > 0.25
                    elseif humanoid.MoveDirection.Magnitude > 0 and flatOffset.Magnitude > 0 then
                        towardLocal = humanoid.MoveDirection.Unit:Dot(flatOffset.Unit) > 0.25
                    end
                    local likelyTarget = IsLocalPlayerLikelyTarget(root, localRoot)
                    local chaseSpeed = humanoid.WalkSpeed >= chaseThreshold
                    local angry = likelyTarget and (
                        (chaseSpeed and towardLocal)
                        or (attacking and distance <= 55)
                        or (acting and chaseSpeed and distance <= 140)
                    )
                    if angry then
                        closestMonster = monster
                        closestDistance = distance
                    end
                end
            end
        end
    end
    return closestMonster, closestDistance
end

local MonsterAlertScanAccumulator = 0
local MonsterAlertActive = false
local MonsterAlertStuds = math.huge
local MonsterAlertTarget
local MonsterAlertLastSound = 0
local MonsterAlertConnection = RunService.RenderStepped:Connect(function(deltaTime)
    if not State.MonsterAngerAlert then
        MonsterAlertActive = false
        MonsterAlertTarget = nil
        MonsterAlertGui.Enabled = false
        return
    end

    MonsterAlertScanAccumulator = MonsterAlertScanAccumulator + deltaTime
    if MonsterAlertScanAccumulator >= 0.1 then
        MonsterAlertScanAccumulator = 0
        local monster, distance = GetNearestAngryMonster()
        MonsterAlertActive = monster ~= nil
        MonsterAlertTarget = monster
        MonsterAlertStuds = distance or math.huge
        MonsterAlertGui.Enabled = MonsterAlertActive
        if MonsterAlertActive then
            MonsterAlertDistance.Text = "Running at you  ·  " .. tostring(math.floor(MonsterAlertStuds + 0.5)) .. " studs"
            local soundInterval = math.clamp(MonsterAlertStuds / 100, 0.65, 3)
            if MonsterAlertSound and os.clock() - MonsterAlertLastSound >= soundInterval and not MonsterAlertSound.Playing then
                MonsterAlertLastSound = os.clock()
                MonsterAlertSound:Play()
            end
        elseif MonsterAlertSound and MonsterAlertSound.Playing then
            MonsterAlertSound:Stop()
        end
    end

    if MonsterAlertActive then
        Camera = workspace.CurrentCamera
        local root = MonsterAlertTarget and (MonsterAlertTarget:FindFirstChild("HumanoidRootPart") or MonsterAlertTarget.PrimaryPart)
        if Camera and root then
            local screenPoint = Camera:WorldToViewportPoint(root.Position)
            local viewportSize = Camera.ViewportSize
            local halfWidth = MonsterAlertFrame.AbsoluteSize.X * 0.5
            local frameHeight = MonsterAlertFrame.AbsoluteSize.Y
            local margin = 14
            local x
            local y
            if screenPoint.Z <= 0 then
                -- A threat behind the camera stays at the bottom instead of shaking.
                x = viewportSize.X * 0.5
                y = viewportSize.Y - frameHeight - margin
            else
                x = math.clamp(screenPoint.X, halfWidth + margin, viewportSize.X - halfWidth - margin)
                y = math.clamp(screenPoint.Y - frameHeight - 24, margin, viewportSize.Y - frameHeight - margin)
            end
            MonsterAlertFrame.Position = UDim2.fromOffset(x, y)
        end
        MonsterAlertFrame.Rotation = 0
        MonsterAlertStroke.Thickness = 1
    end
end)

local function IsStaminaName(name)
    return string.find(string.lower(tostring(name)), "stamina", 1, true) ~= nil
end

local function DisconnectStaminaLocks()
    for object, connections in pairs(StaminaLocks) do
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
        StaminaLocks[object] = nil
    end
end

local function LockStaminaTarget(target)
    local object = target.Object
    if not object or StaminaLocks[object] then return end

    local connections = {}
    StaminaLocks[object] = connections

    if target.Kind == "Value" then
        connections.Value = object:GetPropertyChangedSignal("Value"):Connect(function()
            if State.InfiniteStamina and object.Parent and object.Value ~= 100 then
                object.Value = 100
            end
        end)
    else
        connections[target.Name] = object:GetAttributeChangedSignal(target.Name):Connect(function()
            if State.InfiniteStamina and object.Parent and object:GetAttribute(target.Name) ~= 100 then
                object:SetAttribute(target.Name, 100)
            end
        end)
    end
end

local function RefreshStaminaTargets()
    table.clear(StaminaTargets)
    local roots = {
        LocalPlayer,
        LocalPlayer.Character,
        LocalPlayer:FindFirstChildOfClass("PlayerGui")
    }

    for _, root in ipairs(roots) do
        if root then
            local objects = {root}
            for _, descendant in ipairs(root:GetDescendants()) do
                table.insert(objects, descendant)
            end

            for _, object in ipairs(objects) do
                if IsStaminaName(object.Name) and (object:IsA("NumberValue") or object:IsA("IntValue")) then
                    local target = {Kind = "Value", Object = object}
                    table.insert(StaminaTargets, target)
                end

                for attributeName, attributeValue in pairs(object:GetAttributes()) do
                    if type(attributeValue) == "number" and IsStaminaName(attributeName) then
                        local target = {
                            Kind = "Attribute",
                            Object = object,
                            Name = attributeName
                        }
                        table.insert(StaminaTargets, target)
                    end
                end
            end
        end
    end
end

local function ForceInfiniteStamina()
    for index = #StaminaTargets, 1, -1 do
        local target = StaminaTargets[index]
        if not target.Object or not target.Object.Parent then
            table.remove(StaminaTargets, index)
        elseif target.Kind == "Value" then
            pcall(function()
                target.Object.Value = 100
            end)
        else
            pcall(function()
                target.Object:SetAttribute(target.Name, 100)
            end)
        end
    end
end

UISettings.TPWalk = MovementSection:CreateCheckbox("TP Walk", false, function(value)
    State.TPWalk = value
end)

UISettings.TPWalkSpeed = MovementSection:CreateSlider("TP Walk Speed", 0.1, 1, 0.3, function(value)
    State.TPWalkSpeed = value
end, 0.1)

local function GetMouseLockBoundKeys()
    local playerModule = LocalPlayer:FindFirstChild("PlayerScripts")
    playerModule = playerModule and playerModule:FindFirstChild("PlayerModule")
    local cameraModule = playerModule and playerModule:FindFirstChild("CameraModule")
    local mouseLockController = cameraModule and cameraModule:FindFirstChild("MouseLockController")
    return mouseLockController and mouseLockController:FindFirstChild("BoundKeys")
end

MouseLockBoundKeys = GetMouseLockBoundKeys()
if MouseLockBoundKeys and MouseLockBoundKeys:IsA("StringValue") then
    OriginalMouseLockKeys = MouseLockBoundKeys.Value
end

UISettings.CtrlLock = CameraSection:CreateCheckbox("CtrlLock", false, function(value)
    State.CtrlLock = value
    MouseLockBoundKeys = GetMouseLockBoundKeys()
    if MouseLockBoundKeys and MouseLockBoundKeys:IsA("StringValue") then
        MouseLockBoundKeys.Value = value and "LeftControl,RightControl" or OriginalMouseLockKeys
    end
end)

UISettings.InfiniteStamina = StaminaSection:CreateCheckbox("Infinite Stamina", false, function(value)
    State.InfiniteStamina = value
    if value then
        CharacterConfiguration.StaminaDeductionRate = 0
        CharacterConfiguration.StaminaRegenRate = math.max(OriginalStaminaRegenRate, 100)
        RefreshStaminaTargets()
        ForceInfiniteStamina()
    else
        CharacterConfiguration.StaminaDeductionRate = OriginalStaminaDeductionRate
        CharacterConfiguration.StaminaRegenRate = OriginalStaminaRegenRate
        DisconnectStaminaLocks()
    end
end)

local RuntimeConnection = RunService.Heartbeat:Connect(function()
    if State.TPWalk then
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart and humanoid.Health > 0 and humanoid.MoveDirection.Magnitude > 0 then
            rootPart.CFrame = rootPart.CFrame + humanoid.MoveDirection * State.TPWalkSpeed * 0.1
        end
    end

    if State.InfiniteStamina then
        ForceInfiniteStamina()
    end
end)

RunService:BindToRenderStep("BinHubAQuietAimlock", Enum.RenderPriority.Camera.Value + 1, function()
    Camera = workspace.CurrentCamera
    local screenCenter = Camera and (Camera.ViewportSize / 2) or Vector2.zero
    local mousePosition = UserInputService:GetMouseLocation()

    if AimRuntime.SilentAimEnabled then
        local silentTarget = GetAimTarget("SilentAim")
        AimRuntime.SilentAimTarget = silentTarget
        AimRuntime.SilentAimTargetName = silentTarget and silentTarget:GetFullName() or nil
    else
        AimRuntime.SilentAimTarget = nil
        AimRuntime.SilentAimTargetName = nil
    end

    if AimlockFOVCircle then
        AimlockFOVCircle.Position = State.AimlockFOVFollowCursor and mousePosition or screenCenter
        AimlockFOVCircle.Radius = State.AimlockFOV
        AimlockFOVCircle.Color = State.AimlockFOVColor
        AimlockFOVCircle.Visible = State.AimlockUseFOV
    end
    if SilentAimFOVCircle then
        SilentAimFOVCircle.Position = mousePosition
        SilentAimFOVCircle.Radius = State.SilentAimFOV
        SilentAimFOVCircle.Color = State.SilentAimFOVColor
        SilentAimFOVCircle.Visible = State.SilentAimUseFOV
    end

    if State.Aimlock and State.AimlockKeyHeld then
        local target = GetAimTarget("Aimlock")
        if Camera and target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end
end)

local LastPlayerOptionsSignature = ""
task.spawn(function()
    while not Unloaded do
        RefreshESPRecords()
        if State.InfiniteStamina then
            RefreshStaminaTargets()
            ForceInfiniteStamina()
        end
        if AimRuntime.SilentAimEnabled or State.Aimlock then
            RefreshAimCandidates()
        end
        local playerOptions = GetPlayerOptions()
        local playerOptionsSignature = table.concat(playerOptions, "\0")
        if playerOptionsSignature ~= LastPlayerOptionsSignature then
            LastPlayerOptionsSignature = playerOptionsSignature
            UISettings.AimlockIgnored:UpdateOptions(playerOptions)
            UISettings.SilentAimIgnored:UpdateOptions(playerOptions)
        end
        task.wait(1)
    end
end)

local function Cleanup()
    if Unloaded then return end
    Unloaded = true
    State.TPWalk = false
    State.InfiniteStamina = false
    State.CtrlLock = false
    State.MonsterAngerAlert = false
    State.AutoWeapons = false
    State.InstantReload = false
    State.AutoReload = false
    State.FastFireRate = false
    ApplyGunMods()
    CharacterUtilities.CanUseItem = OriginalCanUseItem
    if MonsterEscapeBusy then FinishMonsterEscape() end
    if MonsterEscapeInputConnection then MonsterEscapeInputConnection:Disconnect() end
    if KeybindInputChangedConnection then KeybindInputChangedConnection:Disconnect() end
    if KeybindInputEndedConnection then KeybindInputEndedConnection:Disconnect() end
    if KeybindMenuVisibilityConnection then KeybindMenuVisibilityConnection:Disconnect() end
    if KeybindOverlayGui then KeybindOverlayGui:Destroy() end
    SetInstantProximityPrompts(false)
    if PromptAddedConnection then
        PromptAddedConnection:Disconnect()
        PromptAddedConnection = nil
    end
    ApplySilentMode(false)
    if CharacterSoundDescendantConnection then
        CharacterSoundDescendantConnection:Disconnect()
        CharacterSoundDescendantConnection = nil
    end
    if CharacterSoundCharacterConnection then
        CharacterSoundCharacterConnection:Disconnect()
        CharacterSoundCharacterConnection = nil
    end
    State.SilentAim = false
    AimRuntime.SilentAimEnabled = false
    State.Aimlock = false
    State.AimlockKeyHeld = false
    RunService:UnbindFromRenderStep("BinHubAQuietAimlock")
    if AimInputBegan then AimInputBegan:Disconnect() end
    if AimInputEnded then AimInputEnded:Disconnect() end
    if AimlockFOVCircle then AimlockFOVCircle:Remove() end
    if SilentAimFOVCircle then SilentAimFOVCircle:Remove() end
    AimRuntime.AimlockFOVCircle = nil
    AimRuntime.SilentAimFOVCircle = nil
    DisconnectStaminaLocks()
    CharacterConfiguration.StaminaDeductionRate = OriginalStaminaDeductionRate
    CharacterConfiguration.StaminaRegenRate = OriginalStaminaRegenRate
    MouseLockBoundKeys = GetMouseLockBoundKeys()
    if MouseLockBoundKeys and MouseLockBoundKeys:IsA("StringValue") then
        MouseLockBoundKeys.Value = OriginalMouseLockKeys
    end
    if RuntimeConnection then
        RuntimeConnection:Disconnect()
        RuntimeConnection = nil
    end
    if ESPConnection then
        ESPConnection:Disconnect()
        ESPConnection = nil
    end
    if MonsterAlertConnection then
        MonsterAlertConnection:Disconnect()
        MonsterAlertConnection = nil
    end
    if MonsterAlertGui then MonsterAlertGui:Destroy() end
    if MonsterAlertSound then MonsterAlertSound:Destroy() end
    for _, records in pairs(ESPRecords) do
        for object, record in pairs(records) do
            RemoveESPRecord(record)
            records[object] = nil
        end
    end
    getgenv().AQuietPlaceDeadzoneESPRuntime = nil
end

getgenv().AQuietPlaceDeadzoneCleanup = Cleanup

local function EnsureConfigFolder()
    if not isfolder or not makefolder then
        return false
    end

    if not isfolder("BinHubConfigs") then
        makefolder("BinHubConfigs")
    end
    if not isfolder(CONFIG_ROOT) then
        makefolder(CONFIG_ROOT)
    end
    return true
end

local function CleanConfigName(name)
    name = tostring(name or "Default")
    name = name:gsub("[\\/:*?\"<>|]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then
        return "Default"
    end
    return name:sub(1, 48)
end

local function GetConfigs()
    EnsureConfigFolder()
    local configs = {}

    if listfiles then
        local success, files = pcall(listfiles, CONFIG_ROOT)
        if success then
            for _, path in ipairs(files) do
                local name = path:match("([^\\/]+)%.json$")
                if name then
                    table.insert(configs, name)
                end
            end
        end
    end

    table.sort(configs)
    if #configs == 0 then
        table.insert(configs, "Default")
    end
    return configs
end

local CurrentConfigName = "Default"
local ConfigDropdown
local ConfigTextbox
local ToggleKeyControl

local function SaveConfig(name)
    if not writefile or not EnsureConfigFolder() then
        Notify("Your executor does not support config files.")
        return
    end

    name = CleanConfigName(name)
    CurrentConfigName = name
    local data = {
        ToggleKey = Window.ToggleKey.Name,
        TPWalk = State.TPWalk,
        TPWalkSpeed = State.TPWalkSpeed,
        InfiniteStamina = State.InfiniteStamina,
        CtrlLock = State.CtrlLock,
        MonsterAngerAlert = State.MonsterAngerAlert,
        MonsterEscapeKey = State.MonsterEscapeKey.Name,
        KeybindPanelPinned = State.KeybindPanelPinned,
        KeybindPanelX = State.KeybindPanelX,
        KeybindPanelY = State.KeybindPanelY,
        SilentMode = State.SilentMode,
        InstantProximityPrompts = State.InstantProximityPrompts,
        AutoWeapons = State.AutoWeapons,
        InstantReload = State.InstantReload,
        AutoReload = State.AutoReload,
        FastFireRate = State.FastFireRate,
        FireRateRPM = tonumber(State.FireRateRPM) or 600,
        SilentAim = AimRuntime.SilentAimEnabled,
        SilentAimUseFOV = State.SilentAimUseFOV,
        SilentAimFOV = State.SilentAimFOV,
        SilentAimFOVColor = {State.SilentAimFOVColor.R, State.SilentAimFOVColor.G, State.SilentAimFOVColor.B},
        SilentAimIgnored = State.SilentAimIgnored,
        SilentAimPlayerTargetPart = State.SilentAimPlayerTargetPart,
        SilentAimMonsterTargetPart = State.SilentAimMonsterTargetPart,
        TargetViewerType = State.TargetViewerType,
        Aimlock = State.Aimlock,
        AimlockUseFOV = State.AimlockUseFOV,
        AimlockFOV = State.AimlockFOV,
        AimlockFOVColor = {State.AimlockFOVColor.R, State.AimlockFOVColor.G, State.AimlockFOVColor.B},
        AimlockFOVFollowCursor = State.AimlockFOVFollowCursor,
        AimlockIgnored = State.AimlockIgnored,
        AimlockKey = State.AimlockKey.Name,
        MonsterESP = State.MonsterESP,
        MonsterNametag = State.MonsterNametag,
        MonsterNametagColor = {State.MonsterNametagColor.R, State.MonsterNametagColor.G, State.MonsterNametagColor.B},
        MonsterBox = State.MonsterBox,
        MonsterBoxColor = {State.MonsterBoxColor.R, State.MonsterBoxColor.G, State.MonsterBoxColor.B},
        MonsterHealthbar = State.MonsterHealthbar,
        MonsterHealthbarColor = {State.MonsterHealthbarColor.R, State.MonsterHealthbarColor.G, State.MonsterHealthbarColor.B},
        MonsterSkeleton = State.MonsterSkeleton,
        MonsterSkeletonColor = {State.MonsterSkeletonColor.R, State.MonsterSkeletonColor.G, State.MonsterSkeletonColor.B},
        PlayerESP = State.PlayerESP,
        PlayerNametag = State.PlayerNametag,
        PlayerNametagColor = {State.PlayerNametagColor.R, State.PlayerNametagColor.G, State.PlayerNametagColor.B},
        PlayerBox = State.PlayerBox,
        PlayerBoxColor = {State.PlayerBoxColor.R, State.PlayerBoxColor.G, State.PlayerBoxColor.B},
        PlayerHealthbar = State.PlayerHealthbar,
        PlayerHealthbarColor = {State.PlayerHealthbarColor.R, State.PlayerHealthbarColor.G, State.PlayerHealthbarColor.B},
        PlayerSkeleton = State.PlayerSkeleton,
        PlayerSkeletonColor = {State.PlayerSkeletonColor.R, State.PlayerSkeletonColor.G, State.PlayerSkeletonColor.B},
        ItemESP = State.ItemESP,
        ItemNametag = State.ItemNametag,
        ItemNametagColor = {State.ItemNametagColor.R, State.ItemNametagColor.G, State.ItemNametagColor.B},
        ItemBox = State.ItemBox,
        ItemBoxColor = {State.ItemBoxColor.R, State.ItemBoxColor.G, State.ItemBoxColor.B}
    }

    local success, err = pcall(function()
        writefile(CONFIG_ROOT .. "/" .. name .. ".json", HttpService:JSONEncode(data))
    end)

    if not success then
        warn("[BinHub] Config save failed: " .. tostring(err))
        Notify("Failed to save config " .. name .. ".")
        return
    end

    if ConfigDropdown and ConfigDropdown.UpdateOptions then
        ConfigDropdown:UpdateOptions(GetConfigs())
    end
    Notify("Saved config " .. name .. ".")
end

local function LoadConfig(name, silent)
    name = CleanConfigName(name)
    local path = CONFIG_ROOT .. "/" .. name .. ".json"

    if not readfile or not isfile or not isfile(path) then
        if not silent then
            Notify("Config " .. name .. " was not found.")
        end
        return false
    end

    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)

    if not success or type(data) ~= "table" then
        Notify("Config " .. name .. " is invalid.")
        return false
    end

    local toggleKey = type(data.ToggleKey) == "string" and Enum.KeyCode[data.ToggleKey] or nil
    if toggleKey then
        Window.ToggleKey = toggleKey
        if ToggleKeyControl then
            ToggleKeyControl:SetValue(toggleKey)
        end
    end

    if type(data.TPWalkSpeed) == "number" then
        UISettings.TPWalkSpeed:SetValue(data.TPWalkSpeed)
    end
    if type(data.TPWalk) == "boolean" then
        UISettings.TPWalk:SetValue(data.TPWalk)
    end
    if type(data.InfiniteStamina) == "boolean" then
        UISettings.InfiniteStamina:SetValue(data.InfiniteStamina)
    end
    if type(data.CtrlLock) == "boolean" then
        UISettings.CtrlLock:SetValue(data.CtrlLock)
    end
    if type(data.MonsterAngerAlert) == "boolean" then
        UISettings.MonsterAngerAlert:SetValue(data.MonsterAngerAlert)
    end
    if type(data.MonsterEscapeKey) == "string" and Enum.KeyCode[data.MonsterEscapeKey] then
        UISettings.MonsterEscapeKey:SetValue(Enum.KeyCode[data.MonsterEscapeKey])
    end
    if type(data.KeybindPanelPinned) == "boolean" then
        State.KeybindPanelPinned = data.KeybindPanelPinned
    end
    if type(data.KeybindPanelX) == "number" then State.KeybindPanelX = math.floor(data.KeybindPanelX + 0.5) end
    if type(data.KeybindPanelY) == "number" then State.KeybindPanelY = math.floor(data.KeybindPanelY + 0.5) end
    KeybindPanel.Position = UDim2.fromOffset(State.KeybindPanelX, State.KeybindPanelY)
    UpdateKeybindPanel()
    if type(data.SilentMode) == "boolean" then
        SilentRuntime.SuppressNotification = true
        UISettings.SilentMode:SetValue(data.SilentMode)
        SilentRuntime.SuppressNotification = false
    end
    if type(data.InstantProximityPrompts) == "boolean" then
        UISettings.InstantProximityPrompts:SetValue(data.InstantProximityPrompts)
    end
    if type(data.FireRateRPM) == "number" then
        UISettings.FireRateRPM:SetValue(math.clamp(data.FireRateRPM, 100, 1200))
    end
    for _, key in ipairs({"AutoWeapons", "InstantReload", "AutoReload", "FastFireRate"}) do
        if type(data[key]) == "boolean" and UISettings[key] then
            UISettings[key]:SetValue(data[key])
        end
    end
    if type(data.SilentAim) == "boolean" then
        UISettings.SilentAim:SetValue(data.SilentAim)
    end
    if type(data.SilentAimUseFOV) == "boolean" then
        UISettings.SilentAimUseFOV:SetValue(data.SilentAimUseFOV)
    end
    if type(data.SilentAimFOV) == "number" then
        UISettings.SilentAimFOV:SetValue(data.SilentAimFOV)
    end
    if type(data.SilentAimFOVColor) == "table" and #data.SilentAimFOVColor >= 3 then
        UISettings.SilentAimUseFOV:SetColor(Color3.new(data.SilentAimFOVColor[1], data.SilentAimFOVColor[2], data.SilentAimFOVColor[3]))
    end
    if type(data.SilentAimIgnored) == "table" then
        UISettings.SilentAimIgnored:SetValue(data.SilentAimIgnored)
    end
    if type(data.SilentAimPlayerTargetPart) == "string" then
        if not table.find(PlayerTargetPartOptions, data.SilentAimPlayerTargetPart) then
            table.insert(PlayerTargetPartOptions, data.SilentAimPlayerTargetPart)
            table.sort(PlayerTargetPartOptions)
            UISettings.SilentAimPlayerTargetPart:UpdateOptions(PlayerTargetPartOptions)
        end
        UISettings.SilentAimPlayerTargetPart:SetValue(data.SilentAimPlayerTargetPart)
    end
    if type(data.SilentAimMonsterTargetPart) == "string" then
        if not table.find(MonsterTargetPartOptions, data.SilentAimMonsterTargetPart) then
            table.insert(MonsterTargetPartOptions, data.SilentAimMonsterTargetPart)
            table.sort(MonsterTargetPartOptions)
            UISettings.SilentAimMonsterTargetPart:UpdateOptions(MonsterTargetPartOptions)
        end
        UISettings.SilentAimMonsterTargetPart:SetValue(data.SilentAimMonsterTargetPart)
    end
    if data.TargetViewerType == "Monster" or data.TargetViewerType == "Player" then
        UISettings.TargetViewerType:SetValue(data.TargetViewerType)
    end
    if type(data.Aimlock) == "boolean" then
        UISettings.Aimlock:SetValue(data.Aimlock)
    end
    if type(data.AimlockUseFOV) == "boolean" then
        UISettings.AimlockUseFOV:SetValue(data.AimlockUseFOV)
    end
    if type(data.AimlockFOV) == "number" then
        UISettings.AimlockFOV:SetValue(data.AimlockFOV)
    end
    if type(data.AimlockFOVColor) == "table" and #data.AimlockFOVColor >= 3 then
        UISettings.AimlockUseFOV:SetColor(Color3.new(data.AimlockFOVColor[1], data.AimlockFOVColor[2], data.AimlockFOVColor[3]))
    end
    if type(data.AimlockFOVFollowCursor) == "boolean" then
        UISettings.AimlockFOVFollowCursor:SetValue(data.AimlockFOVFollowCursor)
    end
    if type(data.AimlockIgnored) == "table" then
        UISettings.AimlockIgnored:SetValue(data.AimlockIgnored)
    end
    if type(data.AimlockKey) == "string" and Enum.KeyCode[data.AimlockKey] then
        UISettings.AimlockKey:SetValue(Enum.KeyCode[data.AimlockKey])
    end

    local espBooleanKeys = {
        "MonsterESP", "MonsterNametag", "MonsterBox", "MonsterHealthbar", "MonsterSkeleton",
        "PlayerESP", "PlayerNametag", "PlayerBox", "PlayerHealthbar", "PlayerSkeleton",
        "ItemESP", "ItemNametag", "ItemBox"
    }
    for _, key in ipairs(espBooleanKeys) do
        if type(data[key]) == "boolean" and UISettings[key] then
            UISettings[key]:SetValue(data[key])
        end
    end

    local espColorKeys = {
        "MonsterNametagColor", "MonsterBoxColor", "MonsterHealthbarColor", "MonsterSkeletonColor",
        "PlayerNametagColor", "PlayerBoxColor", "PlayerHealthbarColor", "PlayerSkeletonColor",
        "ItemNametagColor", "ItemBoxColor"
    }
    for _, key in ipairs(espColorKeys) do
        local colorData = data[key]
        local controlKey = key:gsub("Color$", "")
        if type(colorData) == "table" and #colorData >= 3 and UISettings[controlKey] then
            UISettings[controlKey]:SetColor(Color3.new(colorData[1], colorData[2], colorData[3]))
        end
    end

    CurrentConfigName = name
    if ConfigTextbox then
        ConfigTextbox:SetValue(name)
    end
    if not silent then
        Notify("Loaded config " .. name .. ".")
    end
    return true
end

ToggleKeyControl = ConfigSection:CreateKeybind("Toggle UI", Enum.KeyCode.LeftAlt, function(key)
    Window.ToggleKey = key
    UpdateKeybindPanel()
end)

ConfigDropdown = ConfigSection:CreateDropdown("Configs", GetConfigs(), "Default", function(value)
    CurrentConfigName = CleanConfigName(value)
    if ConfigTextbox then
        ConfigTextbox:SetValue(CurrentConfigName)
    end
end)

ConfigTextbox = ConfigSection:CreateTextbox("Config Name", "Enter name...", "Default", function(value)
    CurrentConfigName = CleanConfigName(value)
end)

ConfigSection:CreateButton("Save Config", function()
    SaveConfig(CurrentConfigName)
end)

ConfigSection:CreateButton("Load Config", function()
    LoadConfig(CurrentConfigName, false)
end)

ConfigSection:CreateButton("Set Autoload", function()
    if not writefile or not EnsureConfigFolder() then
        Notify("Your executor does not support autoload files.")
        return
    end

    CurrentConfigName = CleanConfigName(CurrentConfigName)
    writefile(AUTOLOAD_PATH, CurrentConfigName)
    Notify("Autoload set to " .. CurrentConfigName .. ".")
end)

ConfigSection:CreateButton("Unload UI", function()
    Cleanup()
    local gui = Window.Gui or CoreGui:FindFirstChild("BinHubV2")
    if gui then
        gui:Destroy()
    end
end)

EnsureConfigFolder()
if isfile and readfile and isfile(AUTOLOAD_PATH) then
    local success, name = pcall(readfile, AUTOLOAD_PATH)
    if success then LoadConfig(name, true) end
end
