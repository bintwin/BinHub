-- Default Universal Hub Script for unsupported games (V2 Nebula Theme)
local UILibrary = getgenv().UILibraryV2 or loadstring(game:HttpGet("https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/uilib/uilib_v2.luau?t=" .. tostring(tick())))()

if not UILibrary then
    warn("Failed to load UILibraryV2. Ensure it is pushed to github!")
    return
end

local Window = UILibrary:CreateWindow({
    TitleFirst = "nebula",
    TitleSecond = "tech",
    FooterLeft = "Universal Script for Roblox",
    FooterRight = "nebulatech"
})

-- SERVICES & GLOBALS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    WalkSpeed = 16,
    WalkSpeedEnabled = false,
    JumpPower = 50,
    JumpPowerEnabled = false,
    InfJump = false,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    AntiFling = false,
    ESP = false,
    ESPTeamCheck = false,
    ESPColor = Color3.fromRGB(123, 97, 255),
    ESPName = false,
    ESPNameColor = Color3.fromRGB(255, 255, 255)
}

local ESPDrawings = {}
local UISettings = {}

-- [CATEGORIES & TABS]
local PlayersCat = Window:CreateCategory({Name = "Players"})
local VisualsCat = Window:CreateCategory({Name = "Visuals"})
local MiscCat = Window:CreateCategory({Name = "Misc"})

local LocalTab = PlayersCat:CreateTab("Self")
local CombatTab = PlayersCat:CreateTab("Protection")

local EspTab = VisualsCat:CreateTab("Enemies")

local SettingsTab = MiscCat:CreateTab("Settings")

-- [LOCAL TAB - CARDS]
local MovementCard = LocalTab:CreateSection("Movement")
UISettings.WalkSpeedEnabled = MovementCard:CreateCheckbox("Enable WalkSpeed", false, function(v) Settings.WalkSpeedEnabled = v end)
UISettings.WalkSpeed = MovementCard:CreateSlider("WalkSpeed", 16, 200, 16, function(v) Settings.WalkSpeed = v end)

local JumpCard = LocalTab:CreateSection("Jumping")
UISettings.JumpPowerEnabled = JumpCard:CreateCheckbox("Enable JumpPower", false, function(v) Settings.JumpPowerEnabled = v end)
UISettings.JumpPower = JumpCard:CreateSlider("JumpPower", 50, 200, 50, function(v) Settings.JumpPower = v end)
UISettings.InfJump = JumpCard:CreateCheckbox("Infinite Jump", false, function(v) Settings.InfJump = v end)

local AdvancedCard = LocalTab:CreateSection("Advanced")
UISettings.Noclip = AdvancedCard:CreateCheckbox("Noclip", false, function(v) Settings.Noclip = v end)

local flyBV, flyBG
local FlyCard = LocalTab:CreateSection("Flight")
UISettings.Fly = FlyCard:CreateCheckbox("Enable Fly", false, function(state)
    Settings.Fly = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    
    if state then
        hum.PlatformStand = true
        flyBG = Instance.new("BodyGyro")
        flyBG.P = 9e4
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.CFrame = hrp.CFrame
        flyBG.Parent = hrp
        
        flyBV = Instance.new("BodyVelocity")
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Parent = hrp
    else
        hum.PlatformStand = false
        if flyBG then flyBG:Destroy() end
        if flyBV then flyBV:Destroy() end
        hrp.Velocity = Vector3.new(0, 0, 0)
    end
end)
UISettings.FlySpeed = FlyCard:CreateSlider("Fly Speed", 10, 300, 50, function(v) Settings.FlySpeed = v end)

-- [COMBAT TAB - CARDS]
local ProtectionCard = CombatTab:CreateSection("Anti-Abuse")
UISettings.AntiFling = ProtectionCard:CreateCheckbox("Anti-Fling", false, function(v) Settings.AntiFling = v end)

-- [VISUALS TAB - CARDS]
local EspCard = EspTab:CreateSection("General")
UISettings.ESP = EspCard:CreateColorCheckbox("Enable Box ESP", Color3.fromRGB(123, 97, 255), false, function(color)
    Settings.ESPColor = color
end, function(v)
    Settings.ESP = v
end)

UISettings.ESPName = EspCard:CreateColorCheckbox("Enable Name ESP", Color3.fromRGB(255, 255, 255), false, function(color)
    Settings.ESPNameColor = color
end, function(v)
    Settings.ESPName = v
end)

UISettings.ESPTeamCheck = EspCard:CreateCheckbox("Team Check", false, function(v) Settings.ESPTeamCheck = v end)
UISettings.ESPColor = UISettings.ESP
UISettings.ESPNameColor = UISettings.ESPName
EspCard:CreateDropdown("Dropdown", {"Scoped", "Flashed", "Knocked", "Touched", "Skid"}, "Scoped", function(v) print("Selected:", v) end)


if isfolder and not isfolder("BinHubConfigs/Universal") then
    if not isfolder("BinHubConfigs") then makefolder("BinHubConfigs") end
    makefolder("BinHubConfigs/Universal")
end

local function SerializeColor(c) return {r = c.R, g = c.G, b = c.B} end
local function DeserializeColor(t) return Color3.new(t.r, t.g, t.b) end

local function GetConfigs()
    if not listfiles then return {"Default"} end
    local success, files = pcall(function() return listfiles("BinHubConfigs/Universal") end)
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
    for k, v in pairs(Settings) do
        if typeof(v) == "Color3" then export[k] = {type = "Color3", val = SerializeColor(v)}
        elseif typeof(v) == "EnumItem" then export[k] = {type = "EnumItem", val = v.Name}
        else export[k] = {type = "raw", val = v} end
    end
    -- Add toggle key manually
    export["ToggleKey"] = {type = "EnumItem", val = Window.ToggleKey.Name}
    
    writefile("BinHubConfigs/Universal/" .. name .. ".json", HttpService:JSONEncode(export))
    if ConfigDropdown and ConfigDropdown.UpdateOptions then
        ConfigDropdown:UpdateOptions(GetConfigs())
    end
end

local function LoadConfig(name)
    if not readfile then return end
    local path = "BinHubConfigs/Universal/" .. name .. ".json"
    if not isfile(path) then return end
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if success and type(decoded) == "table" then
        for k, item in pairs(decoded) do
            local val = item.val
            if item.type == "Color3" then val = DeserializeColor(val)
            elseif item.type == "EnumItem" then val = Enum.KeyCode[val] or Enum.KeyCode.LeftAlt end
            
            if k == "ToggleKey" then
                Window.ToggleKey = val
                if UISettings.ToggleKey then UISettings.ToggleKey:SetValue(val) end
            else
                Settings[k] = val
                if UISettings[k] then 
                    if typeof(val) == "Color3" then
                        UISettings[k]:SetColor(val)
                    else
                        UISettings[k]:SetValue(val) 
                    end
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

-- [MISC TAB - CARDS]
local ConfigCard = SettingsTab:CreateSection("Configuration", "rbxassetid://7734053495")
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
    if getgenv().UniRenderLoop then getgenv().UniRenderLoop:Disconnect() end
    if getgenv().UniSteppedLoop then getgenv().UniSteppedLoop:Disconnect() end
    if getgenv().UniInfJump then getgenv().UniInfJump:Disconnect() end
    
    for _, draws in pairs(ESPDrawings) do
        if draws.Box then draws.Box:Remove() end
        if draws.Name then draws.Name:Remove() end
    end
    table.clear(ESPDrawings)
    
    local success, core = pcall(function() return game:GetService("CoreGui"):FindFirstChild("BinHubV2") end)
    if success and core then core:Destroy() end
end)


-- ESP LOGIC
local function createESP(player)
    if ESPDrawings[player] then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Settings.ESPColor
    box.Thickness = 1
    box.Filled = false
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Text = player.Name
    name.Size = 16
    name.Center = true
    name.Outline = true
    
    ESPDrawings[player] = { Box = box, Name = name }
end

local function removeESP(player)
    if ESPDrawings[player] then
        ESPDrawings[player].Box:Remove()
        ESPDrawings[player].Name:Remove()
        ESPDrawings[player] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createESP(p) end
end
Players.PlayerAdded:Connect(function(p) createESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)


-- [MAIN LOOPS] --
if getgenv().UniRenderLoop then getgenv().UniRenderLoop:Disconnect() end
getgenv().UniRenderLoop = RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if hum then
        if Settings.WalkSpeedEnabled then hum.WalkSpeed = Settings.WalkSpeed end
        if Settings.JumpPowerEnabled then hum.JumpPower = Settings.JumpPower end
    end
    
    if Settings.Fly and hrp and hum and flyBG and flyBV then
        hum.PlatformStand = true 
        local cf = Camera.CFrame
        local look = cf.LookVector
        local right = cf.RightVector
        local f = (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0) + (UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0)
        local r = (UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0) + (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0)
        
        local moveVec = (look * f) + (right * r)
        flyBV.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * Settings.FlySpeed or Vector3.zero
        flyBG.CFrame = cf
    end
    
    if not Settings.ESP and not Settings.ESPName then
        for _, draws in pairs(ESPDrawings) do
            draws.Box.Visible = false
            draws.Name.Visible = false
        end
        return
    end
    
    local cam = Camera
    local myTeam = LocalPlayer.Team
    for player, draws in pairs(ESPDrawings) do
        local pChar = player.Character
        local pRoot = pChar and pChar:FindFirstChild("HumanoidRootPart")
        local pHum = pChar and pChar:FindFirstChildOfClass("Humanoid")
        
        if pRoot and pHum and pHum.Health > 0 then
            if Settings.ESPTeamCheck and player.Team == myTeam then
                draws.Box.Visible = false
                draws.Name.Visible = false
                continue
            end
            
            local pos, onScreen = cam:WorldToViewportPoint(pRoot.Position)
            
            if onScreen then
                local size = 3000 / pos.Z
                
                if Settings.ESP then
                    draws.Box.Size = Vector2.new(size, size * 1.5)
                    draws.Box.Position = Vector2.new(pos.X - size / 2, pos.Y - (size * 1.5) / 2)
                    draws.Box.Color = typeof(Settings.ESPColor) == "Color3" and Settings.ESPColor or Color3.fromRGB(123, 97, 255)
                    draws.Box.Visible = true
                else
                    draws.Box.Visible = false
                end
                
                if Settings.ESPName then
                    draws.Name.Position = Vector2.new(pos.X, pos.Y - (size * 1.5) / 2 - 20)
                    draws.Name.Color = typeof(Settings.ESPNameColor) == "Color3" and Settings.ESPNameColor or Color3.fromRGB(255, 255, 255)
                    draws.Name.Visible = true
                else
                    draws.Name.Visible = false
                end
            else
                draws.Box.Visible = false
                draws.Name.Visible = false
            end
        else
            draws.Box.Visible = false
            draws.Name.Visible = false
        end
    end
end)

local steppedTick = 0
if getgenv().UniSteppedLoop then getgenv().UniSteppedLoop:Disconnect() end
getgenv().UniSteppedLoop = RunService.Stepped:Connect(function()
    steppedTick = steppedTick + 1
    local char = LocalPlayer.Character
    
    if Settings.Noclip and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    if Settings.AntiFling and steppedTick % 3 == 0 then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, part in pairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end
end)

if getgenv().UniInfJump then getgenv().UniInfJump:Disconnect() end
getgenv().UniInfJump = UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

CheckAutoload()
