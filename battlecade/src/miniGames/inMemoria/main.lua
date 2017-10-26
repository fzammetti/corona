local miniGameName = "inMemoria";
local miniGamePath = "miniGames/inMemoria/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Hope your memory is good! Find as many matches as possible before time runs out." ..
  "||Tap a tile to flip it, then another that you think matches.";


-- Store what tile(s) are currently flipped.
scene.currentlyFlipped = { };

-- Time used to unflip tiles.
scene.unflipDelay = nil;


--- ====================================================================================================================
--  ====================================================================================================================
--  Scene lifecycle Event Handlers
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Handler for the create event.
--
-- @param inEvent The event object.
--
function scene:create(inEvent)

  self.parent.create(self, inEvent);
  --utils:log(self.miniGameName, "create()");

  -- Load graphics.

  local imageSheet, sheetInfo = self.resMan:newImageSheet(
    "imageSheet", "miniGames." .. miniGameName .. ".imageSheet", miniGamePath .. "imageSheet.png"
  );

  -- First, create the array where we'll store the tile types that each tile will be.  This will be shuffled and used
  -- to set the animation sequence later.
  local tileTypes = {
    "tile_01", "tile_01", "tile_02", "tile_02", "tile_03", "tile_03", "tile_04", "tile_04", "tile_05", "tile_05",
    "tile_06", "tile_06", "tile_07", "tile_07", "tile_08", "tile_08", "tile_09", "tile_09", "tile_10", "tile_10",
    "tile_11", "tile_11", "tile_12", "tile_12", "tile_13", "tile_13", "tile_14", "tile_14", "tile_15", "tile_15",
    "tile_16", "tile_16", "tile_17", "tile_17", "tile_18", "tile_18", "tile_19", "tile_19", "tile_20", "tile_20",
    "tile_21", "tile_21"
  };
  utils:shuffleTable(tileTypes);

  -- Load graphics to create tiles.  Each tile is a sprite and each tile type is a sequence.  So randomizing the tiles
  -- just means switching to a sequence.
  local tileWidth = 136;
  local tileHeight = 204;
  local horizontalSpace = 32;
  local verticalSpace = 32;
  local xOffset = 114;
  local yOffset = 300;
  local i = 1;
  local xLoc = 0;
  local yLoc = yOffset;
  for y = 1, 7, 1 do
    xLoc = xOffset;
    for x = 1, 6, 1 do
      local t = self.resMan:newSprite("tiles" .. i, self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
        { name = "tile_unflipped", start = sheetInfo:getFrameIndex("tile_unflipped"), count = 1, time = 9999 },
        { name = "tile_01", start = sheetInfo:getFrameIndex("tile_01"), count = 1, time = 9999 },
        { name = "tile_02", start = sheetInfo:getFrameIndex("tile_02"), count = 1, time = 9999 },
        { name = "tile_03", start = sheetInfo:getFrameIndex("tile_03"), count = 1, time = 9999 },
        { name = "tile_04", start = sheetInfo:getFrameIndex("tile_04"), count = 1, time = 9999 },
        { name = "tile_05", start = sheetInfo:getFrameIndex("tile_05"), count = 1, time = 9999 },
        { name = "tile_06", start = sheetInfo:getFrameIndex("tile_06"), count = 1, time = 9999 },
        { name = "tile_07", start = sheetInfo:getFrameIndex("tile_07"), count = 1, time = 9999 },
        { name = "tile_08", start = sheetInfo:getFrameIndex("tile_08"), count = 1, time = 9999 },
        { name = "tile_09", start = sheetInfo:getFrameIndex("tile_09"), count = 1, time = 9999 },
        { name = "tile_10", start = sheetInfo:getFrameIndex("tile_10"), count = 1, time = 9999 },
        { name = "tile_11", start = sheetInfo:getFrameIndex("tile_11"), count = 1, time = 9999 },
        { name = "tile_12", start = sheetInfo:getFrameIndex("tile_12"), count = 1, time = 9999 },
        { name = "tile_13", start = sheetInfo:getFrameIndex("tile_13"), count = 1, time = 9999 },
        { name = "tile_14", start = sheetInfo:getFrameIndex("tile_14"), count = 1, time = 9999 },
        { name = "tile_15", start = sheetInfo:getFrameIndex("tile_15"), count = 1, time = 9999 },
        { name = "tile_16", start = sheetInfo:getFrameIndex("tile_16"), count = 1, time = 9999 },
        { name = "tile_17", start = sheetInfo:getFrameIndex("tile_17"), count = 1, time = 9999 },
        { name = "tile_18", start = sheetInfo:getFrameIndex("tile_18"), count = 1, time = 9999 },
        { name = "tile_19", start = sheetInfo:getFrameIndex("tile_19"), count = 1, time = 9999 },
        { name = "tile_20", start = sheetInfo:getFrameIndex("tile_20"), count = 1, time = 9999 },
        { name = "tile_21", start = sheetInfo:getFrameIndex("tile_21"), count = 1, time = 9999 },
      });
      t.x = xLoc;
      t.y = yLoc;
      t.tileType = tileTypes[i];
      t.tileNumber = i;
      t:setSequence("tile_unflipped");
      i = i + 1;
      xLoc = xLoc + tileWidth + horizontalSpace;
    end
    yLoc = yLoc + tileHeight + verticalSpace;
  end

  -- Load sounds.
  self.resMan:loadSound("flip", self.sharedResourcePath .. "scratch.wav");
  self.resMan:loadSound("unFlip", self.sharedResourcePath .. "scratch.wav");
  self.resMan:loadSound("match", self.sharedResourcePath .. "explosion.wav");
  self.resMan:loadSound("noMatch", self.sharedResourcePath .. "buzzer.wav");
  self.resMan:loadSound("fanfare", self.sharedResourcePath .. "fanfare.wav");

end -- End create().


---
-- Handler for the show event.
--
-- @param inEvent The event object.
--
function scene:show(inEvent)

  self.parent.show(self, inEvent);

  if inEvent.phase == "did" then

    --utils:log(self.miniGameName, "show(): did");

    -- Attach touch handlers to tiles.
    for i = 1, 42, 1 do
      self.resMan:getSprite("tiles" .. i):addEventListener("touch", function(inEvent) self:touchHandler(inEvent); end );
    end

  end

end -- End show().


---
-- Handler for the hide event.
--
-- @param inEvent The event object.
--
function scene:hide(inEvent)

  self.parent.hide(self, inEvent);

  if inEvent.phase == "did" then

    --utils:log(self.miniGameName, "hide(): did");

  end

end -- End hide().


---
-- Handler for the destroy event.
--
-- @param inEvent The event object.
--
function scene:destroy(inEvent)

  self.parent.destroy(self, inEvent);

  --utils:log(self.miniGameName, "destroy()");

  if self.unflipDelay ~= nil then
    timer.cancel(self.unflipDelay);
  end

end -- End destroy().


---
-- Called when the menu is triggered (either from it being shown or hidden).
--
function scene:menuTriggered()
end -- End menuTriggered().


---
-- Called when the starting countdown begins.
--
function scene:countdownStartEvent()
end -- End countdownStartEvent().


---
-- Called right after "GO!" is displayed to start a game.
--
function scene:startEvent()
end -- End startEvent().


---
-- Called right before "GAME OVER" is shown to end a game.
--
function scene:endEvent()
end -- End endEvent().


--- ====================================================================================================================
--  ====================================================================================================================
--  EnterFrame
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Handler for the enterFrame event.
--
-- @param inEvent The event object.
--
function scene:enterFrame(inEvent)

  self.parent.enterFrame(self, inEvent);

end -- End enterFrame().


--- ====================================================================================================================
--  ====================================================================================================================
--  Touch Handler(s)
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Function that handles touch events on the screen generally.
--
-- @param inEvent The event object.
--
function scene:touch(inEvent)
end -- End touch().


---
-- Function that handles touch events.  Note that this game only cares about touch events on specific objects,
-- which have event listeners hooked up to this function.  The global touch() handler is just empty here.
--
-- @param inEvent The event object.
--
function scene:touchHandler(inEvent)

  if self.gameState == self.STATE_PLAYING and self.unflipDelay == nil then
    if inEvent.phase == "ended" then

      if inEvent.target.sequence == "tile_unflipped" then

        -- Flip the tile to show it.
        inEvent.target:setSequence(inEvent.target.tileType);
        audio.play(self.resMan:getSound("flip"));

        -- Record that it's flipped.
        table.insert(self.currentlyFlipped, inEvent.target.tileNumber);

        -- Now, if we've got two flipped tiles, see if they match.
        if #self.currentlyFlipped == 2 then

          local tile1 = self.resMan:getSprite("tiles" .. self.currentlyFlipped[1]);
          local tile2 = self.resMan:getSprite("tiles" .. self.currentlyFlipped[2])

          if tile1.tileType == tile2.tileType then

            -- Match, hide them.
            local explosionParticleEmitter1 = display.newEmitter(self.explosionEmitterParams);
            local explosionParticleEmitter2 = display.newEmitter(self.explosionEmitterParams);
            explosionParticleEmitter1.x = tile1.x;
            explosionParticleEmitter1.y = tile1.y;
            explosionParticleEmitter2.x = tile2.x;
            explosionParticleEmitter2.y = tile2.y;
            audio.play(self.resMan:getSound("match"));
            tile1.isVisible = false;
            tile2.isVisible = false;
            -- Clear out currentlyFlipped array.
            self.currentlyFlipped = { };
            -- Add to score.
            self.updateScore(self, 5);
            -- See if it's time to reset the game (when all matches have been found).
            local anyShowing = false;
            for i = 1, 42, 1 do
              if self.resMan:getSprite("tiles" .. i).isVisible == true then
                anyShowing = true;
                break;
              end
            end
            if anyShowing == false then
              audio.play(self.resMan:getSound("fanfare"));
              self.updateScore(self, 50);
              self:resetBoard();
            end

          else

            -- No match, unflip them, after a delay.
            audio.play(self.resMan:getSound("noMatch"));
            self.unflipDelay = timer.performWithDelay(500,
              function()
                tile1:setSequence("tile_unflipped");
                tile2:setSequence("tile_unflipped");
                -- Clear out currentlyFlipped array.
                self.currentlyFlipped = { };
                self.unflipDelay = nil;
              end
            );

          end
        end

      else

        -- Unflip this tile.
        inEvent.target:setSequence("tile_unflipped");
        -- Clear out currentlyFlipped array.
        self.currentlyFlipped = { };
        audio.play(self.resMan:getSound("unFlip"));

      end
    end
  end

  return true;

end -- End touchHandler().


--- ====================================================================================================================
--  ====================================================================================================================
--  Collision Handler
--  ====================================================================================================================
--  ====================================================================================================================


--- ====================================================================================================================
--  ====================================================================================================================
--  Game Utility Functions
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Reset the board when it's been cleared.
--
function scene:resetBoard()

  --utils:log(self.miniGameName, "resetBoard()");

  local tileTypes = {
    "tile_01", "tile_01", "tile_02", "tile_02", "tile_03", "tile_03", "tile_04", "tile_04", "tile_05", "tile_05",
    "tile_06", "tile_06", "tile_07", "tile_07", "tile_08", "tile_08", "tile_09", "tile_09", "tile_10", "tile_10",
    "tile_11", "tile_11", "tile_12", "tile_12", "tile_13", "tile_13", "tile_14", "tile_14", "tile_15", "tile_15",
    "tile_16", "tile_16", "tile_17", "tile_17", "tile_18", "tile_18", "tile_19", "tile_19", "tile_20", "tile_20",
    "tile_21", "tile_21"
  };

  utils:shuffleTable(tileTypes);

  local i = 1;
  for y = 1, 7, 1 do
    for x = 1, 6, 1 do
      local tile = self.resMan:getSprite("tiles" .. i);
      tile.tileType = tileTypes[i];
      tile:setSequence("tile_unflipped");
      tile.isVisible = true;
      i = i + 1;
    end
  end

end -- End resetBoard().


--- ====================================================================================================================
--  ====================================================================================================================
--  ====================================================================================================================
--  ====================================================================================================================


--utils:log(miniGameName, "Attaching lifecycle handlers");

scene:addEventListener("create", scene);
scene:addEventListener("show", scene);
scene:addEventListener("hide", scene);
scene:addEventListener("destroy", scene);

return scene;
