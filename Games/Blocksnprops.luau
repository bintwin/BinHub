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

-- Visuals Tab
VisualsTab:CreateTextSection("ESP / Visuals")

VisualsTab:CreateToggle("Player ESP", false, function(state)
    print("Player ESP:", state)
end, "Visuals_PlayerESP")

VisualsTab:CreateToggle("Prop ESP", false, function(state)
    getgenv().PropESP = state
    
    local function updatePropESP()
        for _, prop in ipairs(workspace.Projectiles:GetChildren()) do
            if getgenv().PropESP then
                if not prop:FindFirstChild("PropHighlight") then
                    local h = Instance.new("Highlight")
                    h.Name = "PropHighlight"
                    h.FillColor = Color3.fromRGB(255, 100, 100)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.FillTransparency = 0.5
                    h.Parent = prop
                end
            else
                if prop:FindFirstChild("PropHighlight") then
                    prop.PropHighlight:Destroy()
                end
            end
        end
    end
    
    if getgenv().PropESPConn then
        getgenv().PropESPConn:Disconnect()
        getgenv().PropESPConn = nil
    end
    
    if state then
        getgenv().PropESPConn = workspace.Projectiles.ChildAdded:Connect(function(prop)
            task.wait(0.1) -- Wait for model to load
            if getgenv().PropESP then
                if not prop:FindFirstChild("PropHighlight") then
                    local h = Instance.new("Highlight")
                    h.Name = "PropHighlight"
                    h.FillColor = Color3.fromRGB(255, 100, 100)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.FillTransparency = 0.5
                    h.Parent = prop
                end
            end
        end)
    end
    
    updatePropESP()
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
