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
local GameUtilities = require(ReplicatedStorage.Game.Utilities)
local ItemConfiguration = require(ReplicatedStorage.Item.Configuration)
local MonsterConfiguration = require(ReplicatedStorage.Monster.Configuration)
local Events = ReplicatedStorage:WaitForChild("Events")
local Remotes = Events:WaitForChild("Remotes")
local RequestCharacterAction = Remotes:WaitForChild("RequestCharacterAction")
local VoicePing = Remotes:WaitForChild("VoicePing")
local OriginalStaminaDeductionRate = CharacterConfiguration.StaminaDeductionRate
local OriginalStaminaRegenRate = CharacterConfiguration.StaminaRegenRate
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
    MonsterSkeleton = false,
    MonsterSkeletonColor = Color3.fromRGB(255, 150, 70),
    PlayerESP = false,
    PlayerNametag = false,
    PlayerNametagColor = Color3.fromRGB(100, 180, 255),
    PlayerBox = false,
    PlayerBoxColor = Color3.fromRGB(80, 150, 255),
    PlayerSkeleton = false,
    PlayerSkeletonColor = Color3.fromRGB(140, 210, 255),
    ItemESP = false,
    ItemNametag = false,
    ItemNametagColor = Color3.fromRGB(255, 230, 100),
    ItemBox = false,
    ItemBoxColor = Color3.fromRGB(255, 200, 70)
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

local function IsLocalCharacterSource(source)
    local character = LocalPlayer.Character
    return character ~= nil and typeof(source) == "Instance"
        and (source == character or source:IsDescendantOf(character))
end

-- Keep local weighted audio audible, but remove the weight that feeds the
-- game's sound-ping system. Voice pings are handled in the namecall hook.
if SilentRuntime.PatchVersion ~= 1 then
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
        if runtime and runtime.Enabled and type(properties) == "table" and properties.Weight ~= nil
            and (typeof(parent) == "CFrame" or IsLocalCharacterSource(parent)) then
            local silentProperties = {}
            for key, value in pairs(properties) do
                if key ~= "Weight" then silentProperties[key] = value end
            end
            properties = silentProperties
        end
        return SilentRuntime.OriginalPlayAudio(self, audioFolder, audioName, parent, properties)
    end
    SilentRuntime.PatchVersion = 1
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
end

ApplySilentMode(false)

local function Notify(text)
    task.spawn(function()
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "BinHub",
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

local AimCategory = Window:CreateCategory({Name = "Aim"})
local VisualsCategory = Window:CreateCategory({Name = "Visuals"})
local PlayerCategory = Window:CreateCategory({Name = "Player"})
local MiscCategory = Window:CreateCategory({Name = "Misc"})
local AimTab = AimCategory:CreateTab("Aim")
local VisualsTab = VisualsCategory:CreateTab("Visuals")
local PlayerTab = PlayerCategory:CreateTab("Player")
local SettingsTab = MiscCategory:CreateTab("Settings")
local OPAimSection = AimTab:CreateSection("OP Aim")
local SilentAimSection = AimTab:CreateSection("Silent Aim")
local MonsterESPSection = VisualsTab:CreateSection("Monster")
local PlayerESPSection = VisualsTab:CreateSection("Player")
local ItemESPSection = VisualsTab:CreateSection("Item")
local ModelViewerSection = VisualsTab:CreateSection("Model Viewer")
local MovementSection = PlayerTab:CreateSection("Movement")
local CameraSection = PlayerTab:CreateSection("Camera")
local StaminaSection = PlayerTab:CreateSection("Stamina")
local ConfigSection = SettingsTab:CreateSection("Configuration", "rbxassetid://7734053495")
local MiscSettingsSection = SettingsTab:CreateSection("Misc")

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

UISettings.MonsterAngerAlert = MiscSettingsSection:CreateCheckbox("Monster Anger Alert", false, function(value)
    State.MonsterAngerAlert = value
    if not value then MonsterAlertGui.Enabled = false end
end)

UISettings.SilentMode = MiscSettingsSection:CreateCheckbox("Silent Mode", false, function(value)
    ApplySilentMode(value)
    Notify(value and "Silent Mode enabled. Player noise pings are suppressed." or "Silent Mode disabled.")
end)

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
end)

UISettings.AimlockKey = OPAimSection:CreateKeybind("Aimlock Key", Enum.KeyCode.Q, function(key)
    State.AimlockKey = key
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
    for _, line in ipairs(record.Lines) do
        line.Visible = false
    end
end

local function RemoveESPRecord(record)
    if record.Box then record.Box:Remove() end
    if record.Nametag then record.Nametag:Remove() end
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
        return State.MonsterESP, State.MonsterNametag, State.MonsterNametagColor, State.MonsterBox, State.MonsterBoxColor, State.MonsterSkeleton, State.MonsterSkeletonColor
    elseif group == "Player" then
        return State.PlayerESP, State.PlayerNametag, State.PlayerNametagColor, State.PlayerBox, State.PlayerBoxColor, State.PlayerSkeleton, State.PlayerSkeletonColor
    end
    return State.ItemESP, State.ItemNametag, State.ItemNametagColor, State.ItemBox, State.ItemBoxColor, false, Color3.new(1, 1, 1)
end

local ESPGroupActive = {Monster = false, Player = false, Item = false}
local function UpdateESPGroup(group)
    local enabled, nametagEnabled, nametagColor, boxEnabled, boxColor, skeletonEnabled, skeletonColor = GetESPSettings(group)
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

local function IsLocalPlayerLikelyTarget(monsterPosition, localDistance)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and root then
                if (root.Position - monsterPosition).Magnitude + 8 < localDistance then
                    return false
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
                    local likelyTarget = IsLocalPlayerLikelyTarget(root.Position, distance)
                    local chaseSpeed = humanoid.WalkSpeed >= chaseThreshold
                    local angry = (chaseSpeed and (towardLocal or likelyTarget))
                        or (attacking and distance <= 55)
                        or (acting and chaseSpeed and distance <= 140 and likelyTarget)
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
    ApplySilentMode(false)
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
        SilentMode = State.SilentMode,
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
        MonsterSkeleton = State.MonsterSkeleton,
        MonsterSkeletonColor = {State.MonsterSkeletonColor.R, State.MonsterSkeletonColor.G, State.MonsterSkeletonColor.B},
        PlayerESP = State.PlayerESP,
        PlayerNametag = State.PlayerNametag,
        PlayerNametagColor = {State.PlayerNametagColor.R, State.PlayerNametagColor.G, State.PlayerNametagColor.B},
        PlayerBox = State.PlayerBox,
        PlayerBoxColor = {State.PlayerBoxColor.R, State.PlayerBoxColor.G, State.PlayerBoxColor.B},
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
    if type(data.SilentMode) == "boolean" then
        UISettings.SilentMode:SetValue(data.SilentMode)
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
        "MonsterESP", "MonsterNametag", "MonsterBox", "MonsterSkeleton",
        "PlayerESP", "PlayerNametag", "PlayerBox", "PlayerSkeleton",
        "ItemESP", "ItemNametag", "ItemBox"
    }
    for _, key in ipairs(espBooleanKeys) do
        if type(data[key]) == "boolean" and UISettings[key] then
            UISettings[key]:SetValue(data[key])
        end
    end

    local espColorKeys = {
        "MonsterNametagColor", "MonsterBoxColor", "MonsterSkeletonColor",
        "PlayerNametagColor", "PlayerBoxColor", "PlayerSkeletonColor",
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
    if success and LoadConfig(name, true) then
        Notify("Autoloaded config " .. CleanConfigName(name) .. ".")
    end
end
