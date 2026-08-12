print("BinHUb Loader Started")

-- Map Game/Place configs to their respective game script URLs
local SupportedGames = {
    {
        Places = {2537430692},
        GameId = 905198065,
        Script = "https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/Games/Blocksnprops.luau"
    },
    {
        Places = {142823291},
        GameId = 112420803,
        Script = "https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/Games/mm2kids.luau"
    }
}

local PlaceId = game.PlaceId
local GameId = game.GameId
local gameScriptUrl = nil

for _, gameInfo in ipairs(SupportedGames) do
    if gameInfo.GameId == GameId or table.find(gameInfo.Places, PlaceId) then
        gameScriptUrl = gameInfo.Script
        break
    end
end

-- For testing purposes, if you aren't in a supported game, it defaults to gamename.luau
if not gameScriptUrl then
    warn("BinHUb: Game not explicitly supported! Loading default gamename.luau.")
    gameScriptUrl = "https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/Games/gamename.luau"
end

if gameScriptUrl then
    print("BinHUb: Loading UI Library...")
    local uiLibUrl = "https://raw.githubusercontent.com/bintwin/BinHub/refs/heads/main/uilib/uilib.luau?t=" .. tostring(tick())
    
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
