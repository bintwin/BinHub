-- Try to get UILibrary from the loader, or fetch it directly from GitHub
local UILibrary = getgenv().UILibrary or loadstring(game:HttpGet("https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/uilib/uilib.luau"))()

if not UILibrary then
    warn("Failed to load UILibrary")
    return
end

local Window = UILibrary:CreateWindow({
    Name = "BinHUb"
})

local PlayerTab = Window:CreateTab("Player")
local VisualsTab = Window:CreateTab("Visuals")
local MovementTab = Window:CreateTab("Movement")
local MiscTab = Window:CreateTab("Misc")
local EmotesTab = Window:CreateTab("Emotes")
local SettingsTab = Window:CreateTab("Settings")

-- Setup Misc Tab based on reference image
MiscTab:CreateTextSection("Spray Paint")

MiscTab:CreateButton("Start", function()
    print("Start clicked")
end)

MiscTab:CreateButton("Stop", function()
    print("Stop clicked")
end)

MiscTab:CreateButton("Save", function()
    print("Save clicked")
end)

MiscTab:CreateTextSection("Recordings")

MiscTab:CreateDropdown("Recording", {"Recording 1", "Recording 2", "Recording 3", "Recording 4"}, "Recording 4", function(selected)
    print("Selected:", selected)
end)

MiscTab:CreateButton("Load", function()
    print("Load clicked")
end)

MiscTab:CreateButton("Delete", function()
    print("Delete clicked")
end)

-- Some examples in other tabs to show off features
PlayerTab:CreateToggle("God Mode", false, function(state)
    print("God Mode:", state)
end)

PlayerTab:CreateSlider("WalkSpeed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

PlayerTab:CreateKeybind("Fly Toggle", Enum.KeyCode.F, function()
    print("Fly Keybind Pressed")
end)
