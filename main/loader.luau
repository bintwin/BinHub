print("BinHUb Loader Started")

-- Map Game/Place configs to their respective game script URLs
local SupportedGames = {
    {
        Name = "Blocksnprops",
        Places = {2537430692},
        GameId = 905198065,
        Script = "https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/Games/Blocksnprops.luau"
    },
    {
        Name = "mm2kids",
        Places = {70670854739587, 142823291},
        GameId = 70670854739587,
        Script = "https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/Games/mm2kids.luau"
    }
}

local PlaceId = game.PlaceId
local GameId = game.GameId
local gameScriptUrl = nil
local TargetGame = getgenv().TargetGame

if TargetGame then
    local matchedGameInfo = nil
    for _, info in ipairs(SupportedGames) do
        if info.Name:lower() == TargetGame:lower() then
            matchedGameInfo = info
            break
        end
    end
    
    if matchedGameInfo then
        -- Verify they are actually in the targeted game
        if matchedGameInfo.GameId ~= GameId and not table.find(matchedGameInfo.Places, PlaceId) then
            warn("[BinHub] Wrong game detected! Firing notification...")
            local bindable = Instance.new("BindableFunction")
            bindable.OnInvoke = function(button)
                if button == "Yes" then
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/Games/gamename.luau"))()
                end
            end
            task.spawn(function()
                local success = false
                local retries = 0
                while not success and retries < 10 do
                    success, _ = pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "BinHub",
                            Text = "Wrong game! want to load our universal script?",
                            Duration = 10,
                            Button1 = "Yes",
                            Button2 = "No",
                            Callback = bindable
                        })
                    end)
                    if not success then
                        task.wait(1)
                        retries = retries + 1
                    end
                end
            end)
            return -- Halt loading
        end
        gameScriptUrl = matchedGameInfo.Script
    else
        warn("BinHub: Invalid TargetGame specified.")
    end
else
    -- Universal Routing: automatically find the script for the current game
    for _, gameInfo in ipairs(SupportedGames) do
        if gameInfo.GameId == GameId or table.find(gameInfo.Places, PlaceId) then
            gameScriptUrl = gameInfo.Script
            break
        end
    end
end

-- For testing purposes, if you aren't in a supported game, it defaults to gamename.luau
if not gameScriptUrl then
    warn("BinHUb: Game not explicitly supported! Loading default gamename.luau.")
    gameScriptUrl = "https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/Games/gamename.luau"
end

if gameScriptUrl then
    print("BinHUb: Loading UI Library...")
    local uiLibUrl = "https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/uilib/uilib_v2.luau?t=" .. tostring(tick())
    
    -- Fetch the UI Library globally so game scripts can use it
    local success, uiLib = pcall(function()
        return loadstring(game:HttpGet(uiLibUrl))()
    end)
    
    if success and uiLib then
        getgenv().UILibraryV2 = uiLib
        
        print("BinHUb: Loading Game Script for PlaceId " .. tostring(PlaceId) .. "...")
        local scriptSuccess, err = pcall(function()
            loadstring(game:HttpGet(gameScriptUrl))()
        end)
        
        if not scriptSuccess then
            warn("BinHUb Error loading game script: " .. tostring(err))
        end
    else
        warn("BinHUb Error: Failed to load UI Library.")
    end
end
