local function fetchFile(path)
    if isfile and readfile and isfile(path) then
        return readfile(path)
    end
    return nil
end

local function executeFile(path)
    local content = fetchFile(path)
    if content then
        local success, err = pcall(function()
            loadstring(content)()
        end)
        if not success then
            warn("Error executing " .. path .. ":\n" .. tostring(err))
        end
    else
        warn("Could not find file: " .. path)
    end
end

print("BinHUb Loader Started")
print("Loading UI Library...")
-- Note: gamename.luau loads the uilib internally, but we could also load it here and pass it.
-- For this setup, we just execute the game script which handles its own UI initialization.

-- Example logic for detecting game:
local PlaceId = game.PlaceId
local gameScriptPath = "BinHUb/Games/gamename.luau"

-- If we wanted to load specific scripts for specific games:
-- if PlaceId == 12345678 then
--     gameScriptPath = "BinHUb/Games/someothergame.luau"
-- end

print("Loading Game Script...")
executeFile(gameScriptPath)

print("BinHUb Successfully Loaded!")
