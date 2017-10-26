local miniGameName = "theRedeyeOrder";
local miniGamePath = "miniGames/theRedeyeOrder/";
--utils:log(miniGameName, "Loaded");
local miniGameBase = require("miniGames.miniGameBase");
local scene = miniGameBase:newMiniGameScene(miniGameName);

-- Game instructions.
scene.instructions =
  "Even a Jedi would be challenged! Put the tiles in order (the ones with X's are 10 and higher)." ..
  "||Tap a tile next to the blank area to swap them.";


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

  local tileTypes = {
    "tile_01", "tile_02", "tile_03", "tile_04", "tile_05", "tile_06", "tile_07", "tile_08", "tile_09",
    "tile_10", "tile_11", "tile_12", "tile_13", "tile_14", "tile_15", "tile_empty"
  };
  utils:shuffleTable(tileTypes);

  -- Load graphics to create tiles.  Eaxh tile is a sprite and each tile type is a sequence.  So randomizing the tiles
  -- just means switching to a sequence.
  local tileWidth = 250;
  local tileHeight = 400;
  local horizontalSpace = 14;
  local verticalSpace = 14;
  local xOffset = 144;
  local yOffset = 370;
  local i = 1;
  local xLoc = 0;
  local yLoc = yOffset;
  for y = 1, 4, 1 do
    xLoc = xOffset;
    for x = 1, 4, 1 do
      local tile = self.resMan:newSprite("tiles" .. i, self.resMan:getDisplayGroup("gameGroup"), imageSheet, {
        { name = "tile_empty", start = sheetInfo:getFrameIndex("tile_empty"), count = 1, time = 9999 },
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
        { name = "tile_15", start = sheetInfo:getFrameIndex("tile_15"), count = 1, time = 9999 }
      });
      tile.x = xLoc;
      tile.y = yLoc;
      tile.tileType = tileTypes[i];
      tile.tileNumber = i;
      tile:setSequence(tileTypes[i]);
      i = i + 1;
      xLoc = xLoc + tileWidth + horizontalSpace;
    end
    yLoc = yLoc + tileHeight + verticalSpace;
  end

  -- Load sounds.
  self.resMan:loadSound("move", self.sharedResourcePath .. "splat2.wav");
  self.resMan:loadSound("win", self.sharedResourcePath .. "harp.wav");

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

    for i = 1, 16, 1 do
      self.resMan:getSprite("tiles" .. i):addEventListener("touch",
        function(inEvent) self:touchHandler(inEvent); end
      );
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

  -- Give some points for each tile in the correct position so hopefully they never end with no points at all.
  if self.resMan:getSprite("tiles1").tileType == "tile_01" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles2").tileType == "tile_02" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles3").tileType == "tile_03" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles4").tileType == "tile_04" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles5").tileType == "tile_05" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles6").tileType == "tile_06" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles7").tileType == "tile_07" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles8").tileType == "tile_08" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles9").tileType == "tile_09" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles10").tileType == "tile_10" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles11").tileType == "tile_11" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles12").tileType == "tile_12" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles13").tileType == "tile_13" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles14").tileType == "tile_14" then self.updateScore(self, 10); end
  if self.resMan:getSprite("tiles15").tileType == "tile_15" then self.updateScore(self, 10); end

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

  if self.gameState == self.STATE_PLAYING and self.mode == self.MODE_REPEAT then
    if inEvent.phase == "ended" then
      local tile = inEvent.target;
      local tileNumber = tile.tileNumber;
      local toLeft = tileNumber - 1;
      local toRight = tileNumber + 1;
      local toTop = tileNumber - 4;
      local toBottom = tileNumber + 4;
      local tileToLeft = self.resMan:getSprite("tiles" .. toLeft);
      local tileToRight = self.resMan:getSprite("tiles" .. toRight);
      local tileToTop = self.resMan:getSprite("tiles" .. toTop);
      local tileToBottom = self.resMan:getSprite("tiles" .. toBottom);
      if toLeft > 0 and tileToLeft.tileType == "tile_empty" then
        audio.play(self.resMan:getSound("move"));
        tileToLeft.tileType = tile.tileType;
        tileToLeft:setSequence(tile.tileType);
        tile.tileType = "tile_empty";
        tile:setSequence("tile_empty");
        if self:didWin() == true then
          self:resetGame();
        end
      elseif toRight < 17 and tileToRight.tileType == "tile_empty" then
        audio.play(self.resMan:getSound("move"));
        tileToRight.tileType = tile.tileType;
        tileToRight:setSequence(tile.tileType);
        tile.tileType = "tile_empty";
        tile:setSequence("tile_empty");
        if self:didWin() == true then
          self:resetGame();
        end
      elseif toTop > 0 and tileToTop.tileType == "tile_empty" then
        audio.play(self.resMan:getSound("move"));
        tileToTop.tileType = tile.tileType;
        tileToTop:setSequence(tile.tileType);
        tile.tileType = "tile_empty";
        tile:setSequence("tile_empty");
        if self:didWin() == true then
          self:resetGame();
        end
      elseif toBottom < 17 and tileToBottom.tileType == "tile_empty" then
        audio.play(self.resMan:getSound("move"));
        tileToBottom.tileType = tile.tileType;
        tileToBottom:setSequence(tile.tileType);
        tile.tileType = "tile_empty";
        tile:setSequence("tile_empty");
        if self:didWin() == true then
          self:resetGame();
        end
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


---
-- Function that handles touch events on the screen generally.
--
-- @param inEvent The event object.
--
function scene:collision(inEvent)
end -- End collision().


--- ====================================================================================================================
--  ====================================================================================================================
--  Game Utility Functions
--  ====================================================================================================================
--  ====================================================================================================================


---
-- Determines if the player won the game.
--
-- @return True if the player won, false if not.
--
function scene:didWin()

  if
    self.resMan:getSprite("tiles1").tileType == "tile_01" and self.resMan:getSprite("tiles2").tileType == "tile_02" and
    self.resMan:getSprite("tiles3").tileType == "tile_03" and self.resMan:getSprite("tiles4").tileType == "tile_04" and
    self.resMan:getSprite("tiles5").tileType == "tile_05" and self.resMan:getSprite("tiles6").tileType == "tile_06" and
    self.resMan:getSprite("tiles7").tileType == "tile_07" and self.resMan:getSprite("tiles8").tileType == "tile_08" and
    self.resMan:getSprite("tiles9").tileType == "tile_09" and self.resMan:getSprite("tiles10").tileType == "tile_10" and
    self.resMan:getSprite("tiles11").tileType == "tile_11" and self.resMan:getSprite("tiles12").tileType == "tile_12" and
    self.resMan:getSprite("tiles13").tileType == "tile_13" and self.resMan:getSprite("tiles14").tileType == "tile_14" and
    self.resMan:getSprite("tiles15").tileType == "tile_15" then
    audio.play(self.resMan:getSound("win"));
    self.updateScore(self, 250);
     return true;
  else
    return  false;
  end

end -- End didWin().


---
-- Called to reset the game after a win.
--
function scene:resetGame()

  local tileTypes = {
    "tile_01", "tile_02", "tile_03", "tile_04", "tile_05", "tile_06", "tile_07", "tile_08", "tile_09",
    "tile_10", "tile_11", "tile_12", "tile_13", "tile_14", "tile_15", "tile_empty"
  };
  utils:shuffleTable(tileTypes);
  local i = 1;
  for y = 1, 4, 1 do
    for x = 1, 4, 1 do
      local tile = self.resMan:getSprite("tiles" .. i);
      tile.tileType = tileTypes[i];
      tile.tileNumber = i;
      tile:setSequence(tileTypes[i]);
      i = i + 1;
    end
  end

end -- End resetGame().


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
