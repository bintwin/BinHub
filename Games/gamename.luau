-- Default Universal Hub Script for unsupported games (V2 Nebula Theme)
local UILibrary = getgenv().UILibraryV2 or loadstring(game:HttpGet("https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/uilib/uilib_v2.luau?t=" .. tostring(tick())))()

if not UILibrary then
    warn("Failed to load UILibraryV2. Ensure it is pushed to github!")
    return
end

local Window = UILibrary:CreateWindow({
    Name = "binhub"
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
    ESPTeamCheck = false
}

-- [CATEGORIES & TABS]
local PlayersCat = Window:CreateCategory({Name = "Players", Icon = "rbxassetid://6034287525"})
local VisualsCat = Window:CreateCategory({Name = "Visuals", Icon = "rbxassetid://6031265978"})

local LocalTab = PlayersCat:CreateTab("Self")
local CombatTab = PlayersCat:CreateTab("Protection")

local EspTab = VisualsCat:CreateTab("Enemies")

-- [LOCAL TAB - CARDS]
local MovementCard = LocalTab:CreateSection("Movement", "rbxassetid://6031265978")
MovementCard:CreateCheckbox("Enable WalkSpeed", false, function(v) Settings.WalkSpeedEnabled = v end)
MovementCard:CreateSlider("WalkSpeed", 16, 200, 16, function(v) Settings.WalkSpeed = v end)

local JumpCard = LocalTab:CreateSection("Jumping", "rbxassetid://6031265978")
JumpCard:CreateCheckbox("Enable JumpPower", false, function(v) Settings.JumpPowerEnabled = v end)
JumpCard:CreateSlider("JumpPower", 50, 200, 50, function(v) Settings.JumpPower = v end)
JumpCard:CreateCheckbox("Infinite Jump", false, function(v) Settings.InfJump = v end)

local AdvancedCard = LocalTab:CreateSection("Advanced", "rbxassetid://6031265978")
AdvancedCard:CreateCheckbox("Noclip", false, function(v) Settings.Noclip = v end)

local flyBV, flyBG
local FlyCard = LocalTab:CreateSection("Flight", "rbxassetid://6031265978")
FlyCard:CreateCheckbox("Enable Fly", false, function(state)
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
FlyCard:CreateSlider("Fly Speed", 10, 300, 50, function(v) Settings.FlySpeed = v end)

-- [COMBAT TAB - CARDS]
local ProtectionCard = CombatTab:CreateSection("Anti-Abuse", "rbxassetid://6031265978")
ProtectionCard:CreateCheckbox("Anti-Fling", false, function(v) Settings.AntiFling = v end)

-- [VISUALS TAB - CARDS]
local EspCard = EspTab:CreateSection("General", "rbxassetid://6031265978")
EspCard:CreateCheckbox("Enable ESP", false, function(v) Settings.ESP = v end)
EspCard:CreateCheckbox("Team Check", false, function(v) Settings.ESPTeamCheck = v end)


-- ESP LOGIC
local ESPDrawings = {}
local function createESP(player)
    if ESPDrawings[player] then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(123, 97, 255)
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
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum then
        if Settings.WalkSpeedEnabled then hum.WalkSpeed = Settings.WalkSpeed end
        if Settings.JumpPowerEnabled then hum.JumpPower = Settings.JumpPower end
    end
    
    if Settings.Fly and hrp and hum and flyBG and flyBV then
        hum.PlatformStand = true 
        local ctrl = {f = 0, b = 0, l = 0, r = 0}
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then ctrl.f = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then ctrl.b = -1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then ctrl.l = -1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then ctrl.r = 1 end
        
        local look = Camera.CFrame.LookVector
        local right = Camera.CFrame.RightVector
        
        local moveVec = ((look * (ctrl.f + ctrl.b)) + (right * (ctrl.l + ctrl.r)))
        if moveVec.Magnitude > 0 then
            flyBV.Velocity = moveVec.Unit * Settings.FlySpeed
        else
            flyBV.Velocity = Vector3.new(0, 0, 0)
        end
        flyBG.CFrame = Camera.CFrame
    end
    
    for player, draws in pairs(ESPDrawings) do
        if Settings.ESP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Settings.ESPTeamCheck and player.Team == LocalPlayer.Team then
                draws.Box.Visible = false
                draws.Name.Visible = false
                continue
            end
            
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local size = 3000 / pos.Z
                draws.Box.Size = Vector2.new(size, size * 1.5)
                draws.Box.Position = Vector2.new(pos.X - draws.Box.Size.X / 2, pos.Y - draws.Box.Size.Y / 2)
                draws.Box.Visible = true
                
                draws.Name.Position = Vector2.new(pos.X, pos.Y - draws.Box.Size.Y / 2 - 20)
                draws.Name.Visible = true
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

if getgenv().UniSteppedLoop then getgenv().UniSteppedLoop:Disconnect() end
getgenv().UniSteppedLoop = RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    
    if Settings.Noclip and char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    if Settings.AntiFling then
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
