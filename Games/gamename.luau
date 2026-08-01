-- Default game script for unsupported games
local UILibrary = getgenv().UILibrary or loadstring(game:HttpGet("https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/uilib/uilib.luau?t=" .. tostring(tick())))()

if not UILibrary then
    warn("Failed to load UILibrary")
    return
end

local Window = UILibrary:CreateWindow({
    Name = "BinHUb - Default Game"
})

local PlayerTab = Window:CreateTab("Player", "user")
local MiscTab = Window:CreateTab("Misc", "box")

-- Player Tab
PlayerTab:CreateTextSection("Local Player")

PlayerTab:CreateSlider("WalkSpeed", 16, 100, 16, function(value)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = value
    end
end, "Default_WalkSpeed")

-- Misc Tab
MiscTab:CreateTextSection("Miscellaneous")
MiscTab:CreateButton("Print Hello", function()
    print("Hello from BinHUb Default Script!")
end)
