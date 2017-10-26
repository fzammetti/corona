-- The globalFunctions object.
local globalFunctions = { };


---
-- Loads the gameState object.
--
function globalFunctions:loadGameState()

  --utils:log("globalFunctions", "loadGameState()");

  local path = system.pathForFile("gameState.json", system.DocumentsDirectory);
  if path ~= nil then
    local fh = io.open(path, "r");
    if fh ~= nil then
      gameState = json.decode(fh:read("*a"));
      io.close(fh);
    end
  end

  --utils:log("globalFunctions", "loadGameState(): ", gameState);

end -- End loadState().


---
-- Saves the gameState object.
--
function globalFunctions:saveGameState()

  --utils:log("globalFunctions", "saveGameState(): ", gameState);

  local path = system.pathForFile("gameState.json", system.DocumentsDirectory);
  if path ~= nil then
    local fh = io.open(path, "w+");
    fh:write(json.encode(gameState));
    io.close(fh);
  end

end -- End saveGameState().


---
-- Finds the index in the gameList for a game based on its match ID.
--
-- @param inMatchID The match ID of the game to find.
--
function globalFunctions:findGameIndexByID(inMatchID)

  --utils:log("globalFunctions", "findGameIndexByID(): ", gameState);
  --utils:log("globalFunctions", "findGameIndexByID() inMatchID: ", inMatchID);

  for i = 1, #gameList, 1 do
    if gameList[i].matchID == inMatchID then
      return i;
    end
  end

end -- End findGameIndexByID().


-- *********************************************************************************************************************
-- *********************************************************************************************************************


return globalFunctions;
