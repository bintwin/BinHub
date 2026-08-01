print("BinHUb Loader Started")

-- Map PlaceIds to their respective game script URLs
local SupportedGames = {
    [12345678] = "https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/Games/gamename.luau",
    [2537430692] = "https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/Games/Blocksnprops.luau",
}

local PlaceId = game.PlaceId
local gameScriptUrl = SupportedGames[PlaceId]

-- For testing purposes, if you aren't in a supported game, it defaults to gamename.luau
if not gameScriptUrl then
    warn("BinHUb: Game not explicitly supported! Loading default gamename.luau.")
    gameScriptUrl = "https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/Games/gamename.luau"
end

if gameScriptUrl then
    print("BinHUb: Loading UI Library...")
    local uiLibUrl = "https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/uilib/uilib.luau"
    
    -- Fetch the UI Library globally so game scripts can use it
    local success, uiLib = pcall(function()
        return loadstring(game:HttpGet(uiLibUrl))()
    end)
    
    if success and uiLib then
        getgenv().UILibrary = uiLib
        
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
