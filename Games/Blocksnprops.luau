-- Try to get UILibrary from the loader, or fetch it directly from GitHub
local UILibrary = getgenv().UILibrary or loadstring(game:HttpGet("https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/uilib/uilib.luau"))()

if not UILibrary then
    warn("Failed to load UILibrary")
    return
end

local Window = UILibrary:CreateWindow({
    Name = "BinHUb - Blocks n Props"
})

local PlayerTab = Window:CreateTab("Player")
local VisualsTab = Window:CreateTab("Visuals")
local MiscTab = Window:CreateTab("Misc")
local SettingsTab = Window:CreateTab("Settings")

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

-- Visuals Tab
VisualsTab:CreateTextSection("ESP / Visuals")

VisualsTab:CreateToggle("Player ESP", false, function(state)
    print("Player ESP:", state)
end, "Visuals_PlayerESP")

VisualsTab:CreateToggle("Prop ESP", false, function(state)
    print("Prop ESP:", state)
end, "Visuals_PropESP")

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

SettingsTab:CreateButton("Clear Config", function()
    -- An example button
    print("Clearing Config is not yet implemented")
end)
